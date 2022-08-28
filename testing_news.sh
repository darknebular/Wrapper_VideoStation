#!/bin/bash

version="SCPT_1.8"
# Changes:
# SCPT_1.0: Initial release of the automatic installer script for DMS 7.X. (Deprecated migrated to SCPT_1.1)
# SCPT_1.1: To avoid discrepancies and possible deletion of original binaries when there is a previously installed wrapper, an analyzer of other installations has been added. (Deprecated migrated to SCPT_1.2)
# SCPT_1.2: Added a configurator tool for select the codecs. (Deprecated migrated to SCPT_1.3)
# SCPT_1.3: Added a interactive menu when you do not especify any Flag in bash command or you are using basic launch. (Deprecated migrated to SCPT_1.4)
# SCPT_1.4: Fixed a bug: when you select simplest_wrapper with only MP3 2.0 and then try to change the order of the audio codecs you will have a error. (Deprecated migrated to SCPT_1.5)
# SCPT_1.5: Fixed a bug: when you have a low connection to Internet that could have problems. (Deprecated migrated to SCPT_1.6)
# SCPT_1.6: Added a independent audio's streams for DLNA. (Deprecated migrated to SCPT_1.7)
# SCPT_1.7: Added a independent installer for simplest_wrapper in MAIN menu. Added new configuration options in configurator_menu. Now you can change from AAC 512kbps to AC3 640kbps and vice versa. (Deprecated migrated to SCPT_1.8)
# SCPT_1.8: Added a logging of the Installation's process and consolidate with the wrapper itself. Check if the user is using root account. Added the possibility that someone change TransProfiles in VideoStation.

###############################
# VARIABLES
###############################

# dsm_version=$(cat /etc.defaults/VERSION | grep productversion | sed 's/productversion=//' | tr -d '"')
repo_url="https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation"
setup="start"
dependencias=("VideoStation" "ffmpeg" "CodecPack" "MediaServer")
RED="\u001b[31m"
BLUE="\u001b[36m"
PURPLE="\u001B[35m"
GREEN="\u001b[32m"
YELLOW="\u001b[33m"
supported_versions=("7.0" "7.1")
injector="1-12.3.3"

