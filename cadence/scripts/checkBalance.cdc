import ERC721 from 0x02
import NonFungibleToken from 0x01
import FlowToken from 0x04
import FungibleToken from 0x03

pub fun main(account: Address){
  let FlowTokenVault = getAccount(account).getCapability<&FlowToken.Vault{FungibleToken.Balance}>(/public/flowTokenBalance)
  log(FlowTokenVault.borrow()!.balance)
}