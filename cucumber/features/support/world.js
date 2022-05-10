const { setWorldConstructor, setDefaultTimeout } = require('@cucumber/cucumber')

setDefaultTimeout(10000)

function CustomWorld ({ attach }) {
  this.attach = attach
  this.browser = null
  this.page = null
}

setWorldConstructor(CustomWorld)
