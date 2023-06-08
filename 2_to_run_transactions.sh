flow project deploy --network=emulator

flow transactions send ./cadence/transactions/setup_account.cdc --args-json "$(cat ./cadence/transactions/Args/setup-account-args.json)" --signer "emulator-account";

flow transactions send ./cadence/transactions/Admin/create_event_ERC721.cdc --args-json "$(cat ./cadence/transactions/Args/create-event-erc721-args.json)" --signer "emulator-account";

flow transactions send ./cadence/transactions/transfer_flow-token.cdc  "0xe03daebed8ca0615" "1000.0" --signer "emulator-account";

flow scripts execute ./cadence/scripts/check_balance.cdc "0xe03daebed8ca0615"

flow transactions send ./cadence/transactions/User/create_empty_collection.cdc --signer "ranjan";

flow transactions send ./cadence/transactions/User/mint_token.cdc --args-json "$(cat ./cadence/transactions/Args/create-mint-token-args.json)" --signer "ranjan";

flow scripts execute ./cadence/scripts/collection/get_collection_ids.cdc "0xe03daebed8ca0615"

flow transactions send ./cadence/transactions/User/batch_mint_tokens.cdc --args-json "$(cat ./cadence/transactions/Args/batch-mint-tokens-args.json)" --signer "ranjan";
