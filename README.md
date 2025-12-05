---

## Automatic Startup (Linux & Mac)

To run enfo.sh automatically at login, add this line to your shell profile:

```sh
# Uncomment to run enfo.sh at login (Linux/Mac):
# bash ~/Desktop/Projects/enfo/enfo.sh &
```

For more control (Linux):
- Create a systemd user service:
  1. Create `~/.config/systemd/user/enfo.service` with:
	  ```ini
	  [Unit]
	  Description=Enfo Search Script
	  [Service]
	  ExecStart=/usr/bin/bash /home/youruser/Desktop/Projects/enfo/enfo.sh
	  [Install]
	  WantedBy=default.target
	  ```
  2. Enable with:
	  ```sh
	  systemctl --user enable enfo
	  systemctl --user start enfo
	  ```

On Mac, you can also use Automator or launchd for background startup.
---

## Automatic Startup

Ready-to-use setup commands for automatic startup are included (commented out) in `enfo.sh`:

- **Windows:** PowerShell command for registry Run key
- **Linux/Mac:** Shell profile line and systemd user service
- **Mac:** Use launchd or Automator

Uncomment and use the relevant section in `enfo.sh` to enable automatic startup for your platform. See script comments for details.
# enfo.sh

> Advanced CLI Dorking & Search Automation Tool

**enfo.sh** is a powerful, minimal-dependency Bash script for advanced search (dorking) and automation across Google, DuckDuckGo, and Bing, right from your terminal. It supports batch queries, live preview, automation, proxy, filtering, logging, and more.

---

## Features

- **Multi-Engine Search:** Google, DuckDuckGo, Bing (switches automatically)
- **Batch Mode:** Run multiple queries from a file
- **Proxy Support:** Route requests through a proxy (HTTP/S)
- **Config File:** Set defaults in `enfo.conf` (proxy, batch file, delay, etc.)
- **Delay & Parallel Jobs:** Control speed and safety (avoid bans)
- **Live Preview Mode:** See results update as you type
- **Automation Mode:** Random query generation, parallel jobs, auto-stop on result
- **Result Filtering:** Include/exclude keywords in results
- **Clipboard Integration:** Copies first result to clipboard (supports xclip, xsel, pbcopy, clip)
- **Comprehensive Logging:** All queries and results (including "No results found") logged to `results.log`
- **Short & Long Flags:** Flexible CLI argument parsing
- **Minimal Dependencies:** Only Bash, curl, python3 required
- **Portable:** Works on Linux, macOS, and Windows (with Bash)

---

## Requirements

- Bash
- python3 (for URL encoding)
- curl
- (Optional) xclip, xsel, pbcopy, or clip for clipboard support

---

## Usage

### Basic Search
```sh
./enfo.sh -q "your search"
```
Or just run it and type your query interactively.

### Batch Mode
```sh
./enfo.sh --batch=queries.txt
```
Runs all queries in `queries.txt` (one per line).

### Proxy
```sh
./enfo.sh --proxy=http://127.0.0.1:8080
```
Or set `ENFO_PROXY` in `enfo.conf`.

### Delay & Parallel Jobs
```sh
./enfo.sh --delay=2 --jobs=4
```
Delay (seconds) between queries. Jobs = parallel workers (automation mode).

### Live Preview Mode
```sh
./enfo.sh --live
```
Results update after every keystroke.

### Automation Mode
```sh
./enfo.sh --auto
```
Random queries, parallel jobs, stops on first result.

### Filtering
```sh
./enfo.sh --include=keyword --exclude=otherword
```
Only show results containing/excluding keywords.

### Clipboard
First result is copied to clipboard if supported.

### Logging
All queries and results are logged to `results.log`.

---

## Configuration

Edit `enfo.conf` to set defaults:
```sh
#ENFO_PROXY=http://127.0.0.1:8080
#ENFO_BATCH=queries.txt
#ENFO_DELAY=2
```

---

## Notes

- If search engines change their HTML, result parsing may break. Update patterns as needed.
- Use delay and jobs settings carefully to avoid bans.
- Script is modular and easy to extend.

---

If it breaks, blame the search engines. If it works, pretend you wrote it.
