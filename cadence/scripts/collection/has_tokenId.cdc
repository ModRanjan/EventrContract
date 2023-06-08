import Eventr1 from "../../contracts/Eventr.cdc"

// This script returns true if a token with the specified ID
// exists in a user's collection
// Parameters:
//
// account: The Flow Address of the account whose token data needs to be read
// id: The unique ID for the token whose data needs to be read
// Returns: Bool
// Whether a token with specified ID exists in user's collection
pub fun main(account: Address, id: UInt64): Bool {

    let collectionRef = getAccount(account).getCapability(Eventr1.CollectionPublicPath)
        .borrow<&{Eventr1.CollectionPublic}>()
        ?? panic("Could not get public token collection reference")

    return collectionRef.borrowNFT(id: id) != nil
}