## Nginx Bad Bot and User-Agent Blocker, customised for fedi instances.
#### The default configuration for this blocker interferes with fedi software, such as Mastodon/GoToSocial from federating correctly.

## Problem:
- The `deny.conf` behavior of blocking dot file/folder requests doesn't exclude `.well-known`, that fedi software needs to crawl to federate properly.
- The `deny.conf` behavior also blocks image hotlinking, which breaks fedi software.
- The `globalblacklist.conf` user-agent blocklist includes a lot of keywords that are, or may, be part of many fedi instance domains, which are included in user-agents by said software when they crawl other instances, causing instances to be falsely blocked.

## Changes:
- In `deny.conf`, add an exclusion for `.well-known` requests: [Edits](https://github.com/jwbjnwolf/nginx-bad-bot-blocker/commit/bbc4b2f13b69132e055ab87c30cef82119d7903a).
- In `deny.conf`, comment out the image hotlinking section so hotlinking isn't prevented: [Edits](https://github.com/jwbjnwolf/nginx-bad-bot-blocker/commit/7f80200a183cf2cd72180be381032c23940eb724).
- In `globalblacklist.conf`, comment out problem user-agent keyword blocks so they don't cause false positives: See below for list.
- In `globalblacklist.conf'`, changed the very not good bot "AdsBot-Google" to be blocked. ADs can get in the damn bin.

## User-agent Keywords commented out:
```
- Alligator,
- Anarchie,
- Anarchy,
- Attach,

- BackStreet,
- BackWeb,
- Badass,
- Bandit,
- Bigfoot,
- Blow,
- Bolt,
- Buck,
- Buddy,
- Bullseye,

- Collector,
- Copier,
- Cosmos,
- Crescent,
- Curious,
- Custo,

- Demon,
- Devil,
- Disco,
- Dragonfly,
- Drip,

- Evil,
- FrontPage,
- Fuzz,
- Gopher,

- Harvest,
- Iria,
- Kinza,
- Leap,

- Magnet,
- Mojeek,

- Needle,
- Nibbler,
- Ninja,

- Octopus,
- Obot,
- Pump,

- Reaper,
- Ripper,
- Ripz,

- Screaming,
- Snake,
- Snoopy,
- Spanner,
- Steeler,
- Stripper,
- Sucker,

- TakeOut,
- Teleport,
- TheNomad,
- Titan,
- Twice,

- Webster,
- Whack,
- Whacker,
- Widow,
- Xenu,
- Zade,
- Zeus.
```

## Changed "good" user agents to be blocked:
```
- AdsBot-Google.
```

## Updater script:
- Edit your `update-ngxblocker` updater script to point to the configuration hosted here: [Edits](https://github.com/jwbjnwolf/nginx-bad-bot-blocker/commit/b083e4af2faed92fa14b02c7a64126f739557893).
