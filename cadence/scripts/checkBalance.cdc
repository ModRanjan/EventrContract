import Eventr from 0xc2bf854ac7c824f6
import NonFungibleToken from 00xc2bf854ac7c824f6
import FlowToken from 0x7e60df042a9c0868
import FungibleToken from 0x9a0766d93b6608b7

pub fun main(account: Address){
  let FlowTokenVault = getAccount(account).getCapability<&FlowToken.Vault{FungibleToken.Balance}>(/public/flowTokenBalance)
  log(FlowTokenVault.borrow()!.balance)
}