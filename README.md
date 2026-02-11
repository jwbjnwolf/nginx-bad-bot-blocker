## Nginx Bad Bot and User-Agent Blocker, customised for fedi instances, and made more tor friendly.

* Hosted with Forgejo: https://git.wolfi.ee/jase/nginx-bad-bot-blocker.
* Codeberg Mirror: https://codeberg.org/jasewolf/nginx-bad-bot-blocker-mirror.
* Forked from: https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker.
* Also mirrored on [Github](https://github.com/jwbjnwolf/nginx-bad-bot-blocker), but please github users of this fork, migrate to using either Codeberg or Forgejo.

## Why this fork?
* The default configuration for this blocker interferes with fedi software, such as Mastodon/GoToSocial/IceShrimp/Akkoma from federating correctly.<br>
* It also blocks a lot of Tor exit nodes as a result of them getting caught up in bad traffic.<br>
* This semi hard fork of the project exists to solve this, so it's suitable for fedi admins and people who wish to have their services available to tor users. This is achieved by having a list of keywords for removal, along with retrieving the list of all Tor exit nodes from TorProject to remove matches.<br>
* Also in addition to the above purposes, I've made the  `deny.conf` compatible for running [Anubis](https://github.com/TecharoHQ/anubis) or [go-away](https://git.gammaspectra.live/git/go-away) behind this blocker.<br>
* And lastly, this is a semi hard fork which is able to stay working and updated, even when upstream is broken. I used to just merge and comment out matches. Now I generate the blocklist independantly using the lists provided from upstream, plus my own, and most importantly, retrieve the 10,000 top reported IP list from AbuseIPDB's api directly. You still should use instructions from upstream for installation though.

## Problem:
- The `deny.conf` behavior of blocking dot file/folder requests doesn't exclude `.well-known`, that fedi software needs to crawl to federate properly.
- The `deny.conf` behavior also blocks image hotlinking, which breaks fedi software.
- The `globalblacklist.conf` user-agent blocklist includes a lot of keywords that are, or may, be part of many fedi instance domains, which are included in user-agents by said software when they crawl other instances, causing instances to be falsely blocked.
- Many tor exit node IPs get caught up in bad traffic, reported to AbuseIPDB in overwhelming numbers and end up in the `globalblacklist.conf` list as a result. There's only a finite amount of these nodes so even one block can be very noticable as a Tor user, and needing to refresh the exit node as a result, which isn't optimal.

## Changes:
- In `deny.conf`, add an exclusion for `.well-known` requests: [Edits](../../../commit/3de818248d71e2c03ad3569805f2e209ce9b60c3).
- In `deny.conf`, comment out the image hotlinking section so hotlinking isn't prevented: [Edits](../../../commit/37f484d327bfe9807b5f400d0d8cb1adb9bfd4b5).
- In `deny.conf`, if you want to block fedi blocklist scrapers, add a block for `/api/v1/blocks`, `api/v1/instance/domain_blocks` & `/api/v1/peers` requests: [Edits](../../../commit/045b777b481b56be536f341538050664d72f4f16).
- In `deny.conf`, block empty/blank user agents. [Edits](../../../commit/e4d62f391d2b3d0424027755a0873d7f2679cf2d).
- In `deny.conf`, in order for [Anubis](https://github.com/TecharoHQ/anubis) or [go-away](https://git.gammaspectra.live/git/go-away) to work, add exclusions for `.within-website` and `.git.` requests (not to be confused with `.git`): [Edits](../../../commit/da9669657274ce53f435d9dfad7df1a31016ae07).
- In `globalblacklist.conf`, updated the blocklist generating script to remove problem user-agent keyword blocks and matches of any tor exit node IPs (synced from check.torproject.com) so they don't cause false positives. See below for the user agent keyword list that's been removed.
- In `globalblacklist.conf`, changed the very not good bot "AdsBot-Google" to be blocked. ADs can get in the damn bin.
- In `globalblacklist.conf`, added some AI crawler bots to be blocked that aren't currently present.
- In `globalblacklist.conf`, added user agent and referrer blocks from [Oliphant's Unified Tier 0 Blocklist](https://writer.oliphant.social/oliphant/the-oliphant-social-blocklist), because fuck nazis.

## How to use this fork instead of upstream:
- Follow instructions for installing files from the [upstream repo](https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/blob/master/MANUAL-CONFIGURATION.md).
- Edit your `deny.conf` file with the above listed changes where wanted.
- Edit your `update-ngxblocker` updater script to point to the configuration hosted here: [Edits](../../../commit/d516896054398363a6ec8eb85cc2752afecec42a).
- Alternatively, point your updater script to the configuration hosted on my Codeberg mirror: [Edits](../../../commit/bf87f7c276cdf4801b54fc2afa606e971ccf4ac4).

## Important `deny.conf` notes:
- **Self hosted Git Repos**:
  - Please ensure you do not include the `deny.conf` in any server blocks or location blocks for git repositories such as Forgejo to ensure the repos function as intended. Using it with a git repo that has dotFiles for example will result in the dot files in the repo being inaccessible, and same goes for every other denied path.
- **Proof of Work challenge AI bot blockers**:
  - You can and I do recommend to use this blocker as a first layor of defence before proxying through proof of work challenge AI bot blockers such as [Anubis](https://github.com/TecharoHQ/anubis) or [go-away](https://git.gammaspectra.live/git/go-away). But like stated above, you will need to make changes to your `deny.conf` since the challenge makes use of dotFolders. Anubis uses `<path>/.within.website`, and go-away uses `<path>/.well-known/.git.gammaspectra.live`. Please note that other proof of work challenge blockers haven't been tested against so you need to use caution if you don't use either of these. Though if one uses `<path>/.git.<something>` for it's challenge then it'll work.
  

## User-agent Keywords removed:
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
- Pump,

- Reaper,
- Ripper,

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
- Yak,
- Zade,
- Zeus.
```

## Changed "good" user agents to be blocked:
```
- AdsBot-Google.
```

## Added user agents to be blocked:
```
- Ai[0-9]bot (AI2 Bot & AI2 Bot-Dolma specifically but [0-9] for just incase),
- Bot/Research-Public,
- FediBigData,
- fediblock.manalejandro.com,
- FediList Agent,
- Go-http-client,
- WellKnownBot.

And also AI user agent list from https://github.com/ai-robots-txt/ai.robots.txt
```
