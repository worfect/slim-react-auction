import { Given } from '@cucumber/cucumber'
import { CustomWorld } from '../world'

Given('I am a guest user', () => null)

Given('I am a user', async function (this: CustomWorld) {
  if (!this.page) {
    throw new Error('Page is undefined')
  }
  await this.page.evaluateOnNewDocument(() => {
    localStorage.setItem('auth.tokens', JSON.stringify({
      accessToken:
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiJmcm9udGVuZCIsImp0aSI6ImExZmY5NTBkYmEzNDdiMjE4M2NiN2E5MjM3ZWM1ZTg4MmNiOGI4NmZhOTllNTMxNmM2ODMyOTNhNmY4NWRmZjBlNjQ3OTFlNGUwZmNhZWY4IiwiaWF0IjoxNjUzMDY5MjM2LjQ3NTU3NSwibmJmIjoxNjUzMDY5MjM2LjQ3NTU4LCJleHAiOjMzMjA5OTc4MDM2LjQ3MjE1LCJzdWIiOiIwMDAwMDAwMC0wMDAwLTAwMDAtMDAwMC0wMDAwMDAwMDAwMDEiLCJzY29wZXMiOlsiY29tbW9uIl0sInJvbGUiOiJ1c2VyIn0.XmsUdkSVaYA5OI3bZsfGS3YqZsbLyUoZRGEZnpHNRGpgHZYfHU9zmmAY06aHTeU1cZ3R0ulIMX08OyJ2fHvBmdFDFDzypt_WD4T_1C6oCKqY-Ar-XZ64KP3z6_4p2D7SzcK_sSSJ4FLuuvDLVfb2ycZ4xEQrlRMfSz0jzyC5xMOKphIirx4CX0i9bWDZ1fcwBWcbyBkFGye81zt6fOvu7ttM1K5fJbmFaRDrPrCqbvKgjdSC0ZX8U4zgGmruMHSoG5OkFHM7SiUQiIh0bGv80ibRJGIzze4N1inomv9EfhVl8g_VVMQwgEcOwBICsAXiNYQZ7AeEC__HMzAUus2GLw',
      expires: new Date().getTime() + 36000000,
      refreshToken: ''
    }))
  })
})
