/*
const hre = require("hardhat");

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;

  const lockedAmount = hre.ethers.utils.parseEther("0.001");

  const Lock = await hre.ethers.getContractFactory("Lock");
  const lock = await Lock.deploy(unlockTime, { value: lockedAmount });

  await lock.deployed();

  console.log(
    `Lock with ${ethers.utils.formatEther(
      lockedAmount
    )}ETH and unlock timestamp ${unlockTime} deployed to ${lock.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
*/

const hre = require("hardhat");
async function main(){
  const [deployer] = await hre.ethers.getSigners();
  console.log(`deploying contract with this address: ${deployer.address}`);

  const balance = await deployer.getBalance();
  console.log(`the balance of this address is: ${balance.toString()}`);

  const registerContract = await hre.ethers.getContractFactory("Register");
  const deployRegisterContract = await registerContract.deploy();
  console.log(`deployed to ${deployRegisterContract.address}`);
}

try {
  main();
} catch (e) {
  console.log(e);
}