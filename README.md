## Nginx Bad Bot and User-Agent Blocker, customised for fedi instances, and made more tor friendly.

* Hosted with Forgejo: https://git.wolfi.ee/jase/nginx-bad-bot-blocker.
* Codeberg Mirror: https://codeberg.org/jasewolf/nginx-bad-bot-blocker-mirror.
* Forked from: https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker.
* Also mirrored on [Github](https://github.com/jwbjnwolf/nginx-bad-bot-blocker), but please github users of this fork, migrate to using either Codeberg or Forgejo.

#### The default configuration for this blocker interferes with fedi software, such as Mastodon/GoToSocial from federating correctly.
#### It also blocks a lot of Tor exit nodes as a result of them getting caught up in bad traffic.

## Problem:
- The `deny.conf` behavior of blocking dot file/folder requests doesn't exclude `.well-known`, that fedi software needs to crawl to federate properly.
- The `deny.conf` behavior also blocks image hotlinking, which breaks fedi software.
- The `globalblacklist.conf` user-agent blocklist includes a lot of keywords that are, or may, be part of many fedi instance domains, which are included in user-agents by said software when they crawl other instances, causing instances to be falsely blocked.
- Many tor exit node IPs get caught up in bad traffic, reported to AbuseIPDB in overwhelming numbers and end up in the `globalblacklist.conf` list as a result. There's only a finite amount of these nodes so even one block can be very noticable as a Tor user, and needing to refresh the exit node as a result, which isn't optimal.

## Changes:
- In `deny.conf`, add an exclusion for `.well-known` requests: [Edits](../../../commit/d3459217f2394ac9ed50d1fcac0cd7b323637c7f).
- In `deny.conf`, in order for [Anubis](https://github.com/TecharoHQ/anubis) or [go-away](https://git.gammaspectra.live/git/go-away) to work, add exclusions for `.within-website` and `.git.` requests (not to be confused with `.git`): [Edits](../../../commit/c7cb0d953b4bd617bb1015806c22ff7e2cf9c72c).
- In `deny.conf`, comment out the image hotlinking section so hotlinking isn't prevented: [Edits](../../../commit/13b8798f04dfffd58d9d22224b7ec3e660398da5).
- In `globalblacklist.conf`, comment out problem user-agent keyword blocks so they don't cause false positives: See below for list.
- In `globalblacklist.conf`, changed the very not good bot "AdsBot-Google" to be blocked. ADs can get in the damn bin.
- In `globalblacklist.conf`, added some AI crawler bots to be blocked that aren't currently present.
- Added a bash script to routinely comment out Tor exit node IPs in `globalblacklist.conf` when I sync from upstream.

## How to use this fork instead of upstream:
- Follow instructions for installing files from the [upstream repo](https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/blob/master/MANUAL-CONFIGURATION.md).
- Edit your `deny.conf` file with the changes provided in these two commits as also stated above: [Commit 1](../../../commit/d3459217f2394ac9ed50d1fcac0cd7b323637c7f), [Commit 2](../../../commit/13b8798f04dfffd58d9d22224b7ec3e660398da5).
- If you use Anubis or go-away, edit your `deny.conf` file with the changes provided in this commit as also stated above: [Commit](../../../commit/c7cb0d953b4bd617bb1015806c22ff7e2cf9c72c).
- Edit your `update-ngxblocker` updater script to point to the configuration hosted here: [Edits](../../../commit/cc16f568bf61b14d1ce0080fe4635595cd1d9a4c).
- Alternatively, point your updater script to the configuration hosted on my Codeberg mirror: [Edits](../../../commit/bf87f7c276cdf4801b54fc2afa606e971ccf4ac4).

## Important `deny.conf` notes:
- **Self hosted Git Repos**:
  - Please ensure you do not include the `deny.conf` in any server blocks or location blocks for git repositories such as Forgejo to ensure the repos function as intended. Using it with a git repo that has dotFiles for example will result in the dot files in the repo being inaccessible.
- **Proof of Work challenge AI bot blockers**:
  - You can and I do recommend to use this blocker as a first layor of defence before proxying through proof of work challenge AI bot blockers such as [Anubis](https://github.com/TecharoHQ/anubis) or [go-away](https://git.gammaspectra.live/git/go-away). But like stated above, you will need to make changes to your `deny.conf` since the challenge makes use of dotFolders. Anubis uses `<path>/.within.website`, and go-away uses `<path>/.well-known/.git.gammaspectra.live`. Please note that other proof of work challenge blockers haven't been tested against so you need to use caution if you don't use either of these. Though if one uses `<path>/.git.<something>` for it's challenge then it'll work.
  

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
- Omgilibot,
- WellKnownBot.
```
