// add_passCategories_to_Event.cdc
import Eventr1 from "../../contracts/Eventr.cdc"

transaction(eventID: UInt64, passCategories: [UInt64]) {
    
    let adminRef: &Eventr1.Admin

    prepare(signer: AuthAccount) {
        let adminStoragePath  = StoragePath(identifier: "EventrAdminEventId".concat(eventID.toString()))
                    ?? panic("does not specify a storage path")

        // borrow a reference to the Admin resource in storage
        self.adminRef = signer.borrow<&Eventr1.Admin>(from: adminStoragePath)
            ?? panic("No admin resource in storage")
    }

    execute {
        // borrow a reference to the event to be added to
        let eventRef = self.adminRef.borrowEvent(eventID: eventID)

        // Add the specified passCategory IDs
        eventRef.addPassCategories(categoryIDs: passCategories)
    }
}