// get_categories_pass.cdc
// import Eventr from 0x04
import Eventr1 from "../../contracts/Eventr.cdc"

// This script returns an array of the category IDs that are
// in the specified event
// Parameters:
//
// eventID: The unique ID for the event whose data needs to be read
// Returns: [UInt64]
// Array of categories IDs in specified set
pub fun main(eventID: UInt64): [UInt64] {

    let categories = Eventr1.getCategoriesInPass(eventID: eventID)!

    return categories
}