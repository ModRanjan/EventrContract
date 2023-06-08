// create_passCategory.cdc
// import Eventr from 0x04
import Eventr1 from "../../contracts/Eventr.cdc"

// This transaction creates a new PassCategories structs 
// and stores it in the Eventr smart contract
// and also add newly created category to respective event
//
// Parameters: 
//      eventID (UInt64)
//      categoryNames ([String])
//      prices ([UFix64])
//      maxLimits ([UInt32])
//
transaction(eventID: UInt64, categoryNames: [String], prices: [UFix64], maxLimits: [UInt32]) {

    let adminRef: &Eventr1.Admin
    let categoryIDs:[UInt64] 
    
    prepare(acct: AuthAccount) {
        let adminStoragePath = StoragePath(identifier: "EventrAdminEventId".concat(eventID.toString()))
            ?? panic("does not specify a storage path")

        // borrow a reference to the admin resource
        self.adminRef = acct.borrow<&Eventr1.Admin>(from: adminStoragePath)
            ?? panic("No admin resource in storage")

        self.categoryIDs = []
    }

    execute {

        for index, categoryName in categoryNames {
            let categoryId = self.adminRef.createPassCategory(eventID: eventID, categoryName: categoryName, price: prices[index], maxLimit: maxLimits[index])

            self.categoryIDs.append(categoryId)
        }

        log(self.categoryIDs)

        let eventRef = self.adminRef.borrowEvent(eventID: eventID)

        eventRef.addPassCategories(categoryIDs: self.categoryIDs)
        log("PassCategories added to Event")
    }
}
