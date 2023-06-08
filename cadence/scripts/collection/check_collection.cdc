import Eventr1 from "../../contracts/Eventr.cdc"

pub fun main(account: Address): Bool {
    // Get the user's account
    let userAccount = getAccount(account)

    let collectionRef = userAccount.getCapability(Eventr1.CollectionPublicPath).borrow<&{Eventr1.CollectionPublic}>()?? nil

    // Check if the Collection resource exists
    if collectionRef != nil {
        return true
    } else {
        return false
    }
}
 