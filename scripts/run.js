const main = async () => {
  // Constants
  const weth = 1000000000000000000;

  // Init contract
  const [client, addr1, addr2] = await hre.ethers.getSigners();
  const JobFactory = await hre.ethers.getContractFactory('Job');
  let jobContract = await JobFactory.deploy();
  await jobContract.deployed();
  console.log('Contract deployed to:', jobContract.address);
  console.log();


  // Deposit ETH to the contract
  await jobContract.deposit({value: ethers.utils.parseEther('1.3')});
  const payout = await jobContract.getPayout();
  console.log('Payout (ETH): ', payout / weth);
  console.log();

  // Accept job
  jobContract = jobContract.connect(addr1);
  await jobContract.acceptJob([addr1.address, addr2.address], [75, 25]);
  const state = await jobContract.getJobState();
  console.log('Current Job State: ', state);
  console.log();

  // Complete job, check address balances
  jobContract = jobContract.connect(client);
  let preBal = await addr1.getBalance();
  console.log('Pre-Job Value: ', preBal / weth);
  await jobContract.complete();
  let postBal = await addr1.getBalance();
  console.log('Post-Job Value: ', postBal / weth);
  console.log('Value Difference: ', (postBal - preBal) / weth);
}

const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
};
    
runMain();