### Fail2ban for Nginx bad bot blocker

You may want to yourself play around with these settings for your usage, but this is what I've done at least.

Warning with the 404s and 403s, you probably do not want them too low or you'll get a bunch of false blocks.

I've added a permaban jail too so can just quick as anything manually ban permanently bad IPs to that jail.

Here's a useful at a glance script for fail2ban which makes fail2ban so much better: https://github.com/Incognify/fail2ban-at-a-glance

I've personally put the script into my /usr/local/bin named as fail2ban.sh.
