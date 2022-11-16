import path from 'path';
import {
  init,
  emulator,
  deployContractByName,
  shallPass,
  getAccountAddress,
  sendTransaction,
  executeScript,
  shallRevert,
} from '@onflow/flow-js-testing';

let args = [];
let signer;
let Alice;
beforeEach(async () => {
  const basePath = path.resolve(__dirname, '../../cadence');
  await init(basePath);
  await emulator.start();

  Alice = await getAccountAddress('Alice');
  signer = [Alice];
  args = [
    '/storage/MyNFTCollection',
    '/public/MyNFTCollection',
    '/private/MyNFTCollection',
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

  await shallPass(sendTransaction('createCollection', signer, args));
  await shallPass(sendTransaction('nftMinter', signer, []));
});

test('should not premint nft if collection does not exist', async () => {
  await shallRevert(
    sendTransaction('premintNFT', signer, [
      'ipfsHash',
      'MyFirstNFT',
      '/storage/MyNFTCollection2',
    ]),
  );
});

test('should premint nft', async () => {
  await shallPass(
    sendTransaction('premintNFT', signer, [
      'ipfsHash',
      'MyFirstNFT',
      '/storage/MyNFTCollection',
    ]),
  );

  const [res] = await executeScript('getNFTs', [
    Alice,
    '/public/MyNFTCollection',
  ]);
  expect(res.length).toBe(1);
});

afterEach(async () => {
  await emulator.stop();
});
