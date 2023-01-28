const factoryCont = artifacts.require("Factory");

const { setEnvValue } = require("../utils/env-man");

const conf = require("../migration-parameters");

const setFactory = (n, v) => {
  setEnvValue("../", `Factory_ADDRESS${n.toUpperCase()}`, v);
};

module.exports = async (deployer, network, accounts) => {
  switch (network) {
    case "rinkeby":
      c = { ...conf.goerli };
      break;
    case "mainnet":
      c = { ...conf.mainnet };
      break;
    case "development":
    default:
      c = { ...conf.devnet };
  }

  // deploy Factory
  await deployer.deploy(factoryCont);

  const factory = await factoryCont.deployed();

  if (factory) {
    console.log(
      `Deployed: Factory
       network: ${network}
       address: ${factory.address}
       creator: ${accounts[0]}
    `
    );
    setFactory(network, factory.address);
  } else {
    console.log("Factory Deployment UNSUCCESSFUL");
  }
};
