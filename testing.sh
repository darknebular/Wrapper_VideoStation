#!/bin/bash

##############################################################
version="SCPT_1.17_BETA"
# Changes:
# SCPT_1.0: Initial release of the automatic installer script for DMS 7.X. (Deprecated migrated to SCPT_1.1)
# SCPT_1.1: To avoid discrepancies and possible deletion of original binaries when there is a previously installed wrapper, an analyzer of other installations has been added. (Deprecated migrated to SCPT_1.2)
# SCPT_1.2: Added a configurator tool for select the codecs. (Deprecated migrated to SCPT_1.3)
# SCPT_1.3: Added a interactive menu when you do not especify any Flag in bash command or you are using basic launch. (Deprecated migrated to SCPT_1.4)
# SCPT_1.4: Fixed a bug: when you select simplest_wrapper with only MP3 2.0 and then try to change the order of the audio codecs you will have a error. (Deprecated migrated to SCPT_1.5)
# SCPT_1.5: Fixed a bug: when you have a low connection to Internet that could have problems. (Deprecated migrated to SCPT_1.6)
# SCPT_1.6: Added a independent audio's streams via DLNA. (Deprecated migrated to SCPT_1.7)
# SCPT_1.7: Added a independent installer for simplest_wrapper in MAIN menu. Added new configuration options in configurator_menu. Now you can change from AAC 512kbps to AC3 640kbps and vice versa. (Deprecated migrated to SCPT_1.8)
# SCPT_1.8: Modify the log file and consolidation with the wrapper itself. Check if the user is using root account. Added the possibility that someone change TransProfiles in VideoStation. Fixed a bucle in old Uninstall process. (Deprecated migrated to SCPT_1.9)
# SCPT_1.9: Modify the compatibility for all 7.x DSMs and not only 7.0 and 7.1. (Deprecated migrated to SCPT_1.10)
# SCPT_1.10: Now the Installer Script is independent of the existence of DLNA Media Server, DLNA MediaServer is a optional package. Now You can see the installation logs and the Wrapper logs in: /tmp/wrapper_ffmpeg.log.(Deprecated migrated to SCPT_1.11)
# SCPT_1.11: Adding the function for checking keys and expand error logs. Minimal changes. Improvements in the Configurator Tool menu when It's launched if you haven't MediaServer Installed. Added a checker of the existence of a licence in AME Package. (Deprecated migrated to SCPT_1.12)
# SCPT_1.12: Now the audio's codecs are independent between VideoStation and Media Station. Added the new wrapper in the installer. (Deprecated migrated to SCPT_1.13)
# SCPT_1.13: Fixed aesthetic flaws in the texts of Configurator Tool Menu. (Deprecated migrated to SCPT_1.14)
# SCPT_1.14: Added two new options in Configurator Tool, now you can change to use an unique audio's stream for low powered devices. (Deprecated migrated to SCPT_1.15)
# SCPT_1.15: Added the new wrapper's version in the installer. (Deprecated migrated to SCPT_1.16)
# SCPT_1.16: Improvement in the Licence checker of the AME. Ensuring that the Installer will only patching DSM 7.0.X and 7.1.X legit. (Deprecated migrated to SCPT_1.17)
# SCPT_1.17: Added Multi-Language Support.

##############################################################


###############################
# VARIABLES
###############################

dsm_version=$(cat /etc.defaults/VERSION | grep productversion | sed 's/productversion=//' | tr -d '"')
repo_url="https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation"
setup="start"
dependencias=("VideoStation" "ffmpeg" "CodecPack")
RED="\u001b[31m"
BLUE="\u001b[36m"
PURPLE="\u001B[35m"
GREEN="\u001b[32m"
YELLOW="\u001b[33m"
injector="0-12.2.4"
vs_path=/var/packages/VideoStation/target
ms_path=/var/packages/MediaServer/target
vs_libsynovte_file="$vs_path/lib/libsynovte.so"
ms_libsynovte_file="$ms_path/lib/libsynovte.so"
cp_bin_path=/var/packages/CodecPack/target/bin
all_files=("$ms_libsynovte_file.orig" "vs_libsynovte_file.orig" "/var/packages/CodecPack/target/bin/ffmpeg41.orig" "/var/packages/CodecPack/target/pack/bin/ffmpeg41.orig" "$ms_path/bin/ffmpeg.orig" "$vs_path/etc/TransProfile.orig" "$vs_path/bin/ffmpeg.orig")
firma="DkNbulDkNbul"
firma2="DkNbular"
declare -i control=0
logfile="/tmp/wrapper_ffmpeg.log"
LANG="0"

###############################
# FUNCIONES
###############################

function log() {
  echo -e  "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1: $2"
}
function info() {
  log "${BLUE}INFO" "${YELLOW}$1"
}
function error() {
  log "${RED}ERROR" "${RED}$1"
}

function restart_packages() {
  
  info "${GREEN}Restarting CodecPack..."
  info "${GREEN}Restarting CodecPack..." >> $logfile
  synopkg restart CodecPack 2>> $logfile
  
  info "${GREEN}Restarting VideoStation..."
  info "${GREEN}Restarting VideoStation..." >> $logfile
  synopkg restart VideoStation 2>> $logfile
  
  
  if [[ -d "$ms_path" ]]; then
  info "${GREEN}Restarting MediaServer..."
  info "${GREEN}Restarting MediaServer..." >> $logfile
  synopkg restart MediaServer 2>> $logfile
  fi

}

function check_dependencias() {
 
 text_ckck_depen2=("You have ALL necessary packages Installed, GOOD." "Tienes TODOS los paquetes necesarios ya instalados, BIEN.")
for dependencia in "${dependencias[@]}"; do
    if [[ ! -d "/var/packages/${dependencia[@]}" ]]; then
      error "MISSING $dependencia Package." 
      error "MISSING $dependencia Package." >> $logfile
    let "npacks=npacks+1"

    fi
done

if [[ npacks -eq control ]]; then
echo -e  "${GREEN}${text_ckck_depen2[$LANG]}"
fi
#else
if [[ npacks -ne control ]]; then
echo -e  "${RED}At least you need $npacks package/s to Install, please Install the dependencies and RE-RUN the Installer again."
exit 1
fi

}
function welcome() {
  echo -e "${YELLOW}FFMPEG WRAPPER INSTALLER version: $version"

  welcome=$(curl -s -L "$repo_url/main/welcome.txt")
  if [ "${#welcome}" -ge 1 ]; then
    echo ""
    echo -e "${GREEN}	$welcome"
    echo ""
  fi
}

function config_A() {
    if [[ "$check_amrif" == "$firma2" ]]; then  
    info "${YELLOW}Changing to use FIRST STREAM= MP3 2.0 256kbpss, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) in VIDEO-STATION."
    info "${YELLOW}Changing to use FIRST STREAM= MP3 2.0 256kbpss, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) in VIDEO-STATION." >> $logfile
    sed -i 's/args2vs+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/args2vs+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac:1" "6" "-ac:2" "$1")/args2vs+=("-ac:1" "$1" "-ac:2" "6")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a:0" "512k" "-b:a:1" "256k")/args2vs+=("-b:a:0" "256k" "-b:a:1" "512k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-c:a:0" "ac3" "-c:a:1" "$1")/args2vs+=("-c:a:0" "$1" "-c:a:1" "ac3")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac:1" "" "-ac:2" "$1")/args2vs+=("-ac:1" "$1" "-ac:2" "")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a:0" "640k" "-b:a:1" "256k")/args2vs+=("-b:a:0" "256k" "-b:a:1" "640k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1")/args2vs+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1" "-map" "0:1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a" "ac3")/args2vs+=("-c:a:0" "$1" "-c:a:1" "ac3")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a" "$1")/args2vs+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a" "libfdk_aac")/args2vs+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-ac" "")/args2vs+=("-ac:1" "$1" "-ac:2" "")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac" "6")/args2vs+=("-ac:1" "$1" "-ac:2" "6")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac" "$1")/args2vs+=("-ac:1" "$1" "-ac:2" "6")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-b:a" "640k")/args2vs+=("-b:a:0" "256k" "-b:a:1" "640k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a" "512k")/args2vs+=("-b:a:0" "256k" "-b:a:1" "512k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a" "256k")/args2vs+=("-b:a:0" "256k" "-b:a:1" "512k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}Sucesfully changed the audio stream's order to: 1) MP3 2.0 256kbps and 2) AAC 5.1 512kbps (or AC3 5.1 640kbps) in VIDEO-STATION."
    echo ""
     info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ===================="
     info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
     exit 1   
    fi
	
	if [[ "$check_amrif" == "$firma" ]]; then  
    info "${YELLOW}Changing to use FIRST STREAM= MP3 2.0 256kbpss, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) in VIDEO-STATION."
    info "${YELLOW}Changing to use FIRST STREAM= MP3 2.0 256kbpss, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) in VIDEO-STATION." >> $logfile
    sed -i 's/args2vs+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/args2vs+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac:1" "6" "-ac:2" "$1")/args2vs+=("-ac:1" "$1" "-ac:2" "6")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a:0" "512k" "-b:a:1" "256k")/args2vs+=("-b:a:0" "256k" "-b:a:1" "512k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-c:a:0" "ac3" "-c:a:1" "$1")/args2vs+=("-c:a:0" "$1" "-c:a:1" "ac3")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac:1" "" "-ac:2" "$1")/args2vs+=("-ac:1" "$1" "-ac:2" "")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a:0" "640k" "-b:a:1" "256k")/args2vs+=("-b:a:0" "256k" "-b:a:1" "640k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1")/args2vs+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1" "-map" "0:1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a" "ac3")/args2vs+=("-c:a:0" "$1" "-c:a:1" "ac3")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a" "$1")/args2vs+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a" "libfdk_aac")/args2vs+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-ac" "")/args2vs+=("-ac:1" "$1" "-ac:2" "")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac" "6")/args2vs+=("-ac:1" "$1" "-ac:2" "6")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac" "$1")/args2vs+=("-ac:1" "$1" "-ac:2" "6")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-b:a" "640k")/args2vs+=("-b:a:0" "256k" "-b:a:1" "640k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a" "512k")/args2vs+=("-b:a:0" "256k" "-b:a:1" "512k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a" "256k")/args2vs+=("-b:a:0" "256k" "-b:a:1" "512k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}Sucesfully changed the audio stream's order to: 1) MP3 2.0 256kbps and 2) AAC 5.1 512kbps (or AC3 5.1 640kbps) in VIDEO-STATION."
    echo ""
   
   else
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything."
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams."
   
   start
   
   fi
}

function config_B() {
if [[ "$check_amrif" == "$firma2" ]]; then  
info "${YELLOW}Changing to use FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps in VIDEO-STATION."
info "${YELLOW}Changing to use FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps in VIDEO-STATION." >> $logfile
    sed -i 's/args2vs+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/args2vs+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac:1" "$1" "-ac:2" "6")/args2vs+=("-ac:1" "6" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a:0" "256k" "-b:a:1" "512k")/args2vs+=("-b:a:0" "512k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-c:a:0" "$1" "-c:a:1" "ac3")/args2vs+=("-c:a:0" "ac3" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac:1" "$1" "-ac:2" "")/args2vs+=("-ac:1" "" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a:0" "256k" "-b:a:1" "640k")/args2vs+=("-b:a:0" "640k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1")/args2vs+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1" "-map" "0:1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a" "ac3")/args2vs+=("-c:a:0" "ac3" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a" "$1")/args2vs+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a" "libfdk_aac")/args2vs+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-ac" "")/args2vs+=("-ac:1" "" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac" "6")/args2vs+=("-ac:1" "6" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac" "$1")/args2vs+=("-ac:1" "6" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-b:a" "640k")/args2vs+=("-b:a:0" "640k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a" "512k")/args2vs+=("-b:a:0" "512k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a" "256k")/args2vs+=("-b:a:0" "512k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}Sucesfully changed the audio stream's order to: 1) AAC 5.1 512kbps (or AC3 5.1 640kbps) and 2) MP3 2.0 256kbps in VIDEO-STATION."
    echo ""
    info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ===================="
    info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
    exit 1   
fi

if [[ "$check_amrif" == "$firma" ]]; then  
    info "${YELLOW}Changing to use FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps in VIDEO-STATION."
    info "${YELLOW}Changing to use FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps in VIDEO-STATION." >> $logfile
    sed -i 's/args2vs+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/args2vs+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac:1" "$1" "-ac:2" "6")/args2vs+=("-ac:1" "6" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a:0" "256k" "-b:a:1" "512k")/args2vs+=("-b:a:0" "512k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-c:a:0" "$1" "-c:a:1" "ac3")/args2vs+=("-c:a:0" "ac3" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac:1" "$1" "-ac:2" "")/args2vs+=("-ac:1" "" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a:0" "256k" "-b:a:1" "640k")/args2vs+=("-b:a:0" "640k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1")/args2vs+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1" "-map" "0:1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a" "ac3")/args2vs+=("-c:a:0" "ac3" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a" "$1")/args2vs+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a" "libfdk_aac")/args2vs+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-ac" "")/args2vs+=("-ac:1" "" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac" "6")/args2vs+=("-ac:1" "6" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac" "$1")/args2vs+=("-ac:1" "6" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-b:a" "640k")/args2vs+=("-b:a:0" "640k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a" "512k")/args2vs+=("-b:a:0" "512k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a" "256k")/args2vs+=("-b:a:0" "512k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}Sucesfully changed the audio stream's order to: 1) AAC 5.1 512kbps (or AC3 5.1 640kbps) and 2) MP3 2.0 256kbps in VIDEO-STATION."
    echo ""
else
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything."
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams."
   
   start
fi
}

function config_C() {
if [[ "$check_amrif" == "$firma2" ]]; then 
info "${YELLOW}Changing the 5.1 audio's codec from AAC 512kbps to AC3 640kbps independently of its audio's streams order in VIDEO-STATION."
info "${YELLOW}Changing the 5.1 audio's codec from AAC 512kbps to AC3 640kbps independently of its audio's streams order in VIDEO-STATION." >> $logfile
    sed -i 's/"libfdk_aac"/"ac3"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/"512k"/"640k"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/"6"/""/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}Sucesfully changed the 5.1 audio's codec from AAC 512kbps to AC3 640kbps in VIDEO-STATION."
    echo ""
    info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ===================="
    info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
    exit 1  
fi

if [[ "$check_amrif" == "$firma" ]]; then  
    info "${YELLOW}Changing the 5.1 audio's codec from AAC 512kbps to AC3 640kbps independently of its audio's streams order in VIDEO-STATION and DLNA MediaServer."
    info "${YELLOW}Changing the 5.1 audio's codec from AAC 512kbps to AC3 640kbps independently of its audio's streams order in VIDEO-STATION and DLNA MediaServer." >> $logfile
    sed -i 's/"libfdk_aac"/"ac3"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/"512k"/"640k"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/"6"/""/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}Sucesfully changed the 5.1 audio's codec from AAC 512kbps to AC3 640kbps in VIDEO-STATION and DLNA MediaServer."
    echo ""
 else
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything."
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams."
   
   start
fi   
}

function config_D() {
if [[ "$check_amrif" == "$firma2" ]]; then 
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED in DLNA MediaServer and this codec Configurator CAN'T change anything."
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED in DLNA MediaServer and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams."
   start
fi

if [[ "$check_amrif" == "$firma" ]]; then  
    info "${YELLOW}Changing to use FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps in DLNA MediaServer."
    info "${YELLOW}Changing to use FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps in DLNA MediaServer." >> $logfile
    sed -i 's/args2vsms+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/args2vsms+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-ac:1" "$1" "-ac:2" "6")/args2vsms+=("-ac:1" "6" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-b:a:0" "256k" "-b:a:1" "512k")/args2vsms+=("-b:a:0" "512k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vsms+=("-c:a:0" "$1" "-c:a:1" "ac3")/args2vsms+=("-c:a:0" "ac3" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-ac:1" "$1" "-ac:2" "")/args2vsms+=("-ac:1" "" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-b:a:0" "256k" "-b:a:1" "640k")/args2vsms+=("-b:a:0" "640k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vsms+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1")/args2vsms+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1" "-map" "0:1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-c:a" "ac3")/args2vsms+=("-c:a:0" "ac3" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-c:a" "$1")/args2vsms+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-c:a" "libfdk_aac")/args2vsms+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vsms+=("-ac" "")/args2vsms+=("-ac:1" "" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-ac" "6")/args2vsms+=("-ac:1" "6" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-ac" "$1")/args2vsms+=("-ac:1" "6" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vsms+=("-b:a" "640k")/args2vsms+=("-b:a:0" "640k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-b:a" "512k")/args2vsms+=("-b:a:0" "512k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-b:a" "256k")/args2vsms+=("-b:a:0" "512k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}Sucesfully changed the audio stream's order to: 1) AAC 5.1 512kbps (or AC3 5.1 640kbps) and 2) MP3 2.0 256kbps in DLNA MediaServer."
    echo ""
else
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything."
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams."
   start
fi	
}

function config_E() {
if [[ "$check_amrif" == "$firma2" ]]; then 
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED in DLNA MediaServer and this codec Configurator CAN'T change anything."
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED in DLNA MediaServer and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams."
   start
fi

if [[ "$check_amrif" == "$firma" ]]; then  
    info "${YELLOW}Changing to use FIRST STREAM= MP3 2.0 256kbpss, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) in DLNA MediaServer."
    info "${YELLOW}Changing to use FIRST STREAM= MP3 2.0 256kbpss, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) in DLNA MediaServer." >> $logfile
    sed -i 's/args2vsms+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/args2vsms+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-ac:1" "6" "-ac:2" "$1")/args2vsms+=("-ac:1" "$1" "-ac:2" "6")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-b:a:0" "512k" "-b:a:1" "256k")/args2vsms+=("-b:a:0" "256k" "-b:a:1" "512k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vsms+=("-c:a:0" "ac3" "-c:a:1" "$1")/args2vsms+=("-c:a:0" "$1" "-c:a:1" "ac3")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-ac:1" "" "-ac:2" "$1")/args2vsms+=("-ac:1" "$1" "-ac:2" "")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-b:a:0" "640k" "-b:a:1" "256k")/args2vsms+=("-b:a:0" "256k" "-b:a:1" "640k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vsms+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1")/args2vsms+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1" "-map" "0:1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-c:a" "ac3")/args2vsms+=("-c:a:0" "$1" "-c:a:1" "ac3")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-c:a" "$1")/args2vsms+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-c:a" "libfdk_aac")/args2vsms+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vsms+=("-ac" "")/args2vsms+=("-ac:1" "$1" "-ac:2" "")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-ac" "6")/args2vsms+=("-ac:1" "$1" "-ac:2" "6")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-ac" "$1")/args2vsms+=("-ac:1" "$1" "-ac:2" "6")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vsms+=("-b:a" "640k")/args2vsms+=("-b:a:0" "256k" "-b:a:1" "640k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-b:a" "512k")/args2vsms+=("-b:a:0" "256k" "-b:a:1" "512k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-b:a" "256k")/args2vsms+=("-b:a:0" "256k" "-b:a:1" "512k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}Sucesfully changed the audio stream's order to: 1) MP3 2.0 256kbps and 2) AAC 5.1 512kbps (or AC3 5.1 640kbps) in DLNA MediaServer."
    echo ""
else
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything."
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams."
   start
fi	
}

function config_F() {
if [[ "$check_amrif" == "$firma2" ]]; then 
info "${YELLOW}Changing the 5.1 audio's codec from AC3 640kbps to AAC 512kbps independently of its audio's streams order in VIDEO-STATION."
info "${YELLOW}Changing the 5.1 audio's codec from AC3 640kbps to AAC 512kbps independently of its audio's streams order in VIDEO-STATION." >> $logfile
    sed -i 's/"ac3"/"libfdk_aac"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/"640k"/"512k"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/""/"6"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}Sucesfully changed the 5.1 audio's codec from AC3 640kbps to AAC 512kbps in VIDEO-STATION."
    echo ""
    info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ===================="
    info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
    exit 1  
fi

if [[ "$check_amrif" == "$firma" ]]; then  
    info "${YELLOW}Changing the 5.1 audio's codec from AC3 640kbps to AAC 512kbps independently of its audio's streams order in VIDEO-STATION and DLNA MediaServer."
    info "${YELLOW}Changing the 5.1 audio's codec from AC3 640kbps to AAC 512kbps independently of its audio's streams order in VIDEO-STATION and DLNA MediaServer." >> $logfile
    sed -i 's/"ac3"/"libfdk_aac"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/"640k"/"512k"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/""/"6"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}Sucesfully changed the 5.1 audio's codec from AC3 640kbps to AAC 512kbps in VIDEO-STATION and DLNA MediaServer."
    echo ""
 else
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything."
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams."
   start
fi  
}

function config_G() {
if [[ "$check_amrif" == "$firma2" ]]; then 
info "${YELLOW}Changing to use only an Unique Audio's Stream in VIDEO-STATION (the first stream you had selected before) for save the system resources in low powered devices."
info "${YELLOW}Changing to use only an Unique Audio's Stream in VIDEO-STATION (the first stream you had selected before) for save the system resources in low powered devices." >> $logfile
    sed -i 's/args2vs+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1" "-map" "0:1")/args2vs+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/args2vs+=("-c:a" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a:0" "$1" "-c:a:1" "ac3")/args2vs+=("-c:a" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/args2vs+=("-c:a" "libfdk_aac")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a:0" "ac3" "-c:a:1" "$1")/args2vs+=("-c:a" "ac3")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-b:a:0" "256k" "-b:a:1" "512k")/args2vs+=("-b:a" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a:0" "256k" "-b:a:1" "640k")/args2vs+=("-b:a" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a:0" "512k" "-b:a:1" "256")/args2vs+=("-b:a" "512k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a:0" "640k" "-b:a:1" "256")/args2vs+=("-b:a" "640k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-ac:1" "$1" "-ac:2" "6")/args2vs+=("-ac" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac:1" "$1" "-ac:2" "")/args2vs+=("-ac" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac:1" "6" "-ac:2" "$1")/args2vs+=("-ac" "6")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac:1" "" "-ac:2" "$1")/args2vs+=("-ac" "")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}Sucesfully changed to use only an Unique Audio's Stream in VIDEO-STATION (the first stream you had selected before) for save the system resources in low powered devices."
    echo ""
    info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ===================="
    info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
    exit 1  
fi

if [[ "$check_amrif" == "$firma" ]]; then  
info "${YELLOW}Changing to use only an unique Audio's Stream in VIDEO-STATION (the first stream you had selected before) for save the system resources in low powered devices."
info "${YELLOW}Changing to use only an unique Audio's Stream in VIDEO-STATION (the first stream you had selected before) for save the system resources in low powered devices." >> $logfile
    sed -i 's/args2vs+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1" "-map" "0:1")/args2vs+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/args2vs+=("-c:a" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a:0" "$1" "-c:a:1" "ac3")/args2vs+=("-c:a" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/args2vs+=("-c:a" "libfdk_aac")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-c:a:0" "ac3" "-c:a:1" "$1")/args2vs+=("-c:a" "ac3")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-b:a:0" "256k" "-b:a:1" "512k")/args2vs+=("-b:a" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a:0" "256k" "-b:a:1" "640k")/args2vs+=("-b:a" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a:0" "512k" "-b:a:1" "256k")/args2vs+=("-b:a" "512k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-b:a:0" "640k" "-b:a:1" "256k")/args2vs+=("-b:a" "640k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vs+=("-ac:1" "$1" "-ac:2" "6")/args2vs+=("-ac" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac:1" "$1" "-ac:2" "")/args2vs+=("-ac" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac:1" "6" "-ac:2" "$1")/args2vs+=("-ac" "6")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vs+=("-ac:1" "" "-ac:2" "$1")/args2vs+=("-ac" "")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}Sucesfully changed to use only an Unique Audio's Stream in VIDEO-STATION (the first stream you had selected before) for save the system resources in low powered devices."
    echo ""
 else
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything."
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams."
   start
fi  
}

function config_H() {
if [[ "$check_amrif" == "$firma2" ]]; then 
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED in DLNA MediaServer and this codec Configurator CAN'T change anything."
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED in DLNA MediaServer and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams."
   start
fi

if [[ "$check_amrif" == "$firma" ]]; then  
info "${YELLOW}Changing to use only an Unique Audio's Stream in DLNA MediaServer (the first stream you had selected before) for save the system resources in low powered devices."
info "${YELLOW}Changing to use only an Unique Audio's Stream in DLNA MediaServer (the first stream you had selected before) for save the system resources in low powered devices." >> $logfile
    sed -i 's/args2vsms+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1" "-map" "0:1")/args2vsms+=("-i" "pipe:0" "-map" "0:0" "-map" "0:1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vsms+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/args2vsms+=("-c:a" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-c:a:0" "$1" "-c:a:1" "ac3")/args2vsms+=("-c:a" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/args2vsms+=("-c:a" "libfdk_aac")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-c:a:0" "ac3" "-c:a:1" "$1")/args2vsms+=("-c:a" "ac3")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vsms+=("-b:a:0" "256k" "-b:a:1" "512k")/args2vsms+=("-b:a" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-b:a:0" "256k" "-b:a:1" "640k")/args2vsms+=("-b:a" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-b:a:0" "512k" "-b:a:1" "256k")/args2vsms+=("-b:a" "512k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-b:a:0" "640k" "-b:a:1" "256k")/args2vsms+=("-b:a" "640k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    
    sed -i 's/args2vsms+=("-ac:1" "$1" "-ac:2" "6")/args2vsms+=("-ac" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-ac:1" "$1" "-ac:2" "")/args2vsms+=("-ac" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-ac:1" "6" "-ac:2" "$1")/args2vsms+=("-ac" "6")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2vsms+=("-ac:1" "" "-ac:2" "$1")/args2vsms+=("-ac" "")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}Sucesfully changed to use only an Unique Audio's Stream in DLNA MediaServer (the first stream you had selected before) for save the system resources in low powered devices."
    echo ""
 else
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything."
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams."
   start
fi  
}

function start() {
   echo ""   
   echo -e "${YELLOW}THIS IS THE MAIN MENU, PLEASE CHOOSE YOUR SELECTION:"
   echo ""
   echo -e "${BLUE} ( I ) Install the Advanced Wrapper for VideoStation and DLNA MediaServer (If exist). (With 5.1 and 2.0 support, configurable)"
   echo -e "${BLUE} ( S ) Install the Simplest Wrapper for VideoStation and DLNA MediaServer (If exist). (Only 2.0 support, NOT configurable)"
   echo -e "${BLUE} ( U ) Uninstall the Simplest or the Advanced Wrappers for VideoStation and DLNA MediaServer." 
   echo -e "${BLUE} ( C ) Change the config of the Advanced Wrapper for change the audio's codecs in VIDEO-STATION and DLNA."
   echo ""
   echo -e "${PURPLE} ( Z ) EXIT from this Installer."
        while true; do
	echo -e "${GREEN}"
        read -p "Please, What option wish to use? " isucz
        case $isucz in
        [Ii]* ) install;;
        [Ss]* ) install_simple;;
        [Uu]* ) uninstall;;
	[Cc]* ) configurator;;
      	[Zz]* ) exit;;
        * ) echo -e "${YELLOW}Please answer I or Install | S or Simple | U or Uninstall | C or Config | Z for Exit.";;
        esac
        done
}

function titulo() {
   clear
echo -e "${BLUE}====================FFMPEG WRAPPER INSTALLER FOR DSM 7.0 and above by Dark Nebular.===================="
echo -e "${BLUE}====================This Wrapper Installer is only avalaible for DSM 7.0 and above only===================="
echo ""
echo ""
}

function check_root() {
   if [[ $EUID -ne 0 ]]; then
  error "YOU MUST BE ROOT FOR EXECUTE THIS INSTALLER. Please write ("${PURPLE}" sudo -i "${RED}") and try again with the Installer."
  exit 1
fi
}

function check_licence_AME() {
if [[ ! -f /usr/syno/etc/codec/activation.conf ]]; then
error "YOU HAVEN'T THE LICENCE LOADED in Advanced Media Extension package. Please, LOAD this licence and try again with the Installer."
error "YOU HAVEN'T THE LICENCE LOADED in Advanced Media Extension package. Please, LOAD this licence and try again with the Installer." >> $logfile
exit 1
fi
}

function check_versions() {

if [[ "$dsm_version" == 7.0* ]]; then
cp_bin_path=/var/packages/CodecPack/target/bin
  injector="0-12.2.4"
fi

if [[ "$dsm_version" == 7.1* ]]; then
cp_bin_path=/var/packages/CodecPack/target/pack/bin
  injector="1-12.3.5"
else
error "Your DSM Version $dsm_version is NOT SUPPORTED using this Installer. Please use the MANUAL Procedure."
error "Your DSM Version $dsm_version is NOT SUPPORTED using this Installer. Please use the MANUAL Procedure." >> $logfile
 exit 1
fi
}

function check_firmas() {
  
# CHEQUEOS DE FIRMAS
if [[ -f "$cp_bin_path/ffmpeg41.orig" ]]; then
check_amrif_1=$(sed -n '3p' < $cp_bin_path/ffmpeg41 | tr -d "# " | tr -d "\´sAdvancedWrapper")
fi

if [[ -f "$ms_path/bin/ffmpeg.KEY" ]]; then
check_amrif_2=$(sed -n '1p' < $ms_path/bin/ffmpeg.KEY | tr -d "# " | tr -d "\´sAdvancedWrapper")
else
check_amrif_2="ar"
fi

check_amrif="$check_amrif_1$check_amrif_2"

}


################################
# PROCEDIMIENTOS DEL PATCH
################################

function install() {
  
  info "${BLUE}==================== Installation of the Advanced Wrapper: START ===================="
  info "${BLUE}==================== Installation of the Advanced Wrapper: START ====================" >> $logfile
  echo ""
   info "${BLUE}You are running DSM $dsm_version"
   info "${BLUE}DSM $dsm_version is supported for this installer and the installer will tuned for your DSM"
   info "${BLUE}DSM $dsm_version is using this path: $cp_bin_path"
   info "${BLUE}DSM $dsm_version is using this injector: $injector"

for losorig in "${all_files[@]}"; do
if [[ -f "$losorig" ]]; then
        info "${RED}Actually you have a OLD or OTHER patch applied in your system, please UNINSTALL OLDER Wrapper first."
        info "${RED}Actually you have a OLD or OTHER patch applied in your system, please UNINSTALL OLDER Wrapper first." >> $logfile
	echo ""
	echo -e "${BLUE} ( YES ) = The Installer will Uninstall the OLD patch or Wrapper."
        echo -e "${PURPLE} ( NO ) = EXIT from the Installer menu and return to MAIN MENU."
        while true; do
	echo -e "${GREEN}"
        read -p "Do you wish to Uninstall this OLD wrapper? " yn
        case $yn in
        [Yy]* ) uninstall_old; break;;
        [Nn]* ) start;;
        * ) echo -e "${YELLOW}Please answer YES = (Uninstall the OLD wrapper) or NO = (Return to MAIN Menu).";;
        esac
        done
else
  
	  info "${YELLOW}Backup the original ffmpeg41 as ffmpeg41.orig."
	  info "${YELLOW}Backup the original ffmpeg41 as ffmpeg41.orig." >> $logfile
	mv -n ${cp_bin_path}/ffmpeg41 ${cp_bin_path}/ffmpeg41.orig 2>> $logfile
	  info "${YELLOW}Creating the esqueleton of the ffmpeg41"
	touch ${cp_bin_path}/ffmpeg41
	  info "${YELLOW}Injection of the ffmpeg41 wrapper using this injector: $injector."
	  info "${YELLOW}Injection of the ffmpeg41 wrapper using this injector: $injector." >> $logfile
	wget -q $repo_url/main/ffmpeg41-wrapper-DSM7_$injector -O ${cp_bin_path}/ffmpeg41 2>> $logfile
	 info "${GREEN}Waiting for consolidate the download of the wrapper."
        sleep 3
	  info "${YELLOW}Fixing permissions of the ffmpeg41 wrapper."
	  info "${YELLOW}Fixing permissions of the ffmpeg41 wrapper." >> $logfile
	chmod 755 ${cp_bin_path}/ffmpeg41 2>> $logfile
	info "${GREEN}Ensuring the existence of the new log file wrapper_ffmpeg and its access."
	touch "$logfile"
	chmod 755 "$logfile"
	info "${GREEN}Installed correctly the wrapper41 in $cp_bin_path"
	
	
	
	info "${YELLOW}Backup the original libsynovte.so in VideoStation as libsynovte.so.orig."
	info "${YELLOW}Backup the original libsynovte.so in VideoStation as libsynovte.so.orig." >> $logfile
	cp -n $vs_libsynovte_file $vs_libsynovte_file.orig 2>> $logfile
	  info "${YELLOW}Fixing permissions of $vs_libsynovte_file.orig"
	  info "${YELLOW}Fixing permissions of $vs_libsynovte_file.orig" >> $logfile
	chown VideoStation:VideoStation $vs_libsynovte_file.orig 2>> $logfile
	  info "${YELLOW}Patching $vs_libsynovte_file for compatibility with DTS, EAC3 and TrueHD"
	  info "${YELLOW}Patching $vs_libsynovte_file for compatibility with DTS, EAC3 and TrueHD" >> $logfile
	sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' $vs_libsynovte_file 2>> $logfile
	info "${GREEN}Modified correctly the file $vs_libsynovte_file"
	
	info "${GREEN}Installed correctly the Advanced Wrapper in VideoStation."
	
	break
		
fi
done

if [ ! -f "$ms_path/bin/ffmpeg.KEY" ] && [ -d "$ms_path" ]; then

		info "${YELLOW}Adding of the KEY of this Wrapper in DLNA MediaServer."
		info "${YELLOW}Adding of the KEY of this Wrapper in DLNA MediaServer." >> $logfile
		touch $ms_path/bin/ffmpeg.KEY
		echo -e "# DarkNebular´s Advanced Wrapper" >> $ms_path/bin/ffmpeg.KEY
		info "${GREEN}Installed correctly the Wrapper in $ms_path/bin"
		
		info "${YELLOW}Backup the original libsynovte.so in MediaServer as libsynovte.so.orig."
		info "${YELLOW}Backup the original libsynovte.so in MediaServer as libsynovte.so.orig." >> $logfile
		cp -n $ms_libsynovte_file $ms_libsynovte_file.orig 2>> $logfile
	  info "${YELLOW}Fixing permissions of $ms_libsynovte_file.orig"
	  info "${YELLOW}Fixing permissions of $ms_libsynovte_file.orig" >> $logfile
		chown MediaServer:MediaServer $ms_libsynovte_file.orig 2>> $logfile
		chmod 644 $ms_libsynovte_file.orig 2>> $logfile
	  info "${YELLOW}Patching $ms_libsynovte_file for compatibility with DTS, EAC3 and TrueHD"
	  info "${YELLOW}Patching $ms_libsynovte_file for compatibility with DTS, EAC3 and TrueHD" >> $logfile
		sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' $ms_libsynovte_file 2>> $logfile
		info "${GREEN}Modified correctly the file $ms_libsynovte_file"
		
		info "${GREEN}Installed correctly the Advanced Wrapper in Media Server."
		   
fi

	
restart_packages

info "${BLUE}==================== Installation of the Advanced Wrapper: COMPLETE ===================="
info "${BLUE}==================== Installation of the Advanced Wrapper: COMPLETE ====================" >> $logfile
echo ""   

exit 1
}

function uninstall_old() {
  clear
  info "${BLUE}==================== Uninstallation of OLD wrappers in the system: START ===================="
  info "${BLUE}==================== Uninstallation of OLD wrappers in the system: START ====================" >> $logfile

  info "${YELLOW}Restoring VideoStation's libsynovte.so"
  info "${YELLOW}Restoring VideoStation's libsynovte.so" >> $logfile
  mv -T -f "$vs_libsynovte_file.orig" "$vs_libsynovte_file" 2>> $logfile
  
  
  if [[ -f "$vs_path/etc/TransProfile.orig" ]]; then
  info "${YELLOW}Restoring VideoStation's TransProfile if It has been modified in the past."
  info "${YELLOW}Restoring VideoStation's TransProfile if It has been modified in the past." >> $logfile
  mv -T -f "$vs_path/etc/TransProfile.orig" "$vs_path/etc/TransProfile" 2>> $logfile
  fi
  
  
  if [[ -d "$ms_path" ]]; then
    info "${YELLOW}Restoring MediaServer's libsynovte.so"
    info "${YELLOW}Restoring MediaServer's libsynovte.so" >> $logfile
    mv -T -f "$ms_libsynovte_file.orig" "$ms_libsynovte_file" 2>> $logfile
    
    info "${YELLOW}Remove of the KEY of this Wrapper in DLNA MediaServer."
    info "${YELLOW}Remove of the KEY of this Wrapper in DLNA MediaServer." >> $logfile
    rm $ms_path/bin/ffmpeg.KEY 2>> $logfile
  
    find "$ms_path/bin" -type f -name "*.orig" | while read -r filename; do
    info "${YELLOW}Restoring MediaServer's $filename"
    info "${YELLOW}Restoring MediaServer's $filename" >> $logfile
    mv -T -f "$filename" "${filename::-5}" 2>> $logfile
    done
  fi
  
  find "$vs_path/bin" -type f -name "*.orig" | while read -r filename; do
    info "${YELLOW}Restoring VideoStation's $filename"
    info "${YELLOW}Restoring VideoStation's $filename" >> $logfile
    mv -T -f "$filename" "${filename::-5}" 2>> $logfile
  done
  
  
  find $cp_bin_path -type f -name "*.orig" | while read -r filename; do
      info "Restoring CodecPack's $filename"
      info "Restoring CodecPack's $filename" >> $logfile
      mv -T -f "$filename" "${filename::-5}" 2>> $logfile
  done

   info "${YELLOW}Delete old log file ffmpeg."
   info "${YELLOW}Delete old log file ffmpeg." >> $logfile
   touch /tmp/ffmpeg.log
   rm /tmp/ffmpeg.log
  
     
  info "${GREEN}Uninstalled correctly the old Wrapper"
  echo ""
  info "${BLUE}==================== Uninstallation of OLD wrappers in the system: COMPLETE ===================="
  info "${BLUE}==================== Uninstallation of OLD wrappers in the system: COMPLETE ====================" >> $logfile
  echo ""
  echo ""
  info "${PURPLE}====================CONTINUING With installation of the Advanced Wrapper...===================="
  info "${PURPLE}====================CONTINUING With installation of the Advanced Wrapper...====================" >> $logfile
  echo ""
  
  install
  
}

function uninstall_old_simple() {
  clear
  info "${BLUE}==================== Uninstallation of OLD wrappers in the system: START ===================="
  info "${BLUE}==================== Uninstallation of OLD wrappers in the system: START ====================" >> $logfile

  info "${YELLOW}Restoring VideoStation's libsynovte.so"
  info "${YELLOW}Restoring VideoStation's libsynovte.so" >> $logfile
  mv -T -f "$vs_libsynovte_file.orig" "$vs_libsynovte_file" 2>> $logfile
  
  if [[ -f "$vs_path/etc/TransProfile.orig" ]]; then
  info "${YELLOW}Restoring VideoStation's TransProfile if It has been modified in the past."
  info "${YELLOW}Restoring VideoStation's TransProfile if It has been modified in the past." >> $logfile
  mv -T -f "$vs_path/etc/TransProfile.orig" "$vs_path/etc/TransProfile" 2>> $logfile
  fi
  
  if [[ -d "$ms_path" ]]; then
  info "${YELLOW}Restoring MediaServer's libsynovte.so"
  info "${YELLOW}Restoring MediaServer's libsynovte.so" >> $logfile
  mv -T -f "$ms_libsynovte_file.orig" "$ms_libsynovte_file" 2>> $logfile
  
  info "${YELLOW}Remove of the KEY of this Wrapper in DLNA MediaServer."
    info "${YELLOW}Remove of the KEY of this Wrapper in DLNA MediaServer." >> $logfile
    rm $ms_path/bin/ffmpeg.KEY 2>> $logfile
  
  find "$ms_path/bin" -type f -name "*.orig" | while read -r filename; do
    info "${YELLOW}Restoring MediaServer's $filename"
    info "${YELLOW}Restoring MediaServer's $filename" >> $logfile
    mv -T -f "$filename" "${filename::-5}" 2>> $logfile
  done
  fi


  find "$vs_path/bin" -type f -name "*.orig" | while read -r filename; do
    info "${YELLOW}Restoring VideoStation's $filename"
    info "${YELLOW}Restoring VideoStation's $filename" >> $logfile
    mv -T -f "$filename" "${filename::-5}" 2>> $logfile
  done
  
  

  find $cp_bin_path -type f -name "*.orig" | while read -r filename; do
      info "Restoring CodecPack's $filename"
      info "Restoring CodecPack's $filename" >> $logfile
      mv -T -f "$filename" "${filename::-5}" 2>> $logfile
  done
  
 
   info "${YELLOW}Delete old log file ffmpeg."
   info "${YELLOW}Delete old log file ffmpeg." >> $logfile
   touch /tmp/ffmpeg.log
   rm /tmp/ffmpeg.log
  
    

  info "${GREEN}Uninstalled correctly the old Wrapper"
  echo ""
  info "${BLUE}==================== Uninstallation of OLD wrappers in the system: COMPLETE ===================="
  info "${BLUE}==================== Uninstallation of OLD wrappers in the system: COMPLETE ====================" >> $logfile
  echo ""
  echo ""
  info "${PURPLE}====================CONTINUING With installation of the Simplest Wrapper...===================="
  info "${PURPLE}====================CONTINUING With installation of the Simplest Wrapper...====================" >> $logfile
  echo ""
  
  install_simple
  
}

function uninstall() {
  for losorig in "${all_files[@]}"; do
  if [[ -f "$losorig" ]]; then
  info "${BLUE}==================== Uninstallation the Simplest or the Advanced Wrapper: START ===================="
  
  info "${YELLOW}Restoring VideoStation's libsynovte.so"
  mv -T -f "$vs_libsynovte_file.orig" "$vs_libsynovte_file"
  
  if [[ -d "$ms_path" ]]; then
  info "${YELLOW}Restoring MediaServer's libsynovte.so"
  mv -T -f "$ms_libsynovte_file.orig" "$ms_libsynovte_file"
  
  info "${YELLOW}Remove of the KEY of this Wrapper in DLNA MediaServer."
    info "${YELLOW}Remove of the KEY of this Wrapper in DLNA MediaServer." >> $logfile
    rm $ms_path/bin/ffmpeg.KEY 2>> $logfile
    
       find "$ms_path/bin" -type f -name "*.orig" | while read -r filename; do
       info "${YELLOW}Restoring MediaServer's $filename"
       mv -T -f "$filename" "${filename::-5}"
       done
  fi

      find $cp_bin_path -type f -name "*.orig" | while read -r filename; do
      info "Restoring CodecPack's $filename"
      mv -T -f "$filename" "${filename::-5}"
      done
  info "${YELLOW}Delete new log file wrapper_ffmpeg."
	touch "$logfile"
	rm "$logfile"

  restart_packages
  
  info "${GREEN}Uninstalled correctly the Simplest or the Advanced Wrapper in DLNA MediaServer (If exist) and VideoStation."

  echo ""
  info "${BLUE}==================== Uninstallation the Simplest or the Advanced Wrapper: COMPLETE ===================="
  exit 1
  
  else
  
  info "${RED}Actually You HAVEN'T ANY Wrapper Installed. The Uninstaller CAN'T do anything."
  exit 1
  
  fi
  done
}

function configurator() {
clear

if [[ "$check_amrif" == "$firma2" ]]; then 

        echo ""
        info "${BLUE}==================== Configuration of the Advanced Wrapper: START ===================="
	echo ""
        echo -e "${YELLOW}REMEMBER: If you change the order in VIDEO-STATION you will have ALWAYS AAC 5.1 512kbps (or AC3 5.1 640kbps) in first audio stream and some devices not compatibles with 5.1 neigther multi audio streams like Chromecast will not work"
        echo -e "${GREEN}Now you can change the audio's codec from from AAC 512kbps to AC3 640kbps independently of its audio's streams."
	echo -e "${GREEN}AC3 640kbps has a little bit less quality and worse performance than AAC but is more compatible with LEGACY devices."
	echo -e "${GREEN}Changing the audio stream's order automatically will put again 2 audio Streams."
	echo ""
        echo ""
        echo -e "${YELLOW}THIS IS THE CONFIGURATOR TOOL MENU, PLEASE CHOOSE YOUR SELECTION:"
        echo ""
        echo -e "${BLUE} ( A ) FIRST STREAM= MP3 2.0 256kbpss, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) when It needs to do transcoding in VIDEO-STATION. (DEFAULT ORDER VIDEO-STATION)"
        echo -e "${BLUE} ( B ) FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps when It needs to do transcoding in VIDEO-STATION." 
        echo -e "${YELLOW} ( C ) Change the 5.1 audio's codec from AAC 512kbps to AC3 640kbps independently of its audio's streams order in both."
        echo -e "${RED} ( D ) FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps when It needs to do transcoding in DLNA MediaServer. (DEFAULT ORDER DLNA)"
        echo -e "${RED} ( E ) FIRST STREAM= MP3 2.0 256kbpss, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) when It needs to do transcoding in DLNA MediaServer."
        echo -e "${YELLOW} ( F ) Change the 5.1 audio's codec from AC3 640kbps to AAC 512kbps independently of its audio's streams order in both."
	echo -e "${BLUE} ( G ) Use only an Unique Audio's Stream in VIDEO-STATION (the first stream you had selected before) for save the system resources in low powered devices."
	echo -e "${RED} ( H ) Use only an Unique Audio's Stream in DLNA MediaServer (the first stream you had selected before) for save the system resources in low powered devices."
        echo ""
        echo -e "${PURPLE} ( Z ) RETURN to MAIN menu."
   	while true; do
	echo -e "${GREEN}"
        read -p "Do you wish to change the order of these audio stream in the Advanced wrapper? " abcdefghz
        case $abcdefghz in
        [Aa] ) config_A; break;;
        [Bb] ) config_B; break;;
	[Cc] ) config_C; break;;
	[Dd] ) config_D; break;;
	[Ee] ) config_E; break;;
	[Ff] ) config_F; break;;
	[Gg] ) config_G; break;;
	[Hh] ) config_H; break;;
	[Zz] ) start; break;;
        * ) echo -e "${YELLOW}Please answer with the correct option writing: A or B or C or D or E or F or G or H. Write Z (for return to MAIN menu).";;
        esac
        done
   
   info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ===================="
   info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
   exit 1
fi

if [[ "$check_amrif" == "$firma" ]]; then

        echo ""
        info "${BLUE}==================== Configuration of the Advanced Wrapper: START ===================="
	echo ""
        echo -e "${YELLOW}REMEMBER: If you change the order in VIDEO-STATION you will have ALWAYS AAC 5.1 512kbps (or AC3 5.1 640kbps) in first audio stream and some devices not compatibles with 5.1 neigther multi audio streams like Chromecast will not work"
        echo -e "${GREEN}Now you can change the audio's codec from from AAC 512kbps to AC3 640kbps independently of its audio's streams."
	echo -e "${GREEN}AC3 640kbps has a little bit less quality and worse performance than AAC but is more compatible with LEGACY devices."
	echo -e "${GREEN}Changing the audio stream's order automatically will put again 2 audio Streams."
	echo ""
        echo ""
        echo -e "${YELLOW}THIS IS THE CONFIGURATOR TOOL MENU, PLEASE CHOOSE YOUR SELECTION:"
        echo ""
        echo -e "${BLUE} ( A ) FIRST STREAM= MP3 2.0 256kbpss, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) when It needs to do transcoding in VIDEO-STATION. (DEFAULT ORDER VIDEO-STATION)"
        echo -e "${BLUE} ( B ) FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps when It needs to do transcoding in VIDEO-STATION." 
        echo -e "${BLUE} ( C ) Change the 5.1 audio's codec from AAC 512kbps to AC3 640kbps independently of its audio's streams order in both."
        echo -e "${BLUE} ( D ) FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps when It needs to do transcoding in DLNA MediaServer. (DEFAULT ORDER DLNA)"
        echo -e "${BLUE} ( E ) FIRST STREAM= MP3 2.0 256kbpss, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) when It needs to do transcoding in DLNA MediaServer."
        echo -e "${BLUE} ( F ) Change the 5.1 audio's codec from AC3 640kbps to AAC 512kbps independently of its audio's streams order in both."
	echo -e "${BLUE} ( G ) Use only an Unique Audio's Stream in VIDEO-STATION (the first stream you had selected before) for save the system resources in low powered devices."
	echo -e "${BLUE} ( H ) Use only an Unique Audio's Stream in DLNA MediaServer (the first stream you had selected before) for save the system resources in low powered devices."
        echo ""
        echo -e "${PURPLE} ( Z ) RETURN to MAIN menu."
   	while true; do
	echo -e "${GREEN}"
        read -p "Do you wish to change the order of these audio stream in the Advanced wrapper? " abcdefghz
        case $abcdefghz in
        [Aa] ) config_A; break;;
        [Bb] ) config_B; break;;
	[Cc] ) config_C; break;;
	[Dd] ) config_D; break;;
	[Ee] ) config_E; break;;
	[Ff] ) config_F; break;;
	[Gg] ) config_G; break;;
	[Hh] ) config_H; break;;
	[Zz] ) start; break;;
        * ) echo -e "${YELLOW}Please answer with the correct option writing: A or B or C or D or E or F or G or H. Write Z (for return to MAIN menu).";;
        esac
        done
   
   info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ===================="
   info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
   exit 1

else
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything."
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}Please, Install the Advanced Wrapper first and then you will can change the audio's streams order."
   start
fi


}

function install_simple() {
  
  info "${BLUE}==================== Installation of the Simplest Wrapper: START ===================="
  info "${BLUE}==================== Installation of the Simplest Wrapper: START ====================" >> $logfile
  echo ""
   info "${BLUE}You are running DSM $dsm_version"
   info "${BLUE}DSM $dsm_version is supported for this installer and the installer will tuned for your DSM"
   info "${BLUE}DSM $dsm_version is using this path: $cp_bin_path"
   info "${BLUE}DSM $dsm_version is using this injector: Simple"
   
for losorig in "${all_files[@]}"; do
if [[ -f "$losorig" ]]; then
        info "${RED}Actually you have a OLD or OTHER patch applied in your system, please UNINSTALL OLDER Wrapper first."
        info "${RED}Actually you have a OLD or OTHER patch applied in your system, please UNINSTALL OLDER Wrapper first." >> $logfile
	echo ""
	echo -e "${BLUE} ( YES ) = The Installer will Uninstall the OLD patch or Wrapper."
        echo -e "${PURPLE} ( NO ) = EXIT from the Installer menu and return to MAIN MENU."
        while true; do
	echo -e "${GREEN}"
        read -p "Do you wish to Uninstall this OLD wrapper? " yn
        case $yn in
        [Yy]* ) uninstall_old_simple; break;;
        [Nn]* ) start;;
        * ) echo -e "${YELLOW}Please answer YES = (Uninstall the OLD wrapper) or NO = (Return to MAIN Menu).";;
        esac
        done
else
  
	  info "${YELLOW}Backup the original ffmpeg41 as ffmpeg41.orig."
	  info "${YELLOW}Backup the original ffmpeg41 as ffmpeg41.orig." >> $logfile
    	mv -n ${cp_bin_path}/ffmpeg41 ${cp_bin_path}/ffmpeg41.orig 2>> $logfile
	  info "${YELLOW}Creating the esqueleton of the ffmpeg41"
	touch ${cp_bin_path}/ffmpeg41 
	  info "${YELLOW}Injection of the ffmpeg41 wrapper using this injector: Simplest."
	  info "${YELLOW}Injection of the ffmpeg41 wrapper using this injector: Simplest." >> $logfile
	wget -q $repo_url/main/simplest_wrapper -O ${cp_bin_path}/ffmpeg41 2>> $logfile
	  info "${GREEN}Waiting for consolidate the download of the wrapper."
        sleep 3
	  info "${YELLOW}Fixing permissions of the ffmpeg41 wrapper."
	  info "${YELLOW}Fixing permissions of the ffmpeg41 wrapper." >> $logfile
	chmod 755 ${cp_bin_path}/ffmpeg41 2>> $logfile
	info "${GREEN}Ensuring the existence of the new log file wrapper_ffmpeg and its access."
	touch "$logfile"
	chmod 755 "$logfile"
	info "${GREEN}Installed correctly the wrapper41 in $cp_bin_path"
		
	info "${YELLOW}Backup the original libsynovte.so in VideoStation as libsynovte.so.orig."
	info "${YELLOW}Backup the original libsynovte.so in VideoStation as libsynovte.so.orig." >> $logfile
	cp -n $vs_libsynovte_file $vs_libsynovte_file.orig 2>> $logfile
	  info "${YELLOW}Fixing permissions of $vs_libsynovte_file.orig"
	  info "${YELLOW}Fixing permissions of $vs_libsynovte_file.orig" >> $logfile
	chown VideoStation:VideoStation $vs_libsynovte_file.orig 2>> $logfile
	  info "${YELLOW}Patching $vs_libsynovte_file for compatibility with DTS, EAC3 and TrueHD"
	  info "${YELLOW}Patching $vs_libsynovte_file for compatibility with DTS, EAC3 and TrueHD" >> $logfile
	sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' $vs_libsynovte_file 2>> $logfile
	info "${GREEN}Modified correctly the file $vs_libsynovte_file"
	
	info "${GREEN}Installed correctly the Simplest Wrapper in Video Station."
	
	break
fi
done

if [ ! -f "$ms_path/bin/ffmpeg.KEY" ] && [ -d "$ms_path" ]; then

	info "${YELLOW}Adding of the KEY of this Wrapper in DLNA MediaServer."
	info "${YELLOW}Adding of the KEY of this Wrapper in DLNA MediaServer." >> $logfile
	touch $ms_path/bin/ffmpeg.KEY
	echo -e "# DarkNebular´s Simplest Wrapper" >> $ms_path/bin/ffmpeg.KEY
	info "${GREEN}Installed correctly the Wrapper in $ms_path/bin"
		
	info "${YELLOW}Backup the original libsynovte.so in MediaServer as libsynovte.so.orig."
	info "${YELLOW}Backup the original libsynovte.so in MediaServer as libsynovte.so.orig." >> $logfile
	cp -n $ms_libsynovte_file $ms_libsynovte_file.orig 2>> $logfile
	  info "${YELLOW}Fixing permissions of $ms_libsynovte_file.orig"
	  info "${YELLOW}Fixing permissions of $ms_libsynovte_file.orig" >> $logfile
	chown MediaServer:MediaServer $ms_libsynovte_file.orig 2>> $logfile
	chmod 644 $ms_libsynovte_file.orig 2>> $logfile
	  info "${YELLOW}Patching $ms_libsynovte_file for compatibility with DTS, EAC3 and TrueHD"
	  info "${YELLOW}Patching $ms_libsynovte_file for compatibility with DTS, EAC3 and TrueHD" >> $logfile
	sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' $ms_libsynovte_file 2>> $logfile
	info "${GREEN}Modified correctly the file $ms_libsynovte_file"
	
	info "${GREEN}Installed correctly the Simplest Wrapper in Media Server."
   
fi

restart_packages

echo ""
info "${BLUE}==================== Installation of the Simplest Wrapper: COMPLETE ===================="
info "${BLUE}==================== Installation of the Simplest Wrapper: COMPLETE ====================" >> $logfile
exit 1

}

################################
# EJECUCIÓN
################################
while getopts s: flag; do
  case "${flag}" in
    s) setup=${OPTARG};;
    *) echo "usage: $0 [-s install|uninstall|config|info]" >&2; exit 1;;
  esac
done

titulo

check_root

welcome

check_dependencias

check_licence_AME

check_versions

check_firmas


case "$setup" in
  start) start;;
  install) install;;
  uninstall) uninstall;;
  config) configurator;;
  info) exit 1;;
esac
