var Planet = artifacts.require('./Planet.sol');
var Star = artifacts.require('./Star.sol');
var PlanetFight = artifacts.require('./PlanetFight.sol');
module.exports = function(deployer) {
  deployer.deploy(Planet);
  deployer.deploy(Star);
  deployer.deploy(PlanetFight);
};
