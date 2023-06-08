// batch_transfer_token.cdc

import Eventr from "../../../contracts/EventrTab.cdc"
import NonFungibleToken from "../../../contracts/NonFungibleToken.cdc"

// This transaction transfers a number of moments to a recipient
// Parameters
//
// recipientAddress: the Flow address who will receive the NFTs
// momentIDs: an array of moment IDs of NFTs that recipient will receive
transaction(recipientAddress: Address, tokenIDs: [UInt64]) {

    let transferTokens: @NonFungibleToken.Collection
    
    prepare(acct: AuthAccount) {

        self.transferTokens <- acct.borrow<&Eventr.Collection>(from: Eventr.CollectionStoragePath)!.batchWithdraw(ids: tokenIDs)
    }

    execute {
        
        // get the recipient's public account object
        let recipient = getAccount(recipientAddress)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(Eventr.CollectionPublicPath).borrow<&{Eventr.CollectionPublic}>()
            ?? panic("Could not borrow a reference to the recipients token receiver")

        // deposit the NFT in the receivers collection
        receiverRef.batchDeposit(tokens: <-self.transferTokens)
    }
}