#!/bin/bash
##############################################################################                                                                
#       _  __     _                                                          #
#      / |/ /__ _(_)__ __ __                                                 #
#     /    / _ `/ / _ \\ \ /                                                 #
#    /_/|_/\_, /_/_//_/_\_\                                                  #
#       __/___/      __   ___       __     ___  __         __                #
#      / _ )___ ____/ /  / _ )___  / /_   / _ )/ /__  ____/ /_____ ____      #
#     / _  / _ `/ _  /  / _  / _ \/ __/  / _  / / _ \/ __/  '_/ -_) __/      #
#    /____/\_,_/\_,_/  /____/\___/\__/  /____/_/\___/\__/_/\_\\__/_/         #
#                                                                            #
##############################################################################

#### Ensure are on dev branch
git checkout dev
####

echo "Creating blocklist. Please hold."

### File variables
###################################################
    ### Template
    TemplateFile="./_compiling/globalblacklist-nginx.template"
    TempFile="./_compiling/globalblacklist-nginx.tmp"
    OutputFile="./conf.d/globalblacklist.conf"
    BuildFile="./_compiling/buildnumber.nginx"
    cp $TemplateFile $TempFile
    ### Lists
    AllowedBots="./_generator_lists/allowed-user-agents.list"
    BadIPs="./_generator_lists/bad-ip-addresses.list"
    BadReferrers="./_generator_lists/bad-referrers.list"
        BadReferrersRegex="./_compiling/referrers-regex-format-nginx.txt"
    BadBots="./_generator_lists/bad-user-agents.list"
    BingIPs="./_generator_lists/bing-ip-ranges.list"
    BunnyIPs="./_generator_lists/bunnycdn-net.list"
    CloudflareIPs="./_generator_lists/cloudflare-ip-ranges.list"
    FakeGoogleIPs="./_generator_lists/fake-googlebots.list"
    GoodBots="./_generator_lists/good-user-agents.list"
    GoogleIPs="./_generator_lists/google-ip-ranges.list"
    LimitedBots="./_generator_lists/limited-user-agents.list"
    NibblerIPs="./_generator_lists/nibbler-seo.list"
    SEOIPs="./_generator_lists/seo-analysis-tools.list"
    WPBotIPs="./_generator_lists/wordpress-theme-detectors.list"
###################################################
### Files

# =============================
# BEGIN SECTION 1 - USER-AGENTS
# =============================
    # --------------------------------------------------
    # BAD UA (User-Agent) Strings That We Block Outright
    # --------------------------------------------------
        BAD_BOTS_LIST=""; sorted_list=$(sort -u "$BadBots")
        while read -r bot; do BAD_BOTS_LIST+="\"~*(?:\\b)$bot(?:\\b)\"		3;\n"; done <<< "$sorted_list"

        # START BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###
        sed -i '' "s|!!!!BAD-BOTS-LIST-HERE!!!!|$BAD_BOTS_LIST|g" "$TempFile"
        # END BAD BOTS ### DO NOT EDIT THIS LINE AT ALL ###
    # --------------------------------------------
    # GOOD UA User-Agent Strings We Know and Trust
    # --------------------------------------------
        GOOD_BOTS_LIST=""; sorted_list=$(sort -u "$GoodBots")
        while read -r bot; do GOOD_BOTS_LIST+="\"~*(?:\\b)$bot(?:\\b)\"		0;\n"; done <<< "$sorted_list"
        ALLOWED_BOTS_LIST=""; sorted_list=$(sort -u "$AllowedBots")
        while read -r bot; do ALLOWED_BOTS_LIST+="\"~*(?:\\b)$bot(?:\\b)\"		1;\n"; done <<< "$sorted_list"
        LIMITED_BOTS_LIST=""; sorted_list=$(sort -u "$LimitedBots")
        while read -r bot; do LIMITED_BOTS_LIST+="\"~*(?:\\b)$bot(?:\\b)\"		2;\n"; done <<< "$sorted_list"

        # START GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###
        sed -i '' "s|!!!!GOOD-BOTS-LIST-HERE!!!!|$GOOD_BOTS_LIST|g" "$TempFile"
        # END GOOD BOTS ### DO NOT EDIT THIS LINE AT ALL ###

        # START ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###
        sed -i '' "s|!!!!ALLOWED-BOTS-LIST-HERE!!!!|$ALLOWED_BOTS_LIST|g" "$TempFile"
        # END ALLOWED BOTS ### DO NOT EDIT THIS LINE AT ALL ###

        # START LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###
        sed -i '' "s|!!!!LIMITED-BOTS-LIST-HERE!!!!|$LIMITED_BOTS_LIST|g" "$TempFile"
        # END LIMITED BOTS ### DO NOT EDIT THIS LINE AT ALL ###
# ===========================
# END SECTION 1 - USER-AGENTS
# ===========================

# =======================================
# BEGIN SECTION 2 - REFERRERS AND DOMAINS
# =======================================
    BAD_REFERRERS_LIST=""
    while IFS= read -r line; do BAD_REFERRERS_LIST+="$(echo "$line" | sed 's/[\/&]/\\&/g')\n"; done < "$BadReferrersRegex"
    BAD_REFERRERS_LIST=${BAD_REFERRERS_LIST%\\n}

    # START BAD REFERRERS ### DO NOT EDIT THIS LINE AT ALL ###
    sed -i '' "s|!!!!BAD-REFERRERS-LIST-HERE!!!!|$BAD_REFERRERS_LIST|g" "$TempFile"
    # END BAD REFERRERS ### DO NOT EDIT THIS LINE AT ALL ###
# =======================================
# END SECTION 2 - REFERRERS AND DOMAINS
# =======================================

# ========================================================================
# BEGIN SECTION 3 - WHITELISTING AND BLACKLISTING IP ADDRESSESE AND RANGES
# ========================================================================
    # ---------
    # Blocking
    # ---------
        FAKE_GOOGLEBOTS_LIST=""; sorted_list=$(sort -u "$FakeGoogleIPs")
        while read -r ip; do FAKE_GOOGLEBOTS_LIST+=$ip"		1;\n"; done <<< "$sorted_list"
        WORDPRESS_BOTS_LIST=""; sorted_list=$(sort -u "$WPBotIPs")
        while read -r ip; do WORDPRESS_BOTS_LIST+=$ip"\n"; done <<< "$sorted_list"
        NIBBLER_LIST=""; sorted_list=$(sort -u "$NibblerIPs")
        while read -r ip; do NIBBLER_LIST+=$ip"		1;\n"; done <<< "$sorted_list"
        SEO_LIST=""; sorted_list=$(sort -u "$SEOIPs")
        while read -r ip; do SEO_LIST+=$ip"		1;\n"; done <<< "$sorted_list"
        BAD_IP_LIST=""; sorted_list=$(sort -u "$BadIPs")
        while read -r ip; do BAD_IP_LIST+=$ip"		1;\n"; done <<< "$sorted_list"

        # START FAKE GOOGLEBOTS ### DO NOT EDIT THIS LINE AT ALL ###
        sed -i '' "s|!!!!FAKE-GOOGLEBOTS-LIST-HERE!!!!|$FAKE_GOOGLEBOTS_LIST|g" "$TempFile"
        # END FAKE GOOGLEBOTS ### DO NOT EDIT THIS LINE AT ALL ###

        # START WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###
        sed -i '' "s|!!!!WORDPRESS-BOTS-LIST-HERE!!!!|$WORDPRESS_BOTS_LIST|g" "$TempFile"
        # END WP THEME DETECTORS ### DO NOT EDIT THIS LINE AT ALL ###

        # START NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###
        sed -i '' "s|!!!!NIBBLER-LIST-HERE!!!!|$NIBBLER_LIST|g" "$TempFile"
        # END NIBBLER ### DO NOT EDIT THIS LINE AT ALL ###

        # START SEO ANALYSIS TOOLS ### DO NOT EDIT THIS LINE AT ALL ###
        sed -i '' "s|!!!!SEO-LIST-HERE!!!!|$SEO_LIST|g" "$TempFile"
        # END SEO ANALYSIS TOOLS ### DO NOT EDIT THIS LINE AT ALL ###

        # START KNOWN BAD IP ADDRESSES ### DO NOT EDIT THIS LINE AT ALL ###
        sed -i '' "s|!!!!BAD-IP-LIST-HERE!!!!|$BAD_IP_LIST|g" "$TempFile"
        # END KNOWN BAD IP ADDRESSES ### DO NOT EDIT THIS LINE AT ALL ###s
    # ---------
    # Allowing
    # ---------
        GOOGLE_IP_LIST=""; sorted_list=$(sort -u "$GoogleIPs")
        while read -r ip; do GOOGLE_IP_LIST+=$ip"		0;\n"; done <<< "$sorted_list"
        BING_IP_LIST=""; sorted_list=$(sort -u "$BingIPs")
        while read -r ip; do BING_IP_LIST+=$ip"		0;\n"; done <<< "$sorted_list"
        CLOUDFLARE_IP_LIST=""; sorted_list=$(sort -u "$CloudflareIPs")
        while read -r ip; do CLOUDFLARE_IP_LIST+=$ip"		0;\n"; done <<< "$sorted_list"
        BUNNY_IP_LIST=""; sorted_list=$(sort -u "$BunnyIPs")
        while read -r ip; do BUNNY_IP_LIST+=$ip"		0;\n"; done <<< "$sorted_list"

        # START GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###
        sed -i '' "s|!!!!GOOGLE-IP-LIST-HERE!!!!|$GOOGLE_IP_LIST|g" "$TempFile"
        # END GOOGLE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###

        # START BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###
        sed -i '' "s|!!!!BING-IP-LIST-HERE!!!!|$BING_IP_LIST|g" "$TempFile"
        # END BING IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###

        # START CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###
        sed -i '' "s|!!!!CLOUDFLARE-IP-LIST-HERE!!!!|$CLOUDFLARE_IP_LIST|g" "$TempFile"
        # END CLOUDFLARE IP RANGES ### DO NOT EDIT THIS LINE AT ALL ###

        # START BUNNY.NET CDN ### DO NOT EDIT THIS LINE AT ALL ###
        sed -i '' "s|!!!!BUNNY-IP-LIST-HERE!!!!|$BUNNY_IP_LIST|g" "$TempFile"
        # END BUNNY.NET CDN ### DO NOT EDIT THIS LINE AT ALL ###    
# ========================================================================
# END SECTION 3 - WHITELISTING AND BLACKLISTING IP ADDRESSESE AND RANGES
# ========================================================================

### VERSION INFORMATION #
###################################################
    ##### Variables
    YEAR=$(date +"%Y"); MONTH=$(date +"%m"); _now="$(date)"
    lastbuild=$(cat $BuildFile); thisbuild=$((lastbuild + 1))
    MY_GIT_TAG=V4.${YEAR}.${MONTH}.${thisbuild}
    BAD_REFERRERS=$(wc -l < $BadReferrers | xargs); BAD_BOTS=$(wc -l < $BadBots | xargs)
    #####
    ### Version:
    sed -i '' "s|!!!!build-version-here!!!!|$MY_GIT_TAG|g" "$TempFile"
    ### Updated:
    sed -i '' "s|!!!!update-timedate-here!!!!|$_now|g" "$TempFile"
    ### Bad Referrers Count:
    sed -i '' "s|!!!!bad-referrer-count-here!!!!|$BAD_REFERRERS|g" "$TempFile"
    ### Bad Bot Count:
    sed -i '' "s|!!!!bad-bot-count-here!!!!|$BAD_BOTS|g" "$TempFile"
    ##### Update build file
    echo "$thisbuild" > "$BuildFile"
###################################################
### VERSION INFORMATION ##

### Save the new blocklist
mv $TempFile $OutputFile
echo "Finished creating $MY_GIT_TAG at $_now. Previous build: $lastbuild"
###