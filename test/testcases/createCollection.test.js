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
let args = [];
let args2 = [];
beforeEach(async () => {
  const basePath = path.resolve(__dirname, '../../cadence');
  await init(basePath);
  await emulator.start();

  Alice = await getAccountAddress('Alice');
  Bob = await getAccountAddress('Bob');
  signer = [Alice];
  signer2 = [Bob];

  args = [
    '/storage/MyNFTCollection',
    '/public/MyNFTCollection',
    '/private/MyNFTCollection',
  ];

  args2 = [
    '/storage/MyNFTCollection2',
    '/public/MyNFTCollection2',
    '/private/MyNFTCollection2',
  ];
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

test('create collections', async () => {
  await shallPass(sendTransaction('createCollection', signer, args));
  await shallRevert(sendTransaction('createCollection', signer, args));
  await shallPass(sendTransaction('createCollection', signer, args2));
  await shallPass(sendTransaction('createCollection', signer2, args));
});

afterEach(async () => {
  await emulator.stop();
});
