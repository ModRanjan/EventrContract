/**
    # to run: 
        1. flow transactions send ./transactions/transfer_flow-token.cdc "0xf8d6e0586b0a20c7" "50.0" --signer "account-2"

        2. flow transactions send ./cadence//transactions/transfer_flow-token.cdc  "0x01cf0e2f2f715450" "1000.0" --signer "emulator-account"
*/ 

// for flow-emulator
import FlowToken from 0x0ae53cb6e3f42a79
import FungibleToken from 0xee82856bf20e2aa6

// for flow-testnet 
// import FlowToken from 0x7e60df042a9c0868
// import FungibleToken from 0x9a0766d93b6608b7

transaction(recepient: Address, amount: UFix64){

    prepare(signer: AuthAccount){
        let sender = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
        ?? panic("Could not borrow Provider reference to the Vault")

        let receiverAccount = getAccount(recepient)

        let receiver = receiverAccount.getCapability(/public/flowTokenReceiver)
        .borrow<&FlowToken.Vault{FungibleToken.Receiver}>()
        ?? panic("Could not borrow Receiver reference to the Vault")

        let tempVault <- sender.withdraw(amount: amount)
      
        receiver.deposit(from: <- tempVault)

    }
} 
 