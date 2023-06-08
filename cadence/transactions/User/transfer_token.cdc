// mint_token.cdc
// import Eventr from 0x04
import Eventr1 from "../../contracts/Eventr.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
// This transaction transfers a moment to a recipient
// This transaction is how a topshot user would transfer a moment
// from their account to another account
// The recipient must have a TopShot Collection object stored
// and a public MomentCollectionPublic capability stored at
// `/public/MomentCollection`
// Parameters:
//
// recipient: The Flow address of the account to receive the moment.
// withdrawID: The id of the moment to be transferred

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
