// get_tokensCount_ratio.cdc
// import Eventr1 from 0x04
import Eventr1 from "../../contracts/Eventr.cdc"

pub  struct totalTokenCount {
    pub let totalTokens: UInt32
    pub let currentTokensMinted: UInt32

    init(_totalTokens: UInt32, _currentTokensMinted: UInt32){
        self.totalTokens= _totalTokens
        self.currentTokensMinted= _currentTokensMinted
    }
}

pub fun main(eventID: UInt64): totalTokenCount {

    let categoriesId = Eventr1.getCategoriesInPass(eventID: eventID)
                        ?? panic("No categories found! Check your eventId")

   
    var totalTokensWillBe: UInt32 = 0
    var currentTokensMinted: UInt32 = 0

    for categoryId in categoriesId {
        let totalTokens = Eventr1.getPassCategoryMaxLimit(categoryID: categoryId)!

        let currentTokenCount = Eventr1.getNumTokensInPassCategory(eventID: eventID, categoryID: categoryId)
            ?? panic("Could not find the specified edition")

        totalTokensWillBe = totalTokensWillBe + totalTokens
        currentTokensMinted = currentTokensMinted + currentTokenCount
    }

    return totalTokenCount(_totalTokens: totalTokensWillBe, _currentTokensMinted: currentTokensMinted)
}