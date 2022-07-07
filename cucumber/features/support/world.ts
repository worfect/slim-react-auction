import { World, setDefaultTimeout, setWorldConstructor } from '@cucumber/cucumber'
import { Browser, Page } from 'puppeteer'

setDefaultTimeout(10000)

export class CustomWorld extends World {
  browser: Browser | null = null
  page: Page | null = null;

  [key: string]: any;
}

setWorldConstructor(CustomWorld)
