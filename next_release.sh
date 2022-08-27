#!/bin/bash

version="SCPT_1.7"
# Changes:
# SCPT_1.0: Initial release of the automatic installer script for DMS 7.X. (Deprecated migrated to SCPT_1.1)
# SCPT_1.1: To avoid discrepancies and possible deletion of original binaries when there is a previously installed wrapper, an analyzer of other installations has been added. (Deprecated migrated to SCPT_1.2)
# SCPT_1.2: Added a configurator tool for select the codecs. (Deprecated migrated to SCPT_1.3)
# SCPT_1.3: Added a interactive menu when you don´t especify any Flag in bash command or you are using basic launch. (Deprecated migrated to SCPT_1.4)
# SCPT_1.4: Fixed a bug: when you select simplest_wrapper with only MP3 2.0 and then try to change the order of the audio codecs you will have a error. (Deprecated migrated to SCPT_1.5)
# SCPT_1.5: Fixed a bug: when you have a low connection to Internet that could have problems. (Deprecated migrated to SCPT_1.6)
# SCPT_1.6: Added a independent audio´s streams for DLNA. (Deprecated migrated to SCPT_1.7)
# SCPT_1.7: Added a independent installer for simplest_wrapper in MAIN menu. Added new configuration options in configurator_menu. Now you can change from AAC to AC3. 

###############################
# VARIABLES
###############################

dsm_version=$(cat /etc.defaults/VERSION | grep productversion | sed 's/productversion=//' | tr -d '"')
repo_url="https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation"
setup="start"
dependencias=("VideoStation" "ffmpeg" "CodecPack" "MediaServer")
RED="\u001b[31m"
BLUE="\u001b[36m"
GREEN="\u001b[32m"
YELLOW="\u001b[33m"
supported_versions=("7.0" "7.1")
injector="1-12.3.3"
vs_path=/var/packages/VideoStation/target
ms_path=/var/packages/MediaServer/target
vs_libsynovte_file="$vs_path/lib/libsynovte.so"
ms_libsynovte_file="$ms_path/lib/libsynovte.so"
cp_bin_path=/var/packages/CodecPack/target/pack/bin
all_files=("$ms_libsynovte_file.orig" "vs_libsynovte_file.orig" "$cp_bin_path/ffmpeg41.orig" "$ms_path/bin/ffmpeg.orig")
firma="# DarkNebular´s Advanced Wrapper"

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
  if [[ -d $cp_bin_path ]]; then
    info "${GREEN}Restarting CodecPack..."
    synopkg restart CodecPack
  fi

  info "${GREEN}Restarting VideoStation..."
  synopkg restart VideoStation
  
  info "${GREEN}Restarting MediaServer..."
  synopkg restart MediaServer
}

function check_dependencias() {
  for dependencia in "${dependencias[@]}"; do
    if [[ ! -d "/var/packages/$dependencia" ]]; then
      error "Missing $dependencia package, please install it and re-run the patcher setup."
      exit 1
    fi
  done
}
function welcome() {
  info "FFMPEG WRAPPER INSTALLER version: $version"

  welcome=$(curl -s -L "$repo_url/main/welcome.txt")
  if [ "${#welcome}" -ge 1 ]; then
    echo ""
    echo -e "${GREEN}	$welcome"
    echo ""
  fi
}
function check_version() {
    DSM=$1
    DELIMITER=$2
    VALUE=$3
    LIST_WHITESPACES=`echo $DSM | tr "$DELIMITER" " "`
    for xdsm in $LIST_WHITESPACES; do
        if [ "$xdsm" = "$VALUE" ]; then
            return 0
        fi
    done
    return 1
}
function config_A() {
    info "${YELLOW}Restoring the default audio´s codecs and stream´s order of this wrapper in VIDEO-STATION."
    
    wget $repo_url/main/ffmpeg41-wrapper-DSM7_$injector -O ${cp_bin_path}/ffmpeg41
    info "${GREEN}Waiting for consolidate the download of the wrapper."
    sleep 2
    info "${GREEN}Sucesfully changed the audio stream´s order to: 1) MP3 2.0 256kbp and 2) AAC 5.1 512kbps in VIDEO-STATION."
    echo ""
    
}

function config_B() {
    info "${YELLOW}Changing to use this audio´s codecs and stream´s order of this wrapper in VIDEO-STATION."
    
    wget $repo_url/main/ffmpeg41-wrapper-DSM7_$injector -O ${cp_bin_path}/ffmpeg41
    info "${GREEN}Waiting for consolidate the download of the wrapper."
    sleep 2
    info "${YELLOW}Changing the default codecs order of this Wrapper."
    sed -i 's/args2vs+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/args2vs+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/gi' ${cp_bin_path}/ffmpeg41
    sed -i 's/args2vs+=("-ac:1" "$1" "-ac:2" "6")/args2vs+=("-ac:1" "6" "-ac:2" "$1")/gi' ${cp_bin_path}/ffmpeg41
    sed -i 's/("-b:a:0" "256k" "-b:a:1" "512k")/("-b:a:0" "512k" "-b:a:1" "256k")/gi' ${cp_bin_path}/ffmpeg41
    info "${GREEN}Sucesfully changed the audio stream´s order to: 1) AAC 5.1 512kbps and 2) MP3 2.0 256kbps in VIDEO-STATION."
    echo ""
    
}

function config_C() {
    info "${YELLOW}Changing to use ALWAYS MP3 2.0 128kbps in VIDEO-STATION."
    info "${YELLOW}Applying the simplest wrapper."
    
    wget $repo_url/main/simplest_wrapper -O ${cp_bin_path}/ffmpeg41
        
    info "${GREEN}Waiting for consolidate the download of the simplest wrapper."
    sleep 2
    info "${GREEN}Sucesfully changed the audio to a unique audio stream: 1) MP3 2.0 128kbps in VIDEO-STATION."
    echo ""
    
}

function config_D() {
    info "${YELLOW}Restoring the default audio´s codecs and stream´s order of this wrapper in DLNA MediaServer."
	cp ${cp_bin_path}/ffmpeg41 $ms_path/bin/ffmpeg
	info "${YELLOW}Fixing permissions of the ffmpeg wrapper for the DLNA."
	chmod 755 $ms_path/bin/ffmpeg
	chown MediaServer:MediaServer $ms_path/bin/ffmpeg
	info "${YELLOW}Restoring the default codecs order of this Wrapper in DLNA MediaServer."
        sed -i 's/args2vs+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/args2vs+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/gi' $ms_path/bin/ffmpeg
        sed -i 's/args2vs+=("-ac:1" "$1" "-ac:2" "6")/args2vs+=("-ac:1" "6" "-ac:2" "$1")/gi' $ms_path/bin/ffmpeg
        sed -i 's/("-b:a:0" "256k" "-b:a:1" "512k")/("-b:a:0" "512k" "-b:a:1" "256k")/gi' $ms_path/bin/ffmpeg
	info "${YELLOW}Correcting of the version of this Wrapper in DLNA MediaServer."
	sed -i 's/rev="AME_12/rev="MS_12/gi' $ms_path/bin/ffmpeg
	info "${YELLOW}Correcting of the paths of this Wrapper in DLNA MediaServer."
	sed -i 's#/var/packages/CodecPack/target/pack/bin/ffmpeg41.orig#/var/packages/MediaServer/target/bin/ffmpeg.orig#gi' $ms_path/bin/ffmpeg
        info "${GREEN}Sucesfully changed the audio stream´s order to: 1) AAC 5.1 512kbps and 2) MP3 2.0 256kbps in DLNA MediaServer."
	echo ""
	
}

function config_E() {
    info "${YELLOW}Changing to use this audio´s codecs and stream´s order of this wrapper in DLNA MediaServer."
	cp ${cp_bin_path}/ffmpeg41 $ms_path/bin/ffmpeg
	info "${YELLOW}Fixing permissions of the ffmpeg wrapper for the DLNA."
	chmod 755 $ms_path/bin/ffmpeg
	chown MediaServer:MediaServer $ms_path/bin/ffmpeg
	info "${YELLOW}Changing the default codecs order of this Wrapper in DLNA MediaServer."
        sed -i 's/args2vs+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/args2vs+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/gi' $ms_path/bin/ffmpeg
        sed -i 's/args2vs+=("-ac:1" "6" "-ac:2" "$1")/args2vs+=("-ac:1" "$1" "-ac:2" "6")/gi' $ms_path/bin/ffmpeg
        sed -i 's/("-b:a:0" "512k" "-b:a:1" "256k")/("-b:a:0" "256k" "-b:a:1" "512k")/gi' $ms_path/bin/ffmpeg
	info "${YELLOW}Correcting of the version of this Wrapper in DLNA MediaServer."
	sed -i 's/rev="AME_12/rev="MS_12/gi' $ms_path/bin/ffmpeg
	info "${YELLOW}Correcting of the paths of this Wrapper in DLNA MediaServer."
	sed -i 's#/var/packages/CodecPack/target/pack/bin/ffmpeg41.orig#/var/packages/MediaServer/target/bin/ffmpeg.orig#gi' $ms_path/bin/ffmpeg
        info "${GREEN}Sucesfully changed the audio stream´s order to: 1) MP3 2.0 256kbps and 2) AAC 5.1 512kbps in DLNA MediaServer."
	echo ""
	
}

function config_F() {
    info "${YELLOW}Changing to use ALWAYS MP3 2.0 128kbps in DLNA MediaServer."
	wget $repo_url/main/simplest_wrapper -O $ms_path/bin/ffmpeg
        
    info "${GREEN}Waiting for consolidate the download of the simplest wrapper."
    sleep 2
    info "${GREEN}Sucesfully changed the audio to a Unique audio´s stream: 1) MP3 2.0 128kbps in DLNA MediaServer."
    echo ""
    
}

function start() {
   echo ""   
   echo -e "${YELLOW}THIS IS THE MAIN MENU, PLEASE CHOOSE YOUR SELECTION:"
   echo ""
   echo -e "${BLUE}I) Install the Advanced Wrapper for VideoStation and DLNA MediaServer. (With 5.1 and 2.0 support, configurable)"
   echo -e "${BLUE}S) Install the Simplest Wrapper for VideoStation and DLNA MediaServer. (Only 2.0 support, NOT configurable)"
   echo -e "${BLUE}U) Uninstall all the wrappers for VideoStation and DLNA MediaServer." 
   echo -e "${BLUE}C) Change the config of the Advanced Wrapper for change the audio´s codecs in VIDEO-STATION and DLNA."
   echo ""
   echo -e "${BLUE}E) EXIT from this installer."
        while true; do
	echo -e "${GREEN}"
        read -p "Please, What option wish to use? " isuce
        case $isuce in
        [Ii]* ) install;;
        [Ss]* ) install_simple;;
        [Uu]* ) uninstall;;
	      [Cc]* ) configurator;;
      	[Ee]* ) exit;;
        * ) echo -e "${YELLOW}Please answer I or Install | S or Simple | U or Uninstall | C or Config | E or Exit.";;
        esac
        done
}

################################
# PROCEDIMIENTOS DEL PATCH
################################

function install() {
  info "${BLUE}==================== Installation of the Advanced Wrapper: START ===================="
  echo ""
   info "${BLUE}You are running DSM $dsm_version"
   info "${BLUE}DSM $dsm_version is supported for this installer and the installer will tuned for your DSM"
   info "${BLUE}DSM $dsm_version is using this path: $cp_bin_path"
   info "${BLUE}DSM $dsm_version is using this injector: $injector"

for losorig in "$all_files"; do
if [[ -f "$losorig" ]]; then
        info "${RED}Actually you have a OLD or OTHER patch applied in your system, please UNINSTALL OLDER Wrapper first."
	echo ""
	echo -e "${BLUE}YES) The installer will Uninstall the OLD patch or Wrapper."
        echo -e "${BLUE}NO) Exit from the installer menu and return to MAIN MENU."
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
    	mv -n ${cp_bin_path}/ffmpeg41 ${cp_bin_path}/ffmpeg41.orig
	  info "${YELLOW}Creating the esqueleton of the ffmpeg41"
	touch ${cp_bin_path}/ffmpeg41 
	  info "${YELLOW}Injection of the ffmpeg41 wrapper."
	wget $repo_url/main/ffmpeg41-wrapper-DSM7_$injector -O ${cp_bin_path}/ffmpeg41
	  info "${GREEN}Waiting for consolidate the download of the wrapper."
        sleep 2
	  info "${YELLOW}Fixing permissions of the ffmpeg41 wrapper."
	chmod 755 ${cp_bin_path}/ffmpeg41
	info "${YELLOW}Ensuring the existence of the log file."
	touch /tmp/ffmpeg.log
	info "${YELLOW}Ensuring that the wrapper starts with a perfectly empty log file."
	rm /tmp/ffmpeg.log
	info "${GREEN}Installed correctly the wrapper41 in $cp_bin_path"
	
	info "${YELLOW}Backup the original ffmpeg as ffmpeg.orig in DLNA MediaServer."
	mv -n $ms_path/bin/ffmpeg $ms_path/bin/ffmpeg.orig
	info "${YELLOW}Reuse of the ffmpeg41 wrapper in DLNA MediaServer."
	cp ${cp_bin_path}/ffmpeg41 $ms_path/bin/ffmpeg
	info "${YELLOW}Fixing permissions of the ffmpeg wrapper for the DLNA."
	chmod 755 $ms_path/bin/ffmpeg
	chown MediaServer:MediaServer $ms_path/bin/ffmpeg
	info "${YELLOW}Changing the default codecs order of this Wrapper in DLNA MediaServer."
        sed -i 's/args2vs+=("-c:a:0" "$1" "-c:a:1" "libfdk_aac")/args2vs+=("-c:a:0" "libfdk_aac" "-c:a:1" "$1")/gi' $ms_path/bin/ffmpeg
        sed -i 's/args2vs+=("-ac:1" "$1" "-ac:2" "6")/args2vs+=("-ac:1" "6" "-ac:2" "$1")/gi' $ms_path/bin/ffmpeg
        sed -i 's/("-b:a:0" "256k" "-b:a:1" "512k")/("-b:a:0" "512k" "-b:a:1" "256k")/gi' $ms_path/bin/ffmpeg
	info "${YELLOW}Correcting of the version of this Wrapper in DLNA MediaServer."
	sed -i 's/rev="AME_12/rev="MS_12/gi' $ms_path/bin/ffmpeg
	info "${YELLOW}Correcting of the paths of this Wrapper in DLNA MediaServer."
	sed -i 's#/var/packages/CodecPack/target/pack/bin/ffmpeg41.orig#/var/packages/MediaServer/target/bin/ffmpeg.orig#gi' $ms_path/bin/ffmpeg
        info "${GREEN}Installed correctly the Wrapper in $ms_path/bin"
	
	info "${YELLOW}Backup the original libsynovte.so in VideoStation as libsynovte.so.orig."
	cp -n $vs_libsynovte_file $vs_libsynovte_file.orig
	  info "${YELLOW}Fixing permissions of $vs_libsynovte_file.orig"
	chown VideoStation:VideoStation $vs_libsynovte_file.orig
	  info "${YELLOW}Patching $vs_libsynovte_file for compatibility with DTS, EAC3 and TrueHD"
	sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' $vs_libsynovte_file
	info "${GREEN}Modified correctly the file $vs_libsynovte_file"
	
	info "${YELLOW}Backup the original libsynovte.so in MediaServer as libsynovte.so.orig."
	cp -n $ms_libsynovte_file $ms_libsynovte_file.orig
	  info "${YELLOW}Fixing permissions of $ms_libsynovte_file.orig"
	chown MediaServer:MediaServer $ms_libsynovte_file.orig
	chmod 644 $ms_libsynovte_file.orig
	  info "${YELLOW}Patching $ms_libsynovte_file for compatibility with DTS, EAC3 and TrueHD"
	sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' $ms_libsynovte_file
	info "${GREEN}Modified correctly the file $ms_libsynovte_file"
	
	restart_packages
	
	info "${GREEN}Installed correctly the Advanced Wrapper"
	
	info "${BLUE}==================== Installation of the Advanced Wrapper: COMPLETE ===================="
	
fi
done

echo ""
}

function uninstall_old() {
  info "${BLUE}==================== Uninstallation of old wrappers in the system: START ===================="

  info "${YELLOW}Restoring VideoStation´s libsynovte.so"
  mv -T -f "$vs_libsynovte_file.orig" "$vs_libsynovte_file"
  
  info "${YELLOW}Restoring MediaServer´s libsynovte.so"
  mv -T -f "$ms_libsynovte_file.orig" "$ms_libsynovte_file"

  find "$vs_path/bin" -type f -name "*.orig" | while read -r filename; do
    info "${YELLOW}Restoring VideoStation's $filename"
    mv -T -f "$filename" "${filename::-5}"
  done
  
  find "$ms_path/bin" -type f -name "*.orig" | while read -r filename; do
    info "${YELLOW}Restoring MediaServer's $filename"
    mv -T -f "$filename" "${filename::-5}"
  done

  find $cp_bin_path -type f -name "*.orig" | while read -r filename; do
      info "Restoring CodecPack's $filename"
      mv -T -f "$filename" "${filename::-5}"
  done

  info "${GREEN}Uninstalled correctly the old Wrapper"
  echo ""
  info "${BLUE}==================== Uninstallation of old wrappers in the system: COMPLETE ===================="
  echo ""
  echo ""
  info "${BLUE}====================CONTINUING With installation of the new wrapper...===================="
  echo ""
  
  install
  
}

function uninstall() {
  info "${BLUE}==================== Uninstallation all wrappers: START ===================="

  info "${YELLOW}Restoring VideoStation´s libsynovte.so"
  mv -T -f "$vs_libsynovte_file.orig" "$vs_libsynovte_file"
  
  info "${YELLOW}Restoring MediaServer´s libsynovte.so"
  mv -T -f "$ms_libsynovte_file.orig" "$ms_libsynovte_file"
  
  find "$ms_path/bin" -type f -name "*.orig" | while read -r filename; do
  info "${YELLOW}Restoring MediaServer's $filename"
  mv -T -f "$filename" "${filename::-5}"
  done

  find $cp_bin_path -type f -name "*.orig" | while read -r filename; do
      info "Restoring CodecPack's $filename"
      mv -T -f "$filename" "${filename::-5}"
    done
  info "${YELLOW}Delete old log file."
	touch /tmp/ffmpeg.log
	rm /tmp/ffmpeg.log

  restart_packages
  info "${GREEN}Uninstalled correctly all the Wrappers in DLNA MediaServer and VideoStation."

  echo ""
  info "${BLUE}==================== Uninstallation all wrappers: COMPLETE ===================="
}

function configurator() {
   for losorig in "$all_files"; do
   if [[ -f "$losorig" ]]; then
     find $cp_bin_path -type f -name "ffmpeg41" | while read -r linea; do
  	if [[ $linea == $firma ]]; then
   
        echo ""
        info "${BLUE}==================== Configuration of the Advanced Wrapper: START ===================="
        echo ""
        echo -e "${YELLOW}REMEMBER: If you change the order in VIDEO-STATION you will have ALWAYS AAC 5.1 512kbps in first audio stream and some devices not compatibles with 5.1 neigther multi audio streams like Chromecast won't work"
        echo ""
        echo -e "${BLUE}A) FIRST STREAM= MP3 2.0 256kbpss, SECOND STREAM= AAC 5.1 512kbps when It needs to do transcoding in VIDEO-STATION. (DEFAULT ORDER VIDEO-STATION)"
        echo -e "${BLUE}B) FIRST STREAM= AAC 5.1 512kbps, SECOND STREAM= MP3 2.0 256kbps when It needs to do transcoding in VIDEO-STATION." 
        echo -e "${BLUE}C) ONLY ONE AUDIO STREAM MP3 2.0 128kbps when It needs to do transcoding in VIDEO-STATION. This is the behaviour of VideoStation without wrappers. (This option installs the simplest_wrapper in VIDEO-STATION)."
        echo -e "${BLUE}D) FIRST STREAM= AAC 5.1 512kbps, SECOND STREAM= MP3 2.0 256kbps when It needs to do transcoding in DLNA. (DEFAULT ORDER DLNA)"
        echo -e "${BLUE}E) FIRST STREAM= MP3 2.0 256kbpss, SECOND STREAM= AAC 5.1 512kbps when It needs to do transcoding in DLNA."
        echo -e "${BLUE}F) ONLY ONE AUDIO STREAM MP3 2.0 128kbps when It needs to do transcoding in DLNA. This is the behaviour of DLNA without wrappers. (This option installs the simplest_wrapper in DLNA MediaServer)."
        echo ""
        echo -e "${BLUE}Z) Exit from this Configurator menu and return to MAIN menu."
   	while true; do
	echo -e "${GREEN}"
        read -p "Do you wish to change the order of these audio stream in the actual wrapper? " abcdefz
        case $abcdefz in
        [Aa] ) config_A; break;;
        [Bb] ) config_B; break;;
	[Cc] ) config_C; break;;
	[Dd] ) config_D; break;;
	[Ee] ) config_E; break;;
	[Ff] ) config_F; break;;
	[Zz] ) start; break;;
        * ) echo -e "${YELLOW}Please answer with the correct option writing: A or B or C or D or E or F. Write Z (for return to MAIN menu).";;
        esac
        done
   
   info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ===================="
        else 
	info "${RED}Actually you haven't the Advanced Wrapper installed and this codec configurator can't change anything."
        info "${BLUE}Please, install the Advanced Wrapper first and then you will can change the audio´s streams order."
        start
        fi
   done
  else
   info "${RED}Actually you haven't any Wrapper installed and this codec configurator can't change anything."
   info "${BLUE}Please, install the Advanced Wrapper first and then you will can change the audio´s streams order."
   start
 fi
   done
}

function install_simple() {
  info "${BLUE}==================== Installation of the Simplest Wrapper: START ===================="
  echo ""
   info "${BLUE}You are running DSM $dsm_version"
   info "${BLUE}DSM $dsm_version is supported for this installer and the installer will tuned for your DSM"
   info "${BLUE}DSM $dsm_version is using this path: $cp_bin_path"
   info "${BLUE}DSM $dsm_version is using this injector: Simple"
   
for losorig in "$all_files"; do
if [[ -f "$losorig" ]]; then
        info "${RED}Actually you have a OLD or OTHER patch applied in your system, please UNINSTALL OLDER Wrapper first."
	echo ""
	echo -e "${BLUE}YES) The installer will Uninstall the OLD patch or Wrapper."
        echo -e "${BLUE}NO) Exit from the installer menu and return to MAIN MENU."
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
    	mv -n ${cp_bin_path}/ffmpeg41 ${cp_bin_path}/ffmpeg41.orig
	  info "${YELLOW}Creating the esqueleton of the ffmpeg41"
	touch ${cp_bin_path}/ffmpeg41 
	  info "${YELLOW}Injection of the ffmpeg41 wrapper."
	wget $repo_url/main/simplest_wrapper -O ${cp_bin_path}/ffmpeg41
	  info "${GREEN}Waiting for consolidate the download of the wrapper."
        sleep 2
	  info "${YELLOW}Fixing permissions of the ffmpeg41 wrapper."
	chmod 755 ${cp_bin_path}/ffmpeg41
	info "${YELLOW}Ensuring the existence of the log file."
	touch /tmp/ffmpeg.log
	info "${YELLOW}Ensuring that the wrapper starts with a perfectly empty log file."
	rm /tmp/ffmpeg.log
	info "${GREEN}Installed correctly the wrapper41 in $cp_bin_path"
	
	info "${YELLOW}Backup the original ffmpeg as ffmpeg.orig in DLNA MediaServer."
	mv -n $ms_path/bin/ffmpeg $ms_path/bin/ffmpeg.orig
	info "${YELLOW}Reuse of the ffmpeg41 wrapper in DLNA MediaServer."
	cp ${cp_bin_path}/ffmpeg41 $ms_path/bin/ffmpeg
	info "${YELLOW}Fixing permissions of the ffmpeg wrapper for the DLNA."
	chmod 755 $ms_path/bin/ffmpeg
	chown MediaServer:MediaServer $ms_path/bin/ffmpeg
	info "${GREEN}Installed correctly the Wrapper in $ms_path/bin"
	
	info "${YELLOW}Backup the original libsynovte.so in VideoStation as libsynovte.so.orig."
	cp -n $vs_libsynovte_file $vs_libsynovte_file.orig
	  info "${YELLOW}Fixing permissions of $vs_libsynovte_file.orig"
	chown VideoStation:VideoStation $vs_libsynovte_file.orig
	  info "${YELLOW}Patching $vs_libsynovte_file for compatibility with DTS, EAC3 and TrueHD"
	sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' $vs_libsynovte_file
	info "${GREEN}Modified correctly the file $vs_libsynovte_file"
	
	info "${YELLOW}Backup the original libsynovte.so in MediaServer as libsynovte.so.orig."
	cp -n $ms_libsynovte_file $ms_libsynovte_file.orig
	  info "${YELLOW}Fixing permissions of $ms_libsynovte_file.orig"
	chown MediaServer:MediaServer $ms_libsynovte_file.orig
	chmod 644 $ms_libsynovte_file.orig
	  info "${YELLOW}Patching $ms_libsynovte_file for compatibility with DTS, EAC3 and TrueHD"
	sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' $ms_libsynovte_file
	info "${GREEN}Modified correctly the file $ms_libsynovte_file"
	
	restart_packages
	
	info "${GREEN}Installed correctly the Simplest Wrapper"
	
	info "${BLUE}==================== Installation of the Simplest Wrapper: COMPLETE ===================="
	
fi
done

echo ""
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

# start
clear
echo -e "${BLUE}====================FFMPEG WRAPPER INSTALLER FOR DSM 7.X by Dark Nebular.===================="
echo -e "${BLUE}====================This wrapper installer is only avalaible for DSM "${supported_versions[@]}" only===================="
echo ""
echo ""

welcome

check_dependencias

if check_version "$dsm_version" " " 7.0; then
   cp_bin_path=/var/packages/CodecPack/target/bin
   injector="0-12.2.2"
fi
if check_version "$dsm_version" " " 7.1; then
   cp_bin_path=/var/packages/CodecPack/target/pack/bin
   injector="1-12.3.3"
else
 error "Your DSM Version $dsm_version is NOT supported using this installer. Please use the MANUAL Procedure."
 exit 1
fi




case "$setup" in
  start) start;;
  install) install;;
  uninstall) uninstall;;
  config) configurator;;
  info) exit 1;;
esac
