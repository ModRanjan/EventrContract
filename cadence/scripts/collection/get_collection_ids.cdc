// get_collection_ids.cdc
import Eventr1 from "../../contracts/Eventr.cdc"

// This is the script to get a list of all the token' ids an account owns
// Just change the argument to `getAccount` to whatever account you want
// and as long as they have a published Collection receiver, you can see
// the tokens they own.
// Parameters:
//
// account: The Flow Address of the account whose token data needs to be read
// Returns: [UInt64]
// list of all tokens' ids an account owns
pub fun main(account: Address): [UInt64] {

    let acct = getAccount(account)

    let collectionRef = acct.getCapability(Eventr1.CollectionPublicPath)
        .borrow<&{Eventr1.CollectionPublic}>()!

    let IDs = collectionRef.getIDs()
    log(IDs)

    return IDs
}
 