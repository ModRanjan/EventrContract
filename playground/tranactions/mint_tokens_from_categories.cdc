// 4_test_batch_mint_token.cdc
import Eventr1 from 0x04

// This transaction mints multiple moments 
// from a single set/play combination (otherwise known as edition)
// Parameters:
//
// eventID: the ID of the event to be minted from
// categoryID: the ID of the PassCategory from which the Tokens are minted 
// quantity: the quantity of Tokens to be minted
// recipientAddr: the Flow address of the account receiving the collection of minted moments
transaction(eventID: UInt64, categoryIDs: [UInt64], quantities: [UInt32], prices: [UFix64], ownerAddr: Address, recipientAddr: Address) {

    let eventOwnerCapability: &AnyResource{Eventr1.NFTMinterPublic}

    prepare(acct: AuthAccount) {
        
    
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
        
        for index, categoryId in categoryIDs {
            self.eventOwnerCapability.testBatchMintToken(eventID: eventID, categoryID: categoryId, quantity: quantities[index], price: prices[index], collection: receiverRef)

            log(index)
            log("token mintd")
        }
    }
}
 