// get_event_locked.cdc
// import Eventr from 0x04
import Eventr1 from "../../contracts/Eventr.cdc"

// This script returns a boolean indicating if the specified event is locked
// meaning new categories cannot be added to it
// Parameters:
//
// eventID: The unique ID for the event whose data needs to be read
// Returns: Bool
// Whether specified event is locked
pub fun main(eventID: UInt64): Bool {

    let isLocked = Eventr1.isEventLocked(eventID: eventID)

    return isLocked
}