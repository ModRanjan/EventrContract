import Eventr1 from "../../contracts/Eventr.cdc"


pub fun main(categoryId: UInt64): UInt32?  {

    return Eventr1.getPassCategoryMaxLimit(categoryID: categoryId)
}