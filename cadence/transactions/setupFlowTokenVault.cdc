import FungibleToken from 0x03
import FlowToken from 0x04

transaction {

    prepare(signer: AuthAccount) {

        if signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) != nil {
            log("FlowTokenVault already exists")
            return
        }
        signer.save(
            <-FlowToken.createEmptyVault(),
            to: /storage/flowTokenVault
        )
        signer.link<&FlowToken.Vault{FungibleToken.Receiver}>(
            /public/flowTokenReceiver,
            target: /storage/flowTokenVault
        )
        signer.link<&FlowToken.Vault{FungibleToken.Balance}>(
            /public/flowTokenBalance,
            target: /storage/flowTokenVault
        )
        log("FlowToken Vault Created")
    }
}