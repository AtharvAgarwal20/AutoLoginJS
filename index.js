require("dotenv").config();
const { Builder, Browser, By, Key, until } = require("selenium-webdriver");
const os = require("os");

function getBrowser() {
  const envBrowser = (process.env.BROWSER || "").toLowerCase();

  if (envBrowser === "chrome") return Browser.CHROME;
  if (envBrowser === "firefox") return Browser.FIREFOX;
  if (envBrowser === "safari") return Browser.SAFARI;

  // Auto-detect: Safari on macOS, Chrome everywhere else
  if (os.platform() === "darwin") return Browser.SAFARI;
  return Browser.CHROME;
}

async function AutoLoginHandler() {
  const browser = getBrowser();
  console.log(`[AutoLoginJS] Browser: ${browser} | OS: ${os.platform()}`);
  let driver = await new Builder().forBrowser(browser).build();

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
