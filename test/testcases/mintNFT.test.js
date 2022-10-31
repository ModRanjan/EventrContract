import path from 'path';
import {
  init,
  emulator,
  deployContractByName,
  shallPass,
  getAccountAddress,
  sendTransaction,
  executeScript,
  mintFlow,
  shallResolve,
  getFlowBalance,
  shallRevert,
} from '@onflow/flow-js-testing';

let args = [];
let signer, signer2;
let Alice, Bob;
let aliceBalance, bobBalance;
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
  await shallPass(sendTransaction('createCollection', signer2, args));
  await shallPass(sendTransaction('nftMinter', signer2, []));

  await mintFlow(Alice, '100.0');
  aliceBalance = await shallResolve(getFlowBalance(Alice));
  bobBalance = await shallResolve(getFlowBalance(Bob));
  expect(parseFloat(aliceBalance[0])).toBe(100.001);
  expect(parseFloat(bobBalance[0])).toBe(0.001);
});

test('should not mint nft if collection does not exist', async () => {
  await shallRevert(
    sendTransaction('mintNFT', signer, [
      `${Bob}`,
      'ipfsHash',
      'MyFirstNFT',
      '25.0',
      '/storage/MyNFTCollection2',
    ]),
  );
});
test('should not mint nft if insufficient balance', async () => {
  await shallRevert(
    sendTransaction('mintNFT', signer2, [
      `${Alice}`,
      'ipfsHash',
      'MyFirstNFT',
      '75.0',
      '/storage/MyNFTCollection',
    ]),
  );
});
test('should mint nft', async () => {
  await shallPass(
    sendTransaction('mintNFT', signer, [
      `${Bob}`,
      'ipfsHash',
      'MyFirstNFT',
      '25.0',
      '/storage/MyNFTCollection',
    ]),
  );
  const [res] = await executeScript('getNFTs', [
    Alice,
    '/public/MyNFTCollection',
  ]);
  expect(res.length).toBe(1);
  aliceBalance = await shallResolve(getFlowBalance(Alice));
  bobBalance = await shallResolve(getFlowBalance(Bob));
  expect(parseFloat(aliceBalance[0])).toBe(75.001);
  expect(parseFloat(bobBalance[0])).toBe(25.001);
});

afterEach(async () => {
  await emulator.stop();
});
