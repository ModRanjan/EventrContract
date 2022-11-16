import path from 'path';
import {
  init,
  emulator,
  deployContractByName,
  shallPass,
  getAccountAddress,
  sendTransaction,
  shallRevert,
} from '@onflow/flow-js-testing';

let signer, signer2;
let Alice, Bob;
beforeEach(async () => {
  const basePath = path.resolve(__dirname, '../../cadence');
  await init(basePath);
  await emulator.start();

  Alice = await getAccountAddress('Alice');
  Bob = await getAccountAddress('Bob');
  signer = [Alice];
  signer2 = [Bob];

  await shallPass(
    deployContractByName({
      name: 'NonFungibleToken',
    }),
  );
  await shallPass(
    deployContractByName({
      name: 'Eventr',
    }),
  );
});

test('setting up nftMinter', async () => {
  await shallPass(sendTransaction('nftMinter', signer, []));
  await shallRevert(sendTransaction('nftMinter', signer, []));
  await shallPass(sendTransaction('nftMinter', signer2, []));
});

afterEach(async () => {
  await emulator.stop();
});
