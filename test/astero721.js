const { expect } = require("chai")
const { ethers } = require("hardhat")
const { splitEvery } = require("ramda")
const { nanoid } = require("nanoid")
const { from18, to18, a, b, deploy, deployJSON } = require("../lib/utils")
const ethSigUtil = require("eth-sig-util")
const Wallet = require("ethereumjs-wallet").default

const EIP712Domain = [
  { name: "name", type: "string" },
  { name: "version", type: "string" },
  { name: "chainId", type: "uint256" },
  { name: "verifyingContract", type: "address" },
]

describe("ASTERO721", function () {
  it("Should validate erc712", async function () {
    const [p, p2, p3, p4, p5] = await ethers.getSigners()
    const name = "Asteroid Articles"
    const version = "1"
    const astero721 = await deploy("ASTERO721", name, "ASTEROARTICLES", version)
    const minter = await deploy("Minter", a(astero721))
    await astero721.grantRole(await astero721.MINTER_ROLE(), a(minter))
    let i = 0
    while (i < 10) {
      const tx = nanoid(40)
      const _id = nanoid(9)
      const nonce = i + 1
      const chainId = (await minter.getChainId()).toNumber()
      const message = {
        id: _id,
      }
      const data = {
        types: {
          EIP712Domain,
          Article: [{ name: "id", type: "string" }],
        },
        domain: { name, version, chainId, verifyingContract: a(astero721) },
        primaryType: "Article",
        message,
      }
      const wallet = Wallet.generate()
      const signature = ethSigUtil.signTypedMessage(wallet.getPrivateKey(), {
        data,
      })
      const uint = Math.ceil(Math.random() * 10)
      const uint2 = Math.ceil(Math.random() * 10)
      const extra = ethers.utils.keccak256(
        ethers.utils.defaultAbiCoder.encode(["uint", "uint"], [uint, uint2])
      )
      const message2 = {
        signature,
        arweave_tx: tx,
        nonce,
        extra,
      }
      const data2 = {
        types: {
          EIP712Domain,
          NFT: [
            { name: "signature", type: "bytes" },
            { name: "arweave_tx", type: "string" },
            { name: "nonce", type: "uint256" },
            { name: "extra", type: "bytes32" },
          ],
        },
        domain: { name, version, chainId, verifyingContract: a(astero721) },
        primaryType: "NFT",
        message: message2,
      }
      const signature2 = ethSigUtil.signTypedMessage(wallet.getPrivateKey(), {
        data: data2,
      })
      await minter.mint(
        _id,
        signature,
        tx,
        nonce,
        extra,
        signature2,
        uint,
        uint2
      )
      expect(await astero721.tokenURI(i + 1)).to.equal(`ar://${tx}`)
      i++
    }
  })
})
