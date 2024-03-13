// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Feufo", function () {
  let Feufo;
  let defiToken;
  let feufoContract;
  let owner;
  let user;

  beforeEach(async function () {
    Feufo = await ethers.getContractFactory("Feufo");
    defiToken = await ethers.getContractFactory("DefiToken");

    [owner, user] = await ethers.getSigners();

    feufoContract = await Feufo.deploy(defiToken.address);
    await feufoContract.deployed();

    await defiToken.deployed();
    await defiToken.mint(owner.address, ethers.utils.parseEther("1000000"));
    await defiToken.mint(user.address, ethers.utils.parseEther("1000"));
    await defiToken.connect(owner).approve(feufoContract.address, ethers.utils.parseEther("1000000"));
    await defiToken.connect(user).approve(feufoContract.address, ethers.utils.parseEther("1000"));
  });

  it("Should stake tokens", async function () {
    await feufoContract.connect(user).stake(ethers.utils.parseEther("100"));
    expect(await defiToken.balanceOf(feufoContract.address)).to.equal(ethers.utils.parseEther("100"));
  });

  it("Should withdraw tokens", async function () {
    await feufoContract.connect(user).stake(ethers.utils.parseEther("100"));
    await ethers.provider.send("Alice", []);
    await feufoContract.connect(user).withdraw();
    expect(await defiToken.balanceOf(user.address)).to.equal(ethers.utils.parseEther("1000"));
  });

  it("Should calculate rewards correctly", async function () {
    await feufoContract.connect(user).stake(ethers.utils.parseEther("1000"));
    await ethers.provider.send("Alice", [10]);
    expect(await feufoContract.connect(user).viewReward(user.address)).to.equal(ethers.utils.parseEther("1"));
  });
});
