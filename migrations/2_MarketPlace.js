const MarketPlace = artifacts.require("contracts/MarketPlace");

module.exports = function (deployer) {
  deployer.deploy(MarketPlace);
};
