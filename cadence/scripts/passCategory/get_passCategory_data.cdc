// get_passCategory_data.cdc
import Eventr1 from "../../contracts/Eventr.cdc"

pub fun main(categoryID: UInt64): Eventr1.PassCategory? {

    return Eventr1.getPassCategoryData(categoryID: categoryID)
}
 