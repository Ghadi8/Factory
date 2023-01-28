// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Minimal proxy library
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./IFactory.sol";

/// @dev an interface to interact with the base contracts
interface IContracts {
    function initialize(bytes memory data, address owner_) external;
}

contract Factory is IFactory, Ownable, ReentrancyGuard {
    /// @notice cheaply clone contract functionality in an immutable way
    using Clones for address;

    /// @notice using a counter to increment next contract type number
    using Counters for Counters.Counter;

    /// @notice id of contract to be implemented next
    Counters.Counter private contractTypeTracker_;

    /// @notice structure of base contracts
    struct ContractBase {
        address impAddress;
        string name;
    }

    /// @notice Base Contracts implementations
    mapping(uint256 => ContractBase) private ContractsBase_;

    /// @notice contracts mapped by owner address
    mapping(address => mapping(uint256 => address[])) private clonedContracts;

    receive() external payable {
        revert("CloneFactory: Please call createClone");
    }

    fallback() external payable {
        revert("CloneFactory: Please call createClone");
    }

    /**
     * @notice initializing the cloned contract
     * @param _data encoded data as param for initializing the proxy
     * @param _baseId id of the desired implementation to clone
     **/
    function createClone(uint256 _baseId, bytes memory _data)
        external
        virtual
        override
        nonReentrant
    {
        address identicalChild = ContractsBase_[_baseId].impAddress.clone();

        clonedContracts[msg.sender][_baseId].push(identicalChild);

        IContracts(identicalChild).initialize(_data, msg.sender);

        emit NewContractClone(identicalChild, msg.sender, _baseId);
    }

    /**
     * @notice function returns cloned contracts by owner address
     * @param _owner owner address
     * @param _baseId id of an implementation
     **/
    function getClonedContracts(address _owner, uint256 _baseId)
        external
        view
        virtual
        override
        returns (address[] memory)
    {
        return clonedContracts[_owner][_baseId];
    }

    /**
     * @notice Add Base Contracts as new implementations to be cloned
     * @param _implAddr address of Base contract
     * @param _name name of Base contract
     */
    function addBaseContract(address _implAddr, string memory _name)
        external
        virtual
        override
        onlyOwner
    {
        require(
            _exists(_implAddr),
            "CloneFactory: New implementation must be a contract"
        );
        ContractsBase_[contractTypeTracker_.current()].impAddress = _implAddr;
        ContractsBase_[contractTypeTracker_.current()].name = _name;
        contractTypeTracker_.increment();

        emit NewImplementation(_implAddr, _name);
    }

    /**
     * @notice Return Base Contract
     * @param _baseId Id of base contract to be returned
     */
    function getBaseContract(uint256 _baseId)
        public
        view
        virtual
        override
        returns (address, string memory)
    {
        return (
            ContractsBase_[_baseId].impAddress,
            ContractsBase_[_baseId].name
        );
    }

    /// @notice returns true for existing address
    /// @param _what the address to be tested for existance
    function _exists(address _what) internal view returns (bool) {
        uint256 size;
        assembly {
            /* solium-disable-line */
            size := extcodesize(_what)
        }
        return size > 0;
    }
}
