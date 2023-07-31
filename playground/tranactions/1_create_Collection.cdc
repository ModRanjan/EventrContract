// 1_create_Collection.cdc
import NonFungibleToken from 0x01
import Eventr1 from 0x04
import MetadataViews from 0x03

transaction() {

    prepare(signer: AuthAccount) {

        if signer.borrow<&Eventr1.Collection>(from: Eventr1.CollectionStoragePath) == nil {

            let collection <- Eventr1.createEmptyCollection() as! @Eventr1.Collection

            signer.save(<-collection, to: Eventr1.CollectionStoragePath)

            signer.link<&{NonFungibleToken.CollectionPublic, Eventr1.CollectionPublic, MetadataViews.ResolverCollection}>(Eventr1.CollectionPublicPath, target: Eventr1.CollectionStoragePath)
        } else {
            log("You already have Collection")
        }
    }
}