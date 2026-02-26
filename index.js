const { Builder, Browser, By, Key } = require("selenium-webdriver");

async function AutoLoginHandler() {
  //   let driver = await new Builder().forBrowser(Browser.CHROME).build();
  let driver = await new Builder().forBrowser(Browser.SAFARI).build();

  try {
    await driver.get("http://captive.apple.com");
    await driver.findElement(By.id("username")).sendKeys("username");
    await driver.findElement(By.name("password")).sendKeys("password");
    // await driver.findElement(By.name("login")).click();
  } catch (err) {
    console.log(err);
  } finally {
    await driver.sleep(5000);
    await driver.quit();
  }
}

AutoLoginHandler();
