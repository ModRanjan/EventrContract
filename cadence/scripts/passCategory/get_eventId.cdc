import Eventr1 from "../../contracts/Eventr.cdc"

pub fun main(categoryId: UInt64): UInt64?  {

    return Eventr1.getPassCategoryEventId(categoryId: categoryId)
}