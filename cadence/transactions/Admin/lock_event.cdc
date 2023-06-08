// lock_event.cdc
// import Eventr from 0x04
import Eventr1 from "../../contracts/Eventr.cdc"

transaction( eventID: UInt64) {
    let adminRef: &Eventr1.Admin

    prepare(signer: AuthAccount) {
        let adminStoragePath = StoragePath(identifier: "EventrAdminEventId".concat(eventID.toString()))
            ?? panic("does not specify a storage path")

        // borrow a reference to the Admin resource
        self.adminRef = signer.borrow<&Eventr1.Admin>(from: adminStoragePath)
            ?? panic("No admin resource in storage")
    }

    execute {
       let EventRef = self.adminRef.borrowEvent(eventID: eventID)

       EventRef.lock()
    }

    post {
        Eventr1.isEventLocked(eventID: eventID)!: "Event did not lock"
    }
}
 