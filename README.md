
# enfo.sh

Oh look, another script. This one searches Google, DuckDuckGo, and Bing. Because apparently, you need three search engines to find anything these days.

## What’s the point?

You type something. It spits out links. Sometimes it even works. If it doesn’t, well, that’s life.

## Features (if you can call them that)

- Searches Google, DuckDuckGo, and Bing. All at once. Because more is better, right?
- Batch mode. Feed it a file. Or don’t. I’m not your boss.
- Proxy support. Hide yourself. Or don’t. Again, not my problem.
- Delay and jobs. Go fast, get banned. Go slow, get bored.
- Live preview. Watch results change as you type. Thrilling.
- Automation mode. It’ll just keep guessing random stuff. For science.
- Filtering. Include or exclude words. Because you’re picky.
- Clipboard. First result gets copied. If your system can handle it.
- Logs everything. Even the failures. Especially the failures.

## How to use it

```sh
./enfo.sh -q "something"
./enfo.sh --batch=queries.txt
./enfo.sh --proxy=http://127.0.0.1:8080
./enfo.sh --delay=2 --jobs=4
./enfo.sh --live
./enfo.sh --auto
./enfo.sh --include=foo --exclude=bar
```
Or just run it and type your query. It’ll figure it out. Maybe.

## Config

Open `enfo.conf`. Change stuff if you want. Or don’t. Here’s what it might look like:
```sh
#ENFO_PROXY=http://127.0.0.1:8080
#ENFO_BATCH=queries.txt
#ENFO_DELAY=2
```

## Requirements

- Bash
- python3
- curl
- Clipboard stuff (xclip, xsel, pbcopy, clip). Optional. Don’t ask me for help.

## Startup

Want it to run every time you log in? There are commented-out lines in the script. Uncomment them if you’re feeling brave. Don’t come crying to me if you forget and it keeps running forever.

## Notes

- If Google, Bing, or DuckDuckGo change their site, this will break. Not my fault.
- If you get banned, you probably deserved it.
- Want to add more? Go ahead. It’s Bash. Knock yourself out.

---

If it breaks, blame the search engines. If it works, pretend you wrote it.
