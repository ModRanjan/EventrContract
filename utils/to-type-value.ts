// ts version
type ObjectInput = { [key: string]: string };

type CadenceArg = {
  type: string;
  value: string;
};

function toCadenceArg(
  obj: ObjectInput | string[],
  values?: string[],
): Array<CadenceArg> {
  if (Array.isArray(obj)) {
    const keyArray = obj;
    const valueArray = values || [];
    return keyArray.map((item, index) => ({
      type: valueArray[index],
      value: item,
    }));
  } else {
    return Object.entries(obj).map(([key, value]) => ({
      type: value,
      value: String(key),
    }));
  }
}

const obj1 = {
  1: 'UInt64',
  Gold: 'String',
  '5.0': 'UFix64',
  5: 'UInt32',
};

// const arr1 = [1, 'Gold', '5.0', 5].map((x) => x.toString());
const arr1: string[] = ['1', 'Gold', '5.0', '5'];
const arr2: string[] = ['UInt64', 'String', 'UFix64', 'UInt32'];

console.log(toCadenceArg(obj1));
console.log(toCadenceArg(arr1, arr2));
