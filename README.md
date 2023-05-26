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
- In `deny.conf`, add an exclusion for `.well-known` requests: [Edits](../../../commit/2d4301266801148e763da2ca2f8e981ddd613b88).
- In `deny.conf`, comment out the image hotlinking section so hotlinking isn't prevented: [Edits](../../../commit/286baab6fd8055bb1844c8125c6d84c2c4dc4405).
- In `deny.conf`, if you want to block fedi blocklist scrapers, add a block for `/api/v1/blocks`, `api/v1/instance/domain_blocks` & `/api/v1/peers` requests: [Edits](../../../commit/fc621dc2256618bbc5d17c6bd9f5958b63e60e50).
- In `deny.conf`, block empty/blank user agents. [Edits](../../../commit/8b996be10ce82c88694735677f7237babeedc2e0).
- In `deny.conf`, in order for [Anubis](https://github.com/TecharoHQ/anubis) or [go-away](https://git.gammaspectra.live/git/go-away) to work, add exclusions for `.within-website` and `.git.` requests (not to be confused with `.git`): [Edits](../../../commit/b62dd73bb788de1013219c419c6bb1df9e62fb22).
- In `globalblacklist.conf`, updated the blocklist generating script to remove problem user-agent keyword blocks and matches of any tor exit node IPs (synced from check.torproject.com) so they don't cause false positives. See below for the user agent keyword list that's been removed.
- In `globalblacklist.conf`, changed the very not good bot "AdsBot-Google" to be blocked. ADs can get in the damn bin.
- In `globalblacklist.conf`, added some AI crawler bots to be blocked that aren't currently present.
- In `globalblacklist.conf`, added user agent and referrer blocks from [Oliphant's Unified Tier 0 Blocklist](https://writer.oliphant.social/oliphant/the-oliphant-social-blocklist), because fuck nazis.

## How to use this fork instead of upstream:
- Follow instructions for installing files from the [upstream repo](https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/blob/master/MANUAL-CONFIGURATION.md). Please thooughly ensure you follow them and remember to whitelist your domains.
- Edit your `deny.conf` file with the above listed changes where wanted.
- Edit your `update-ngxblocker` updater script to point to the configuration hosted here: [Edits](../../../commit/1bb0177cd53b24227d1a0b1add70c2c0314c2c35).
- Alternatively, point your updater script to the configuration hosted on my Codeberg mirror: [Edits](../../../commit/ede488b38a15e761cf431220fab8c5da117146a1).
- Want a 70k IP blocklist instead of the standard 10k list provided by abuseIPDB? Point your updater script to my [borestad](https://github.com/borestad/blocklist-abuseipdb) variant of the list: [Edits for Forgejo](../../../commit/97c76c4bdce3f2954261a6d06009537f16f66ab7), [Edits for Codeberg mirror](../../../commit/37636c4753e6a46529962c5ca343ec9160b62f7e).

## Important `deny.conf` notes:
- **Self hosted Git Repos**:<br>
  Please ensure you do not include the `deny.conf` in any server blocks or location blocks for git repositories such as Forgejo to ensure the repos function as intended. Using it with a git repo that has dotFiles for example will result in the dot files in the repo being inaccessible, and same goes for every other denied path.
- **Proof of Work challenge AI bot blockers**:<br>
  You can and I do recommend to use this blocker as a first layor of defence before proxying through proof of work challenge AI bot blockers such as [Anubis](https://github.com/TecharoHQ/anubis) or [go-away](https://git.gammaspectra.live/git/go-away). But like stated above, you will need to make changes to your `deny.conf` since the challenge makes use of dotFolders. Anubis uses `<path>/.within.website`, and go-away uses `<path>/.well-known/.git.gammaspectra.live`. Please note that other proof of work challenge blockers haven't been tested against so you need to use caution if you don't use either of these. Though if one uses `<path>/.git.<something>` for it's challenge then it'll work.

## User-agent Keywords removed:
- See [_generator_lists/allowed-user-agents-fedi.list](_generator_lists/allowed-user-agents-fedi.list) for user agents removed to be fedi friendly.

## Changed "good" user agents to be blocked:
- See [_generator_lists/good-to-bad-user-agents.list](_generator_lists/good-to-bad-user-agents.list) for user agents swapped from "good" to bad.

## Added user agents to be blocked:
- See [_generator_lists/added-bad-user-agents.list](_generator_lists/added-bad-user-agents.list) for added user agents that have been blocked.
- See also [_generator_lists/ai-robots-txt.list](_generator_lists/ai-robots-txt.list) for even more added AI user agents that have been blocked. This list is from [ai.robots.txt](https://github.com/ai-robots-txt/ai.robots.txt).
- Also in user agents and referrer blocklists is [Oliphant's Unified Tier 0 Blocklist](https://writer.oliphant.social/oliphant/the-oliphant-social-blocklist) to block the worst of fedi. See list at [_generator_lists/oliphant_unified_tier0.list](_generator_lists/oliphant_unified_tier0.list).
