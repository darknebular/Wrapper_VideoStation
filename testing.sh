#!/bin/bash

##############################################################
version="SCPT_3.4.RC1.4"
# Changes:
# SCPT_1.X: See these changes in the releases notes in my Repository in Github. (Deprecated)
# SCPT_2.X: See these changes in the releases notes in my Repository in Github. (Deprecated)
# SCPT_3.0: Initial new major Release. Clean the code from last versions. (Deprecated migrated to SCPT_3.1)
# SCPT_3.1: Add compatibility to DSXXX-Play appliances using ffmpeg27. Change the name of the injectors. (Deprecated migrated to SCPT_3.2)
# SCPT_3.2: Reflect the new Wrapper change in the installation script. (Deprecated migrated to SCPT_3.3)
# SCPT_3.3: Support for the new versions of FFMPEG 6.0.X and deprecate the use of ffmpeg 4.X.X. (Deprecated migrated to SCPT_3.4)
# SCPT_3.4: Improvements in checking DSM's versions. Reduced the size of this script using a external file called SCPT_Languages.

##############################################################

###############################
# VARIABLES GLOBALES
###############################

source "/etc/VERSION"
dsm_version=$(cat /etc.defaults/VERSION | grep productversion | sed 's/productversion=//' | tr -d '"')
repo_url="https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation"
setup="start"
dependencias=("VideoStation" "ffmpeg6" "CodecPack")
RED="\u001b[31m"
BLUE="\u001b[36m"
PURPLE="\u001B[35m"
GREEN="\u001b[32m"
YELLOW="\u001b[33m"
injector="0-Advanced"
vs_path=/var/packages/VideoStation/target
ms_path=/var/packages/MediaServer/target
vs_libsynovte_file="$vs_path/lib/libsynovte.so"
ms_libsynovte_file="$ms_path/lib/libsynovte.so"
cp_bin_path=/var/packages/CodecPack/target/bin
firma="DkNbulDkNbul"
firma2="DkNbular"
firma_cp="DkNbul"
declare -i control=0
logfile="/tmp/wrapper_ffmpeg.log"
LANG="0"

###############################
# FICHERO AUXILIAR PARA IDIOMAS
###############################
touch /tmp/SCPT_VAR_Languages
curl -sSL "$repo_url/main/SCPT_VAR_Languages" -o "/tmp/SCPT_VAR_Languages" 2>> $logfile
# Se cargará en la función intro que tiene una espera de 3 segundos para asegurar su descarga.


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
    
  info "${GREEN}${text_restart_1[$LANG]}"
  info "${GREEN}Restarting CodecPack..." >> $logfile
  synopkg restart CodecPack 2>> $logfile
  
  info "${GREEN}${text_restart_2[$LANG]}"
  info "${GREEN}Restarting VideoStation..." >> $logfile
  synopkg restart VideoStation 2>> $logfile
  
  
  if [[ -d "$ms_path" ]]; then
  info "${GREEN}${text_restart_3[$LANG]}"
  info "${GREEN}Restarting MediaServer..." >> $logfile
  synopkg restart MediaServer 2>> $logfile
  fi

}

function check_dependencias() {

for dependencia in "${dependencias[@]}"; do
    if [[ ! -d "/var/packages/${dependencia[@]}" ]]; then
      error "MISSING $dependencia Package." 
      error "MISSING $dependencia Package." >> $logfile
    let "npacks=npacks+1"

    fi
done

if [[ npacks -eq control ]]; then
echo -e  "${GREEN}${text_ckck_depen1[$LANG]}"
fi

if [[ npacks -ne control ]]; then
echo -e  "At least you need $npacks package/s to Install, please Install the dependencies and RE-RUN the Installer again."
rm -f /tmp/SCPT_VAR_Languages
exit 1
fi

}
function intro() {
  clear
  intro=$(curl -s -L "$repo_url/main/intro.txt")
  if [ "${#intro}" -ge 1 ]; then
    echo ""
    echo -e "${PURPLE}	$intro"
    echo ""
  fi
sleep 3
#cat /etc/VERSION >> /tmp/SCPT_VAR_Languages
source "/tmp/SCPT_VAR_Languages"
echo "$major"
echo "$minor"
sleep 5
}
function welcome() {
  echo -e "${YELLOW}${text_welcome_1[$LANG]}"

  welcome=$(curl -s -L "$repo_url/main/texts/welcome_$LANG.txt")
  if [ "${#welcome}" -ge 1 ]; then
    echo ""
    echo -e "${GREEN}	$welcome"
    echo ""
  fi
}
function welcome_config() {
 
  welcome_config=$(curl -s -L "$repo_url/main/texts/welcome_config_$LANG")
  if [ "${#welcome_config}" -ge 1 ]; then
    echo -e "${GREEN}	$welcome_config"
    echo ""
  fi
}

function config_A() {
     
    if [[ "$check_amrif" == "$firma2" ]]; then  
    info "${YELLOW}${text_configA_1[$LANG]}"
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
    info "${GREEN}${text_configA_2[$LANG]}"
    echo ""
     echo -e "${BLUE}${text_configA_3[$LANG]}"
     info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
     rm -f /tmp/SCPT_VAR_Languages
     exit 0   
    fi
	
	if [[ "$check_amrif" == "$firma" ]]; then  
    info "${YELLOW}${text_configA_1[$LANG]}"
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
    info "${GREEN}${text_configA_2[$LANG]}"
    echo ""
   
   else
   info "${RED}${text_configA_4[$LANG]}"
   info "${RED}Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configA_5[$LANG]}"
   
   start
   
   fi
}

function config_B() {

if [[ "$check_amrif" == "$firma2" ]]; then  
info "${YELLOW}${text_configB_1[$LANG]}"
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
    info "${GREEN}${text_configB_2[$LANG]}"
    echo ""
    echo -e "${BLUE}${text_configB_3[$LANG]}"
    info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
    rm -f /tmp/SCPT_VAR_Languages
    exit 0   
fi

if [[ "$check_amrif" == "$firma" ]]; then  
    info "${YELLOW}${text_configB_1[$LANG]}"
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
    info "${GREEN}${text_configB_2[$LANG]}"
    echo ""
else
   info "${RED}${text_configB_4[$LANG]}"
   info "${RED}Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configB_5[$LANG]}"
   
   start
fi
}

function config_C() {

if [[ "$check_amrif" == "$firma2" ]]; then 
info "${YELLOW}${text_configC_1[$LANG]}"
info "${YELLOW}Changing the 5.1 audio codec from AAC to AC3 regardless of the order of its audio streams in VIDEO-STATION." >> $logfile
    sed -i 's/"libfdk_aac"/"ac3"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/"512k"/"640k"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/"6"/""/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}${text_configC_2[$LANG]}"
    echo ""
    echo -e "${BLUE}${text_configC_3[$LANG]}"
    info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
    rm -f /tmp/SCPT_VAR_Languages
    exit 0  
fi

if [[ "$check_amrif" == "$firma" ]]; then  
    info "${YELLOW}${text_configC_6[$LANG]}"
    info "${YELLOW}Changing the 5.1 audio codec from AAC to AC3 regardless of the order of its audio streams in VIDEO-STATION and DLNA MediaServer." >> $logfile
    sed -i 's/"libfdk_aac"/"ac3"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/"512k"/"640k"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/"6"/""/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}${text_configC_7[$LANG]}"
    echo ""
 else
   info "${RED}${text_configC_4[$LANG]}"
   info "${RED}Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configC_5[$LANG]}"
   
   start
fi   
}

function config_D() {

if [[ "$check_amrif" == "$firma2" ]]; then 
   info "${RED}${text_configD_5[$LANG]}"
   info "${RED}Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configD_4[$LANG]}"
   start
fi

if [[ "$check_amrif" == "$firma" ]]; then  
    info "${YELLOW}${text_configD_1[$LANG]}"
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
    info "${GREEN}${text_configD_2[$LANG]}"
    echo ""
else
   info "${RED}${text_configD_3[$LANG]}"
   info "${RED}Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configD_4[$LANG]}"
   start
fi	
}

function config_E() {

if [[ "$check_amrif" == "$firma2" ]]; then 
   info "${RED}${text_configE_5[$LANG]}"
   info "${RED}Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configE_4[$LANG]}"
   start
fi

if [[ "$check_amrif" == "$firma" ]]; then  
    info "${YELLOW}${text_configE_1[$LANG]}"
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
    info "${GREEN}${text_configE_2[$LANG]}"
    echo ""
else
   info "${RED}${text_configE_3[$LANG]}"
   info "${RED}Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configE_4[$LANG]}"
   start
fi	
}

function config_F() {

if [[ "$check_amrif" == "$firma2" ]]; then 
info "${YELLOW}${text_configF_1[$LANG]}"
info "${YELLOW}Changing the 5.1 audio's codec from AC3 640kbps to AAC 512kbps independently of its audio's streams order in VIDEO-STATION." >> $logfile
    sed -i 's/"ac3"/"libfdk_aac"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/"640k"/"512k"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/""/"6"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}${text_configF_2[$LANG]}"
    echo ""
    echo -e "${BLUE}${text_configF_3[$LANG]}"
    info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
    rm -f /tmp/SCPT_VAR_Languages
    exit 0  
fi

if [[ "$check_amrif" == "$firma" ]]; then  
    info "${YELLOW}${text_configF_6[$LANG]}"
    info "${YELLOW}Changing the 5.1 audio's codec from AC3 640kbps to AAC 512kbps independently of its audio's streams order in VIDEO-STATION and DLNA MediaServer." >> $logfile
    sed -i 's/"ac3"/"libfdk_aac"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/"640k"/"512k"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/""/"6"/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}${text_configF_7[$LANG]}"
    echo ""
 else
   info "${RED}${text_configF_4[$LANG]}"
   info "${RED}Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configF_5[$LANG]}"
   start
fi  
}

function config_G() {

if [[ "$check_amrif" == "$firma2" ]]; then 
info "${YELLOW}${text_configG_1[$LANG]}"
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
    info "${GREEN}${text_configG_2[$LANG]}"
    echo ""
    echo -e "${BLUE}${text_configG_3[$LANG]}"
    info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
    rm -f /tmp/SCPT_VAR_Languages
    exit 0  
fi

if [[ "$check_amrif" == "$firma" ]]; then  
info "${YELLOW}${text_configG_1[$LANG]}"
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
    info "${GREEN}${text_configG_2[$LANG]}"
    echo ""
 else
   info "${RED}${text_configG_4[$LANG]}"
   info "${RED}Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configG_5[$LANG]}"
   start
fi  
}

function config_H() {

if [[ "$check_amrif" == "$firma2" ]]; then 
   info "${RED}${text_configH_5[$LANG]}"
   info "${RED}Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configH_4[$LANG]}"
   start
fi

if [[ "$check_amrif" == "$firma" ]]; then  
info "${YELLOW}${text_configH_1[$LANG]}"
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
    info "${GREEN}${text_configH_2[$LANG]}"
    echo ""
 else
   info "${RED}${text_configH_3[$LANG]}"
   info "${RED}Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configH_4[$LANG]}"
   start
fi  
}

function start() {

   echo ""
   echo ""
   echo -e "${YELLOW}${text_start_1[$LANG]}"
   echo ""
   echo -e "${BLUE} ( I ) ${text_start_2[$LANG]}"
   echo -e "${BLUE} ( S ) ${text_start_3[$LANG]}"
   echo -e "${BLUE} ( U ) ${text_start_4[$LANG]}" 
   echo -e "${BLUE} ( C ) ${text_start_5[$LANG]}"
   echo -e "${BLUE} ( L ) ${text_start_6[$LANG]}"
   echo ""
   echo -e "${PURPLE} ( Z ) ${text_start_7[$LANG]}"
        while true; do
	echo -e "${GREEN}"
        read -p "${text_start_8[$LANG]}" isuclz
        case $isuclz in
        [Ii]* ) install_advanced;;
        [Ss]* ) install_simple;;
        [Uu]* ) uninstall_new;;
	[Cc]* ) configurator;;
	[Ll]* ) language;;
      	[Zz]* ) rm -f /tmp/SCPT_VAR_Languages; exit;;
        * ) echo -e "${YELLOW}${text_start_9[$LANG]}";;
        esac
        done
}

function titulo() {
   clear

echo -e "${BLUE}${text_titulo_1[$LANG]}"
echo -e "${BLUE}${text_titulo_2[$LANG]}"
echo ""
echo ""
}

function check_root() {
# NO SE TRADUCE
   if [[ $EUID -ne 0 ]]; then
  error "YOU MUST BE ROOT FOR EXECUTE THIS INSTALLER. Please write ("${PURPLE}" sudo -i "${RED}") and try again with the Installer."
  rm -f /tmp/SCPT_VAR_Languages
  exit 1
fi
}

function check_licence_AME() {
# NO SE TRADUCE
if [[ ! -f /usr/syno/etc/codec/activation.conf ]]; then
error "YOU HAVEN'T THE LICENCE LOADED in Advanced Media Extension package. Please, LOAD this licence and try again with the Installer."
error "YOU HAVEN'T THE LICENCE LOADED in Advanced Media Extension package. Please, LOAD this licence and try again with the Installer." >> $logfile
rm -f /tmp/SCPT_VAR_Languages
exit 1
fi
if grep "false" /usr/syno/etc/codec/activation.conf >> $logfile; then
error "YOU HAVEN'T THE LICENCE LOADED in Advanced Media Extension package. Please, LOAD this licence and try again with the Installer."
error "YOU HAVEN'T THE LICENCE LOADED in Advanced Media Extension package. Please, LOAD this licence and try again with the Installer." >> $logfile
rm -f /tmp/SCPT_VAR_Languages
exit 1
fi
}

function check_versions() {
# NO SE TRADUCE

# Verificar si la majorversion es menor a 7
if [[ "$majorversion" -lt 7 ]]; then
  error "Your DSM Version $majorversion-$minorversion is NOT SUPPORTED using this Installer."
  error "Your DSM Version $majorversion-$minorversion is NOT SUPPORTED using this Installer." >> $logfile
  rm -f /tmp/SCPT_VAR_Languages
  exit 1
fi

# Verificar el valor de minorversion si es igual o mayor a 1
if [[ "$minorversion" > "0" ]]; then
  cp_bin_path=/var/packages/CodecPack/target/pack/bin
  injector="X-Advanced"
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

function language() {
 clear
 
	echo ""
        echo -e "${BLUE}${text_language_5[$LANG]}"
	info "${BLUE}==================== Configuration of the Language in this Installer ====================" >> $logfile
	echo ""
	echo ""
        echo -e "${YELLOW}${text_language_1[$LANG]}"
	echo ""
	echo -e "${BLUE} ( E ) English."
        echo -e "${BLUE} ( C ) Castellano." 
        echo -e "${BLUE} ( P ) Português."
        echo -e "${BLUE} ( F ) Français."
        echo -e "${BLUE} ( D ) Deutsch."
        echo -e "${BLUE} ( I ) Italiano."
	echo -e ""
        echo -e "${PURPLE} ( Z ) ${text_language_2[$LANG]}"
   	while true; do
	echo -e "${GREEN}"
        read -p "${text_language_3[$LANG]}" ecpfdiz
        case $ecpfdiz in
        [Ee]* ) language_E; break;;
        [Cc]* ) language_C; break;;
	[Pp]* ) language_P; break;;
	[Ff]* ) language_F; break;;
	[Dd]* ) language_D; break;;
	[Ii]* ) language_I; break;;
	[Zz]* ) start; break;;
        * ) echo -e "${YELLOW}${text_language_4[$LANG]}";;  
        esac
	done
}

function language_E() {
LANG="0"
echo ""
info "${GREEN}Changed correctly the Language in this Installer to: ENGLISH"
info "${BLUE}==================== Changed the Language in this Installer to: ENGLISH ====================" >> $logfile
sleep 2
clear
titulo
welcome
check_dependencias
check_licence_AME
check_versions
check_firmas
start
}

function language_C() {
LANG="1"
echo ""
info "${GREEN}Cambió correctamente el idioma en este instalador a: CASTELLANO"
info "${BLUE}==================== Changed the Language in this Installer to: SPANISH ====================" >> $logfile
sleep 2
clear
titulo
welcome
check_dependencias
check_licence_AME
check_versions
check_firmas
start
}
function language_P() {
LANG="2"
echo ""
info "${GREEN}Alterado corretamente o Idioma neste Instalador para: PORTUGUÊS"
info "${BLUE}==================== Changed the Language in this Installer to: PORTUGUESE ====================" >> $logfile
sleep 2
clear
titulo
welcome
check_dependencias
check_licence_AME
check_versions
check_firmas
start
}
function language_F() {
LANG="3"
echo ""
info "${GREEN}Changé correctement la langue dans ce programme d'installation en : FRANÇAIS"
info "${BLUE}==================== Changed the Language in this Installer to: FRENCH ====================" >> $logfile
sleep 2
clear
titulo
welcome
check_dependencias
check_licence_AME
check_versions
check_firmas
start
}
function language_D() {
LANG="4"
echo ""
info "${GREEN}Die Sprache in diesem Installer korrekt geändert auf: GERMAN"
info "${BLUE}==================== Changed the Language in this Installer to: GERMAN ====================" >> $logfile
sleep 2
clear
titulo
welcome
check_dependencias
check_licence_AME
check_versions
check_firmas
start
}
function language_I() {
LANG="5"
echo ""
info "${GREEN}Modificata correttamente la Lingua in questo Installer in: ITALIANO"
info "${BLUE}==================== Changed the Language in this Installer to: ITALIAN ====================" >> $logfile
sleep 2
clear
titulo
welcome
check_dependencias
check_licence_AME
check_versions
check_firmas
start
}

function install_simple() {
  mode="Simplest"
  injector="X-Simplest"
  install
}
function install_advanced() {
  mode="Advanced"
  if [[ $setup == autoinstall ]]; then
  # NO SE TRADUCE
  echo -e "${YELLOW}Installer is running in Automatic Mode."
  echo ""
  fi
  install
}
function uninstall_new() {
  unmode="New"
  uninstall
}
function uninstall_old() {
  unmode="Old"
  uninstall
}

################################
# PROCEDIMIENTOS DEL PATCH
################################

function install() {
if [[ "$mode" == "Simplest" ]]; then
text_install_1=("==================== Installation of the Simplest Wrapper: START ====================" "==================== Instalación del Wrapper más Simple: INICIO ====================" "==================== Instalando o wrapper mais simples: START =====================" "==================== Installation de l'encapsuleur le plus simple : DÉMARRER ====================" "==================== Installation des einfachsten Wrappers: START ====================" "===================== Installazione del wrapper più semplice: START ====================")
info "${BLUE}==================== Installation of the Simplest Wrapper: START ====================" >> $logfile
fi

if [[ "$mode" == "Advanced" ]]; then
text_install_1=("==================== Installation of the Advanced Wrapper: START ====================" "==================== Instalación del Advanced Wrapper: INICIO ====================" "==================== Instalando o Wrapper Avançado: START =====================" "==================== Installation de l'encapsuleur avancé : DÉMARRER ====================" "==================== Installation des Advanced Wrappers: START ====================" "===================== Installazione del wrapper avanzato: START ====================")
info "${BLUE}==================== Installation of the Advanced Wrapper: START ====================" >> $logfile
check_versions
fi

   info "${BLUE}${text_install_1[$LANG]}"
   echo ""
   info "${BLUE}${text_install_2[$LANG]}"
   info "${BLUE}${text_install_3[$LANG]}"
   info "${BLUE}${text_install_4[$LANG]}"
   info "${BLUE}${text_install_5[$LANG]}"

if [[ -f "/tmp/wrapper.KEY" ]] && [[ $setup == autoinstall ]]; then
  	uninstall_old
	break
fi

if [[ -f "/tmp/wrapper.KEY" ]]; then

        info "${RED}${text_install_6[$LANG]}"
        info "${RED}Actually you have a OLD or OTHER patch applied in your system, please UNINSTALL OLDER Wrapper first." >> $logfile
	echo ""
	echo -e "${BLUE}${text_install_7[$LANG]}"
        echo -e "${PURPLE}${text_install_8[$LANG]}"
        while true; do
	echo -e "${GREEN}"
        read -p "${text_install_9[$LANG]}" ysojn
	case $ysojn in
	[Yy]* ) uninstall_old; break;;
	[Ss]* ) uninstall_old; break;;
	[Oo]* ) uninstall_old; break;;
	[Jj]* ) uninstall_old; break;;
        [Nn]* ) start;;
        * ) echo -e "${YELLOW}${text_install_10[$LANG]}";;
        esac
        done
else
  
	  info "${YELLOW}${text_install_11[$LANG]}"
	  info "${YELLOW}Backup the original ffmpeg41 as ffmpeg41.orig." >> $logfile
	mv -n ${cp_bin_path}/ffmpeg41 ${cp_bin_path}/ffmpeg41.orig 2>> $logfile
	  info "${YELLOW}${text_install_12[$LANG]}"
	touch ${cp_bin_path}/ffmpeg41
	  info "${YELLOW}${text_install_13[$LANG]}"
	  info "${YELLOW}Injection of the ffmpeg41 wrapper using this injector: $injector." >> $logfile
	wget -q $repo_url/main/ffmpeg41-wrapper-DSM7_$injector -O ${cp_bin_path}/ffmpeg41 2>> $logfile
	 info "${GREEN}${text_install_14[$LANG]}"
        sleep 3
	  info "${YELLOW}${text_install_15[$LANG]}"
	  info "${YELLOW}Fixing permissions of the ffmpeg41 wrapper." >> $logfile
	chmod 755 ${cp_bin_path}/ffmpeg41 2>> $logfile
	info "${GREEN}${text_install_16[$LANG]}"
	touch "$logfile"
	chmod 755 "$logfile"
	info "${GREEN}${text_install_17[$LANG]}"
	info "${YELLOW}${text_install_23[$LANG]}"
	info "${YELLOW}Adding of the KEY of this Wrapper in /tmp." >> $logfile
	touch /tmp/wrapper.KEY
	echo -e "# DarkNebular´s $mode Wrapper" >> /tmp/wrapper.KEY
	info "${GREEN}${text_install_24[$LANG]}"
	
  if [[ -f "${cp_bin_path}/ffmpeg27" ]]; then
  	mv -n ${cp_bin_path}/ffmpeg27 ${cp_bin_path}/ffmpeg27.orig 2>> $logfile
  	ln -s -f ${cp_bin_path}/ffmpeg41 ${cp_bin_path}/ffmpeg27 2>> $logfile
  fi
	
	info "${YELLOW}${text_install_18[$LANG]}"
	info "${YELLOW}Backup the original libsynovte.so in VideoStation as libsynovte.so.orig." >> $logfile
	cp -n $vs_libsynovte_file $vs_libsynovte_file.orig 2>> $logfile
	  info "${YELLOW}${text_install_19[$LANG]}"
	  info "${YELLOW}Fixing permissions of $vs_libsynovte_file.orig" >> $logfile
	chown VideoStation:VideoStation $vs_libsynovte_file.orig 2>> $logfile
	  info "${YELLOW}${text_install_20[$LANG]}"
	  info "${YELLOW}Patching $vs_libsynovte_file for compatibility with DTS, EAC3 and TrueHD" >> $logfile
	sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' $vs_libsynovte_file 2>> $logfile
	info "${GREEN}${text_install_21[$LANG]}"
	
	if [[ "$mode" == "Simplest" ]]; then
	text_install_22=("Installed correctly the Simplest Wrapper in Video Station." "Instalado correctamente el Wrapper más simple en Video Station." "Instalou com sucesso o Wrapper mais simples do Video Station." "Installation réussie du Wrapper le plus simple dans Video Station." "Der einfachste Wrapper wurde erfolgreich in Video Station installiert." "Installato con successo il wrapper più semplice in Video Station.")
	info "${GREEN}${text_install_22[$LANG]}"
	fi
	if [[ "$mode" == "Advanced" ]]; then
	text_install_22=("Installed correctly the Advanced Wrapper in VideoStation." "Instalado correctamente el Wrapper avanzado en Video Station." "Instalou com sucesso o Advanced Wrapper no Video Station." "L'encapsuleur avancé dans Video Station a été installé avec succès." "Der Advanced Wrapper wurde erfolgreich in Video Station installiert." "Installazione riuscita del wrapper avanzato in Video Station.")
	info "${GREEN}${text_install_22[$LANG]}"
	fi
		
fi

if [ ! -f "$ms_path/bin/ffmpeg.KEY" ] && [ -d "$ms_path" ]; then

		info "${YELLOW}${text_install_25[$LANG]}"
		info "${YELLOW}Adding of the KEY of this Wrapper in DLNA MediaServer." >> $logfile
		cp /tmp/wrapper.KEY $ms_path/bin/
		mv $ms_path/bin/wrapper.KEY $ms_path/bin/ffmpeg.KEY
		info "${GREEN}${text_install_26[$LANG]}"
		
		info "${YELLOW}${text_install_27[$LANG]}"
		info "${YELLOW}Backup the original libsynovte.so in MediaServer as libsynovte.so.orig." >> $logfile
		cp -n $ms_libsynovte_file $ms_libsynovte_file.orig 2>> $logfile
	  info "${YELLOW}${text_install_28[$LANG]}"
	  info "${YELLOW}Fixing permissions of $ms_libsynovte_file.orig" >> $logfile
		chown MediaServer:MediaServer $ms_libsynovte_file.orig 2>> $logfile
		chmod 644 $ms_libsynovte_file.orig 2>> $logfile
	  info "${YELLOW}${text_install_29[$LANG]}"
	  info "${YELLOW}Patching $ms_libsynovte_file for compatibility with DTS, EAC3 and TrueHD" >> $logfile
		sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' $ms_libsynovte_file 2>> $logfile
		info "${GREEN}${text_install_31[$LANG]}"
		
		if [[ "$mode" == "Simplest" ]]; then
		text_install_30=("Installed correctly the Simplest Wrapper in Media Server." "Instalado correctamente el Wrapper más simple en Media Server." "Instalou com sucesso o Wrapper mais simples no Media Server." "Installation réussie du Wrapper le plus simple sur Media Server." "Der einfachste Wrapper wurde erfolgreich auf dem Medienserver installiert." "Installato con successo il wrapper più semplice su Media Server.")
		info "${GREEN}${text_install_30[$LANG]}"
		fi
		if [[ "$mode" == "Advanced" ]]; then
		text_install_30=("Installed correctly the Advanced Wrapper in Media Server." "Instalado correctamente el Wrapper avanzado en Media Server." "Instalou com sucesso o Advanced Wrapper no Media Server." "L'encapsuleur avancé dans Media Server a été installé avec succès." "Der Advanced Wrapper wurde erfolgreich in Media Server installiert." "Installazione riuscita del wrapper avanzato in Media Server.")
		info "${GREEN}${text_install_30[$LANG]}"
		fi
		
		   
fi

	
restart_packages

if [[ "$mode" == "Simplest" ]]; then
text_install_22=("==================== Installation of the Simplest Wrapper: COMPLETE ====================" "==================== Instalación del Wrapper más simple: COMPLETADO ====================" "==================== Instalando o Wrapper Mais Simples: COMPLETO =====================" "==================== Installation de l'encapsuleur le plus simple : COMPLET ====================" "==================== Installation des einfachsten Wrappers: VOLLSTÄNDIG ====================" "===================== Installazione del wrapper più semplice: COMPLETO ====================")
info "${BLUE}${text_install_22[$LANG]}"
info "${BLUE}==================== Installation of the Simplest Wrapper: COMPLETE ====================" >> $logfile
echo ""
fi

if [[ "$mode" == "Advanced" ]]; then
text_install_22=("==================== Installation of the Advanced Wrapper: COMPLETE ====================" "==================== Instalación del Wrapper Avanzado: COMPLETADO ====================" "==================== Instalação Avançada do Wrapper: COMPLETA =====================" "==================== Installation de l'encapsuleur avancé : COMPLET ====================" "==================== Installation des Advanced Wrappers: VOLLSTÄNDIG ====================" "===================== Installazione del wrapper avanzato: COMPLETO ====================")
info "${BLUE}${text_install_22[$LANG]}"
info "${BLUE}==================== Installation of the Advanced Wrapper: COMPLETE ====================" >> $logfile
echo ""   
fi

rm -f /tmp/SCPT_VAR_Languages
exit 0
}

function uninstall() {
  if [[ $setup != autoinstall ]]; then
  clear
  fi
  if [ ! -f "/tmp/wrapper.KEY" ] && [ -f "$cp_bin_path/ffmpeg41.orig" ]; then
  touch /tmp/wrapper.KEY
  fi
  
  
if [[ "$unmode" == "Old" ]]; then  
  info "${BLUE}${text_uninstall_1[$LANG]}"
  info "${BLUE}==================== Uninstallation of OLD wrappers in the system: START ====================" >> $logfile

  info "${YELLOW}${text_uninstall_2[$LANG]}"
  info "${YELLOW}Restoring VideoStation's libsynovte.so" >> $logfile
  mv -T -f "$vs_libsynovte_file.orig" "$vs_libsynovte_file" 2>> $logfile
    
  if [[ -f "$vs_path/etc/TransProfile.orig" ]]; then
  info "${YELLOW}${text_uninstall_3[$LANG]}"
  info "${YELLOW}Restoring VideoStation's TransProfile if It has been modified in the past." >> $logfile
  mv -T -f "$vs_path/etc/TransProfile.orig" "$vs_path/etc/TransProfile" 2>> $logfile
  fi
    
  if [[ -d "$ms_path" ]]; then
    info "${YELLOW}${text_uninstall_4[$LANG]}"
    info "${YELLOW}Restoring MediaServer's libsynovte.so" >> $logfile
    mv -T -f "$ms_libsynovte_file.orig" "$ms_libsynovte_file" 2>> $logfile
    
    info "${YELLOW}${text_uninstall_5[$LANG]}"
    info "${YELLOW}Remove of the KEY of this Wrapper in DLNA MediaServer." >> $logfile
    rm $ms_path/bin/ffmpeg.KEY 2>> $logfile
  
    find "$ms_path/bin" -type f -name "*.orig" | while read -r filename; do
    info "${YELLOW}${text_uninstall_6[$LANG]}"
    info "${YELLOW}Restoring MediaServer's $filename" >> $logfile
    mv -T -f "$filename" "${filename::-5}" 2>> $logfile
    done
  fi
	
  find "$vs_path/bin" -type f -name "*.orig" | while read -r filename; do
    info "${YELLOW}${text_uninstall_7[$LANG]}"
    info "${YELLOW}Restoring VideoStation's $filename" >> $logfile
    mv -T -f "$filename" "${filename::-5}" 2>> $logfile
  done
  
  if [[ "$majorversion" -ge 7 && "$minorversion" -ge 1 ]]; then
  # Limpiando la posibilidad de haber instalado otro Wrapper en el path incorrecto en 7.X o futuras.
  find /var/packages/CodecPack/target/bin -type f -name "*.orig" | while read -r filename; do
  text_uninstall_8b=("Restoring CodecPack's link" "Restaurando el link de CodecPack" "Restaurando o CodecPack link" "Restauration de la CodecPack link" "Wiederherstellen der CodecPack link" "Ripristino di CodecPack link")
      info "${YELLOW}${text_uninstall_8b[$LANG]}"
      info "${YELLOW}Restoring CodecPack's link" >> $logfile
      mv -T -f "$filename" "${filename::-5}" 2>> $logfile
  done
  fi
  
  find $cp_bin_path -type f -name "*.orig" | while read -r filename; do
     info "${YELLOW}${text_uninstall_8[$LANG]}"
     info "${YELLOW}Restoring CodecPack's $filename" >> $logfile
     mv -T -f "$filename" "${filename::-5}" 2>> $logfile
  done

   info "${YELLOW}${text_uninstall_9[$LANG]}"
   info "${YELLOW}Delete old log file ffmpeg." >> $logfile
   touch /tmp/ffmpeg.log
   rm /tmp/ffmpeg.log
  
   info "${YELLOW}${text_uninstall_18[$LANG]}"
   info "${YELLOW}Remove of the KEY of this Wrapper in /tmp." >> $logfile
   rm /tmp/wrapper.KEY 2>> $logfile
     
  info "${GREEN}${text_uninstall_10[$LANG]}"
  echo ""
  info "${BLUE}${text_uninstall_11[$LANG]}"
  info "${BLUE}==================== Uninstallation of OLD wrappers in the system: COMPLETE ====================" >> $logfile
  echo ""
  echo ""
  
if [[ "$mode" == "Simplest" ]]; then
text_uninstall_12=("====================CONTINUING With installation of the Simplest Wrapper...====================" "====================CONTINUANDO con la Instalación del Wrapper más simple...====================" "====================CONTINUAÇÃO com a instalação mais simples do wrapper...=====================" "====================SUITE avec l'installation de wrapper la plus simple...====================" "====================FORTSETZUNG mit der einfachsten Wrapper-Installation...====================" "=====================CONTINUA con l'installazione del wrapper più semplice...=====================")
  info "${PURPLE}${text_uninstall_12[$LANG]}"
  info "${PURPLE}====================CONTINUING With installation of the Simplest Wrapper...====================" >> $logfile
  echo ""
fi

if [[ "$mode" == "Advanced" ]]; then
text_uninstall_12=("====================CONTINUING With installation of the Advanced Wrapper...====================" "====================CONTINUANDO con la Instalación del Wrapper Avanzado...====================" "====================CONTINUANDO com a Instalação Avançada do Wrapper...=====================" "====================CONTINUANT ​​avec l'installation avancée de l'encapsuleur...====================" "====================FORTSETZUNG mit der Advanced Wrapper Installation...====================" "=====================CONTINUA con l'installazione avanzata del wrapper...====================")
  info "${PURPLE}${text_uninstall_12[$LANG]}"
  info "${PURPLE}====================CONTINUING With installation of the Advanced Wrapper...====================" >> $logfile
  echo "" 
fi
  
  install
	
fi


if [[ "$unmode" == "New" ]]; then
  if [[ -f "/tmp/wrapper.KEY" ]]; then
  info "${BLUE}${text_uninstall_13[$LANG]}"
  
  info "${YELLOW}${text_uninstall_2[$LANG]}"
  mv -T -f "$vs_libsynovte_file.orig" "$vs_libsynovte_file"
  
  	if [[ -d "$ms_path" ]]; then
  	info "${YELLOW}${text_uninstall_4[$LANG]}"
  	mv -T -f "$ms_libsynovte_file.orig" "$ms_libsynovte_file"
  
  	info "${YELLOW}${text_uninstall_5[$LANG]}"
  	rm $ms_path/bin/ffmpeg.KEY 2>> $logfile
  	fi
  
  find $cp_bin_path -type f -name "*.orig" | while read -r filename; do
  text_uninstall_8=("Restoring CodecPack's $filename" "Restaurando el $filename de CodecPack" "Restaurando o CodecPack $filename" "Restauration de la CodecPack $filename" "Wiederherstellen der CodecPack $filename" "Ripristino di CodecPack $filename")
  info "${YELLOW}${text_uninstall_8[$LANG]}"
  mv -T -f "$filename" "${filename::-5}"
  done
  
  info "${YELLOW}${text_uninstall_18[$LANG]}"
  rm /tmp/wrapper.KEY 2>> $logfile
  
  restart_packages
  
  info "${YELLOW}${text_uninstall_14[$LANG]}"
  touch "$logfile"
  rm "$logfile"
    
  info "${GREEN}${text_uninstall_15[$LANG]}"

  echo ""
  info "${BLUE}${text_uninstall_16[$LANG]}"
  rm "$logfile"
  rm -f /tmp/SCPT_VAR_Languages
  exit 0
  
  else
  
  info "${RED}${text_uninstall_17[$LANG]}"
  rm "$logfile"
  rm -f /tmp/SCPT_VAR_Languages
  exit 1
  
  fi

fi

}

function configurator() {
clear

if [[ "$check_amrif" == "$firma2" ]]; then
YELLOW_BLUEMS="\u001b[33m"
RED_BLUEMS="\u001b[31m"
fi

if [[ "$check_amrif" == "$firma" ]]; then
YELLOW_BLUEMS="\u001b[36m"
RED_BLUEMS="\u001b[36m"
fi

if [[ "$check_amrif_1" == "$firma_cp" ]]; then

        echo ""
        echo -e "${BLUE}${text_configura_1[$LANG]}"
	welcome_config
	echo ""
        echo ""
        echo -e "${YELLOW}${text_configura_2[$LANG]}"
        echo ""
        echo -e "${BLUE}${text_configura_3[$LANG]}"
        echo -e "${BLUE}${text_configura_4[$LANG]}" 
        echo -e "${YELLOW_BLUEMS}${text_configura_5[$LANG]}"
        echo -e "${RED_BLUEMS}${text_configura_6[$LANG]}"
        echo -e "${RED_BLUEMS}${text_configura_7[$LANG]}"
        echo -e "${YELLOW_BLUEMS}${text_configura_8[$LANG]}"
	echo -e "${BLUE}${text_configura_9[$LANG]}"
	echo -e "${RED_BLUEMS}${text_configura_10[$LANG]}"
        echo ""
        echo -e "${PURPLE}${text_configura_11[$LANG]}"
   	while true; do
	echo -e "${GREEN}"
        read -p "${text_configura_12[$LANG]}" abcdefghz
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
        * ) echo -e "${YELLOW}${text_configura_13[$LANG]}";;
        esac
        done
   
   echo -e "${BLUE}${text_configura_14[$LANG]}"
   info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
   exit 0

else
   info "${RED}${text_configura_15[$LANG]}"
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED so this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configura_16[$LANG]}"
   start
fi
}

################################
# EJECUCIÓN
################################

while getopts s: flag; do
  case "${flag}" in
    s) setup=${OPTARG};;
    *) echo "usage: $0 [-s install|autoinstall|uninstall|config|info]" >&2; rm -f /tmp/SCPT_VAR_Languages; exit 0;;
  esac
done


intro

titulo

check_root

welcome

check_dependencias

check_licence_AME

check_versions

check_firmas


case "$setup" in
  start) start;;
  install) install_advanced;;
  autoinstall) install_advanced;;
  uninstall) uninstall_new;;
  config) configurator;;
  info) rm -f /tmp/SCPT_VAR_Languages; exit 0;;
esac
