// get_numTokens_in_passCategory.cdc
// import Eventr from 0x04
import Eventr1 from "../../contracts/Eventr.cdc"

// This script returns the number of specified tokens that have been
// minted for the specified pass-category
// Parameters:
//
// eventID: The unique ID for the event whose data needs to be read
// categoryID: The unique ID for the passCategory whose data needs to be read
// Returns: UInt32
// number of tokens with specified categoryID minted for a event with specified eventID
pub fun main(eventID: UInt64, categoryID: UInt64): UInt32 {

    let numTokens = Eventr1.getNumTokensInPassCategory(eventID: eventID, categoryID: categoryID)
        ?? panic("Could not find the specified pass-category")

    return numTokens
}