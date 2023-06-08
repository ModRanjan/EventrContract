// create_passCategory.cdc
// import Eventr from 0x04
import Eventr1 from "../../contracts/Eventr.cdc"

// This transaction creates a new PassCategory struct 
// and stores it in the Eventr smart contract
// and also add newly created category to respective event
//
// Parameters: 
//      eventID
//      categoryName
//      price
//      maxLimit
//
transaction(eventID: UInt64, categoryName: String, price: UFix64, maxLimit: UInt32) {

    let adminRef: &Eventr1.Admin
    
    prepare(signer: AuthAccount) {
        let adminStoragePath = StoragePath(identifier: "EventrAdminEventId".concat(eventID.toString()))
            ?? panic("does not specify a storage path")

        // borrow a reference to the admin resource
        self.adminRef = signer.borrow<&Eventr1.Admin>(from: adminStoragePath)
            ?? panic("No admin resource in storage")
    }

    execute {
        // Create a Pass-Category and add it to Event
        let categoryId = self.adminRef.createPassCategory(eventID: eventID, categoryName: categoryName, price: price, maxLimit: maxLimit)

        log(categoryId)
    }
}
 