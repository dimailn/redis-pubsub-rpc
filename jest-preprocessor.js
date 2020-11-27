const coffee = require('coffeescript')
const babelJest = require('babel-jest')

module.exports = {
  process: (src, path, config, transformOptions) => {
    if (coffee.helpers.isCoffee(path)) {
      coffeeResult = coffee.compile(src, { bare: true })
      return babelJest.process(coffeeResult, path, config, transformOptions);
    }
    if (!/node_modules/.test(path)) {
      return babelJest.process(src, path);
    }
    return src;
  }
}
