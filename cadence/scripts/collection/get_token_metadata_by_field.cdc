// get_metadata_field.cdc
// import Eventr from 0x04
import Eventr1 from "../../contracts/Eventr.cdc"

// This script gets the metadata associated with a token
// in a collection by looking up its playID and then searching
// for that play's metadata in the Eventr contract. It returns
// the value for the specified metadata field
// Parameters:
//
// account: The Flow Address of the account whose token data needs to be read
// tokenID: The unique ID for the token whose data needs to be read
// fieldToSearch: The specified metadata field whose data needs to be read
// Returns: String
// Value of specified metadata field
pub fun main(account: Address, tokenID: UInt64, fieldToSearch: String): String {

    // borrow a public reference to the owner's token collection 
    let collectionRef = getAccount(account).getCapability(Eventr1.CollectionPublicPath)
        .borrow<&{Eventr1.CollectionPublic}>()
        ?? panic("Could not get public token collection reference")

    // borrow a reference to the specified token in the collection
    let token = collectionRef.borrowToken(id: tokenID)
        ?? panic("Could not borrow a reference to the specified token")

    // Get the tokens data
    let data = token.data

    // Get the metadata field associated with the specific play
    let field = Eventr1.getEventMetaDataByField(eventID: data.eventID, field: fieldToSearch) ?? panic("Event doesn't exist")

    log(field)

    return field
}
 