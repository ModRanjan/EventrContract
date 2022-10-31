import path from 'path';
import {
  init,
  emulator,
  deployContractByName,
  shallPass,
  executeScript,
  shallResolve,
} from '@onflow/flow-js-testing';

beforeEach(async () => {
  const basePath = path.resolve(__dirname, '../../cadence');
  await init(basePath);
  await emulator.start();
});

test('deploy contracts by name', async () => {
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

  const [totalSupply] = await shallResolve(
    executeScript({
      code: `
        import Eventr from 0x01
        pub fun main(): UInt64{
          return Eventr.totalSupply
        }
    `,
    }),
  );
  expect(totalSupply).toBe('0');
});

afterEach(async () => {
  await emulator.stop();
});
