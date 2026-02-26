# AutoLoginJS

Automatically log in to the BITS Pilani campus Wi-Fi captive portal using Selenium WebDriver.

## Prerequisites

- [Node.js](https://nodejs.org/) (v18+)
- Safari browser with WebDriver enabled
  - Open Safari → **Develop** menu → enable **Allow Remote Automation**
  - If you don't see the Develop menu: Safari → **Settings** → **Advanced** → check **Show features for web developers**

## Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Create Your `.env` File

Create a file named `.env` in the project root with your BITS credentials:

```env
USERNAME="your_bits_id"
PASSWORD="your_password"
```

**Example:**

```env
USERNAME="F20XXXXXX"
PASSWORD="YourPassword123#"
```

> ⚠️ **Do not share or commit this file.** It is already listed in `.gitignore`.

## Usage

Connect to the BITS Wi-Fi network, then run:

```bash
node index.js
```

The script will:

1. Open Safari and navigate to `http://captive.apple.com`
2. Wait for the captive portal redirect
3. Fill in your username and password
4. Click the **Continue** button to log in

## Using a Different Browser

By default the script uses Safari. To use Chrome instead, edit `index.js`:

```diff
- let driver = await new Builder().forBrowser(Browser.SAFARI).build();
+ let driver = await new Builder().forBrowser(Browser.CHROME).build();
```

You will also need to install [ChromeDriver](https://developer.chrome.com/docs/chromedriver) for this to work.
