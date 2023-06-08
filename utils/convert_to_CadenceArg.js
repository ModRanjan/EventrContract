/**
 *
 * @param {objOrKeyArray}  that can be either an object or an array
 * If it's an array, the function assumes that valueArray is also an array
 * @returns Return an array of [{type: string, value: string}].
 */
function toCadenceArg(objOrKeyArray, valueArray) {
  if (Array.isArray(objOrKeyArray)) {
    return objOrKeyArray.map((item, index) => ({
      type: valueArray[index],
      value: item,
    }));
  } else {
    return Object.entries(objOrKeyArray).map(([key, value]) => ({
      type: value,
      value: String(key),
    }));
  }
}

export { toCadenceArg };
