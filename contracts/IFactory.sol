// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFactory {
    /// @notice Emitted when a contract gets cloned
    event NewContractClone(
        address indexed _newClone,
        address indexed _owner,
        uint256 indexed _contractNumber
    );

    /// @notice Emitted when a new implementation is added
    event NewImplementation(
        address indexed baseImplemenation,
        string indexed _name
    );

    /**
     * @notice initializing the cloned contract
     * @param _data encoded data as param for initializing the proxy
     * @param _baseId id of the desired implementation to clone
     **/
    function createClone(uint256 _baseId, bytes memory _data) external;

    /**
     * @notice function returns cloned contracts by owner address
     * @param _owner owner address
     * @param _baseId id of an implementation
     **/
    function getClonedContracts(address _owner, uint256 _baseId)
        external
        view
        returns (address[] memory);

    /**
     * @notice Add Base Contracts as new implementations to be cloned
     * @param _implAddr address of Base contract
     * @param _name name of Base contract
     */
    function addBaseContract(address _implAddr, string memory _name) external;

    function getBaseContract(uint256 _baseId)
        external
        view
        returns (address, string memory);
}
