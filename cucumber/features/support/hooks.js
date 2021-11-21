const puppeteer = require('puppeteer')
const { Before, After, Status } = require('@cucumber/cucumber')

Before({ wrapperOptions: { retry: 2 }, timeout: 30000 }, async function () {
  this.browser = await puppeteer.launch({
    args: [
      '--no-sandbox'
    ]
  })
  this.page = await this.browser.newPage()
  await this.page.setViewport({ width: 1280, height: 720 })
})

After(async function (testCase) {
  if (testCase.result.status === Status.FAILED) {
    const screenShot = await this.page.screenshot({ encoding: 'base64', fullPage: true })
    this.attach(screenShot, 'image/png')
  }
  await this.page.close()
  await this.browser.close()
})
