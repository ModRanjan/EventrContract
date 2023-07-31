// 4_test_mint_token.cdc

import Eventr1 from 0x04
import NonFungibleToken from 0x01

// This transaction is what an admin would use to mint a single new moment
// and deposit it in a user's collection
// Parameters:
//
// eventID: the ID of a event containing the target Pass-Category
// categoryID: the ID of a Pass-Category from which a new token is minted
// ownerAddr: event owner Address
// recipientAddr: the Flow address of the account receiving the newly minted token
transaction(eventID: UInt64, categoryID:UInt64, price: UFix64, ownerAddr: Address, recipientAddr: Address) {
 
   let eventOwnerCapability: &AnyResource{Eventr1.NFTMinterPublic}

    prepare(signer: AuthAccount) {
        pre {
            price == Eventr1.getPassCategoryData(categoryID: categoryID)?.price: "NFT price and vault balance should be same"
        }
        log(Eventr1.getPassCategoryData(categoryID: categoryID)?.price)
    
        let adminPublicPath = PublicPath(identifier: "EventrAdminEventId".concat(eventID.toString()))
            ?? panic("does not specify a public path")
        
        let eventOwnerAccount = getAccount(ownerAddr)
        
        // borrow a reference to the Admin resource in storage
        self.eventOwnerCapability =  eventOwnerAccount.getCapability(adminPublicPath).borrow<&{Eventr1.NFTMinterPublic}>()
            ?? panic("Cannot borrow a reference to the Admin's <MintNFTPublic> resource")
    }

    execute {
        let recipientAccount = getAccount(recipientAddr)

        // get the Collection reference for the receiver
        let receiverRef = recipientAccount.getCapability(Eventr1.CollectionPublicPath).borrow<&{Eventr1.CollectionPublic}>()
            ?? panic("Cannot borrow a reference to the recipient's collection")
        
        self.eventOwnerCapability.testMintToken(eventID: eventID, categoryID: categoryID, _price: price, _collection: receiverRef)
        log("token mintd")
    }
}