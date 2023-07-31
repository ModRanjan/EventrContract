// 5_transfer_token.cdccdc
import NonFungibleToken from 0x01
import Eventr1 from 0x04

// This transaction transfers a token to a recipient
// This transaction is how a Eventr user would transfer a token
// from their account to another account
// The recipient must have a Eventr Collection object stored
// and a public Collection capability stored at
// `/public/EventrCollection`
//
// Parameters:
//  recipient: The Flow address of the account to receive the token.
//  withdrawID: The id of the token to be transferred
//
transaction(recipient: Address, withdrawID: UInt64) {

    // local variable for storing the transferred token
    let transferToken: @NonFungibleToken.NFT
    
    prepare(acct: AuthAccount) {

        // borrow a reference to the owner's collection
        let collectionRef = acct.borrow<&Eventr1.Collection>(from: Eventr1.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the stored Token collection")
        
        // withdraw the NFT
        self.transferToken <- collectionRef.withdraw(withdrawID: withdrawID)
    }

    execute {
        
        // get the recipient's public account object
        let recipient = getAccount(recipient)

        // get the Collection reference for the receiver
        let receiverRef = recipient.getCapability(Eventr1.CollectionPublicPath).borrow<&{Eventr1.CollectionPublic}>()!

        // deposit the NFT in the receivers collection
        receiverRef.deposit(token: <-self.transferToken)
    }
}