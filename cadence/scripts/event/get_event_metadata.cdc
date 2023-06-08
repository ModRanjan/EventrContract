// get_event_metadata.cdc

// import Eventr from 0x04
import Eventr1 from "../../contracts/Eventr.cdc"

pub struct EventMetadata {
    pub let eventID: String
    pub let eventName: String
    pub let description: String
    pub let passName: String
    pub let passType: String
    pub let dropType: String
    pub let startTimeStamp: String
    pub let endTimeStamp: String
    pub let profileUrl: String
    pub let coverUrl: String

    init(
        eventID: String,
        eventName: String,
        description: String,
        passName: String,
        passType: String,
        dropType: String,
        startTimeStamp: String,
        endTimeStamp: String,
        profileUrl: String,
        coverUrl: String,
            
    ) {
        
        self.eventID = eventID
        self.eventName = eventName
        self.description = description
        self.passName = passName
        self.passType = passType
        self.dropType = dropType
        self.startTimeStamp = startTimeStamp
        self.endTimeStamp = endTimeStamp
        self.profileUrl = profileUrl
        self.coverUrl = coverUrl
        
    }
}
pub fun main(eventID: UInt64): EventMetadata {

    let eventMetadata = Eventr1.getEventMetaData(eventID: eventID)
        ?? panic("Could not get data for the specified event ID")

    return EventMetadata(eventID: eventMetadata["eventID"]!,
eventName: eventMetadata["eventName"]!,
description: eventMetadata["description"]!,
passName: eventMetadata["passName"]!,
passType: eventMetadata["passType"]!,
dropType: eventMetadata["dropType"]!,
startTimeStamp: eventMetadata["startTimeStamp"]!,
endTimeStamp: eventMetadata["endTimeStamp"]!,
profileUrl: eventMetadata["profileUrl"]!,
coverUrl: eventMetadata["coverUrl"]!,)
}
 