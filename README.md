## Nginx Bad Bot and User-Agent Blocker, customised for fedi instances.
#### The default configuration for this blocker interferes with fedi software, such as Mastodon/GoToSocial from federating correctly.

## Problem:
- The `deny.conf` behavior of blocking dot file/folder requests doesn't exclude `.well-known`, that fedi software needs to crawl to federate properly.
- The `globalblacklist.conf` user-agent blocklist includes a lot of keywords that are, or may, be part of many fedi instance domains, which are included in user-agents by said software when they crawl other instances, causing instances to be falsely blocked.

## Changes:
- In `deny.conf`, add an exclusion for `.well-known` requests: [Edits](https://github.com/jwbjnwolf/nginx-bad-bot-blocker/commit/bbc4b2f13b69132e055ab87c30cef82119d7903a).
- In `globalblacklist.conf`, comment out problem user-agent keyword blocks so they don't cause false positives: See below for list.

## User-agent Keywords commented out:
```
```

## Updater script:
- Edit your `update-ngxblocker` updater script to point to the configuration hosted here: [Edits](https://github.com/jwbjnwolf/nginx-bad-bot-blocker/commit/b083e4af2faed92fa14b02c7a64126f739557893)
