// 1_setup_account.cdc
import NonFungibleToken from 0x01
import Eventr1 from 0x04
import MetadataViews from 0x03

// adminStoragePath: /storage/EventrAdmin{eventName+id}

transaction(eventId: UInt64) {
    let adminStoragePath: StoragePath
    let adminPublicPath: PublicPath

    prepare(signer: AuthAccount) {
        self.adminStoragePath = StoragePath(identifier: "EventrAdminEventId".concat(eventId.toString()))
                                ?? panic("does not specify a storage path")
        self.adminPublicPath = PublicPath(identifier: "EventrAdminEventId".concat(eventId.toString()))
                                ?? panic("does not specify a public path")

        if signer.borrow<&Eventr1.Collection>(from: Eventr1.CollectionStoragePath) == nil {

            let collection <- Eventr1.createEmptyCollection() as! @Eventr1.Collection

            signer.save(<-collection, to: Eventr1.CollectionStoragePath)

            signer.link<&{NonFungibleToken.CollectionPublic, Eventr1.CollectionPublic, MetadataViews.ResolverCollection}>(Eventr1.CollectionPublicPath, target: Eventr1.CollectionStoragePath)
        }
        
        if signer.borrow<&Eventr1.Admin>(from: self.adminStoragePath) == nil {

            signer.save<@Eventr1.Admin>(<- Eventr1.createAdmin(), to: self.adminStoragePath)
            signer.link<&{Eventr1.NFTMinterPublic}>(self.adminPublicPath, target: self.adminStoragePath)
        }
    }
}