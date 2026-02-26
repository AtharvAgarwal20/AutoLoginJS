# AutoLoginJS

Automatically log in to the BITS Pilani campus Wi-Fi captive portal using Selenium WebDriver.

Works on **macOS**, **Linux**, and **Windows**.

## Prerequisites

- [Node.js](https://nodejs.org/) (v18+)
- A supported browser:

| OS      | Default Browser | Driver Required                                                |
| ------- | --------------- | -------------------------------------------------------------- |
| macOS   | Safari          | Built-in (just enable it)                                      |
| Linux   | Chrome          | [ChromeDriver](https://developer.chrome.com/docs/chromedriver) |
| Windows | Chrome          | [ChromeDriver](https://developer.chrome.com/docs/chromedriver) |

### macOS — Enable SafariDriver

```bash
safaridriver --enable
```

Also enable: Safari → **Develop** → **Allow Remote Automation**
(If no Develop menu: Safari → **Settings** → **Advanced** → **Show features for web developers**)

### Linux / Windows — Install ChromeDriver

Install [Google Chrome](https://www.google.com/chrome/) and [ChromeDriver](https://developer.chrome.com/docs/chromedriver) matching your Chrome version.

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

### Manual Run

```bash
node index.js
```

The script auto-detects your OS and picks the right browser.

---

### Background Watchdog (Recommended)

The watchdog runs silently in the background, checking every **5 minutes** if your session has expired and automatically re-authenticates.

<details>
<summary><strong>🍎 macOS</strong></summary>

**Start:**

```bash
./start.sh
```

**Stop:**

```bash
./stop.sh
```

Uses macOS **LaunchAgent** — runs at login, no terminal window needed.

</details>

<details>
<summary><strong>🐧 Linux</strong></summary>

**Start:**

```bash
./linux/start.sh
```

**Stop:**

```bash
./linux/stop.sh
```

**Status:**

```bash
sudo systemctl status autologin-watchdog
```

Uses **systemd** — runs as a system service, persists across reboots.

</details>

<details>
<summary><strong>🪟 Windows</strong></summary>

**Start** (run as Administrator):

```bat
windows\start.bat
```

**Stop:**

```bat
windows\stop.bat
```

Uses **Task Scheduler** — runs at logon, hidden in background.

</details>

### Check Logs (all platforms)

```bash
tail -f watchdog.log          # macOS / Linux
Get-Content watchdog.log -Wait # Windows PowerShell
```
