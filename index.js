require("dotenv").config();
const { Builder, Browser, By, Key, until } = require("selenium-webdriver");

async function AutoLoginHandler() {
  //   let driver = await new Builder().forBrowser(Browser.CHROME).build();
  let driver = await new Builder().forBrowser(Browser.SAFARI).build();

  try {
    await driver.get("http://captive.apple.com");

    let usernameField = await driver.wait(
      until.elementLocated(By.name("username")),
      10000,
    );
    await usernameField.sendKeys(process.env.USERNAME);

    let passwordField = await driver.wait(
      until.elementLocated(By.name("password")),
      10000,
    );
    await passwordField.sendKeys(process.env.PASSWORD);

    await driver.sleep(500);
    let continueBtn = await driver.wait(
      until.elementLocated(By.xpath("//button[@type='submit']")),
      10000,
    );
    await continueBtn.click();
  } catch (err) {
    console.log(err);
  } finally {
    await driver.sleep(500);
    await driver.quit();
  }
}

AutoLoginHandler();
