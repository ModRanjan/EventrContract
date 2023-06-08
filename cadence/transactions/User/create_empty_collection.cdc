// create_empty_collection
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import MetadataViews from "../../contracts/utils/MetadataViews.cdc"
import Eventr1 from "../../contracts/Eventr.cdc"

transaction {

    prepare(signer: AuthAccount) {
         
        // First, check to see if collection already exists
        if signer.borrow<&Eventr1.Collection>(from: Eventr1.CollectionStoragePath) == nil {

            let collection <- Eventr1.createEmptyCollection() as! @Eventr1.Collection

            signer.save(<-collection, to: Eventr1.CollectionStoragePath)

            signer.link<&{NonFungibleToken.CollectionPublic, Eventr1.CollectionPublic, MetadataViews.ResolverCollection}>(Eventr1.CollectionPublicPath, target: Eventr1.CollectionStoragePath)
        } else {
            log("You already have Collection")
        }
    }
}