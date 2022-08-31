var whitelistAddresses = require('../assets/whitelistAddresses.js');

const { ethers } = require("hardhat");
const Web3 = require('web3');
const { MerkleTree } = require('merkletreejs');
const keccak256 = require("keccak256");
const { soliditySha256, soliditySha3, soliditySha3Raw } = require("web3-utils");
const fs = require('fs');

const infuraAPI = {
    projectId: "4b0d4c346f254a1c9c8f8e8a8b707fce",
    projectSecret: "51f2955c887b4d1cb40a0756ad36fac5" 
}

const provider = new ethers.providers.InfuraProvider("rinkeby", infuraAPI);
const web3 = new Web3;

const buildWhitelist = async () => {
  whitelistAddresses = whitelistAddresses.whitelistAddresses;
  // console.log(whitelistAddresses);
  var whitelistAddressesParsed = whitelistAddresses.split('\n');
  var whitelistAddressesLowercase = whitelistAddressesParsed.map(address => address.toLowerCase());

  const leafNodes = whitelistAddressesLowercase.map(addr => soliditySha3(addr));
  const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
  console.log("ROOT");
  console.log(merkleTree.getRoot().toString("hex"))
  console.log('Whitelist Merkle Tree\n', merkleTree.toString());

  return merkleTree;
}

const testMerkletree = async (merkleTree) => {

  const [owner] = await hre.ethers.getSigners();
  const myAddress = owner.address;
  console.log("my address is: ", myAddress);

  console.log("TESTING MERKLE TREE");

  var leaf = soliditySha3(myAddress);
  var proof = merkleTree.getHexProof(leaf);
  var root = merkleTree.getRoot();

  console.log("SHOULD BE TRUE");
  console.log(root);
  console.log(proof);
  console.log(merkleTree.verify(proof, leaf, root));

  leaf = soliditySha3("0x248Ae960dC1a80e237147c94D95C5f6c19A62891");
  proof = merkleTree.getHexProof(leaf);
  root = merkleTree.getRoot().toString('hex');
  
  console.log("SHOULD BE FALSE");
  console.log(root);
  console.log(proof);
  console.log(merkleTree.verify(proof, leaf, root));
}

const testDeploy = async (merkleTree) => {
    const nftContractFactory = await hre.ethers.getContractFactory('DADs');
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log("contract deployed to: ", nftContract.address);
    return nftContract.address

    // const nftContract = await nftContractFactory.attach(
    //   "0x183d04e51C6d048C9fb0B3CCf117DEE7727e9197"
    // );
}

const testMint = async (merkleTree) => {

    const [owner] = await hre.ethers.getSigners();
    const myAddress = owner.address.toLowerCase();
    console.log("my address is: ", myAddress);

    const nftContractFactory = await hre.ethers.getContractFactory('DADs');
    const nftContract = await nftContractFactory.attach(
      "0x183d04e51C6d048C9fb0B3CCf117DEE7727e9197"
    );

    // IS OWNER?
    console.log("owner?");
    console.log(await nftContract.owner());

    // SET MERKLE ROOT
    // txn = await nftContract.setMerkleRoot(merkleTree.getRoot());
    // await txn.wait();
    // console.log("set merkle root");

    // TRY TO MINT PRESALE OFF
    try {
        var options = {value: hre.ethers.utils.parseEther("0.02")}
        const leaf = soliditySha3(myAddress);
        const proof = merkleTree.getHexProof(leaf);
        txn = await nftContract.mint(proof, 2, options);
        await txn.wait();
    } catch (error) {
        // console.log(error);
        console.log("can't mint if sale off");
    }

    var tx = await nftContract.flipMintEnabled();
    await tx.wait();
    console.log("set sale true");

    // TRY TO PUBLIC MINT SALE ON, OVER AMOUNT
    try {
        var options = {value: hre.ethers.utils.parseEther("0.03")}
        const leaf = soliditySha3(myAddress);
        const proof = merkleTree.getHexProof(leaf);
        txn = await nftContract.mint(proof, 3, options);
        await txn.wait();
        console.log("WAS ABLE TO MINT, OVER AMOUNT");
    } catch (error) {
        // console.log(error);
        console.log("can't mint if over amount");
    }

    // TRY TO PREMINT SALE ON, NOT ON WL
    try {
        var options = {value: hre.ethers.utils.parseEther("0.02")}
        const leaf = soliditySha3("0x248Ae960dC1a80e237147c94D95C5f6c19A62891");
        const proof = merkleTree.getHexProof(leaf);
        txn = await nftContract.mint(proof, 2, options);
        await txn.wait();
        console.log("WAS ABLE TO MINT NOT ON WL");
    } catch (error) {
        console.log("can't mint if not on WL");
    }

    // TRY TO MINT SALE ON, NOT ENOUGH ETH
    try {
      var options = {value: hre.ethers.utils.parseEther("0.01")}
      const leaf = soliditySha3(myAddress);
      const proof = merkleTree.getHexProof(leaf);
      txn = await nftContract.mint(proof, 2, options);
      await txn.wait();
      console.log("WAS ABLE TO MINT 2 WITH NOT ENOUGH ETH");
  } catch (error) {
      console.log("can't mint if too little eth");
  }

    // SUCCESS: TRY TO MINT SALE ON
    try {
      var options = {value: hre.ethers.utils.parseEther("0.02")}
      const leaf = soliditySha3(myAddress);
      const proof = merkleTree.getHexProof(leaf);
      txn = await nftContract.mint(proof, 2, options);
      await txn.wait();
      console.log("minted 2 successfully");
    } catch (error) {
        console.log(error)
        console.log("ERROR: couldn't mint 2 but should have");
    }

    // TRY TO MINT, NOW TOO MANY
    try {
      var options = {value: hre.ethers.utils.parseEther("0.02")}
      const leaf = soliditySha3(myAddress);
      const proof = merkleTree.getHexProof(leaf);
      txn = await nftContract.mint(proof, 2, options);
      await txn.wait();
      console.log("Error, minted too many!");
    } catch (error) {
        console.log("tried to mint too many, failed properly");
    }

    var tx = await nftContract.flipMintEnabled();
    console.log("flip mint state to false");
    await tx.wait();

    txn = await nftContract.withdrawMoney(myAddress);
    await txn.wait();
    console.log("withdrew");

    txn = await nftContract.setBaseURI("ipfs://QmTx4FBHCjyeQazsaySG3ALLdxhAiibYjthoeqDMpCwB22/")
    await txn.wait();
    console.log('set base uri');
}

const runMain = async () => {
    try {
        // await testDeploy();
        const merkleTree = await buildWhitelist();
        await testMerkletree(merkleTree);
        await testMint(merkleTree);
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();