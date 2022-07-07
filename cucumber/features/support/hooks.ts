import puppeteer, { Browser, Page } from 'puppeteer'
import { Before, After, Status } from '@cucumber/cucumber'
import { CustomWorld } from './world'

Before(async function (this: CustomWorld) {
  this.browser = await puppeteer.launch({
    args: [
      '--no-sandbox'
    ]
  })
  this.page = await this.browser.newPage()
  await this.page.setViewport({ width: 1280, height: 720 })
})

After(async function (this: CustomWorld, testCase) {
  if (testCase.result && testCase.result.status === Status.FAILED) {
    if (this.page) {
      const screenShot = await this.page.screenshot({ encoding: 'base64', fullPage: true })
      this.attach(screenShot, 'image/png')
    }
  }
  if (this.page) {
    await this.page.close()
  }
  if (this.browser) {
    await this.browser.close()
  }
})
