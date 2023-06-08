// get_eventName.cdc
// import Eventr from 0x04
import Eventr1 from "../../contracts/Eventr.cdc"

// This script gets the eventName of a event with specified eventID
// Parameters:
//
// eventID: The unique ID for the event whose data needs to be read
// Returns: String
// Name of event with specified eventID
pub fun main(eventID: UInt64): String {

    let name = Eventr1.getEventName(eventID: eventID)
        ?? panic("Could not find the specified event")
        
    return name
}