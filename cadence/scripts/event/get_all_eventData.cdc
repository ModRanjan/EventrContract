// get_all_eventData.cdc
import Eventr1 from "../../contracts/Eventr.cdc"

pub fun main(): [Eventr1.EventData] {
 
    let allEvents  = Eventr1.getAllEvents()


    return allEvents
}