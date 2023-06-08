// to run: flow scripts execute ./cadence/scripts/check_balance.cdc "0x01cf0e2f2f715450"

// for flow-emulator
import FlowToken from 0x0ae53cb6e3f42a79
import FungibleToken from 0xee82856bf20e2aa6

// for flow-testnet 
// import FlowToken from 0x7e60df042a9c0868
// import FungibleToken from 0x9a0766d93b6608b7


pub fun main(address: Address): UFix64 {
    let account = getAccount(address)

    let vaultRef = account.getCapability(/public/flowTokenBalance)
            .borrow<&FlowToken.Vault{FungibleToken.Balance}>()
            ?? panic("Could not borrow Balance reference to the Vault")

    return vaultRef.balance
}
 