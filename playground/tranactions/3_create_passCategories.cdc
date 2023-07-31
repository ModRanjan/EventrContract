// 3_create_passCategories.cdc
import Eventr1 from 0x04

// This transaction creates a new PassCategory struct 
// and stores it in the Eventr smart contract
// and also add newly created category to respective event
//
// Parameters: 
//      eventID
//      passID
//      price
//      maxLimit
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

        let eventRef = self.adminRef.borrowEvent(eventID: eventID)

        eventRef.addPassCategories(categoryIDs: self.categoryIDs)

        eventRef.lock()

        log("Category Created and added to event")
        log(self.categoryIDs)
    }
}
