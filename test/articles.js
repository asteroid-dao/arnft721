const { expect } = require("chai")
const { ethers } = require("hardhat")
const { splitEvery } = require("ramda")
const { nanoid } = require("nanoid")
const { from18, to18, a, b, deploy, deployJSON } = require("../lib/utils")

function toEthSignedMessageHash(messageHex) {
  const messageBuffer = Buffer.from(messageHex.substring(2), "hex")
  const prefix = Buffer.from(
    `\u0019Ethereum Signed Message:\n${messageBuffer.length}`
  )
  return web3.utils.sha3(Buffer.concat([prefix, messageBuffer]))
}
const e = new TextEncoder()

const hexEncode = function (s) {
  var hex, i
  var result = ""
  for (i = 0; i < s.length; i++) {
    hex = s.charCodeAt(i).toString(16)
    result += ("0" + hex).slice(-2)
  }

  return "0x" + result
}

describe("ASTERO721", function () {
  it("Should return the new greeting once it's changed", async function () {
    const [p, p2, p3, p4, p5] = await ethers.getSigners()
    const Astero721 = await ethers.getContractFactory("ASTERO721")
    const astero721 = await Astero721.deploy(
      "Asteroid Articles",
      "ASTEROARTICLES"
    )
    await astero721.deployed()
    const Minter = await ethers.getContractFactory("Minter")
    const minter = await Minter.deploy(a(astero721))
    await astero721.grantRole(await astero721.MINTER_ROLE(), a(minter))
    let i = 0
    while (i < 10) {
      const tx = nanoid(40)
      const _id = nanoid(9)
      const id = await p2.signMessage(_id)
      const nonce = i + 1
      const str = [id, tx, nonce].join("&")
      const sig = await p2.signMessage(str)
      const _tx = await minter.mint(_id, id, tx, nonce, sig)
      await _tx.wait()
      const tokenUrl = await astero721.tokenURI(i)
      expect(tokenUrl).to.be.equal(`ar://${tx}`)
      i++
    }
  })
})
