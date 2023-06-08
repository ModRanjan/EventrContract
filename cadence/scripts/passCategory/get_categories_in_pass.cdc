// get_categories_in_pass.cdc
import Eventr1 from "../../contracts/Eventr.cdc"


// This script returns an array of all the passCategories 
// that have ever been created for Eventr
// Returns: UInt64]?
// array of all passCategory created for that particular eventID
pub fun main(eventID: UInt64): [UInt64]? {

    return Eventr1.getCategoriesInPass(eventID: eventID)
}