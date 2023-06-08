// get_eventIDs_by_name.cdc
// import Eventr from 0x04
import Eventr1 from "../../contracts/Eventr.cdc"

// This script returns an array of the eventIDs
// that have the specified name
// Parameters:
//
// eventName: The name of the set whose data needs to be read
// Returns: [UInt64]
// Array of eventIDs that have specified event name
pub fun main(eventName: String): [UInt64] {

    let ids = Eventr1.getEventIDsByName(eventName: eventName)
        ?? panic("Could not find the specified set name")

    return ids
}