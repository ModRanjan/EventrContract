/**
 * convert matadata into cadence argument
 *
 * @param {*} item
 * @returns an array of [{key: string, value: string}]
 */
function toCadenceDict(item) {
  return Object.keys(item).map((key) => {
    // const type= (typeof key).charAt(0).toUpperCase() + (typeof key).slice(1)
    return {
      key: {
        value: key,
        type: 'String',
      },
      value: { value: item[key], type: 'String' },
    };
  });
}

export { toCadenceDict };
