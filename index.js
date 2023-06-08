import fs from 'fs';
import 'dotenv/config';
import { toCadenceArg } from './utils/convert_to_CadenceArg.js';
import { toCadenceDict } from './utils/convert_to_Dict.js';

const ARGS_PATH = process.env.ARGs_PATH;

const eventID = '1';
const eventName = 'event-' + eventID;
const description = 'event-day celeberation. this is description';
const startDate = '02/25/2023'; // mm:dd:yyyy
const endDate = '03/01/2023'; // mm:dd:yyyy
const profileUrl =
  'https://bafybeieyvgiwrhc4qafndqpcx3ghgm6m7i7i3wcq2fjjtlflub263n5a54.ipfs.nftstorage.link/';
const coverUrl =
  'https://bafybeieyvgiwrhc4qafndqpcx3ghgm6m7i7i3wcq2fjjtlflub263n5a54.ipfs.nftstorage.link/';
const passName = 'test-pass';
const passType = 'ERC721'; // "ERC721" | "ERC1155"
const dropType = 'MINT'; // "MINT" | "PRE-MINT"

const passCategoryName = 'Gold'; // String
const passCategoryPrice = '5.0'; // UFix64
const passCategoryMaxLimit = '8'; // UInt32
const quantity = '3'; // UInt32
const categoryID = '1';
const ownerAddr = '0xf8d6e0586b0a20c7';

const Metadata = {
  eventID,
  eventName,
  passName,
  passType,
  dropType,
  description,
  startTimeStamp: new Date(startDate).getTime().toString(),
  endTimeStamp: new Date(endDate).getTime().toString(),
  profileUrl,
  coverUrl,
  ownerAddr,
};

const writeFileAtGivenPath = (path, content) => {
  try {
    fs.writeFileSync(path, JSON.stringify(content));

    // return `file .....args.json has been saved! at: ${path} path`;
    // });
  } catch (err) {
    console.error(err);
  }
};

const setupAccountArgs = () => {
  const setupAccountArg = {
    [eventID]: 'UInt64',
  };

  const setupedAccountArg = toCadenceArg(setupAccountArg);

  writeFileAtGivenPath(
    `${ARGS_PATH}setup-account-args.json`,
    setupedAccountArg,
  );
};

const createEventArgs_ERC721 = (metadata) => {
  const { eventID, eventName, passName, passType, dropType } = metadata;
  const createEventArgObj = {
    [eventID]: 'UInt64',
    [eventName]: 'String',
    [passName]: 'String',
    [passType]: 'String',
    [dropType]: 'String',
  };
  const additionalArgObj = {
    [passCategoryName]: 'String',
    [passCategoryPrice]: 'UFix64',
    [passCategoryMaxLimit]: 'UInt32',
  };

  const requiredArgs = toCadenceArg(createEventArgObj);
  console.log('requiredArgs: ', requiredArgs);
  const requiredAdditionalArgs = toCadenceArg(additionalArgObj);
  console.log('requiredAdditionalArgs: ', requiredAdditionalArgs);

  const metadataObj = { type: 'Dictionary', value: toCadenceDict(Metadata) };

  const createdEventArgs = [
    ...requiredArgs,
    metadataObj,
    ...requiredAdditionalArgs,
  ];

  writeFileAtGivenPath(
    `${ARGS_PATH}create-event-erc721-args.json`,
    createdEventArgs,
  );
};

const createEventArgs_ERC1155 = (metadata) => {
  const { eventID, eventName, passName, passType, dropType } = metadata;
  const createEventArgObj = {
    [eventID]: 'UInt64',
    [eventName]: 'String',
    [passName]: 'String',
    [passType]: 'String',
    [dropType]: 'String',
  };

  const requiredArgs = toCadenceArg(createEventArgObj);

  const metadataObj = { type: 'Dictionary', value: toCadenceDict(Metadata) };

  const createdEventArgs = [...requiredArgs, metadataObj];

  writeFileAtGivenPath(
    `${ARGS_PATH}create-event-erc1155-args.json`,
    createdEventArgs,
  );
};

const createPassCategoryArgs = () => {
  const argArray = [
    eventID,
    passCategoryName,
    passCategoryPrice,
    passCategoryMaxLimit,
  ];

  const argTypeArray = ['UInt64', 'String', 'UFix64', 'UInt32'];

  const PassCategoryArgs = toCadenceArg(argArray, argTypeArray);

  writeFileAtGivenPath(
    `${ARGS_PATH}create-pass-category-args.json`,
    PassCategoryArgs,
  );
};

const createMintTokenArgs = () => {
  const argArray = [eventID, categoryID, ownerAddr];

  const argTypeArray = ['UInt64', 'UInt64', 'Address'];

  const MintTokenArgs = toCadenceArg(argArray, argTypeArray);

  writeFileAtGivenPath(
    `${ARGS_PATH}create-mint-token-args.json`,
    MintTokenArgs,
  );
};

const createBatchMintTokensArgs = () => {
  const argArray = [eventID, categoryID, quantity, ownerAddr];

  const argTypeArray = ['UInt64', 'UInt64', 'UInt32', 'Address'];

  const MintTokenArgs = toCadenceArg(argArray, argTypeArray);

  writeFileAtGivenPath(
    `${ARGS_PATH}batch-mint-tokens-args.json`,
    MintTokenArgs,
  );
};

function main() {
  setupAccountArgs();

  createEventArgs_ERC721(Metadata);
  createEventArgs_ERC1155(Metadata);
  createPassCategoryArgs();
  createMintTokenArgs();
  createBatchMintTokensArgs();
}

main();
