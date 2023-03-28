// https://qiita.com/riversun/items/60307d58f9b2f461082a
const deepmerge = (object1, object2) => {
  const resultObject = Object.assign({}, object1);

  if (isObject(object1) && isObject(object2)) {
    for (const [key, value2] of Object.entries(object2)) {
      const value1 = object1[key];

      if (isObject(value2) && object1.hasOwnProperty(key) && isObject(value1)) {
        resultObject[key] = deepmerge(value1, value2);
      } else {
        Object.assign(resultObject, { [key]: value2 });
      }
    }
  }

  return resultObject;
};

const isObject = (object) => {
  return object && typeof object === "object" && !Array.isArray(object);
};

module.exports = {
  deepmerge,
};
