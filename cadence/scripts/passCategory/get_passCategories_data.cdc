// get_passCategories_data.cdc
import Eventr1 from "../../contracts/Eventr.cdc"

pub struct categoriesData {
      
    pub let categoryID: UInt64
    pub let categoryName: String
    pub let eventID: UInt64
    pub let price: UFix64
    pub let maxEditions: UInt32
    
    init(categoryID: UInt64, categoryName: String, eventID: UInt64, price: UFix64, maxEditions: UInt32 ) {
        self.categoryID = categoryID
        self.categoryName = categoryName
        self.eventID = eventID
        self.price = price
        self.maxEditions = maxEditions
    }
}
    
pub fun main(eventID: UInt64): [Eventr1.PassCategory] {
        
    let categoriesId = Eventr1.getCategoriesInPass(eventID: eventID)
                    ?? panic("No categories found! Check your eventId")
    
    let categoryDatas: [Eventr1.PassCategory] =[]

    if categoriesId.length > 1 {
        for categoryId in categoriesId {
            let categoryData = Eventr1.getPassCategoryData(categoryID: categoryId)!
            categoryDatas.append(categoryData)
        }
    } else {
        let categoryID = categoriesId[0]
        let categoryData = Eventr1.getPassCategoryData(categoryID: categoryID)!
        categoryDatas.append(categoryData)
    }

    return categoryDatas
}
 