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

#### Ensure are on borestad branch
git checkout borestad
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
    ###
    ### Reused files
    BadBots="./_generator_lists/bad-user-agents.list"
    BadReferrers="./_generator_lists/bad-referrers.list"
    Oliphant="./_generator_lists/oliphant_unified_tier0.list"
    ###
###################################################

### Functions
###################################################
    ### User agents & referrers
    generate_list() {
        local list="$1"
        local num="$2"
        local placeholder="$3"
        local tmp
        tmp=$(mktemp) 
        
        sort "$list" | while IFS= read -r line; do escaped_line=${line//./\\.}; echo "\"~*(?:\\b)$escaped_line(?:\\b)\"     $num;" >> "$tmp"; done
        LIST=""; while IFS= read -r line; do LIST+="$(echo "$line" | sed 's/[\/&]/\\&/g')\n"; done < "$tmp"; LIST=${LIST%\\n}
        sed -i '' "s|$placeholder|$LIST|g" "$TempFile"
        rm "$tmp"
    }
    ###
    ### IPs
    generate_list_ips() {
        local list="$1"
        local num="$2"
        local placeholder="$3"
        local tmp
        tmp=$(mktemp)

        sort -u "$list" | while IFS= read -r line; do echo "$line   $num;" >> "$tmp"; done
        sed -i '' "/$placeholder/r $tmp" "$TempFile"; sed -i '' "/$placeholder/d" "$TempFile"
        rm "$tmp"
    }
    generate_list_ips_wp() {
        local list="$1"
        local placeholder="$2"

        sed -i '' "/$placeholder/r $list" "$TempFile"; sed -i '' "/$placeholder/d" "$TempFile"
    }
    ###
###################################################

# =============================
# BEGIN SECTION 1 - USER-AGENTS
# =============================
    # --------------------------------------------------
    # BAD UA (User-Agent) Strings That We Block Outright
    # --------------------------------------------------
        generate_list "$BadBots" 3 "!!!!BAD-BOTS-LIST-HERE!!!!"
        generate_list "$Oliphant" 3 "!!!!OLIPHANT-BAD-BOTS-LIST-HERE!!!!"
    # --------------------------------------------
    # GOOD UA User-Agent Strings We Know and Trust
    # --------------------------------------------
        generate_list "./_generator_lists/good-user-agents.list" 0 "!!!!GOOD-BOTS-LIST-HERE!!!!"
        generate_list "./_generator_lists/allowed-user-agents.list" 1 "!!!!ALLOWED-BOTS-LIST-HERE!!!!"
        generate_list "./_generator_lists/limited-user-agents.list" 2 "!!!!LIMITED-BOTS-LIST-HERE!!!!"
# ===========================
# END SECTION 1 - USER-AGENTS
# ===========================

# =======================================
# BEGIN SECTION 2 - REFERRERS AND DOMAINS
# =======================================
    generate_list "$BadReferrers" 1 "!!!!BAD-REFERRERS-LIST-HERE!!!!"
    generate_list "$Oliphant" 1 "!!!!OLIPHANT-BAD-REFERRERS-LIST-HERE!!!!"
# =======================================
# END SECTION 2 - REFERRERS AND DOMAINS
# =======================================

# ========================================================================
# BEGIN SECTION 3 - WHITELISTING AND BLACKLISTING IP ADDRESSESE AND RANGES
# ========================================================================
    # ---------
    # Blocking
    # ---------
        generate_list_ips "./_generator_lists/fake-googlebots.list" 1 "!!!!FAKE-GOOGLEBOTS-LIST-HERE!!!!"
        generate_list_ips_wp "./_generator_lists/wordpress-theme-detectors.list" "!!!!WORDPRESS-BOTS-LIST-HERE!!!!"
        generate_list_ips "./_generator_lists/nibbler-seo.list" 1 "!!!!NIBBLER-LIST-HERE!!!!"
        generate_list_ips "./_generator_lists/seo-analysis-tools.list" 1 "!!!!SEO-LIST-HERE!!!!"
        generate_list_ips "./_generator_lists/bad-ip-addresses.list" 1 "!!!!BAD-IP-LIST-HERE!!!!"
    # ---------
    # Allowing
    # ---------    
        generate_list_ips "./_generator_lists/google-ip-ranges.list" 0 "!!!!GOOGLE-IP-LIST-HERE!!!!"
        generate_list_ips "./_generator_lists/bing-ip-ranges.list" 0 "!!!!BING-IP-LIST-HERE!!!!"
        generate_list_ips "./_generator_lists/cloudflare-ip-ranges.list" 0 "!!!!CLOUDFLARE-IP-LIST-HERE!!!!"
        generate_list_ips "./_generator_lists/bunnycdn-net.list" 0 "!!!!BUNNY-IP-LIST-HERE!!!!"
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
