// get_event_data.cdc
// to run: flow scripts execute scripts/Eventr/event/get_event_data.cdc "1"

// import Eventr from 0x04
import Eventr1 from "../../contracts/Eventr.cdc"

// This script returns all the metadata about the specified event
// Parameters:
//
// setID: The unique ID for the event whose data needs to be read
// Returns: Eventr.QueryEventData
pub fun main(eventID: UInt64): Eventr1.QueryEventData {

    let data = Eventr1.getEventData(eventID: eventID)
        ?? panic("Could not get data for the specified event ID")

    return data
}
 