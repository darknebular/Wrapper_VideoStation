#!/bin/bash

##############################################################
version="SCPT_3.9.8"
# Changes:
# SCPT_1.X: See these changes in the releases notes in my Repository in Github. (Deprecated)
# SCPT_2.X: See these changes in the releases notes in my Repository in Github. (Deprecated)
# SCPT_3.0: Initial new major Release. Clean the code from last versions. (Deprecated migrated to SCPT_3.1)
# SCPT_3.1: Add compatibility to DSXXX-Play appliances using ffmpeg27. Change the name of the injectors. (Deprecated migrated to SCPT_3.2)
# SCPT_3.2: Reflect the new Wrapper change in the installation script. (Deprecated migrated to SCPT_3.3)
# SCPT_3.3: Support for the new versions of FFMPEG 6.0.X and deprecate the use of ffmpeg 4.X.X. (Deprecated migrated to SCPT_3.4)
# SCPT_3.4: Improvements in checking for future releases of DSM's versions. Creation of installer_OffLine to avoid the 128KB limit and to be able to create more logic in the script and new fuctions. (Deprecated migrated to SCPT_3.5)
# SCPT_3.5: Added an Installer for the License's CRACK for the AME 3.0. Improvements in autoinstall, now the autoinstall will installs the type of Wrapper that you had installed. (Deprecated migrated to SCPT_3.6)
# SCPT_3.6: Added full support for DS21X-Play devices with ARMv8 using a GStreamer's Wrapper. Now the installer recommends to you the Simplest or the Advanced in function of the performance of your system. (Deprecated migrated to SCPT_3.7)
# SCPT_3.7: Fixed a bug in the GStreamer's Wrapper installer that doesn't clear the plugin's cache in AME. (Deprecated migrated to SCPT_3.8)
# SCPT_3.8: Fixed a bug in declaration of the variables for the licenses fix for AME. (Deprecated migrated to SCPT_3.9)
# SCPT_3.9: Added the possibility to transcode AAC codec in Video Station and Media Server. Added new libraries for GStreamer 1.6.3. for this AAC decoding. Added the word BETA for the cracker of the AME's license. (Deprecated migrated to SCPT_3.9.1)
# SCPT_3.9.1: Added in the license's crack the patch for the DSM 7.2. (Deprecated migrated to SCPT_3.9.2)
# SCPT_3.9.2: Homogenize the closing of processes in the Simplest Wrapper with the Advanced Wrapper, to correct a bug carried over from Alex's code. (Deprecated migrated to SCPT_3.9.3)
# SCPT_3.9.3: Fixed the possibility to enter to the Start menu if you haven't got the AME License and you want to install the patch for the license in a XPEnology system. (Deprecated migrated to SCPT_3.9.4)
# SCPT_3.9.4: Changed the installer version for the new Advanced Wrapper version. (Deprecated migrated to SCPT_3.9.5)
# SCPT_3.9.5: Added a new hash for the AME License Patch. (Deprecated migrated to SCPT_3.9.6)
# SCPT_3.9.6: Added into the Uninstall Old function the possibility to delete Orphan files generated from others wrappers, like Alex's one. (Deprecated migrated to SCPT_3.9.7)
# SCPT_3.9.7: Added the possibility of changing the number of audio channels in the OffLine transcoding of the Video Station in the Configuration menu. Fixed a Typo in AME License, in two variables. (Deprecated migrated to SCPT_3.9.8)
# SCPT_3.9.8: Fixed a bug that did not make thumbnails of .mp4 videos in Video Station. I did changes in the Advanced Wrapper.**

##############################################################


###############################
# VARIABLES GLOBALES
###############################

dsm_version=$(cat /etc.defaults/VERSION | grep productversion | sed 's/productversion=//' | tr -d '"')
majorversion=$(cat /etc.defaults/VERSION | grep majorversion | sed 's/majorversion=//' | tr -d '"')
minorversion=$(cat /etc.defaults/VERSION | grep minorversion | sed 's/minorversion=//' | tr -d '"')
repo_url="https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation"
setup="start"
dependencias=("VideoStation" "ffmpeg6" "CodecPack")
RED="\u001b[31m"
BLUE="\u001b[36m"
BLUEGSLP="\u001b[36m"
PURPLE="\u001B[35m"
GREEN="\u001b[32m"
YELLOW="\u001b[33m"
injector="0-Advanced"
vs_path=/var/packages/VideoStation/target
ms_path=/var/packages/MediaServer/target
vs_libsynovte_file="$vs_path/lib/libsynovte.so"
ms_libsynovte_file="$ms_path/lib/libsynovte.so"
cp_path=/var/packages/CodecPack/target
cp_bin_path="$cp_path/bin"
firma="DkNbulDkNbul"
firma2="DkNbular"
firma_cp="DkNbul"
declare -i control=0
logfile="/tmp/wrapper_ffmpeg.log"
LANG="0"
cpu_model=$(cat /proc/cpuinfo | grep "model name")
GST_comp="NO"

values=('669066909066906690' 'B801000000' '30')
hex_values=('1F28' '48F5' '4921' '4953' '4975' '9AC8')
indices=(0 1 1 1 1 2)
cp_usr_path='/var/packages/CodecPack/target/usr'
so="$cp_usr_path/lib/libsynoame-license.so"
so_backup="$cp_usr_path/lib/libsynoame-license.so.orig"
lic="/usr/syno/etc/license/data/ame/offline_license.json"
lic_backup="/usr/syno/etc/license/data/ame/offline_license.json.orig"
licsig="/usr/syno/etc/license/data/ame/offline_license.sig"
licsig_backup="/usr/syno/etc/license/data/ame/offline_license.sig.orig"


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
  text_restart_1=("Restarting CodecPack..." "Reiniciando CodecPack..." "Reiniciando o CodecPack..." "Redémarrage de CodecPack..." "CodecPack wird neu gestartet..." "Riavvio CodecPack...")
  text_restart_2=("Restarting VideoStation..." "Reiniciando VideoStation..." "Reiniciando o VideoStation..." "Redémarrage de VideoStation..." "VideoStation wird neu gestartet..." "Riavvio VideoStation...")
  text_restart_3=("Restarting MediaServer..." "Reiniciando MediaServer..." "Reiniciando o MediaServer..." "Redémarrage de MediaServer..." "MediaServer wird neu gestartet..." "Riavvio MediaServer...")
  
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
text_ckck_depen1=("You have ALL necessary packages Installed, GOOD." "Tienes TODOS los paquetes necesarios ya instalados, BIEN." "Você tem TODOS os pacotes necessários já instalados, BOM." "Vous avez TOUS les packages nécessaires déjà installés, BON." "Sie haben ALLE notwendigen Pakete bereits installiert, GUT." "Hai già installato TUTTI i pacchetti necessari, BUONO.")

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
    sleep 3
  fi
}
function welcome() {
  text_welcome_1=("FFMPEG (or GStreamer) WRAPPER INSTALLER version: $version" "INSTALADOR DEL WRAPPER DE FFMPEG (o GStreamer) versión: $version" "INSTALADOR DE ENVOLTÓRIO FFMPEG (ou GStreamer) versão: $version" "INSTALLATEUR DE WRAPPER FFMPEG (ou GStreamer) version: $version" "FFMPEG (oder GStreamer) WRAPPER INSTALLER Version: $version" "INSTALLATORE WRAPPER FFMPEG (o GStreamer) versione: $version")
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
    text_configA_1=("Changing to use FIRST STREAM= MP3 2.0 256kbps, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) in VIDEO-STATION." "Cambiando para usar PRIMER FLUJO= MP3 2.0 256kbps, SEGUNDO FLUJO= AAC 5.1 512kbps (o AC3 5.1 640kbps) en VIDEO-STATION." "Mudando para usar FIRST STREAM= MP3 2.0 256kbps, SECOND STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps) na VIDEO-STATION." "Commutation pour utiliser PREMIER FLUX = MP3 2.0 256kbps, SECOND FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps) sur VIDEO-STATION." "Umschalten zur Verwendung des ERSTEN STREAM= MP3 2.0 256 kbps, ZWEITER STREAM= AAC 5.1 512 kbps (oder AC3 5.1 640 kbps) auf VIDEO-STATION." "Passaggio all'uso del PRIMO STREAM= MP3 2.0 256 kbps, SECONDO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps) su VIDEO-STATION.")
    text_configA_2=("Sucesfully changed the audio stream's order to: 1) MP3 2.0 256kbps and 2) AAC 5.1 512kbps (or AC3 5.1 640kbps) in VIDEO-STATION." "Cambiado correctamente el orden de los flujos de audio a: 1) MP3 2.0 256kbps y 2) AAC 5.1 512kbps (o AC3 5.1 640kbps) en VIDEO-STATION." "Alterou corretamente a ordem dos fluxos de áudio para: 1) MP3 2.0 256kbps e 2) AAC 5.1 512kbps (ou AC3 5.1 640kbps) no VIDEO-STATION." "Changement correct de l'ordre des flux audio en : 1) MP3 2.0 256kbps et 2) AAC 5.1 512kbps (ou AC3 5.1 640kbps) sur VIDEO-STATION." "Die Reihenfolge der Audiostreams wurde auf VIDEO-STATION korrekt geändert in: 1) MP3 2.0 256 kbps und 2) AAC 5.1 512 kbps (oder AC3 5.1 640 kbps)." "Modificato correttamente l'ordine dei flussi audio in: 1) MP3 2.0 256kbps e 2) AAC 5.1 512kbps (o AC3 5.1 640kbps) su VIDEO-STATION.")
    text_configA_3=("==================== Configuration of the Advanced Wrapper: COMPLETE ====================" "==================== Configuración del Wrapper Avanzado: COMPLETADA ====================" "==================== Configuração avançada do wrapper: CONCLUÍDO ====================" "==================== Configuration avancée de l'encapsuleur : TERMINÉE ====================" "==================== Erweiterte Wrapper-Konfiguration: ABGESCHLOSSEN ====================" "==================== Configurazione avanzata del wrapper: COMPLETATA ====================")
    text_configA_4=("Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
    text_configA_5=("Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams." "Por favor, Instala el Wrapper Avanzado y después podrás cambiar la configuración de los flujos de audio." "Por favor, instale o Advanced Wrapper e então você pode alterar as configurações dos fluxos de áudio." "Veuillez installer Advanced Wrapper et vous pourrez ensuite modifier les paramètres des flux audio." "Bitte installieren Sie den Advanced Wrapper und dann können Sie die Einstellungen der Audiostreams ändern." "Si prega di installare il wrapper avanzato e quindi è possibile modificare le impostazioni dei flussi audio.")
    
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
text_configB_1=("Changing to use FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps in VIDEO-STATION." "Cambiando para usar PRIMER FLUJO= AAC 5.1 512kbps (o AC3 5.1 640kbps), SEGUNDO FLUJO= MP3 2.0 256kbps en VIDEO-STATION." "Mudando para usar FIRST STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps na VIDEO-STATION." "Commutation pour utiliser PREMIER FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps), SECOND FLUX = MP3 2.0 256kbps sur VIDEO-STATION." "Umschalten zur Verwendung des ERSTEN STREAM= AAC 5.1 512 kbps (oder AC3 5.1 640 kbps), ZWEITER STREAM= MP3 2.0 256 kbps auf VIDEO-STATION." "Passaggio all'uso del PRIMO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps), SECONDO STREAM= MP3 2.0 256 kbps su VIDEO-STATION.")
text_configB_2=("Sucesfully changed the audio stream's order to: 1) AAC 5.1 512kbps (or AC3 5.1 640kbps) and 2) MP3 2.0 256kbps in VIDEO-STATION." "Cambiado correctamente el orden de los flujos de audio a: 1) AAC 5.1 512kbps (o AC3 5.1 640kbps) y 2) MP3 2.0 256kbps en VIDEO-STATION." "Alterou corretamente a ordem dos fluxos de áudio para: 1) AAC 5.1 512kbps (ou AC3 5.1 640kbps) e 2) MP3 2.0 256kbps no VIDEO-STATION." "Changement correct de l'ordre des flux audio en : 1) AAC 5.1 512kbps (ou AC3 5.1 640kbps) et 2) MP3 2.0 256kbps sur VIDEO-STATION." "Die Reihenfolge der Audiostreams wurde auf VIDEO-STATION korrekt geändert in: 1) AAC 5.1 512 kbps (oder AC3 5.1 640 kbps) und 2) MP3 2.0 256 kbps." "Modificato correttamente l'ordine dei flussi audio in: 1) AAC 5.1 512kbps (o AC3 5.1 640kbps) e 2) MP3 2.0 256kbps su VIDEO-STATION.")
text_configB_3=("==================== Configuration of the Advanced Wrapper: COMPLETE ====================" "==================== Configuración del Wrapper Avanzado: COMPLETADA ====================" "==================== Configuração avançada do wrapper: CONCLUÍDO ====================" "==================== Configuration avancée de l'encapsuleur : TERMINÉE ====================" "==================== Erweiterte Wrapper-Konfiguration: ABGESCHLOSSEN ====================" "==================== Configurazione avanzata del wrapper: COMPLETATA ====================")
text_configB_4=("Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
text_configB_5=("Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams." "Por favor, Instala el Wrapper Avanzado y después podrás cambiar la configuración de los flujos de audio." "Por favor, instale o Advanced Wrapper e então você pode alterar as configurações dos fluxos de áudio." "Veuillez installer Advanced Wrapper et vous pourrez ensuite modifier les paramètres des flux audio." "Bitte installieren Sie den Advanced Wrapper und dann können Sie die Einstellungen der Audiostreams ändern." "Si prega di installare il wrapper avanzato e quindi è possibile modificare le impostazioni dei flussi audio.")
    

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
text_configC_1=("Changing the 5.1 audio codec from AAC 512kbps to AC3 640kbps regardless of the order of its audio streams in VIDEO-STATION." "Cambiando el codec de audio 5.1 de AAC 512kbps a AC3 640kbps independientemente del orden de sus flujos de audio en VIDEO-STATION." "Alterando o codec de áudio 5.1 de AAC 512kbps para AC3 640kbps, independentemente da ordem de seus fluxos de áudio em VIDEO-STATION." "Changement du codec audio 5.1 de AAC 512kbps à AC3 640kbps quel que soit l'ordre de ses flux audio dans VIDEO-STATION." "Ändern des 5.1-Audiocodecs von AAC 512kbps auf AC3 640kbps, unabhängig von der Reihenfolge seiner Audiostreams in VIDEO-STATION." "Modifica del codec audio 5.1 da AAC 512kbps ad AC3 640kbps indipendentemente dall'ordine dei suoi flussi audio in VIDEO-STATION.")
text_configC_2=("Sucesfully changed the 5.1 audio's codec from AAC 512kbps to AC3 640kbps in VIDEO-STATION." "Cambiado correctamente el codec de audio 5.1 de AAC 512kbps a AC3 640kbps en VIDEO-STATION." "Mudou com sucesso o codec de áudio 5.1 de AAC 512kbps para AC3 640kbps no VIDEO-STATION." "Changement réussi du codec audio 5.1 de AAC 512kbps à AC3 640kbps sur VIDEO-STATION." "Der 5.1-Audio-Codec wurde erfolgreich von AAC 512 kbps auf AC3 640 kbps auf VIDEO-STATION geändert." "Modificato con successo il codec audio 5.1 da AAC 512kbps a AC3 640kbps su VIDEO-STATION.")
text_configC_3=("==================== Configuration of the Advanced Wrapper: COMPLETE ====================" "==================== Configuración del Wrapper Avanzado: COMPLETADA ====================" "==================== Configuração avançada do wrapper: CONCLUÍDO ====================" "==================== Configuration avancée de l'encapsuleur : TERMINÉE ====================" "==================== Erweiterte Wrapper-Konfiguration: ABGESCHLOSSEN ====================" "==================== Configurazione avanzata del wrapper: COMPLETATA ====================")
text_configC_4=("Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
text_configC_5=("Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams." "Por favor, Instala el Wrapper Avanzado y después podrás cambiar la configuración de los flujos de audio." "Por favor, instale o Advanced Wrapper e então você pode alterar as configurações dos fluxos de áudio." "Veuillez installer Advanced Wrapper et vous pourrez ensuite modifier les paramètres des flux audio." "Bitte installieren Sie den Advanced Wrapper und dann können Sie die Einstellungen der Audiostreams ändern." "Si prega di installare il wrapper avanzato e quindi è possibile modificare le impostazioni dei flussi audio.")
text_configC_6=("Changing the 5.1 audio codec from AAC 512kbps to AC3 640kbps regardless of the order of its audio streams in VIDEO-STATION and DLNA MediaServer." "Cambiando el codec de audio 5.1 de AAC 512kbps a AC3 640kbps independientemente del orden de sus flujos de audio en VIDEO-STATION y en DLNA MediaServer." "Alterando o codec de áudio 5.1 de AAC 512kbps para AC3 640kbps, independentemente da ordem de seus fluxos de áudio no VIDEO-STATION e no DLNA MediaServer." "Changer le codec audio 5.1 de AAC 512kbps à AC3 640kbps quel que soit l'ordre de leurs flux audio sur la VIDEO-STATION et sur le DLNA MediaServer." "Ändern des 5.1-Audiocodecs von AAC 512kbps auf AC3 640kbps, unabhängig von der Reihenfolge ihrer Audiostreams auf der VIDEO-STATION und auf dem DLNA-MediaServer." "Modifica del codec audio 5.1 da AAC 512kbps ad AC3 640kbps indipendentemente dall'ordine dei flussi audio sulla VIDEO-STATION e sul DLNA MediaServer.")
text_configC_7=("Sucesfully changed the 5.1 audio's codec from AAC 512kbps to AC3 640kbps in VIDEO-STATION and DLNA MediaServer." "Cambiado correctamente el codec de audio 5.1 de AAC 512kbps a AC3 640kbps en VIDEO-STATION y en DLNA MediaServer." "Alterou com sucesso o codec de áudio 5.1 de AAC 512kbps para AC3 640kbps em VIDEO-STATION e DLNA MediaServer." "Changement réussi du codec audio 5.1 de AAC 512kbps à AC3 640kbps sur VIDEO-STATION et DLNA MediaServer." "Der 5.1-Audio-Codec wurde erfolgreich von AAC 512 kbps auf AC3 640 kbps auf VIDEO-STATION und DLNA MediaServer geändert." "Modificato con successo il codec audio 5.1 da AAC 512kbps a AC3 640kbps su VIDEO-STATION e DLNA MediaServer.")    

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
text_configD_1=("Changing to use FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps in DLNA MediaServer." "Cambiando para usar PRIMER FLUJO= AAC 5.1 512kbps (o AC3 5.1 640kbps), SEGUNDO FLUJO= MP3 2.0 256kbps en DLNA MediaServer." "Mudando para usar FIRST STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps na DLNA MediaServer." "Commutation pour utiliser PREMIER FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps), SECOND FLUX = MP3 2.0 256kbps sur DLNA MediaServer." "Umschalten zur Verwendung des ERSTEN STREAM= AAC 5.1 512 kbps (oder AC3 5.1 640 kbps), ZWEITER STREAM= MP3 2.0 256 kbps auf DLNA MediaServer." "Passaggio all'uso del PRIMO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps), SECONDO STREAM= MP3 2.0 256 kbps su DLNA MediaServer.")
text_configD_2=("Sucesfully changed the audio stream's order to: 1) AAC 5.1 512kbps (or AC3 5.1 640kbps) and 2) MP3 2.0 256kbps in DLNA MediaServer." "Cambiado correctamente el orden de los flujos de audio a: 1) AAC 5.1 512kbps (o AC3 5.1 640kbps) y 2) MP3 2.0 256kbps en DLNA MediaServer." "Alterou corretamente a ordem dos fluxos de áudio para: 1) AAC 5.1 512kbps (ou AC3 5.1 640kbps) e 2) MP3 2.0 256kbps no DLNA MediaServer." "Changement correct de l'ordre des flux audio en : 1) AAC 5.1 512kbps (ou AC3 5.1 640kbps) et 2) MP3 2.0 256kbps sur DLNA MediaServer." "Die Reihenfolge der Audiostreams wurde auf DLNA MediaServer korrekt geändert in: 1) AAC 5.1 512 kbps (oder AC3 5.1 640 kbps) und 2) MP3 2.0 256 kbps." "Modificato correttamente l'ordine dei flussi audio in: 1) AAC 5.1 512kbps (o AC3 5.1 640kbps) e 2) MP3 2.0 256kbps su DLNA MediaServer.")
text_configD_3=("Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
text_configD_4=("Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams." "Por favor, Instala el Wrapper Avanzado y después podrás cambiar la configuración de los flujos de audio." "Por favor, instale o Advanced Wrapper e então você pode alterar as configurações dos fluxos de áudio." "Veuillez installer Advanced Wrapper et vous pourrez ensuite modifier les paramètres des flux audio." "Bitte installieren Sie den Advanced Wrapper und dann können Sie die Einstellungen der Audiostreams ändern." "Si prega di installare il wrapper avanzato e quindi è possibile modificare le impostazioni dei flussi audio.")
text_configD_5=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED in DLNA MediaServer so this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO en DLNA MediaServer y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O ADVANCED WRAPPER INSTALADO no DLNA MediaServer e este Codec Configurator NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS ADVANCED WRAPPER INSTALLÉ sur DLNA MediaServer et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit KEINEN ADVANCED WRAPPER auf dem DLNA MediaServer INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI WRAPPER AVANZATO INSTALLATO su DLNA MediaServer e questo configuratore di codec NON PUÒ modificare nulla.")    

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
text_configE_1=("Changing to use FIRST STREAM= MP3 2.0 256kbps, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) in DLNA MediaServer." "Cambiando para usar PRIMER FLUJO= MP3 2.0 256kbps, SEGUNDO FLUJO= AAC 5.1 512kbps (o AC3 5.1 640kbps) en DLNA MediaServer." "Mudando para usar FIRST STREAM= MP3 2.0 256kbps, SECOND STREAM= AAC 5.1 512kbps (o AC3 5.1 640kbps) na DLNA MediaServer." "Commutation pour utiliser PREMIER FLUX = MP3 2.0 256kbps, SECOND FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps) sur DLNA MediaServer." "Umschalten zur Verwendung des ERSTEN STREAM= MP3 2.0 256 kbps, ZWEITER STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps) auf DLNA MediaServer." "Passaggio all'uso del PRIMO STREAM= MP3 2.0 256 kbps, SECONDO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps) su DLNA MediaServer.")
text_configE_2=("Sucesfully changed the audio stream's order to: 1) MP3 2.0 256kbps and 2) AAC 5.1 512kbps (or AC3 5.1 640kbps) in DLNA MediaServer." "Cambiado correctamente el orden de los flujos de audio a: 1) MP3 2.0 256kbps y 2) AAC 5.1 512kbps (o AC3 5.1 640kbps) en DLNA MediaServer." "Alterou corretamente a ordem dos fluxos de áudio para: 1) MP3 2.0 256kbps e 2) AAC 5.1 512kbps (ou AC3 5.1 640kbps) no DLNA MediaServer." "Changement correct de l'ordre des flux audio en : 1) MP3 2.0 256kbps et 2) AAC 5.1 512kbps (ou AC3 5.1 640kbps) sur DLNA MediaServer." "Die Reihenfolge der Audiostreams wurde auf DLNA MediaServer korrekt geändert in: 1) MP3 2.0 256 kbps und 2) AAC 5.1 512 kbps (oder AC3 5.1 640 kbps)." "Modificato correttamente l'ordine dei flussi audio in: 1) MP3 2.0 256kbps e 2) AAC 5.1 512kbps (o AC3 5.1 640kbps) su DLNA MediaServer.")
text_configE_3=("Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
text_configE_4=("Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams." "Por favor, Instala el Wrapper Avanzado y después podrás cambiar la configuración de los flujos de audio." "Por favor, instale o Advanced Wrapper e então você pode alterar as configurações dos fluxos de áudio." "Veuillez installer Advanced Wrapper et vous pourrez ensuite modifier les paramètres des flux audio." "Bitte installieren Sie den Advanced Wrapper und dann können Sie die Einstellungen der Audiostreams ändern." "Si prega di installare il wrapper avanzato e quindi è possibile modificare le impostazioni dei flussi audio.")
text_configE_5=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED in DLNA MediaServer so this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO en DLNA MediaServer y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O ADVANCED WRAPPER INSTALADO no DLNA MediaServer e este Codec Configurator NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS ADVANCED WRAPPER INSTALLÉ sur DLNA MediaServer et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit KEINEN ADVANCED WRAPPER auf dem DLNA MediaServer INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI WRAPPER AVANZATO INSTALLATO su DLNA MediaServer e questo configuratore di codec NON PUÒ modificare nulla.")    


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
text_configF_1=("Changing the 5.1 audio codec from AC3 640kbps to AAC 512kbps regardless of the order of its audio streams in VIDEO-STATION." "Cambiando el codec de audio 5.1 de AC3 640kbps a AAC 512kbps independientemente del orden de sus flujos de audio en VIDEO-STATION." "Alterando o codec de áudio 5.1 de AC3 640kbps para AAC 512kbps, independentemente da ordem de seus fluxos de áudio em VIDEO-STATION." "Changement du codec audio 5.1 de AC3 640kbps à AAC 512kbps quel que soit l'ordre de ses flux audio dans VIDEO-STATION." "Ändern des 5.1-Audiocodecs von AC3 640kbps auf AAC 512kbps, unabhängig von der Reihenfolge seiner Audiostreams in VIDEO-STATION." "Modifica del codec audio 5.1 da AC3 640kbps ad AAC 512kbps indipendentemente dall'ordine dei suoi flussi audio in VIDEO-STATION.")
text_configF_2=("Sucesfully changed the 5.1 audio's codec from AC3 640kbps to AAC 512kbps in VIDEO-STATION." "Cambiado correctamente el codec de audio 5.1 de AC3 640kbps a AAC 512kbps en VIDEO-STATION." "Mudou com sucesso o codec de áudio 5.1 de AC3 640kbps para AAC 512kbps no VIDEO-STATION." "Changement réussi du codec audio 5.1 de AC3 640kbps à AAC 512kbps sur VIDEO-STATION." "Der 5.1-Audio-Codec wurde erfolgreich von AC3 640 kbps auf AAC 512 kbps auf VIDEO-STATION geändert." "Modificato con successo il codec audio 5.1 da AC3 640kbps a AAC 512kbps su VIDEO-STATION.")
text_configF_3=("==================== Configuration of the Advanced Wrapper: COMPLETE ====================" "==================== Configuración del Wrapper Avanzado: COMPLETADA ====================" "==================== Configuração avançada do wrapper: CONCLUÍDO ====================" "==================== Configuration avancée de l'encapsuleur : TERMINÉE ====================" "==================== Erweiterte Wrapper-Konfiguration: ABGESCHLOSSEN ====================" "==================== Configurazione avanzata del wrapper: COMPLETATA ====================")
text_configF_4=("Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
text_configF_5=("Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams." "Por favor, Instala el Wrapper Avanzado y después podrás cambiar la configuración de los flujos de audio." "Por favor, instale o Advanced Wrapper e então você pode alterar as configurações dos fluxos de áudio." "Veuillez installer Advanced Wrapper et vous pourrez ensuite modifier les paramètres des flux audio." "Bitte installieren Sie den Advanced Wrapper und dann können Sie die Einstellungen der Audiostreams ändern." "Si prega di installare il wrapper avanzato e quindi è possibile modificare le impostazioni dei flussi audio.")
text_configF_6=("Changing the 5.1 audio codec from AC3 640kbps to AAC 512kbps regardless of the order of its audio streams in VIDEO-STATION and DLNA MediaServer." "Cambiando el codec de audio 5.1 de AC3 640kbps a AAC 512kbps independientemente del orden de sus flujos de audio en VIDEO-STATION y en DLNA MediaServer." "Alterando o codec de áudio 5.1 de AC3 640kbps para AAC 512kbps, independentemente da ordem de seus fluxos de áudio no VIDEO-STATION e no DLNA MediaServer." "Changer le codec audio 5.1 de AC3 640kbps à AAC 512kbps quel que soit l'ordre de leurs flux audio sur la VIDEO-STATION et sur le DLNA MediaServer." "Ändern des 5.1-Audiocodecs von AC3 640kbps auf AAC 512kbps, unabhängig von der Reihenfolge ihrer Audiostreams auf der VIDEO-STATION und auf dem DLNA-MediaServer." "Modifica del codec audio 5.1 da AC3 640kbps ad AAC 512kbps indipendentemente dall'ordine dei flussi audio sulla VIDEO-STATION e sul DLNA MediaServer.")
text_configF_7=("Sucesfully changed the 5.1 audio's codec from AC3 640kbps to AAC 512kbps in VIDEO-STATION and DLNA MediaServer." "Cambiado correctamente el codec de audio 5.1 de AC3 640kbps a AAC 512kbps en VIDEO-STATION y en DLNA MediaServer." "Alterou com sucesso o codec de áudio 5.1 de AC3 640kbps para AAC 512kbps em VIDEO-STATION e DLNA MediaServer." "Changement réussi du codec audio 5.1 de AC3 640kbps à AAC 512kbps sur VIDEO-STATION et DLNA MediaServer." "Der 5.1-Audio-Codec wurde erfolgreich von AC3 640 kbps auf AAC 512 kbps auf VIDEO-STATION und DLNA MediaServer geändert." "Modificato con successo il codec audio 5.1 da AC3 640kbps a AAC 512kbps su VIDEO-STATION e DLNA MediaServer.")    


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
text_configG_1=("Changing to use only an Unique Audio's Stream in VIDEO-STATION (the first stream you had selected before) for save the system resources in low powered devices." "Cambiando para usar un único flujo de audio en VIDEO-STATION (el primer flujo que se haya seleccionado antes) para ahorrar recursos de sistema en dispositivos poco potentes." "Mudar para usar um único fluxo de áudio em VIDEO-STATION (o primeiro fluxo selecionado antes) para economizar recursos do sistema em dispositivos menos potentes." "Commutation pour utiliser un seul flux audio dans VIDEO-STATION (le premier flux sélectionné auparavant) pour économiser les ressources système sur les appareils moins puissants." "Umschalten auf die Verwendung eines einzelnen Audiostreams in VIDEO-STATION (der erste Stream, der zuvor ausgewählt wurde), um Systemressourcen auf weniger leistungsstarken Geräten zu sparen." "Passaggio all'utilizzo di un unico flusso audio in VIDEO-STATION (il primo flusso selezionato in precedenza) per risparmiare risorse di sistema su dispositivi meno potenti.")
text_configG_2=("Sucesfully changed to use only an Unique Audio's Stream in VIDEO-STATION (the first stream you had selected before) for save the system resources in low powered devices." "Cambiado correctamente para usar un único flujo de audio en VIDEO-STATION (el primer flujo que se haya seleccionado antes) para ahorrar recursos de sistema en dispositivos poco potentes." "Corretamente alterado para usar um único fluxo de áudio no VIDEO-STATION (o primeiro fluxo selecionado antes) para economizar recursos do sistema em dispositivos menos potentes." "Correctement changé pour utiliser un seul flux audio sur VIDEO-STATION (le premier flux sélectionné auparavant) pour économiser les ressources système sur les appareils moins puissants." "Korrekterweise geändert, um einen einzelnen Audiostream auf VIDEO-STATION (der erste zuvor ausgewählte Stream) zu verwenden, um Systemressourcen auf weniger leistungsstarken Geräten zu sparen." "Modificato correttamente per utilizzare un unico flusso audio su VIDEO-STATION (il primo flusso selezionato prima) per risparmiare risorse di sistema su dispositivi meno potenti.")
text_configG_3=("==================== Configuration of the Advanced Wrapper: COMPLETE ====================" "==================== Configuración del Wrapper Avanzado: COMPLETADA ====================" "==================== Configuração avançada do wrapper: CONCLUÍDO ====================" "==================== Configuration avancée de l'encapsuleur : TERMINÉE ====================" "==================== Erweiterte Wrapper-Konfiguration: ABGESCHLOSSEN ====================" "==================== Configurazione avanzata del wrapper: COMPLETATA ====================")
text_configG_4=("Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
text_configG_5=("Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams." "Por favor, Instala el Wrapper Avanzado y después podrás cambiar la configuración de los flujos de audio." "Por favor, instale o Advanced Wrapper e então você pode alterar as configurações dos fluxos de áudio." "Veuillez installer Advanced Wrapper et vous pourrez ensuite modifier les paramètres des flux audio." "Bitte installieren Sie den Advanced Wrapper und dann können Sie die Einstellungen der Audiostreams ändern." "Si prega di installare il wrapper avanzato e quindi è possibile modificare le impostazioni dei flussi audio.")

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
text_configH_1=("Changing to use only an Unique Audio's Stream in DLNA MediaServer (the first stream you had selected before) for save the system resources in low powered devices." "Cambiando para usar un único flujo de audio en DLNA MediaServer (el primer flujo que se haya seleccionado antes) para ahorrar recursos de sistema en dispositivos poco potentes." "Mudar para usar um único fluxo de áudio em DLNA MediaServer (o primeiro fluxo selecionado antes) para economizar recursos do sistema em dispositivos menos potentes." "Commutation pour utiliser un seul flux audio dans DLNA MediaServer (le premier flux sélectionné auparavant) pour économiser les ressources système sur les appareils moins puissants." "Umschalten auf die Verwendung eines einzelnen Audiostreams in DLNA MediaServer (der erste Stream, der zuvor ausgewählt wurde), um Systemressourcen auf weniger leistungsstarken Geräten zu sparen." "Passaggio all'utilizzo di un unico flusso audio in DLNA MediaServer (il primo flusso selezionato in precedenza) per risparmiare risorse di sistema su dispositivi meno potenti.")
text_configH_2=("Sucesfully changed to use only an Unique Audio's Stream in DLNA MediaServer (the first stream you had selected before) for save the system resources in low powered devices." "Cambiado correctamente para usar un único flujo de audio en DLNA MediaServer (el primer flujo que se haya seleccionado antes) para ahorrar recursos de sistema en dispositivos poco potentes." "Corretamente alterado para usar um único fluxo de áudio no DLNA MediaServer (o primeiro fluxo selecionado antes) para economizar recursos do sistema em dispositivos menos potentes." "Correctement changé pour utiliser un seul flux audio sur DLNA MediaServer (le premier flux sélectionné auparavant) pour économiser les ressources système sur les appareils moins puissants." "Korrekterweise geändert, um einen einzelnen Audiostream auf DLNA MediaServer (der erste zuvor ausgewählte Stream) zu verwenden, um Systemressourcen auf weniger leistungsstarken Geräten zu sparen." "Modificato correttamente per utilizzare un unico flusso audio su DLNA MediaServer (il primo flusso selezionato prima) per risparmiare risorse di sistema su dispositivi meno potenti.")
text_configH_3=("Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
text_configH_4=("Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams." "Por favor, Instala el Wrapper Avanzado y después podrás cambiar la configuración de los flujos de audio." "Por favor, instale o Advanced Wrapper e então você pode alterar as configurações dos fluxos de áudio." "Veuillez installer Advanced Wrapper et vous pourrez ensuite modifier les paramètres des flux audio." "Bitte installieren Sie den Advanced Wrapper und dann können Sie die Einstellungen der Audiostreams ändern." "Si prega di installare il wrapper avanzato e quindi è possibile modificare le impostazioni dei flussi audio.")
text_configH_5=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED in DLNA MediaServer so this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO en DLNA MediaServer y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O ADVANCED WRAPPER INSTALADO no DLNA MediaServer e este Codec Configurator NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS ADVANCED WRAPPER INSTALLÉ sur DLNA MediaServer et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit KEINEN ADVANCED WRAPPER auf dem DLNA MediaServer INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI WRAPPER AVANZATO INSTALLATO su DLNA MediaServer e questo configuratore di codec NON PUÒ modificare nulla.")    

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

function config_I() {
text_configI_1=("Changing the number of audio channels in the VIDEO-STATION OffLine transcoding. (2.0)" "Cambiando el número de canales de audio en la transcodificación OffLine del VIDEO-STATION. (2.0)" "Alterando o número de canais de áudio na transcodificação VIDEO-STATION OffLine. (2.0)" "Modification du nombre de canaux audio dans le transcodage VIDEO-STATION OffLine. (2.0)" "Ändern der Anzahl der Audiokanäle bei der VIDEO-STATION OffLine-Transkodierung. (2.0)" "Modifica del numero di canali audio nella transcodifica OffLine di VIDEO-STATION. (2.0)")
text_configI_2=("Correctly changed the number of audio channels in the OffLine transcoding of the VIDEO-STATION. (2.0)" "Cambiado correctamente el número de canales de audio en la transcodificación OffLine del VIDEO-STATION. (2.0)" "Alterado corretamente o número de canais de áudio na transcodificação OffLine da VIDEO-STATION. (2.0)" "Correction correcte du nombre de canaux audio dans le transcodage hors ligne de la VIDEO-STATION. (2.0)" "Die Anzahl der Audiokanäle bei der Offline-Transkodierung der VIDEO-STATION wurde korrekt geändert. (2.0)" "Modificato correttamente il numero di canali audio nella transcodifica OffLine della VIDEO-STATION. (2.0)")
text_configI_3=("==================== Configuration of the Advanced Wrapper: COMPLETE ====================" "==================== Configuración del Wrapper Avanzado: COMPLETADA ====================" "==================== Configuração avançada do wrapper: CONCLUÍDO ====================" "==================== Configuration avancée de l'encapsuleur : TERMINÉE ====================" "==================== Erweiterte Wrapper-Konfiguration: ABGESCHLOSSEN ====================" "==================== Configurazione avanzata del wrapper: COMPLETATA ====================")
text_configI_4=("Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
text_configI_5=("Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams." "Por favor, Instala el Wrapper Avanzado y después podrás cambiar la configuración de los flujos de audio." "Por favor, instale o Advanced Wrapper e então você pode alterar as configurações dos fluxos de áudio." "Veuillez installer Advanced Wrapper et vous pourrez ensuite modifier les paramètres des flux audio." "Bitte installieren Sie den Advanced Wrapper und dann können Sie die Einstellungen der Audiostreams ändern." "Si prega di installare il wrapper avanzato e quindi è possibile modificare le impostazioni dei flussi audio.")

if [[ "$check_amrif" == "$firma2" ]]; then 
info "${YELLOW}${text_configI_1[$LANG]}"
info "${YELLOW}Changing the number of audio channels in the VIDEO-STATION OffLine transcoding. (2.0)" >> $logfile
    sed -i 's/args2trans+=("-c:a" "libfdk_aac")/args2trans+=("-c:a" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2trans+=("-b:a" "512k")/args2trans+=("-b:a" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2trans+=("-ac" "6")/args2trans+=("-ac" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}${text_configI_2[$LANG]}"
    echo ""
    echo -e "${BLUE}${text_configI_3[$LANG]}"
    info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
    exit 0  
fi

if [[ "$check_amrif" == "$firma" ]]; then  
info "${YELLOW}${text_configI_1[$LANG]}"
info "${YELLOW}Changing the number of audio channels in the VIDEO-STATION OffLine transcoding. (2.0)" >> $logfile
    sed -i 's/args2trans+=("-c:a" "libfdk_aac")/args2trans+=("-c:a" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2trans+=("-b:a" "512k")/args2trans+=("-b:a" "256k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2trans+=("-ac" "6")/args2trans+=("-ac" "$1")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}${text_configI_2[$LANG]}"
    echo ""
 else
   info "${RED}${text_configI_4[$LANG]}"
   info "${RED}Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configI_5[$LANG]}"
   start
fi  
}

function config_J() {
text_configJ_1=("Changing the number of audio channels in the VIDEO-STATION OffLine transcoding. (5.1)" "Cambiando el número de canales de audio en la transcodificación OffLine del VIDEO-STATION. (5.1)" "Alterando o número de canais de áudio na transcodificação VIDEO-STATION OffLine. (5.1)" "Modification du nombre de canaux audio dans le transcodage VIDEO-STATION OffLine. (5.1)" "Ändern der Anzahl der Audiokanäle bei der VIDEO-STATION OffLine-Transkodierung. (5.1)" "Modifica del numero di canali audio nella transcodifica OffLine di VIDEO-STATION. (5.1)")
text_configJ_2=("Correctly changed the number of audio channels in the OffLine transcoding of the VIDEO-STATION. (5.1)" "Cambiado correctamente el número de canales de audio en la transcodificación OffLine del VIDEO-STATION. (5.1)" "Alterado corretamente o número de canais de áudio na transcodificação OffLine da VIDEO-STATION. (5.1)" "Correction correcte du nombre de canaux audio dans le transcodage hors ligne de la VIDEO-STATION. (5.1)" "Die Anzahl der Audiokanäle bei der Offline-Transkodierung der VIDEO-STATION wurde korrekt geändert. (5.1)" "Modificato correttamente il numero di canali audio nella transcodifica OffLine della VIDEO-STATION. (5.1)")
text_configJ_3=("==================== Configuration of the Advanced Wrapper: COMPLETE ====================" "==================== Configuración del Wrapper Avanzado: COMPLETADA ====================" "==================== Configuração avançada do wrapper: CONCLUÍDO ====================" "==================== Configuration avancée de l'encapsuleur : TERMINÉE ====================" "==================== Erweiterte Wrapper-Konfiguration: ABGESCHLOSSEN ====================" "==================== Configurazione avanzata del wrapper: COMPLETATA ====================")
text_configJ_4=("Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
text_configJ_5=("Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams." "Por favor, Instala el Wrapper Avanzado y después podrás cambiar la configuración de los flujos de audio." "Por favor, instale o Advanced Wrapper e então você pode alterar as configurações dos fluxos de áudio." "Veuillez installer Advanced Wrapper et vous pourrez ensuite modifier les paramètres des flux audio." "Bitte installieren Sie den Advanced Wrapper und dann können Sie die Einstellungen der Audiostreams ändern." "Si prega di installare il wrapper avanzato e quindi è possibile modificare le impostazioni dei flussi audio.")

if [[ "$check_amrif" == "$firma2" ]]; then 
info "${YELLOW}${text_configJ_1[$LANG]}"
info "${YELLOW}Changing the number of audio channels in the VIDEO-STATION OffLine transcoding. (5.1)" >> $logfile
    sed -i 's/args2trans+=("-c:a" "$1")/args2trans+=("-c:a" "libfdk_aac")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2trans+=("-b:a" "256k")/args2trans+=("-b:a" "512k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2trans+=("-ac" "$1")/args2trans+=("-ac" "6")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}${text_configJ_2[$LANG]}"
    echo ""
    echo -e "${BLUE}${text_configJ_3[$LANG]}"
    info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
    exit 0  
fi

if [[ "$check_amrif" == "$firma" ]]; then  
info "${YELLOW}${text_configJ_1[$LANG]}"
info "${YELLOW}Changing the number of audio channels in the VIDEO-STATION OffLine transcoding. (5.1)" >> $logfile
    sed -i 's/args2trans+=("-c:a" "$1")/args2trans+=("-c:a" "libfdk_aac")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2trans+=("-b:a" "256k")/args2trans+=("-b:a" "512k")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    sed -i 's/args2trans+=("-ac" "$1")/args2trans+=("-ac" "6")/gi' ${cp_bin_path}/ffmpeg41 2>> $logfile
    info "${GREEN}${text_configJ_2[$LANG]}"
    echo ""
 else
   info "${RED}${text_configJ_4[$LANG]}"
   info "${RED}Actually you HAVEN'T INSTALLED THE ADVANCED WRAPPER so this codec configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configJ_5[$LANG]}"
   start
fi  
}

function start() {
text_start_1=("THIS IS THE MAIN MENU, PLEASE CHOOSE YOUR SELECTION:" "ESTE ES EL MENÚ PRINCIPAL, POR FAVOR ESCOGE TU SELECCIÓN:" "ESTE É O MENU PRINCIPAL, POR FAVOR, ESCOLHA SUA SELEÇÃO:" "CECI EST LE MENU PRINCIPAL, VEUILLEZ CHOISIR VOTRE SÉLECTION:" "DAS IST DAS HAUPTMENÜ, BITTE WÄHLEN SIE IHRE AUSWAHL:" "QUESTO È IL MENU PRINCIPALE, SCEGLI LA TUA SELEZIONE:")
text_start_2=("Install the Advanced Wrapper for VideoStation and DLNA MediaServer (If exist). (With 5.1 and 2.0 support, configurable)" "Instalar el Advanced Wrapper para VideoStation y DLNA MediaServer (si existe). (Con soporte 5.1 y 2.0, configurable)" "Instale o Advanced Wrapper for VideoStation e DLNA MediaServer (se houver). (Com suporte 5.1 e 2.0, configurável)" "Installez le Advanced Wrapper pour VideoStation et DLNA MediaServer (le cas échéant). (Avec prise en charge 5.1 et 2.0, configurable)" "Installieren Sie den Advanced Wrapper for VideoStation und DLNA MediaServer (falls vorhanden). (Mit 5.1 und 2.0 Unterstützung, konfigurierbar)" "Installare il Advanced Wrapper per VideoStation e DLNA MediaServer (se presente). (Con supporto 5.1 e 2.0, configurabile)")
text_start_3=("Install the Simplest Wrapper for VideoStation and DLNA MediaServer (If exist). (Only 2.0 support, NOT configurable)" "Instalar el Wrapper más simple para VideoStation y DLNA MediaServer (si existe). (Con soporte 2.0 solamente, NO configurable)" "Instale o Wrapper mais simples para VideoStation e DLNA MediaServer (se houver). (Somente com suporte 2.0, NÃO configurável)" "Installez le wrapper le plus simple pour VideoStation et DLNA MediaServer (le cas échéant). (Avec prise en charge 2.0 uniquement, NON configurable)" "Installieren Sie den einfachsten Wrapper für VideoStation und DLNA MediaServer (falls vorhanden). (Nur mit 2.0-Unterstützung, NICHT konfigurierbar)" "Installare il wrapper più semplice per VideoStation e DLNA MediaServer (se presente). (Solo con supporto 2.0, NON configurabile)")
text_start_4=("Uninstall the Simplest or the Advanced Wrappers for VideoStation and DLNA MediaServer." "Desinstalar el Wrapper más simple o el Advanced de VideoStation y del DLNA MediaServer." "Desinstale o Simpler ou Advanced Wrapper do VideoStation e do DLNA MediaServer." "Désinstallez Simpler ou Advanced Wrapper de VideoStation et DLNA MediaServer." "Deinstallieren Sie Simpler oder Advanced Wrapper von VideoStation und DLNA MediaServer." "Disinstallare Simpler o Advanced Wrapper da VideoStation e DLNA MediaServer.")
text_start_5=("Change the config of the Advanced Wrapper for change the audio's codecs in VIDEO-STATION and DLNA." "Cambia la configuración del Advanced Wrapper para cambiar los codecs de audio en VIDEO-STATION y DLNA." "Altere as configurações do Advanced Wrapper para alterar os codecs de áudio em VIDEO-STATION e DLNA." "Modifiez les paramètres Advanced Wrapper pour modifier les codecs audio dans VIDEO-STATION et DLNA." "Ändern Sie die erweiterten Wrapper-Einstellungen, um die Audio-Codecs in VIDEO-STATION und DLNA zu ändern." "Modificare le impostazioni di Advanced Wrapper per modificare i codec audio in VIDEO-STATION e DLNA.")
text_start_6=("Change the LANGUAGE in this Installer." "Cambiar el IDIOMA en este Instalador." "Altere o IDIOMA neste Instalador." "Modifiez la LANGUE dans ce programme d'installation." "Ändern Sie die SPRACHE in diesem Installationsprogramm." "Cambia la LINGUA in questo programma di installazione.")
text_start_7=("EXIT from this Installer." "SALIR de este Instalador." "SAIR deste instalador." "QUITTER ce programme d'installation." "BEENDEN Sie dieses Installationsprogramm." "ESCI da questo programma di installazione.")
text_start_8=("Please, What option wish to use?" "Por favor, ¿Qué opción desea utilizar?" "Por favor, qual opção você quer usar?" "S'il vous plaît, quelle option voulez-vous utiliser ?" "Bitte, welche Option möchten Sie verwenden?" "Per favore, quale opzione vuoi usare?")
text_start_9=("Please answer I or Install | S or Simple | U or Uninstall | C or Config | L or Language | P or Patch | Z for Exit." "Por favor responda I o Instalar | S o Simple | U o Uninstall | C o Configuración | L o Lengua | P o Patch | Z para Salir." "Por favor, responda I ou Instalar | S ou Simples | U ou Uninstall | C ou Configuração | L ou Língua | P ou Patch | Z para Sair." "Veuillez répondre I ou Installer | S ou Simple | U ou Uninstall | C ou Configuration | L ou Langue | P ou patch | Z pour quitter." "Bitte antworten Sie I oder Installieren Sie | S oder Simple | U oder Uninstall | C oder Config | L oder Language | P oder Patch | Z zum Beenden." "Per favore rispondi I o Installa | S o Semplice | U o Uninstall | C o Configurazione | L o Lingua | P o Patch | Z per uscire.")
text_start_10=("Menu for the CRACK of the AME's License. (BETA)" "Menú para el CRACK de la Licencia AME. (BETA)" "Menu para o CRACK da Licença AME. (BETA)" "Menu pour le CRACK de la licence AME. (BETA)" "Menü für den AME-Lizenz-CRACK. (BETA)" "Menu per il CRACK della licenza AME. (BETA)")

   echo ""
   echo ""
   echo -e "${YELLOW}${text_start_1[$LANG]}"
   echo ""
   echo -e "${BLUEGSLP} ( I ) ${text_start_2[$LANG]}"
   echo -e "${BLUE} ( S ) ${text_start_3[$LANG]}"
   echo -e "${BLUE} ( U ) ${text_start_4[$LANG]}" 
   echo -e "${BLUE} ( C ) ${text_start_5[$LANG]}"
   echo -e "${BLUE} ( L ) ${text_start_6[$LANG]}"
   echo -e "${BLUE} ( P ) ${text_start_10[$LANG]}"
   echo ""
   echo -e "${PURPLE} ( Z ) ${text_start_7[$LANG]}"
        while true; do
	echo -e "${GREEN}"
        read -p "${text_start_8[$LANG]}" isuclpz
        case $isuclpz in
        [Ii]* ) install_advanced;;
        [Ss]* ) install_simple;;
        [Uu]* ) uninstall_new;;
	[Cc]* ) configurator;;
	[Ll]* ) language;;
	[Pp]* ) crackmenu;;
      	[Zz]* ) exit 0;;
        * ) echo -e "${YELLOW}${text_start_9[$LANG]}";;
        esac
        done
}

function titulo() {
   clear
text_titulo_1=("====================FFMPEG WRAPPER INSTALLER FOR DSM 7.0 and above by Dark Nebular.====================" "====================INSTALADOR DE WRAPPER FFMPEG PARA DSM 7.0 y superior de Dark Nebular.====================" "==================== INSTALADOR DO FFMPEG WRAPPER PARA DSM 7.0 e superior de Dark Nebular.======================" "==================== FFMPEG WRAPPER INSTALLER POUR DSM 7.0 et supérieur de Dark Nebular.====================" "==================== FFMPEG WRAPPER INSTALLER FÜR DSM 7.0 und höher von Dark Nebular.=====================" "==================== INSTALLER FFMPEG WRAPPER PER DSM 7.0 e versioni successive da Dark Nebular.=======================")
text_titulo_2=("====================This Wrapper Installer is only avalaible for DSM 7.0 and above only====================" "====================Este Instalador de Wrapper sólo está disponible para DSM 7.0 y superiores====================" "====================Este Instalador do Wrapper está disponível apenas para DSM 7.0 e superior======================" "====================Ce Wrapper Installer est uniquement disponible pour DSM 7.0 et supérieur=====================" "====================Dieser Wrapper-Installer ist nur für DSM 7.0 und höher verfügbar=====================" "=====================Questo programma di installazione wrapper è disponibile solo per DSM 7.0 e versioni successive=====================")

echo -e "${BLUE}${text_titulo_1[$LANG]}"
echo -e "${BLUE}${text_titulo_2[$LANG]}"
echo ""
echo ""
}

function check_root() {
# NO SE TRADUCE
   if [[ $EUID -ne 0 ]]; then
  error "YOU MUST BE ROOT FOR EXECUTE THIS INSTALLER. Please write ("${PURPLE}" sudo -i "${RED}") and try again with the Installer."
  exit 1
fi
}

function check_licence_AME() {
# NO SE TRADUCE
if [[ ! -f /usr/syno/etc/codec/activation.conf ]]; then
error "YOU HAVEN'T THE LICENCE LOADED in Advanced Media Extension package. Please, LOAD this licence and try again with the Installer."
error "YOU HAVEN'T THE LICENCE LOADED in Advanced Media Extension package. Please, LOAD this licence and try again with the Installer." >> $logfile
exit 1
fi
if grep "false" /usr/syno/etc/codec/activation.conf >> $logfile; then
error "YOU HAVEN'T THE LICENCE ACTIVATED in Advanced Media Extension package. Please, try to transcode something in VideoStation for activate It and try again with the Installer."
error "YOU HAVEN'T THE LICENCE ACTIVATED in Advanced Media Extension package. Please, try to transcode something in VideoStation for activate It and try again with the Installer." >> $logfile
exit 1
fi
}

function check_versions() {
# NO SE TRADUCE

# Contemplando la posibilidad de que las sucesivas versiones 0 de DSM 8 y futuras sigan con las variables correctas.
if [[ "$majorversion" -ge "8" ]]; then
  cp_path="/var/packages/CodecPack/target/pack"
  cp_bin_path="$cp_path/bin"
  injector="X-Advanced"
elif [[ "$majorversion" -eq "7" && "$minorversion" -ge "1" ]]; then
  cp_path="/var/packages/CodecPack/target/pack"
  cp_bin_path="$cp_path/bin"
  injector="X-Advanced"
elif [[ "$majorversion" -eq "7" && "$minorversion" -eq "0" ]]; then
  cp_path="/var/packages/CodecPack/target"
  cp_bin_path="$cp_path/bin"
  injector="0-Advanced"

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

function crackmenu() {
 clear
 text_crackmenu_1=("THIS IS THE LICENSE CRACK MENU, PLEASE CHOOSE YOUR SELECTION:" "ESTE ES EL MENU DEL CRACK DE LICENCIAS, POR FAVOR ELIJA SU SELECCIÓN:" "ESTE É O MENU DE CRACK DE LICENÇA, POR FAVOR, ESCOLHA SUA SELEÇÃO:" "VOICI LE MENU DE CRACK DE LICENCE, VEUILLEZ CHOISIR VOTRE SÉLECTION :" "DIES IST DAS LIZENZ-Crack-MENÜ, BITTE WÄHLEN SIE IHRE AUSWAHL:" "QUESTO È IL MENU CRACK DELLA LICENZA, PER FAVORE SCEGLI LA TUA SELEZIONE:")
 text_crackmenu_2=("RETURN to MAIN menu." "VOLVER al MENU Principal." "VOLTAR ao MENU Principal." "RETOUR au MENU Principal." "ZURÜCK zum Hauptmenü." "INDIETRO al menù principale.")
 text_crackmenu_3=("Do you want to install the crack for the AME license?" "¿Deseas instalar el crack para la licencia del AME?" "Deseja instalar o crack para a licença AME?" "Voulez-vous installer le crack pour la licence AME ?" "Möchten Sie den Crack für die AME-Lizenz installieren?" "Vuoi installare la crack per la licenza AME?")
 text_crackmenu_4=("Please answer with the correct option writing: P (Patch the AME's license) or U (Unpatch the AME's license). Write Z (for return to MAIN menu)." "Por favor, responda con la opción correcta escribiendo: P (parchea la licencia de AME) o U (desparchea la licencia de AME). Escribe Z (para volver al menú PRINCIPAL)." "Por favor, responda com a opção correta digitando: P (patches de licença AME) ou U (unpatches de licença AME). Digite Z (para retornar ao menu PRINCIPAL)." "Veuillez répondre avec l'option correcte en tapant : P (corrige la licence AME) ou U (élimine la licence AME). Tapez Z (pour revenir au menu PRINCIPAL)." "Bitte antworten Sie mit der richtigen Option, indem Sie Folgendes eingeben: P (Patches der AME-Lizenz) oder U (Patches der AME-Lizenz aufheben). Geben Sie Z ein (um zum HAUPTMENÜ zurückzukehren)." "Si prega di rispondere con l'opzione corretta digitando: P (patch della licenza AME) o U (unpatch della licenza AME). Digitare Z (per tornare al menu PRINCIPALE).")
 text_crackmenu_5=("==================== Installation of the AME's License Crack ====================" "==================== Instalación del Crack de Licencia de AME ====================" "==================== Instalando o crack da licença AME =====================" "==================== Installation du crack de licence AME ====================" "==================== Installieren des AME-Lizenz-Cracks ====================" "===================== Installazione della licenza AME Crack ====================")	
 text_crackmenu_6=("INSTALL the AME's License Crack" "INSTALAR el crack de licencia de AME" "INSTALE o crack da licença AME" "INSTALLER le crack de la licence AME" "INSTALLIEREN Sie den AME-Lizenz-Crack" "INSTALLA il crack della licenza AME")
 text_crackmenu_7=("UNINSTALL the AME's License Crack" "DESINSTALAR el crack de licencia de AME" "DESINSTALAR crack de licença AME" "DÉSINSTALLER le crack de la licence AME" "AME-Lizenz-Crack DEINSTALLIEREN" "DISINSTALLA il crack della licenza AME")	
 text_crackmenu_8=("This patcher enables Advanced Media Extensions 3.0 for you, without having to login account." "Este parche habilita Advanced Media Extensions 3.0 para usted, sin tener que iniciar sesión en la cuenta." "Este patch habilita o Advanced Media Extensions 3.0 para você, sem ter que entrar em sua conta." "Ce correctif active Advanced Media Extensions 3.0 pour vous, sans avoir à vous connecter à votre compte." "Dieser Patch aktiviert Advanced Media Extensions 3.0 für Sie, ohne dass Sie sich bei Ihrem Konto anmelden müssen." "Questa patch abilita Advanced Media Extensions 3.0 per te, senza dover accedere al tuo account.")	
 text_crackmenu_9=("This enables the AAC and HEVC codecs and its license in the AME package, until DSM 7.2." "Esto habilita los códecs AAC y HEVC y su licencia en el paquete AME, hasta DSM 7.2." "Isso habilita os codecs AAC e HEVC e suas licenças no pacote AME, até DSM 7.2." "Cela active les codecs AAC et HEVC et leur licence dans le package AME, jusqu'à DSM 7.2." "Dadurch werden die AAC- und HEVC-Codecs und deren Lizenz im AME-Paket bis DSM 7.2 aktiviert." "Ciò abilita i codec AAC e HEVC e la relativa licenza nel pacchetto AME, fino a DSM 7.2.")	
 text_crackmenu_10=("When you install this License crack, the Wrapper will be deleted and you must to re-install it again." "Cuando instale este crack de licencia, el Wrapper se eliminará y deberá volver a instalarlo." "Ao instalar este crack de licença, o contêiner será removido e você precisará reinstalá-lo." "Lorsque vous installez ce crack de licence, le conteneur sera supprimé et vous devrez le réinstaller." "Wenn Sie diesen Lizenz-Crack installieren, wird der Container entfernt und Sie müssen ihn neu installieren." "Quando installi questo crack della licenza, il contenitore verrà rimosso e dovrai reinstallarlo.")
 text_crackmenu_11=("Note that in order to use this, you will have to use a valid SN (but doesn't have to login synology account with that SN)." "Tenga en cuenta que para usar esto, deberá usar un SN válido (pero no tiene que iniciar sesión en una cuenta de Synology con ese SN)." "Observe que, para usá-lo, você precisará usar um SN válido (mas não precisa entrar em uma conta Synology com esse SN)." "Veuillez noter que pour l'utiliser, vous devrez utiliser un SN valide (mais vous n'avez pas besoin de vous connecter à un compte Synology avec ce SN)." "Bitte beachten Sie, dass Sie zur Nutzung eine gültige SN verwenden müssen (Sie müssen sich jedoch nicht mit dieser SN bei einem Synology-Konto anmelden)." "Si noti che per utilizzare questo, sarà necessario utilizzare un SN valido (ma non è necessario accedere a un account Synology con quel SN).")	
 text_crackmenu_12=("DISCLAIMER:" "DESCARGO DE RESPONSABILIDAD:" "ISENÇÃO DE RESPONSABILIDADE:" "CLAUSE DE NON-RESPONSABILITÉ:" "HAFTUNGSAUSSCHLUSS:" "DISCLAIMER:")	
 text_crackmenu_13=("Use at your own risk, although it has been done to be as safe as possible, there could be errors. (Crack for XPenelogy and Synology without AME's license)." "Úsalo bajo tu propia responsabilidad, aunque se ha hecho para ser lo más seguro posible, podría haber errores. (Crack para XPenology y Synology sin licencia de AME)." "Use-o por sua conta e risco, embora tenha sido feito para ser o mais seguro possível, pode haver erros. (Crack para XPenology e Synology sem licença AME)." "Utilisez-le à vos propres risques, bien qu'il ait été fait pour être aussi sûr que possible, il pourrait y avoir des erreurs. (Crack pour XPenology et Synology sans licence AME)." "Die Verwendung erfolgt auf eigene Gefahr. Obwohl dies so sicher wie möglich ist, kann es dennoch zu Fehlern kommen. (Crack für XPenology und Synology ohne AME-Lizenz)." "Usalo a tuo rischio e pericolo, anche se è stato fatto per essere il più sicuro possibile, potrebbero esserci degli errori. (Crack per XPenology e Synology senza licenza AME).")	
  
	echo ""
        echo -e "${BLUE}${text_crackmenu_5[$LANG]}"
	info "${BLUE}==================== Installation of the AME's License Crack ====================" >> $logfile
	echo ""
	echo -e "${GREEN}${text_crackmenu_8[$LANG]}"
	echo -e "${GREEN}${text_crackmenu_9[$LANG]}"
	echo -e "${GREEN}${text_crackmenu_10[$LANG]}"
	echo -e "${GREEN}${text_crackmenu_11[$LANG]}"
	echo ""
	echo ""
	echo -e "${RED}${text_crackmenu_12[$LANG]} ${YELLOW}${text_crackmenu_13[$LANG]}"
	echo ""
        echo -e "${YELLOW}${text_crackmenu_1[$LANG]}"
	echo ""
		echo -e "${BLUE} ( P ) ${text_crackmenu_6[$LANG]}"
        echo -e "${BLUE} ( U ) ${text_crackmenu_7[$LANG]}" 
        
	echo -e ""
        echo -e "${PURPLE} ( Z ) ${text_crackmenu_2[$LANG]}"
   	while true; do
	echo -e "${GREEN}"
    read -p "${text_crackmenu_3[$LANG]}" puz
        case $puz in
        	[Pp]* ) patch_ame_license; break;;
		[Uu]* ) unpatch_ame_license; break;;
		[Zz]* ) reloadstart; break;;
		* ) echo -e "${YELLOW}${text_crackmenu_4[$LANG]}";;  
        esac
	done
}
function patch_ame_license() {
# Adaptation, conversion and improvements made by me of Wangsiji's code
touch "$logfile"

text_patchame_1=("The backup file $so_backup already exists. A new backup will not be created." "El archivo de respaldo $so_backup ya existe. No se creará una nueva copia de seguridad." "O arquivo de backup $so_backup já existe. Um novo backup não será criado." "Le fichier de sauvegarde $so_backup existe déjà. Une nouvelle sauvegarde ne sera pas créée." "Die Sicherungsdatei $so_backup existiert bereits. Es wird kein neues Backup erstellt." "Il file di backup $so_backup esiste già. Non verrà creato un nuovo backup.")
text_patchame_2=("$so backup created as $so_backup." "Copia de seguridad de $so creada como $so_backup." "$so backup criado como $so_backup." "Sauvegarde $so créée en tant que $so_backup." "$so-Backup erstellt als $so_backup." "$so backup creato come $so_backup.")
text_patchame_3=("The backup file $lic_backup already exists. A new backup will not be created." "El archivo de respaldo $lic_backup ya existe. No se creará una nueva copia de seguridad." "O arquivo de backup $lic_backup já existe. Um novo backup não será criado." "Le fichier de sauvegarde $lic_backup existe déjà. Une nouvelle sauvegarde ne sera pas créée." "Die Sicherungsdatei $lic_backup existiert bereits. Es wird kein neues Backup erstellt." "Il file di backup $lic_backup esiste già. Non verrà creato un nuovo backup.")
text_patchame_4=("$lic backup created as $lic_backup." "Copia de seguridad de $lic creada como $lic_backup." "$lic backup criado como $lic_backup." "Sauvegarde $lic créée en tant que $lic_backup." "$lic-Backup erstellt als $lic_backup." "$lic backup creato come $lic_backup.")
text_patchame_5=("The backup file $licsig_backup already exists. A new backup will not be created." "El archivo de respaldo $licsig_backup ya existe. No se creará una nueva copia de seguridad." "O arquivo de backup $licsig_backup já existe. Um novo backup não será criado." "Le fichier de sauvegarde $licsig_backup existe déjà. Une nouvelle sauvegarde ne sera pas créée." "Die Sicherungsdatei $licsig_backup existiert bereits. Es wird kein neues Backup erstellt." "Il file di backup $licsig_backup esiste già. Non verrà creato un nuovo backup.")
text_patchame_6=("$licsig backup created as $licsig_backup." "Copia de seguridad de $licsig creada como $licsig_backup." "$licsig backup criado como $licsig_backup." "Sauvegarde $licsig créée en tant que $licsig_backup." "$licsig-Backup erstellt als $licsig_backup." "$licsig backup creato come $licsig_backup.")
text_patchame_7=("Applying the patch." "Aplicando el patch." "Aplicando o remendo." "Application du patch." "Anbringen des Patches." "Applicazione del cerotto.")	
text_patchame_8=("Checking whether patch is successful..." "Comprobando si el parche es exitoso..." "Verificando se o patch foi bem-sucedido..." "Vérification du succès du correctif..." "Überprüfen, ob der Patch erfolgreich ist..." "Verifica se la patch ha esito positivo...")	
text_patchame_9=("Successful, updating codecs." "Correcto, actualizando códecs." "Certo, atualizando codecs." "Bon, mise à jour des codecs." "Richtig, Codecs aktualisieren." "Giusto, aggiornando i codec.")	
text_patchame_10=("Crack installed correctly." "Crack instalado correctamente." "Crack instalado com sucesso." "Crack installé avec succès." "Crack erfolgreich installiert." "Crack installato con successo.")	
text_patchame_11=("Patched but unsuccessful." "Parcheado pero sin éxito." "Parcheado, mas sem sucesso." "Patché mais sans succès." "Gepatcht, aber ohne Erfolg." "Patched ma senza successo.")	
text_patchame_12=("Please do an uninstallation of the Wrapper first." "Por favor, primero desinstale el Wrapper." "Faça uma desinstalação do Wrapper primeiro." "Veuillez d'abord désinstaller le Wrapper." "Bitte deinstallieren Sie zunächst den Wrapper." "Eseguire prima una disinstallazione del Wrapper.")	
text_patchame_13=("Error occurred while writing to the file." "Se produjo un error al escribir en el archivo." "Ocorreu um erro ao escrever no arquivo." "Une erreur s'est produite lors de l'écriture dans le fichier." "Beim Schreiben in die Datei ist ein Fehler aufgetreten." "Si è verificato un errore durante la scrittura nel file.")

if [[ -f "/tmp/wrapper.KEY" ]]; then
info "${RED}${text_patchame_12[$LANG]}"
info "${RED}Please do an uninstallation of the Wrapper first." >> $logfile
sleep 4
reloadstart
fi

# Verificar si ya existen los archivos de respaldo

if [ -f "$so_backup" ]; then
  info "${GREEN}${text_patchame_1[$LANG]}"
  info "${GREEN}The backup file $so_backup already exists. A new backup will not be created." >> $logfile
else
  # Crear copia de seguridad de libsynoame-license.so
  cp -p "$so" "$so_backup"
  info "${GREEN}${text_patchame_2[$LANG]}"
  info "${GREEN}$so backup created as $so_backup." >> $logfile
fi

if [ -f "$lic_backup" ]; then
  info "${GREEN}${text_patchame_3[$LANG]}"
  info "${GREEN}The backup file $lic_backup already exists. A new backup will not be created." >> $logfile
else
  # Crear copia de seguridad de offline_license.json
  cp -p "$lic" "$lic_backup"
  info "${GREEN}${text_patchame_4[$LANG]}"
  info "${GREEN}$lic backup created as $lic_backup." >> $logfile
fi

if [ -f "$licsig_backup" ]; then
  info "${GREEN}${text_patchame_5[$LANG]}"
  info "${GREEN}The backup file $licsig_backup already exists. A new backup will not be created." >> $logfile
else
  # Crear copia de seguridad de offline_license.sig
  cp -p "$licsig" "$licsig_backup"
  info "${GREEN}${text_patchame_6[$LANG]}"
  info "${GREEN}$licsig backup created as $licsig_backup." >> $logfile
fi

   info "${YELLOW}${text_patchame_7[$LANG]}"
   info "${YELLOW}Applying the patch." >> $logfile

# Comprobar que el fichero a parchear sea exactamente la misma versión que se estudió. 
hash_to_check="$(md5sum -b "$so" | awk '{print $1}')"

if [ "$hash_to_check" = "fcc1084f4eadcf5855e6e8494fb79e23" ]; then
    hex_values=('1F28' '48F5' '4921' '4953' '4975' '9AC8')
  content='[{"appType": 14, "appName": "ame", "follow": ["device"], "server_time": 1666000000, "registered_at": 1651000000, "expireTime": 0, "status": "valid", "firstActTime": 1651000001, "extension_gid": null, "licenseCode": "0", "duration": 1576800000, "attribute": {"codec": "hevc", "type": "free"}, "licenseContent": 1}, {"appType": 14, "appName": "ame", "follow": ["device"], "server_time": 1666000000, "registered_at": 1651000000, "expireTime": 0, "status": "valid", "firstActTime": 1651000001, "extension_gid": null, "licenseCode": "0", "duration": 1576800000, "attribute": {"codec": "aac", "type": "free"}, "licenseContent": 1}]'
elif [ "$hash_to_check" = "923fd0d58e79b7dc0f6c377547545930" ]; then
    hex_values=('1F28' '48F5' '4921' '4953' '4975' '9AC8')
  content='[{"appType": 14, "appName": "ame", "follow": ["device"], "server_time": 1666000000, "registered_at": 1651000000, "expireTime": 0, "status": "valid", "firstActTime": 1651000001, "extension_gid": null, "licenseCode": "0", "duration": 1576800000, "attribute": {"codec": "hevc", "type": "free"}, "licenseContent": 1}, {"appType": 14, "appName": "ame", "follow": ["device"], "server_time": 1666000000, "registered_at": 1651000000, "expireTime": 0, "status": "valid", "firstActTime": 1651000001, "extension_gid": null, "licenseCode": "0", "duration": 1576800000, "attribute": {"codec": "aac", "type": "free"}, "licenseContent": 1}]'
elif [ "$hash_to_check" = "09e3adeafe85b353c9427d93ef0185e9" ]; then
    hex_values=('3718' '60A5' '60D1' '6111' '6137' 'B5F0')
  content='[{"attribute": {"codec": "hevc", "type": "free"}, "status": "valid", "extension_gid": null, "expireTime": 0, "appName": "ame", "follow": ["device"], "duration": 1576800000, "appType": 14, "licenseContent": 1, "registered_at": 1649315995, "server_time": 1685421618, "firstActTime": 1649315995, "licenseCode": "0"}, {"attribute": {"codec": "aac", "type": "free"}, "status": "valid", "extension_gid": null, "expireTime": 0, "appName": "ame", "follow": ["device"], "duration": 1576800000, "appType": 14, "licenseContent": 1, "registered_at": 1649315995, "server_time": 1685421618, "firstActTime": 1649315995, "licenseCode": "0"}]'
  
else
    echo "MD5 mismatch"
    unpatch_ame_license
    exit 1
fi


for ((i = 0; i < ${#hex_values[@]}; i++)); do
    offset=$(( 0x${hex_values[i]} + 0x8000 ))
    value=${values[indices[i]]}
    printf '%s' "$value" | xxd -r -p | dd of="$so" bs=1 seek="$offset" conv=notrunc 2>> "$logfile"
    if [[ $? -ne 0 ]]; then
        info "${RED}${text_patchame_13[$LANG]}"
	# Llama a la función unpatch_ame_license en caso de error
        unpatch_ame_license  
        exit 1
    fi
done


    mkdir -p "$(dirname "$lic")"
    echo "$content" > "$lic"

    info "${YELLOW}${text_patchame_8[$LANG]}"
    info "${YELLOW}Checking whether patch is successful..." >> $logfile
    
	if "$cp_usr_path/bin/synoame-bin-check-license"; then
	info "${YELLOW}${text_patchame_9[$LANG]}"
  	info "${YELLOW}Successful, updating codecs." >> $logfile
        "$cp_usr_path/bin/synoame-bin-auto-install-needed-codec" 2>> "$logfile"
	info "${GREEN}${text_patchame_10[$LANG]}"
        info "${GREEN}Crack installed correctly." >> $logfile
		sleep 4
		reloadstart
    	else
	info "${YELLOW}${text_patchame_11[$LANG]}"
        info "${YELLOW}Patched but unsuccessful." >> $logfile

        exit 1
   	fi
}
function unpatch_ame_license() {

touch "$logfile"

text_unpatchame_1=("$so file restored from $so_backup." "Archivo $so restaurado desde $so_backup." "$so arquivo restaurado de $so_backup." "Fichier $so restauré à partir de $so_backup." "$so-Datei aus $so_backup wiederhergestellt." "$so file ripristinato da $so_backup.")	
text_unpatchame_2=("Backup file $so_backup does not exist. No restore action will be performed." "El archivo de respaldo $so_backup no existe. No se realizará ninguna acción de restauración." "O arquivo de backup $so_backup não existe. Nenhuma ação de restauração será executada." "Le fichier de sauvegarde $so_backup n'existe pas. Aucune action de restauration ne sera effectuée." "Die Sicherungsdatei $so_backup existiert nicht. Es wird keine Wiederherstellungsaktion durchgeführt." "Il file di backup $so_backup non esiste. Non verrà eseguita alcuna azione di ripristino.")	
text_unpatchame_3=("$lic file restored from $lic_backup." "Archivo $lic restaurado desde $lic_backup." "$lic arquivo restaurado de $lic_backup." "Fichier $lic restauré à partir de $lic_backup." "$lic-Datei aus $lic_backup wiederhergestellt." "$lic file ripristinato da $lic_backup.")	
text_unpatchame_4=("Backup file $lic_backup does not exist. No restore action will be performed." "El archivo de respaldo $lic_backup no existe. No se realizará ninguna acción de restauración." "O arquivo de backup $lic_backup não existe. Nenhuma ação de restauração será executada." "Le fichier de sauvegarde $lic_backup n'existe pas. Aucune action de restauration ne sera effectuée." "Die Sicherungsdatei $lic_backup existiert nicht. Es wird keine Wiederherstellungsaktion durchgeführt." "Il file di backup $lic_backup non esiste. Non verrà eseguita alcuna azione di ripristino.")	
text_unpatchame_5=("$licsig file restored from $licsig_backup." "Archivo $licsig restaurado desde $licsig_backup." "$licsig arquivo restaurado de $licsig_backup." "Fichier $licsig restauré à partir de $licsig_backup." "$licsig-Datei aus $licsig_backup wiederhergestellt." "$licsig file ripristinato da $licsig_backup.")	
text_unpatchame_6=("Backup file $licsig_backup does not exist. No restore action will be performed." "El archivo de respaldo $licsig_backup no existe. No se realizará ninguna acción de restauración." "O arquivo de backup $licsig_backup não existe. Nenhuma ação de restauração será executada." "Le fichier de sauvegarde $licsig_backup n'existe pas. Aucune action de restauration ne sera effectuée." "Die Sicherungsdatei $licsig_backup existiert nicht. Es wird keine Wiederherstellungsaktion durchgeführt." "Il file di backup $licsig_backup non esiste. Non verrà eseguita alcuna azione di ripristino.")	
text_unpatchame_7=("Crack uninstalled correctly." "Crack desinstalado correctamente." "Crack desinstalado com sucesso." "Crack désinstallé avec succès." "Crack wurde erfolgreich deinstalliert." "Crack disinstallato con successo.")
	
  if [ -f "$so_backup" ]; then
    mv "$so_backup" "$so"
	info "${GREEN}${text_unpatchame_1[$LANG]}"
    info "${GREEN}$so file restored from $so_backup." >> $logfile
  else
    info "${GREEN}${text_unpatchame_2[$LANG]}"
    info "${GREEN}Backup file $so_backup does not exist. No restore action will be performed." >> $logfile

  fi

  if [ -f "$lic_backup" ]; then
    mv "$lic_backup" "$lic"
	info "${GREEN}${text_unpatchame_3[$LANG]}"
    info "${GREEN}$lic file restored from $lic_backup." >> $logfile

  else
    info "${GREEN}${text_unpatchame_4[$LANG]}"
    info "${GREEN}Backup file $lic_backup does not exist. No restore action will be performed." >> $logfile

  fi
  
  if [ -f "$licsig_backup" ]; then
    mv "$licsig_backup" "$licsig"
	info "${GREEN}${text_unpatchame_5[$LANG]}"
    info "${GREEN}$licsig file restored from $licsig_backup." >> $logfile

  else
    info "${GREEN}${text_unpatchame_6[$LANG]}"
    info "${GREEN}Backup file $licsig_backup does not exist. No restore action will be performed." >> $logfile

  fi
info "${GREEN}${text_unpatchame_7[$LANG]}"
info "${GREEN}Crack uninstalled correctly." >> $logfile
	
sleep 4
reloadstart
}

function other_checks() {
#Para comprobar el rendimiento y recomendar un Wrapper u otro.
text_otherchecks_1=("Your system has a low performance, I recommend to you install the Simplest Wrapper." "Tu sistema tiene un rendimiento bajo, te recomiendo instalar el Wrapper más simple." "Seu sistema está com baixo desempenho, eu recomendo que você instale o Wrapper mais simples." "Votre système a des performances faibles, je vous recommande d'installer le Wrapper le plus simple." "Ihr System hat eine geringe Leistung, ich empfehle Ihnen, den einfachsten Wrapper zu installieren." "Il tuo sistema ha una bassa performance, ti consiglio di installare il Wrapper più semplice.")
text_otherchecks_2=("Your system is a 'ARMv8' device, I recommend to you install the Simplest Wrapper." "Tu sistema es un dispositivo 'ARMv8', te recomiendo que instales el Wrapper más simple." "Seu sistema é um dispositivo 'ARMv8', eu recomendo que você instale o Wrapper mais simples." "Votre système est un appareil 'ARMv8', je vous recommande d'installer le Wrapper le plus simple." "Ihr System ist ein 'ARMv8'-Gerät, ich empfehle Ihnen, den einfachsten Wrapper zu installieren." "Il tuo sistema è un dispositivo 'ARMv8', ti consiglio di installare il Wrapper più semplice.")
cpu_model=$(cat /proc/cpuinfo | grep "model name")

if ! cat /proc/cpuinfo | grep processor | grep -q "3"; then
  echo -e "${YELLOW}${text_otherchecks_1[$LANG]}"
  info "${YELLOW}Your system has a low performance, I recommend to you install the Simplest Wrapper." >> $logfile
  BLUEGSLP="\u001b[33m"	
fi

if [[ $cpu_model == *"ARMv8"* ]]; then
	echo -e "${YELLOW}${text_otherchecks_2[$LANG]}"
	info "${YELLOW}Your system is a 'ARMv8' device, I recommend to you install the Simplest Wrapper." >> $logfile
    BLUEGSLP="\u001b[33m"
	if [[ -f "$vs_path/bin/gst-launch-1.0" ]]; then
	GST_comp="YES"
	fi
fi

}
function cleanorphan() {
  text_cleanorphan=("Cleaning orphan files..." "Limpiando archivos huérfanos..." "Limpando arquivos órfãos..." "Nettoyage des fichiers orphelins..." "Bereinigung von verwaisten Dateien..." "Pulizia dei file orfani...")
# Delete Orphan files from other wrappers, like the Alex's one. 
  rm -f /tmp/tmp.wget
  rm -f /tmp/ffmpeg.stderr
  rm -f /tmp/ffmpeg.stderr.prev
  rm -f /tmp/gstreamer.log
  rm -f /tmp/gst.stderr
  rm -f /tmp/gst.stderr.prev
  
  info "${YELLOW}${text_cleanorphan[$LANG]}"  
  info "${YELLOW}Cleaning orphan files..." >> $logfile
}

function reloadstart() {
clear
titulo
welcome
check_versions
check_firmas
other_checks
start
}

function language() {
 clear
 text_language_1=("PLEASE, CHOOSE YOUR LANGUAGE:" "POR FAVOR, ELIGE TU IDIOMA:" "ESCOLHA O SEU IDIOMA:" "S'IL VOUS PLAÎT CHOISISSEZ VOTRE LANGUE:" "BITTE WÄHLEN SIE IHRE SPRACHE:" "SCEGLI LA TUA LINGUA:")
 text_language_2=("RETURN to MAIN menu." "VOLVER al MENU Principal." "VOLTAR ao MENU Principal." "RETOUR au MENU Principal." "ZURÜCK zum Hauptmenü." "INDIETRO al menù principale.")
 text_language_3=("Do you wish to change the language in this Installer?" "¿Deseas cambiar el idioma en este Instalador?" "Deseja alterar o idioma deste Instalador?" "Voulez-vous changer la langue de ce programme d'installation ?" "Möchten Sie die Sprache in diesem Installationsprogramm ändern?" "Vuoi cambiare la lingua in questo programma di installazione?")
 text_language_4=("Please answer with the correct option writing: E or C or P or F or D or I. Write Z (for return to MAIN menu)." "Por favor, responda con la opción correcta escribiendo: E o C o P o F o D o I. Escribe Z (para volver al menú PRINCIPAL)." "Por favor responda com a opção correta escrevendo: E ou C ou P ou F ou D ou I. Escreva Z (para retornar ao menu PRINCIPAL)." "Veuillez répondre avec l'option correcte en écrivant : E ou C ou P ou F ou D ou I. Écrivez Z (pour retourner au menu PRINCIPAL)." "Bitte antworten Sie mit der richtigen Schreibweise: E oder C oder P oder F oder D oder I. Schreiben Sie Z (für die Rückkehr zum HAUPTMENÜ)." "Rispondi con l'opzione corretta scrivendo: E o C o P o F o D o I. Scrivi Z (per tornare al menu PRINCIPALE).")
 text_language_5=("==================== Configuration of the Language in this Installer ====================" "==================== Configuración del idioma en este instalador ====================" "==================== Configurando o idioma neste instalador =====================" "==================== Réglage de la langue dans ce programme d'installation ====================" "==================== Einstellen der Sprache in diesem Installationsprogramm ====================" "===================== Impostazione della lingua in questo programma di installazione ====================")	
	
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
	[Zz]* ) reloadstart; break;;
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
reloadstart
}

function language_C() {
LANG="1"
echo ""
info "${GREEN}Cambió correctamente el idioma en este instalador a: CASTELLANO"
info "${BLUE}==================== Changed the Language in this Installer to: SPANISH ====================" >> $logfile
sleep 2
reloadstart
}
function language_P() {
LANG="2"
echo ""
info "${GREEN}Alterado corretamente o Idioma neste Instalador para: PORTUGUÊS"
info "${BLUE}==================== Changed the Language in this Installer to: PORTUGUESE ====================" >> $logfile
sleep 2
reloadstart
}
function language_F() {
LANG="3"
echo ""
info "${GREEN}Changé correctement la langue dans ce programme d'installation en : FRANÇAIS"
info "${BLUE}==================== Changed the Language in this Installer to: FRENCH ====================" >> $logfile
sleep 2
reloadstart
}
function language_D() {
LANG="4"
echo ""
info "${GREEN}Die Sprache in diesem Installer korrekt geändert auf: GERMAN"
info "${BLUE}==================== Changed the Language in this Installer to: GERMAN ====================" >> $logfile
sleep 2
reloadstart
}
function language_I() {
LANG="5"
echo ""
info "${GREEN}Modificata correttamente la Lingua in questo Installer in: ITALIANO"
info "${BLUE}==================== Changed the Language in this Installer to: ITALIAN ====================" >> $logfile
sleep 2
reloadstart
}

function install_auto() {
  # NO SE TRADUCE
  echo -e "${YELLOW}Installer is running in Automatic Mode."
  echo ""

if [[ -f "/tmp/wrapper.KEY" ]]; then
    if grep -q "Advanced" /tmp/wrapper.KEY; then
        install_advanced
    fi
    
    if grep -q "Simplest" /tmp/wrapper.KEY; then
	install_simple
    fi
fi

install_advanced

}

function install_simple() {
  mode="Simplest"
  injector="X-Simplest"
  
  install
}
function install_advanced() {
  mode="Advanced"

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

function install_gstreamer() {

text_installgst_1=("Backup the originals GStreamer's binaries." "Haciendo una copia de seguridad de los binarios originales de GStreamer." "Fazer backup dos binários originais do GStreamer." "Sauvegarder les binaires originaux de GStreamer." "Sichern Sie die Original-GStreamer-Binärdateien." "Eseguire il backup dei binari originali di GStreamer.")
text_installgst_2=("Download the additional libraries for GStreamer." "Descargar las bibliotecas adicionales para GStreamer." "Baixar as bibliotecas adicionais para GStreamer." "Télécharger les bibliothèques supplémentaires pour GStreamer." "Laden Sie die zusätzlichen Bibliotheken für GStreamer herunter." "Scarica le librerie aggiuntive per GStreamer.")
text_installgst_3=("Patching GStreamer in VIDEOSTATION." "Parcheando GStreamer en VIDEOSTATION." "Aplicando patch no GStreamer no VIDEOSTATION." "Application du patch GStreamer dans VIDEOSTATION." "GStreamer in VIDEOSTATION patchen." "Applicazione del patch di GStreamer in VIDEOSTATION.")
text_installgst_4=("Copy gstomx.conf to VIDEOSTATION." "Copiar gstomx.conf a VIDEOSTATION." "Copie o gstomx.conf para VIDEOSTATION." "Copier gstomx.conf vers VIDEOSTATION." "Kopieren Sie die gstomx.conf nach VIDEOSTATION." "Copia gstomx.conf in VIDEOSTATION.")
text_installgst_5=("Download the Wrapper for GStreamer and installing it." "Descargar el Wrapper para GStreamer e instalarlo." "Baixe o Wrapper para o GStreamer e instale-o." "Télécharger le Wrapper pour GStreamer et l'installer." "Laden Sie den Wrapper für GStreamer herunter und installieren Sie ihn." "Scarica il Wrapper per GStreamer e installalo.")
text_installgst_6=("Converting the Simplest to a Gstreamer's Wrapper and do links." "Convirtiendo el Wrapper más simple en un Wrapper de Gstreamer y hacer enlaces." "Convertendo o mais simples em um Wrapper do Gstreamer e fazendo links." "Conversion du plus simple en un Wrapper Gstreamer et création de liens." "Umwandeln des Einfachsten in einen Gstreamer-Wrapper und Erstellen von Verknüpfungen." "Conversione del più semplice in un Wrapper di Gstreamer e creazione di collegamenti.")
text_installgst_7=("Installed correctly the GStreamer's Wrapper." "Instalado correctamente el Wrapper de GStreamer" "Wrapper do GStreamer instalado corretamente" "Wrapper GStreamer installé correctement" "GStreamer-Wrapper erfolgreich installiert" "Wrapper GStreamer installato correttamente")
text_installgst_8=("Forcing to refresh the plugincache deleting the GStreamer registry." "Forzando la actualización de la caché de complementos eliminando el registro de GStreamer." "Forçando a atualização do cache de plugins, excluindo o registro do GStreamer." "Forcer la mise à jour du cache des plugins en supprimant le registre de GStreamer." "Erzwingen Sie das Aktualisieren des Plugincache, indem Sie das GStreamer-Registrierung löschen." "Forzare il refresh della cache dei plugin eliminando il registro di GStreamer.")

info "${YELLOW}${text_installgst_1[$LANG]}"  
info "${YELLOW}Backup the originals GStreamer's binaries." >> $logfile
mv -n $vs_path/bin/gst-inspect-1.0 $vs_path/bin/gst-inspect-1.0.orig
mv -n $vs_path/bin/gst-launch-1.0 $vs_path/bin/gst-launch-1.0.orig
mv -n $cp_bin_path/gst-inspect-1.0 $cp_bin_path/gst-inspect-1.0.orig
mv -n $cp_bin_path/gst-launch-1.0 $cp_bin_path/gst-launch-1.0.orig
mv -n $vs_path/etc/gstomx.conf $vs_path/etc/gstomx.conf.orig

info "${YELLOW}${text_installgst_2[$LANG]}"  
info "${YELLOW}Download the additionals libraries for GStreamer." >> $logfile
wget -q $repo_url/main/aux_GStreamer.tar -O /tmp/aux_GStreamer.tar 2>> $logfile
sleep 6

info "${YELLOW}${text_installgst_3[$LANG]}"  
info "${YELLOW}Patching GStreamer in VIDEOSTATION." >> $logfile
tar xf /tmp/aux_GStreamer.tar -C $vs_path/lib/ 2>> $logfile

chown -R VideoStation:VideoStation "$vs_path/lib/patch" 2>> $logfile

info "${YELLOW}${text_installgst_4[$LANG]}"  
info "${YELLOW}Copy gstomx.conf to VIDEOSTATION." >> $logfile
cp $cp_path/etc/gstomx.conf $vs_path/etc/gstomx.conf 2>> $logfile
chown VideoStation:VideoStation "$vs_path/etc/gstomx.conf" 2>> $logfile

info "${YELLOW}${text_installgst_5[$LANG]}"  
info "${YELLOW}Download the Wrapper for GStreamer and installing it." >> $logfile
wget -q $repo_url/main/ffmpeg41-wrapper-DSM7_X-Simplest -O $vs_path/bin/gst-launch-1.0 2>> $logfile
sleep 3
chown root:VideoStation "$vs_path/bin/gst-launch-1.0" 2>> $logfile
chmod 750 "$vs_path/bin/gst-launch-1.0" 2>> $logfile
chmod u+s "$vs_path/bin/gst-launch-1.0" 2>> $logfile
cp -p "$vs_path/bin/gst-launch-1.0" "$vs_path/bin/gst-inspect-1.0" 2>> $logfile

info "${YELLOW}${text_installgst_6[$LANG]}"  
info "${YELLOW}Converting the Simplest to a Gstreamer's Wrapper and do links." >> $logfile
sed -i 's/^# export/export/g' "$vs_path/bin/gst-launch-1.0" 2>> $logfile
sed -i 's/^# export/export/g' "$vs_path/bin/gst-inspect-1.0" 2>> $logfile
sed -i 's|stderrfile="/tmp/ffmpeg-${streamid}.stderr"|stderrfile="/tmp/gst-launch-1.0.stderr"|' "$vs_path/bin/gst-launch-1.0" 2>> $logfile
sed -i 's|stderrfile="/tmp/ffmpeg-${streamid}.stderr"|stderrfile="/tmp/gst-inspect-1.0.stderr"|' "$vs_path/bin/gst-inspect-1.0" 2>> $logfile
sed -i 's|bin1=/var/packages/ffmpeg6/target/bin/ffmpeg|bin1=/var/packages/VideoStation/target/bin/gst-launch-1.0.orig|' "$vs_path/bin/gst-launch-1.0" 2>> $logfile
sed -i 's|bin1=/var/packages/ffmpeg6/target/bin/ffmpeg|bin1=/var/packages/VideoStation/target/bin/gst-inspect-1.0.orig|' "$vs_path/bin/gst-inspect-1.0" 2>> $logfile
sed -i "s/FFmpeg $pid/GST-launch $pid/g" "$vs_path/bin/gst-launch-1.0" 2>> $logfile
sed -i "s/FFmpeg $pid/GST-inspect $pid/g" "$vs_path/bin/gst-inspect-1.0" 2>> $logfile

ln -s $vs_path/bin/gst-launch-1.0 $cp_bin_path/gst-launch-1.0 2>> $logfile
ln -s $vs_path/bin/gst-inspect-1.0 $cp_bin_path/gst-inspect-1.0 2>> $logfile

info "${YELLOW}${text_installgst_8[$LANG]}"  
info "${YELLOW}Forcing to refresh the plugincache deleting the GStreamer registry." >> $logfile
rm -rf /var/packages/CodecPack/etc/gstreamer-1.0/registry.aarch64.bin
rm /tmp/aux_GStreamer.tar 2>> $logfile
info "${GREEN}${text_installgst_7[$LANG]}"  
info "${GREEN}Installed correctly the GStreamer's Wrapper." >> $logfile
}

################################
# PROCEDIMIENTOS DEL PATCH
################################

function install() {
check_dependencias
check_licence_AME

if [[ "$mode" == "Simplest" ]]; then
text_install_1=("==================== Installation of the Simplest Wrapper: START ====================" "==================== Instalación del Wrapper más Simple: INICIO ====================" "==================== Instalando o wrapper mais simples: START =====================" "==================== Installation de l'encapsuleur le plus simple : DÉMARRER ====================" "==================== Installation des einfachsten Wrappers: START ====================" "===================== Installazione del wrapper più semplice: START ====================")
info "${BLUE}==================== Installation of the Simplest Wrapper: START ====================" >> $logfile
fi

if [[ "$mode" == "Advanced" ]]; then
text_install_1=("==================== Installation of the Advanced Wrapper: START ====================" "==================== Instalación del Advanced Wrapper: INICIO ====================" "==================== Instalando o Wrapper Avançado: START =====================" "==================== Installation de l'encapsuleur avancé : DÉMARRER ====================" "==================== Installation des Advanced Wrappers: START ====================" "===================== Installazione del wrapper avanzato: START ====================")
info "${BLUE}==================== Installation of the Advanced Wrapper: START ====================" >> $logfile
check_versions
fi

  
  text_install_2=("You are running DSM $dsm_version" "Estás ejecutando DSM $dsm_version" "Você está executando o DSM $dsm_version" "Vous utilisez DSM $dsm_version" "Sie führen DSM $dsm_version aus" "Stai eseguendo DSM $dsm_version")
  text_install_3=("DSM $dsm_version is supported for this installer and the installer will tuned for your DSM" "DSM $dsm_version es compatible con este instalador y el instalador se ajustará a su DSM" "O DSM $dsm_version é compatível com este instalador e o instalador corresponderá ao seu DSM" "DSM $dsm_version est compatible avec ce programme d'installation et le programme d'installation correspondra à votre DSM" "DSM $dsm_version ist mit diesem Installationsprogramm kompatibel und das Installationsprogramm passt zu Ihrem DSM" "DSM $dsm_version è compatibile con questo programma di installazione e il programma di installazione corrisponderà al tuo DSM")
  text_install_4=("DSM $dsm_version is using this path: $cp_bin_path" "DSM $dsm_version está utilizando esta ruta: $cp_bin_path" "O DSM $dsm_version está usando este caminho: $cp_bin_path" "DSM $dsm_version utilise ce chemin : $cp_bin_path" "DSM $dsm_version verwendet diesen Pfad: $cp_bin_path" "DSM $dsm_version utilizza questo percorso: $cp_bin_path")
  text_install_5=("DSM $dsm_version is using this injector: $injector" "DSM $dsm_version está utilizando este inyector: $injector" "O DSM $dsm_version está usando este injetor: $injector" "DSM $dsm_version utilise cet injecteur : $injector" "DSM $dsm_version verwendet diesen Injektor: $injector" "DSM $dsm_version utilizza questo iniettore: $injector")
  text_install_6=("Actually you have an OLD or OTHER patch applied in your system, please UNINSTALL OLDER Wrapper first." "Actualmente tienes un parche VIEJO u OTRO parche aplicado en tu sistema, por favor, DESINSTALA primero el Wrapper MÁS VIEJO." "Você atualmente tem um patch ANTIGO ou OUTRO aplicado ao seu sistema, por favor, DESINSTALE o Wrapper ANTIGO primeiro." "Vous avez actuellement un ANCIEN ou UN AUTRE correctif appliqué à votre système, veuillez d'abord DÉSINSTALLER l'ANCIEN Wrapper." "Sie haben derzeit einen ALTEN oder ANDEREN Patch auf Ihr System angewendet, bitte DEINSTALLIEREN Sie zuerst den ÄLTEREN Wrapper." "Attualmente hai una patch VECCHIA o UN'ALTRA applicata al tuo sistema, per favore DISINSTALLA prima il wrapper VECCHIO.")
  text_install_7=(" ( YES ) = The Installer will Uninstall the OLD patch or Wrapper." " ( SÍ ) = El Instalador desinstalará el wrapper o el parche VIEJO." " ( YES ) = O Instalador irá desinstalar o wrapper ou patch ANTIGO." " ( OUI ) = Le programme d'installation désinstallera l'ANCIEN wrapper ou correctif." " ( JA ) = Der Installer wird den ALTEN Wrapper oder Patch deinstallieren." " ( SÌ ) = Il programma di installazione disinstallerà il VECCHIO wrapper o patch.")
  text_install_8=(" ( NO ) = EXIT from the Installer menu and return to MAIN MENU." " ( NO ) = SALIR del menú de Instalación y volver al MENÚ PRINCIPAL." " ( NÃO ) = SAIR do menu Instalação e retornar ao MENU PRINCIPAL." " ( NON ) = QUITTER le menu Installation et revenir au MENU PRINCIPAL." " ( NEIN ) = VERLASSEN Sie das Installationsmenü und kehren Sie zum HAUPTMENÜ zurück." " ( NO ) = USCIRE dal menu Installazione e tornare al MENU PRINCIPALE.")
  text_install_9=("Do you wish to Uninstall this OLD wrapper?" "¿Deseas Desinstalar este Wrapper VIEJO?" "Deseja desinstalar este OLD Wrapper?" "Voulez-vous désinstaller cet ancien wrapper ?" "Möchten Sie diesen ALTEN Wrapper deinstallieren?" "Vuoi disinstallare questo VECCHIO Wrapper?")
  text_install_10=("Please answer YES = (Uninstall the OLD wrapper) or NO = (Return to MAIN Menu)." "Por favor, responda SÍ = (Desinstala el Wrapper VIEJO) o NO = (Vuelve al menú PRINCIPAL)." "Por favor, responda SIM = (Desinstale o OLD Wrapper) ou NÃO = (Volte ao menu PRINCIPAL)." "Veuillez répondre OUI = (Désinstaller l'ANCIEN Wrapper) ou NON = (Revenir au menu PRINCIPAL)." "Bitte antworten Sie mit JA = (Deinstallieren Sie den ALTEN Wrapper) oder NEIN = (Gehen Sie zurück zum HAUPTMENÜ)." "Rispondi SÌ = (Disinstalla il VECCHIO Wrapper) o NO = (Torna al menu PRINCIPALE).")
  text_install_11=("Backup the original ffmpeg41 as ffmpeg41.orig." "Copia de seguridad del fichero original ffmpeg41 como ffmpeg41.orig." "Backup do arquivo ffmpeg41 original como ffmpeg41.orig." "Sauvegarde du fichier ffmpeg41 d'origine en tant que ffmpeg41.orig." "Sicherung der ursprünglichen ffmpeg41-Datei als ffmpeg41.orig." "Backup del file ffmpeg41 originale come ffmpeg41.orig.")
  text_install_12=("Creating the esqueleton of the ffmpeg41" "Creando el esqueleto del fichero ffmpeg41" "Criando o esqueleto do arquivo ffmpeg41" "Création du squelette du fichier ffmpeg41" "Erstellen des Skeletts der ffmpeg41-Datei" "Creazione dello scheletro del file ffmpeg41")
  text_install_13=("Injection of the ffmpeg41 wrapper using this injector: $injector." "Inyección del Wrapper ffmpeg41 usando este inyector: $injector." "Injetando o Wrapper ffmpeg41 usando este injetor: $injector." "Injecter le wrapper ffmpeg41 à l'aide de cet injecteur : $injector." "Injizieren des ffmpeg41-Wrappers mit diesem Injektor: $injector." "Iniezione del wrapper ffmpeg41 utilizzando questo iniettore: $injector.")
  text_install_14=("Waiting for consolidate the download of the wrapper." "Esperando para consolidar la descarga del Wrapper." "Aguardando para consolidar o download do Wrapper." "En attente de consolidation du téléchargement de Wrapper." "Warten auf die Konsolidierung des Wrapper-Downloads." "In attesa di consolidare il download del Wrapper.")
  text_install_15=("Fixing permissions of the ffmpeg41 wrapper." "Arreglando permisos del wrapper ffmpeg41." "Corrigindo as permissões do wrapper ffmpeg41." "Correction des autorisations du wrapper ffmpeg41." "Behebung der ffmpeg41-Wrapper-Berechtigungen." "Correzione dei permessi del wrapper ffmpeg41.")
  text_install_16=("Ensuring the existence of the new log file wrapper_ffmpeg and its access." "Asegurar la existencia y sus accesos al nuevo fichero de logs llamado wrapper_ffmpeg." "Assegure a existência e seu acesso ao novo arquivo de log chamado wrapper_ffmpeg." "Assurez-vous de l'existence et de votre accès au nouveau fichier journal appelé wrapper_ffmpeg." "Stellen Sie die Existenz und Ihren Zugriff auf die neue Protokolldatei namens wrapper_ffmpeg sicher." "Assicurati l'esistenza e il tuo accesso al nuovo file di registro chiamato wrapper_ffmpeg.")
  text_install_17=("Installed correctly the wrapper41 in $cp_bin_path" "Instalado correctamente el wrapper41 en $cp_bin_path" "Wrapper41 instalado com sucesso em $cp_bin_path" "Wrapper41 installé avec succès dans $cp_bin_path" "Wrapper41 erfolgreich in $cp_bin_path installiert" "Wrapper41 installato correttamente in $cp_bin_path")
  text_install_18=("Backup the original libsynovte.so in VideoStation as libsynovte.so.orig." "Copia de seguridad del fichero libsynovte.so como libsynovte.so.orig en VideoStation." "Faça backup do arquivo libsynovte.so como libsynovte.so.orig no VideoStation." "Sauvegardez le fichier libsynovte.so sous libsynovte.so.orig sur VideoStation." "Sichern Sie die Datei libsynovte.so als libsynovte.so.orig auf VideoStation." "Eseguire il backup del file libsynovte.so come libsynovte.so.orig su VideoStation.")
  text_install_19=("Fixing permissions of $vs_libsynovte_file.orig" "Arreglando los permisos de $vs_libsynovte_file.orig" "Corrigindo as permissões de $vs_libsynovte_file.orig" "Correction des autorisations de $vs_libsynovte_file.orig" "Korrigieren der Berechtigungen von $vs_libsynovte_file.orig" "Correzione dei permessi di $vs_libsynovte_file.orig")
  text_install_21=("Modified correctly the file $vs_libsynovte_file" "Modificado correctamente el fichero $vs_libsynovte_file" "Modificou corretamente o arquivo $vs_libsynovte_file" "Correctement modifié le fichier $vs_libsynovte_file" "Die Datei $vs_libsynovte_file wurde korrekt geändert" "Modificato correttamente il file $vs_libsynovte_file")
  text_install_23=("Adding of the KEY of this Wrapper in /tmp." "Añadiendo la CLAVE de este Wrapper en /tmp." "Adicionando a KEY deste Wrapper no /tmp." "Ajout de la CLÉ de ce wrapper dans /tmp." "Hinzufügen des SCHLÜSSEL dieses Wrappers in /tmp." "Aggiunta della CHIAVE di questo wrapper in /tmp.")
  text_install_24=("Installed correctly the KEY in /tmp" "Instalada correctamente la CLAVE en /tmp" "KEY instalado com sucesso em /tmp" "CLÉ installé avec succès dans /tmp" "SCHLÜSSEL erfolgreich in /tmp installiert" "CHIAVE installata correttamente in /tmp")
    
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

if [[ -f "/tmp/wrapper.KEY" || -f "$vs_libsynovte_file.orig" ]]; then

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
        [Nn]* ) reloadstart;;
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
	  
	if grep -q "aac_dec" /usr/syno/etc/codec/activation.conf; then
	text_install_20a=("Patching $vs_libsynovte_file for compatibility with DTS, EAC3 and TrueHD" "Parcheando $vs_libsynovte_file para compatibilidad con DTS, EAC3 y TrueHD" "Corrigindo $vs_libsynovte_file para compatibilidade com DTS, EAC3 e TrueHD" "Correction de $vs_libsynovte_file pour la compatibilité DTS, EAC3 et TrueHD" "Patchen von $vs_libsynovte_file für DTS-, EAC3- und TrueHD-Kompatibilität" "Patching $vs_libsynovte_file per la compatibilità DTS, EAC3 e TrueHD")
		info "${YELLOW}${text_install_20a[$LANG]}"
	  	info "${YELLOW}Patching $vs_libsynovte_file for compatibility with DTS, EAC3 and TrueHD" >> $logfile
		sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' $vs_libsynovte_file 2>> $logfile
	else
	text_install_20b=("Patching $vs_libsynovte_file for compatibility with AAC, DTS, EAC3 and TrueHD" "Parcheando $vs_libsynovte_file para compatibilidad con AAC, DTS, EAC3 y TrueHD" "Corrigindo $vs_libsynovte_file para compatibilidade com AAC, DTS, EAC3 e TrueHD" "Correction de $vs_libsynovte_file pour la compatibilité AAC, DTS, EAC3 et TrueHD" "Patchen von $vs_libsynovte_file für AAC-, DTS-, EAC3- und TrueHD-Kompatibilität" "Patching $vs_libsynovte_file per la compatibilità AAC, DTS, EAC3 e TrueHD")
		info "${YELLOW}${text_install_20b[$LANG]}"
	  	info "${YELLOW}Patching $vs_libsynovte_file for compatibility with AAC, DTS, EAC3 and TrueHD" >> $logfile
		sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' -e 's/aac/caa/' $vs_libsynovte_file 2>> $logfile
	fi
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

if [ "$GST_comp" == "YES" ]; then
    if [[ -f "$vs_path/bin/gst-launch-1.0" && ! -d "$vs_path/lib/patch" ]]; then
        install_gstreamer
    fi
fi

if [ ! -f "$ms_path/bin/ffmpeg.KEY" ] && [ -d "$ms_path" ]; then
text_install_23=("Adding of the KEY of this Wrapper in DLNA MediaServer." "Añadiendo la CLAVE de este Wrapper en DLNA MediaServer." "Adicionando a KEY deste Wrapper no DLNA MediaServer." "Ajout de la CLÉ de ce wrapper dans DLNA MediaServer." "Hinzufügen des SCHLÜSSEL dieses Wrappers in DLNA MediaServer." "Aggiunta della CHIAVE di questo wrapper in DLNA MediaServer.")
text_install_24=("Installed correctly the KEY in $ms_path/bin" "Instalada correctamente la CLAVE en $ms_path/bin" "KEY instalado com sucesso em $ms_path/bin" "CLÉ installé avec succès dans $ms_path/bin" "SCHLÜSSEL erfolgreich in $ms_path/bin installiert" "CHIAVE installata correttamente in $ms_path/bin")
text_install_25=("Backup the original libsynovte.so in MediaServer as libsynovte.so.orig." "Copia de seguridad del fichero libsynovte.so como libsynovte.so.orig en MediaServer." "Faça backup do arquivo libsynovte.so como libsynovte.so.orig no MediaServer." "Sauvegardez le fichier libsynovte.so sous libsynovte.so.orig sur MediaServer." "Sichern Sie die Datei libsynovte.so als libsynovte.so.orig auf MediaServer." "Eseguire il backup del file libsynovte.so come libsynovte.so.orig su MediaServer.")
text_install_26=("Fixing permissions of $ms_libsynovte_file.orig" "Arreglando los permisos de $ms_libsynovte_file.orig" "Corrigindo as permissões de $ms_libsynovte_file.orig" "Correction des autorisations de $ms_libsynovte_file.orig" "Korrigieren der Berechtigungen von $ms_libsynovte_file.orig" "Correzione dei permessi di $ms_libsynovte_file.orig")
text_install_28=("Modified correctly the file $ms_libsynovte_file" "Modificado correctamente el fichero $ms_libsynovte_file" "Modificou corretamente o arquivo $ms_libsynovte_file" "Correctement modifié le fichier $ms_libsynovte_file" "Die Datei $ms_libsynovte_file wurde korrekt geändert" "Modificato correttamente il file $ms_libsynovte_file")
    

		info "${YELLOW}${text_install_23[$LANG]}"
		info "${YELLOW}Adding of the KEY of this Wrapper in DLNA MediaServer." >> $logfile
		cp /tmp/wrapper.KEY $ms_path/bin/
		mv $ms_path/bin/wrapper.KEY $ms_path/bin/ffmpeg.KEY
		info "${GREEN}${text_install_24[$LANG]}"
		
		info "${YELLOW}${text_install_25[$LANG]}"
		info "${YELLOW}Backup the original libsynovte.so in MediaServer as libsynovte.so.orig." >> $logfile
		cp -n $ms_libsynovte_file $ms_libsynovte_file.orig 2>> $logfile
	  info "${YELLOW}${text_install_26[$LANG]}"
	  info "${YELLOW}Fixing permissions of $ms_libsynovte_file.orig" >> $logfile
		chown MediaServer:MediaServer $ms_libsynovte_file.orig 2>> $logfile
		chmod 644 $ms_libsynovte_file.orig 2>> $logfile
	  
		if grep -q "aac_dec" /usr/syno/etc/codec/activation.conf; then
		text_install_27a=("Patching $ms_libsynovte_file for compatibility with DTS, EAC3 and TrueHD" "Parcheando $ms_libsynovte_file para compatibilidad con DTS, EAC3 y TrueHD" "Corrigindo $ms_libsynovte_file para compatibilidade com DTS, EAC3 e TrueHD" "Correction de $ms_libsynovte_file pour la compatibilité DTS, EAC3 et TrueHD" "Patchen von $ms_libsynovte_file für DTS-, EAC3- und TrueHD-Kompatibilität" "Patching $ms_libsynovte_file per la compatibilità DTS, EAC3 e TrueHD")
			info "${YELLOW}${text_install_27a[$LANG]}"
	  		info "${YELLOW}Patching $ms_libsynovte_file for compatibility with DTS, EAC3 and TrueHD" >> $logfile
			sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' $ms_libsynovte_file 2>> $logfile
		else
		text_install_27b=("Patching $ms_libsynovte_file for compatibility with AAC, DTS, EAC3 and TrueHD" "Parcheando $ms_libsynovte_file para compatibilidad con AAC, DTS, EAC3 y TrueHD" "Corrigindo $ms_libsynovte_file para compatibilidade com AAC, DTS, EAC3 e TrueHD" "Correction de $ms_libsynovte_file pour la compatibilité AAC, DTS, EAC3 et TrueHD" "Patchen von $ms_libsynovte_file für AAC-, DTS-, EAC3- und TrueHD-Kompatibilität" "Patching $ms_libsynovte_file per la compatibilità AAC, DTS, EAC3 e TrueHD")
			info "${YELLOW}${text_install_27b[$LANG]}"
	  		info "${YELLOW}Patching $ms_libsynovte_file for compatibility with AAC, DTS, EAC3 and TrueHD" >> $logfile
			sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' -e 's/aac/caa/' $ms_libsynovte_file 2>> $logfile
		fi
		info "${GREEN}${text_install_28[$LANG]}"
		
		if [[ "$mode" == "Simplest" ]]; then
		text_install_29=("Installed correctly the Simplest Wrapper in Media Server." "Instalado correctamente el Wrapper más simple en Media Server." "Instalou com sucesso o Wrapper mais simples no Media Server." "Installation réussie du Wrapper le plus simple sur Media Server." "Der einfachste Wrapper wurde erfolgreich auf dem Medienserver installiert." "Installato con successo il wrapper più semplice su Media Server.")
		info "${GREEN}${text_install_29[$LANG]}"
		fi
		if [[ "$mode" == "Advanced" ]]; then
		text_install_29=("Installed correctly the Advanced Wrapper in Media Server." "Instalado correctamente el Wrapper avanzado en Media Server." "Instalou com sucesso o Advanced Wrapper no Media Server." "L'encapsuleur avancé dans Media Server a été installé avec succès." "Der Advanced Wrapper wurde erfolgreich in Media Server installiert." "Installazione riuscita del wrapper avanzato in Media Server.")
		info "${GREEN}${text_install_29[$LANG]}"
		fi
		
		   
fi

	
restart_packages

if [[ "$mode" == "Simplest" ]]; then
text_install_30=("==================== Installation of the Simplest Wrapper: COMPLETE ====================" "==================== Instalación del Wrapper más simple: COMPLETADO ====================" "==================== Instalando o Wrapper Mais Simples: COMPLETO =====================" "==================== Installation de l'encapsuleur le plus simple : COMPLET ====================" "==================== Installation des einfachsten Wrappers: VOLLSTÄNDIG ====================" "===================== Installazione del wrapper più semplice: COMPLETO ====================")
info "${BLUE}${text_install_30[$LANG]}"
info "${BLUE}==================== Installation of the Simplest Wrapper: COMPLETE ====================" >> $logfile
echo ""
fi

if [[ "$mode" == "Advanced" ]]; then
text_install_30=("==================== Installation of the Advanced Wrapper: COMPLETE ====================" "==================== Instalación del Wrapper Avanzado: COMPLETADO ====================" "==================== Instalação Avançada do Wrapper: COMPLETA =====================" "==================== Installation de l'encapsuleur avancé : COMPLET ====================" "==================== Installation des Advanced Wrappers: VOLLSTÄNDIG ====================" "===================== Installazione del wrapper avanzato: COMPLETO ====================")
info "${BLUE}${text_install_30[$LANG]}"
info "${BLUE}==================== Installation of the Advanced Wrapper: COMPLETE ====================" >> $logfile
echo ""   
fi

exit 0
}

function uninstall() {
  if [[ $setup != autoinstall ]]; then
  clear
  fi
  if [ ! -f "/tmp/wrapper.KEY" ] && [ -f "$cp_bin_path/ffmpeg41.orig" ]; then
  touch /tmp/wrapper.KEY
  fi
  
  text_uninstall_1=("==================== Uninstallation of OLD wrappers in the system: START ====================" "==================== Desinstalación de VIEJOS wrappers en el sistema: INICIO ====================" "==================== Desinstalando OLD wrappers no sistema: HOME ======================" "==================== Désinstallation des anciens wrappers sur le système : HOME =====================" "==================== ALTE Wrapper auf dem System deinstallieren: HOME =====================" "===================== Disinstallazione dei VECCHI wrapper sul sistema: HOME =====================")
  text_uninstall_2=("Restoring VideoStation's libsynovte.so" "Restaurando el libsynovte.so de VideoStation" "Restaurando o VideoStation libsynovte.so" "Restauration de la VideoStation libsynovte.so" "Wiederherstellen der VideoStation libsynovte.so" "Ripristino di VideoStation libsynovte.so")
  text_uninstall_3=("Restoring VideoStation's TransProfile if It has been modified in the past." "Restaurando el TransProfile de VideoStation si este ha sido modificado en el pasado." "Restaurar o TransProfile do VideoStation se tiver sido modificado no passado." "Restauration du TransProfile de VideoStation s'il a été modifié dans le passé." "Wiederherstellen des TransProfile der VideoStation, wenn es in der Vergangenheit geändert wurde." "Ripristino del TransProfile di VideoStation se è stato modificato in passato.")
  text_uninstall_4=("Restoring MediaServer's libsynovte.so" "Restaurando el libsynovte.so de MediaServer" "Restaurando o MediaServer libsynovte.so" "Restauration de la MediaServer libsynovte.so" "Wiederherstellen der MediaServer libsynovte.so" "Ripristino di MediaServer libsynovte.so")
  text_uninstall_5=("Remove of the KEY of this Wrapper in DLNA MediaServer." "Eliminar la CLAVE de este Wrapper en DLNA MediaServer." "Exclua a KEY deste Wrapper no DLNA MediaServer." "Supprimez la clé de ce wrapper dans DLNA MediaServer." "Löschen Sie den SCHLÜSSEL dieses Wrappers im DLNA MediaServer." "Eliminare la CHIAVE di questo wrapper in DLNA MediaServer.")
  text_uninstall_9=("Delete old log file ffmpeg." "Borrado del viejo archivo de logs llamado ffmpeg." "Exclua o arquivo de log antigo chamado ffmpeg." "Supprimez l'ancien fichier journal appelé ffmpeg." "Löschen Sie die alte Protokolldatei namens ffmpeg." "Elimina il vecchio file di registro chiamato ffmpeg.")
  text_uninstall_10=("Uninstalled correctly the old Wrapper." "Desinstalado correctamente el viejo Wrapper." "Desinstalado com sucesso o Wrapper antigo." "Désinstallation réussie de l'ancien Wrapper." "Den alten Wrapper erfolgreich deinstalliert." "Disinstallato con successo il vecchio Wrapper.")
  text_uninstall_11=("==================== Uninstallation of OLD wrappers in the system: COMPLETE ====================" "==================== Desinstalación de VIEJOS wrappers en el sistema: COMPLETADO ====================" "==================== Desinstalando OLD wrappers no sistema: COMPLETO ======================" "==================== Désinstallation des anciens wrappers sur le système : COMPLET =====================" "==================== ALTE Wrapper auf dem System deinstallieren: VOLLSTÄNDIG =====================" "===================== Disinstallazione dei VECCHI wrapper sul sistema: COMPLETO =====================")
  text_uninstall_13=("==================== Uninstallation the Simplest or the Advanced Wrapper: START ====================" "==================== Desinstalación del Wrapper más simple o del avanzado: INICIO ====================" "==================== Desinstalando o Wrapper Simples ou Avançado: HOME =====================" "==================== Désinstallation de l'encapsuleur simple ou avancé : ACCUEIL ====================" "==================== Deinstallieren des Simpler oder Advanced Wrappers: HOME ====================" "===================== Disinstallazione del wrapper più semplice o avanzato: HOME ====================")
  text_uninstall_14=("Delete new log file wrapper_ffmpeg." "Borrado del nuevo fichero de logs llamado wrapper_ffmpeg." "Exclua o novo arquivo de log chamado wrapper_ffmpeg." "Supprimez le nouveau fichier journal appelé wrapper_ffmpeg." "Löschen Sie die neue Protokolldatei namens wrapper_ffmpeg." "Elimina il nuovo file di registro chiamato wrapper_ffmpeg.")
  text_uninstall_15=("Uninstalled correctly the Simplest or the Advanced Wrapper in DLNA MediaServer (If exist) and VideoStation." "Desinstalado correctamente el Wrapper más simple o el Avanzado en DLNA MediaServer (si existiese) y VideoStation." "Desinstalou com êxito o Simpler ou Advanced Wrapper no DLNA MediaServer (se houver) e no VideoStation." "Désinstallation réussie de Simpler ou Advanced Wrapper sur DLNA MediaServer (le cas échéant) et VideoStation." "Der Simpler oder Advanced Wrapper wurde erfolgreich auf DLNA MediaServer (falls vorhanden) und VideoStation deinstalliert." "Disinstallazione riuscita di Simpler o Advanced Wrapper su DLNA MediaServer (se presente) e VideoStation.")
  text_uninstall_16=("==================== Uninstallation the Simplest or the Advanced Wrapper: COMPLETE ====================" "==================== Desinstalación del Wrapper más simple o del avanzado: COMPLETADO ====================" "==================== Desinstalando o Wrapper mais simples ou avançado: COMPLETED =====================" "==================== Désinstallation du Wrapper plus simple ou avancé : TERMINÉ ====================" "==================== Deinstallation des einfacheren oder erweiterten Wrappers: ABGESCHLOSSEN ====================" "===================== Disinstallazione del wrapper più semplice o avanzato: COMPLETATO ====================")
  text_uninstall_17=("Actually You HAVEN'T ANY Wrapper Installed. The Uninstaller CAN'T do anything." "Actualmente NO TIENES NINGÚN Wrapper Instalado. El Desinstalador NO PUEDE hacer nada." "Atualmente você NÃO TEM NENHUM Wrapper instalado. O Desinstalador NÃO PODE fazer nada." "Vous N'AVEZ actuellement AUCUN wrapper installé. Le programme de désinstallation ne peut rien faire." "Sie haben derzeit KEINEN Wrapper installiert. Das Deinstallationsprogramm kann NICHTS tun." "Attualmente NON HAI ALCUN Wrapper installato. Il programma di disinstallazione NON PUÒ fare nulla.")
  text_uninstall_18=("Remove of the KEY of this Wrapper in /tmp." "Eliminar la CLAVE de este Wrapper en /tmp." "Exclua a KEY deste Wrapper no /tmp." "Supprimez la clé de ce wrapper dans /tmp." "Löschen Sie den SCHLÜSSEL dieses Wrappers im /tmp." "Eliminare la CHIAVE di questo wrapper in /tmp.")
  text_uninstall_19=("Removing the aux libraries for GStreamer and restoring gstomx.conf." "Eliminando las bibliotecas auxiliares para GStreamer y restaurando gstomx.conf." "Removendo as bibliotecas auxiliares do GStreamer e restaurando o gstomx.conf." "Suppression des bibliothèques aux pour GStreamer et restauration de gstomx.conf." "Entfernen der Aux-Bibliotheken für GStreamer und Wiederherstellen von gstomx.conf." "Rimozione delle librerie ausiliarie per GStreamer e ripristino di gstomx.conf.")
  
if [[ "$unmode" == "Old" ]]; then
  info "${YELLOW}${text_uninstall_14[$LANG]}"
  touch "$logfile"
  rm "$logfile"
  touch "$logfile"
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
    text_uninstall_6=("Restoring MediaServer's $filename" "Restaurando el $filename de MediaServer" "Restaurando o MediaServer $filename" "Restauration de la MediaServer $filename" "Wiederherstellen der MediaServer $filename" "Ripristino di MediaServer $filename")
    info "${YELLOW}${text_uninstall_6[$LANG]}"
    info "${YELLOW}Restoring MediaServer's $filename" >> $logfile
    mv -T -f "$filename" "${filename::-5}" 2>> $logfile
    done
  fi
	
  find "$vs_path/bin" -type f -name "*.orig" | while read -r filename; do
  text_uninstall_7=("Restoring VideoStation's $filename" "Restaurando el $filename de VideoStation" "Restaurando o VideoStation $filename" "Restauration de la VideoStation $filename" "Wiederherstellen der VideoStation $filename" "Ripristino di VideoStation $filename")
    info "${YELLOW}${text_uninstall_7[$LANG]}"
    info "${YELLOW}Restoring VideoStation's $filename" >> $logfile
    mv -T -f "$filename" "${filename::-5}" 2>> $logfile
  done
  
  if [[ "$majorversion" -ge "7" && "$minorversion" -ge "1" ]]; then
  #Limpiando la posibilidad de haber instalado usando otro Wrapper el path incorrecto en 7.1 o superior
  find /var/packages/CodecPack/target/bin -type f -name "*.orig" | while read -r filename; do
  text_uninstall_8b=("Restoring CodecPack's link" "Restaurando el link de CodecPack" "Restaurando o CodecPack link" "Restauration de la CodecPack link" "Wiederherstellen der CodecPack link" "Ripristino di CodecPack link")
      info "${YELLOW}${text_uninstall_8b[$LANG]}"
      info "${YELLOW}Restoring CodecPack's link" >> $logfile
      mv -T -f "$filename" "${filename::-5}" 2>> $logfile
  done
  fi
    
  find $cp_bin_path -type f -name "*.orig" | while read -r filename; do
  text_uninstall_8=("Restoring CodecPack's $filename" "Restaurando el $filename de CodecPack" "Restaurando o CodecPack $filename" "Restauration de la CodecPack $filename" "Wiederherstellen der CodecPack $filename" "Ripristino di CodecPack $filename")
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
   
   if [[ -f "$vs_path/bin/gst-launch-1.0" && -d "$vs_path/lib/patch" ]]; then
	info "${YELLOW}${text_uninstall_19[$LANG]}"
    	info "${YELLOW}Removing the aux libraries for GStreamer and restoring gstomx.conf." >> $logfile
   	rm -r "$vs_path/lib/patch" 2>> $logfile
	mv -T -f $vs_path/etc/gstomx.conf.orig $vs_path/etc/gstomx.conf 2>> $logfile
   fi

  cleanorphan
     
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
  
  if [[ "$GST_comp" == "YES" ]]; then
    find "$vs_path/bin" -type f -name "*.orig" | while read -r filename; do
  text_uninstall_7=("Restoring VideoStation's $filename" "Restaurando el $filename de VideoStation" "Restaurando o VideoStation $filename" "Restauration de la VideoStation $filename" "Wiederherstellen der VideoStation $filename" "Ripristino di VideoStation $filename")
    info "${YELLOW}${text_uninstall_7[$LANG]}"
    info "${YELLOW}Restoring VideoStation's $filename" >> $logfile
    mv -T -f "$filename" "${filename::-5}" 2>> $logfile
    done
	
    info "${YELLOW}${text_uninstall_19[$LANG]}"
    info "${YELLOW}Removing the aux libraries for GStreamer and restoring gstomx.conf." >> $logfile
    rm -r "$vs_path/lib/patch" 2>> $logfile
    mv -T -f $vs_path/etc/gstomx.conf.orig $vs_path/etc/gstomx.conf 2>> $logfile
  fi
  
  info "${YELLOW}${text_uninstall_18[$LANG]}"
  rm /tmp/wrapper.KEY 2>> $logfile
  
  restart_packages
  
  info "${YELLOW}${text_uninstall_14[$LANG]}"
  touch "$logfile"
  rm "$logfile"
    
  info "${GREEN}${text_uninstall_15[$LANG]}"

  echo ""
  info "${BLUE}${text_uninstall_16[$LANG]}"
  exit 0
  
  else
  
  info "${RED}${text_uninstall_17[$LANG]}"
  rm "$logfile"
  exit 1
  
  fi

fi

}

function configurator() {
clear

text_configura_1=("==================== Configuration of the Advanced Wrapper: START ====================" "==================== Configuración para el Wrapper Avanzado: INICIO ====================" "==================== Configurações para o Wrapper Avançado: HOME =====================" "==================== Paramètres de l'encapsuleur avancé : ACCUEIL ====================" "==================== Einstellungen für den Advanced Wrapper: HOME ====================" "===================== Impostazioni per il wrapper avanzato: HOME ====================")
text_configura_2=("THIS IS THE CONFIGURATOR TOOL MENU, PLEASE CHOOSE YOUR SELECTION:" "ESTE ES EL MENÚ DE LA HERRAMIENTA DEL CONFIGURADOR, POR FAVOR ELIJA SU SELECCIÓN:" "ESTE É O MENU DA FERRAMENTA DO CONFIGURADOR, FAÇA SUA SELEÇÃO:" "VOICI LE MENU DE L'OUTIL CONFIGURATEUR, VEUILLEZ FAIRE VOTRE SÉLECTION :" "DAS IST DAS MENÜ DES KONFIGURATOR-TOOLS, BITTE TREFFEN SIE IHRE AUSWAHL:" "QUESTO È IL MENU DELLO STRUMENTO DI CONFIGURAZIONE, SI PREGA DI SELEZIONARE:")
text_configura_3=(" ( A ) FIRST STREAM= MP3 2.0 256kbps, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) when It needs to do transcoding in VIDEO-STATION. (DEFAULT ORDER VIDEO-STATION)" " ( A ) PRIMER FLUJO= MP3 2.0 256kbps, SEGUNDO FLUJO= AAC 5.1 512kbps (or AC3 5.1 640kbps) cuando se necesite transcodificar en VIDEO-STATION. (ORDEN POR DEFECTO en VIDEO-STATION)" " ( A ) PRIMEIRO STREAM= MP3 2.0 256kbps, SEGUNDO STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps) quando a transcodificação é necessária em VIDEO-STATION. (PEDIDO PADRÃO na ESTAÇÃO DE VÍDEO)" " ( A ) PREMIER FLUX = MP3 2.0 256kbps, DEUXIÈME FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps) lorsque le transcodage est nécessaire sur VIDEO-STATION. (ORDRE PAR DEFAUT dans VIDEO-STATION)" " ( A ) ERSTER STREAM = MP3 2.0 256 kbps, ZWEITER STREAM = AAC 5.1 512 kbps (oder AC3 5.1 640 kbps), wenn eine Transcodierung auf VIDEO-STATION erforderlich ist. (STANDARDREIHENFOLGE in VIDEO-STATION)" " ( A ) PRIMO STREAM= MP3 2.0 256 kbps, SECONDO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps) quando è necessaria la transcodifica su VIDEO-STATION. (ORDINE PREDEFINITO in VIDEO-STATION)")
text_configura_4=(" ( B ) FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps when It needs to do transcoding in VIDEO-STATION." " ( B ) PRIMER FLUJO= AAC 5.1 512kbps (or AC3 5.1 640kbps), SEGUNDO FLUJO= MP3 2.0 256kbps cuando se necesite transcodificar en VIDEO-STATION." " ( B ) PRIMEIRO STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps), SEGUNDO STREAM= MP3 2.0 256kbps quando a transcodificação é necessária em VIDEO-STATION." " ( B ) PREMIER FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps), DEUXIÈME FLUX = MP3 2.0 256kbps lorsque le transcodage est nécessaire sur VIDEO-STATION." " ( B ) ERSTER STREAM = AAC 5.1 512 kbps (oder AC3 5.1 640 kbps), ZWEITER STREAM = MP3 2.0 256 kbps, wenn eine Transcodierung auf VIDEO-STATION erforderlich ist." " ( B ) PRIMO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps), SECONDO STREAM= MP3 2.0 256 kbps quando è necessaria la transcodifica su VIDEO-STATION.")
text_configura_5=(" ( C ) Change the 5.1 audio's codec from AAC 512kbps to AC3 640kbps independently of its audio's streams order in both." " ( C ) Cambiar el codec de audio 5.1 de AAC 512 kbps a AC3 640kbps independientemente del orden de los flujos de audio en ambos." " ( C ) Altere o codec de áudio 5.1 de AAC 512kbps para AC3 640kbps, independentemente da ordem dos fluxos de áudio em ambos." " ( C ) Modifiez le codec audio 5.1 de AAC 512kbps à AC3 640kbps quel que soit l'ordre des flux audio dans les deux." " ( C ) Ändern Sie den 5.1-Audiocodec von AAC 512 kbps auf AC3 640 kbps, unabhängig von der Reihenfolge der Audiostreams in beiden." " ( C ) Modificare il codec audio 5.1 da AAC 512 kbps a AC3 640 kbps indipendentemente dall'ordine dei flussi audio in entrambi.")
text_configura_6=(" ( D ) FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps when It needs to do transcoding in DLNA MediaServer. (DEFAULT ORDER in DLNA)" " ( D ) PRIMER FLUJO= AAC 5.1 512kbps (or AC3 5.1 640kbps), SEGUNDO FLUJO= MP3 2.0 256kbps cuando se necesite transcodificar en DLNA MediaServer. (ORDEN POR DEFECTO en DLNA)" " ( D ) PRIMEIRO STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps), SEGUNDO STREAM= MP3 2.0 256kbps quando a transcodificação é necessária em DLNA MediaServer. (PEDIDO PADRÃO na DLNA)" " ( D ) PREMIER FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps), DEUXIÈME FLUX = MP3 2.0 256kbps lorsque le transcodage est nécessaire sur DLNA MediaServer. (ORDRE PAR DEFAUT dans DLNA)" " ( D ) ERSTER STREAM = AAC 5.1 512 kbps (oder AC3 5.1 640 kbps), ZWEITER STREAM = MP3 2.0 256 kbps, wenn eine Transcodierung auf DLNA MediaServer erforderlich ist. (STANDARDREIHENFOLGE in DLNA)" " ( D ) PRIMO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps), SECONDO STREAM= MP3 2.0 256 kbps quando è necessaria la transcodifica su DLNA MediaServer. (ORDINE PREDEFINITO in DLNA)")
text_configura_7=(" ( E ) FIRST STREAM= MP3 2.0 256kbps, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) when It needs to do transcoding in DLNA MediaServer." " ( E ) PRIMER FLUJO= MP3 2.0 256kbps, SEGUNDO FLUJO= AAC 5.1 512kbps (or AC3 5.1 640kbps) cuando se necesite transcodificar en DLNA MediaServer." " ( E ) PRIMEIRO STREAM= MP3 2.0 256kbps, SEGUNDO STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps) quando a transcodificação é necessária em DLNA MediaServer." " ( E ) PREMIER FLUX = MP3 2.0 256kbps, DEUXIÈME FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps) lorsque le transcodage est nécessaire sur DLNA MediaServer." " ( E ) ERSTER STREAM = MP3 2.0 256 kbps, ZWEITER STREAM = AAC 5.1 512 kbps (oder AC3 5.1 640 kbps), wenn eine Transcodierung auf DLNA MediaServer erforderlich ist." " ( E ) PRIMO STREAM= MP3 2.0 256 kbps, SECONDO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps) quando è necessaria la transcodifica su DLNA MediaServer.")
text_configura_8=(" ( F ) Change the 5.1 audio's codec from AC3 640kbps to AAC 512kbps independently of its audio's streams order in both." " ( F ) Cambiar el codec de audio 5.1 de AC3 640kbps a AAC 512 kbps independientemente del orden de los flujos de audio en ambos." " ( F ) Altere o codec de áudio 5.1 de AC3 640kbps para AAC 512kbps, independentemente da ordem dos fluxos de áudio em ambos." " ( F ) Modifiez le codec audio 5.1 de AC3 640kbps à AAC 512kbps quel que soit l'ordre des flux audio dans les deux." " ( F ) Ändern Sie den 5.1-Audiocodec von AC3 640 kbps auf AAC 512 kbps, unabhängig von der Reihenfolge der Audiostreams in beiden." " ( F ) Modificare il codec audio 5.1 da AC3 640 kbps a AAC 512 kbps indipendentemente dall'ordine dei flussi audio in entrambi.")
text_configura_9=(" ( G ) Use only an Unique Audio's Stream in VIDEO-STATION (the first stream you had selected before) for save the system resources in low powered devices." " ( G ) Usar un único flujo de audio en VIDEO-STATION (el primer flujo que se haya seleccionado antes) para ahorrar recursos de sistema en dispositivos poco potentes." " ( G ) Use um único fluxo de áudio no VIDEO-STATION (o primeiro fluxo selecionado acima) para economizar recursos do sistema em dispositivos menos potentes." " ( G ) Utilisez un seul flux audio sur VIDEO-STATION (le premier flux sélectionné ci-dessus) pour économiser les ressources système sur les appareils moins puissants." " ( G ) Verwenden Sie einen einzelnen Audiostream auf VIDEO-STATION (den ersten oben ausgewählten Stream), um Systemressourcen auf weniger leistungsstarken Geräten zu sparen." " ( G ) Utilizzare un unico flusso audio su VIDEO-STATION (il primo flusso selezionato sopra) per risparmiare risorse di sistema su dispositivi meno potenti.")
text_configura_10=(" ( H ) Use only an Unique Audio's Stream in DLNA MediaServer (the first stream you had selected before) for save the system resources in low powered devices." " ( H ) Usar un único flujo de audio en DLNA MediaServer (el primer flujo que se haya seleccionado antes) para ahorrar recursos de sistema en dispositivos poco potentes." " ( H ) Use um único fluxo de áudio no DLNA MediaServer (o primeiro fluxo selecionado acima) para economizar recursos do sistema em dispositivos menos potentes." " ( H ) Utilisez un seul flux audio sur DLNA MediaServer (le premier flux sélectionné ci-dessus) pour économiser les ressources système sur les appareils moins puissants." " ( H ) Verwenden Sie einen einzelnen Audiostream auf DLNA MediaServer (den ersten oben ausgewählten Stream), um Systemressourcen auf weniger leistungsstarken Geräten zu sparen." " ( H ) Utilizzare un unico flusso audio su DLNA MediaServer (il primo flusso selezionato sopra) per risparmiare risorse di sistema su dispositivi meno potenti.")
text_configura_11=(" ( I ) Change the number of audio channels (2.0) in the VIDEO-STATION's OffLine transcoding. (DEFAULT)" " ( I ) Cambiar el número de canales de audio (2.0) en la transcodificación OffLine del VIDEO-STATION. (POR DEFECTO)" " ( I ) Altere o número de canais de áudio (2.0) na transcodificação OffLine do VIDEO-STATION. (POR PADRÃO)" " ( I ) Modifiez le nombre de canaux audio (2.0) dans le transcodage hors ligne de la VIDEO-STATION. (PAR DÉFAUT)" " ( I ) Ändern Sie die Anzahl der Audiokanäle (2.0) in der Offline-Transkodierung der VIDEO-STATION. (STANDARD)" " ( I ) Modificare il numero di canali audio (2.0) nella transcodifica OffLine della VIDEO-STATION. (PREDEFINITO)")
text_configura_12=(" ( J ) Change the number of audio channels (5.1) in the VIDEO-STATION's OffLine transcoding." " ( J ) Cambiar el número de canales de audio (5.1) en la transcodificación OffLine del VIDEO-STATION." " ( J ) Altere o número de canais de áudio (5.1) na transcodificação OffLine do VIDEO-STATION." " ( J ) Modifiez le nombre de canaux audio (5.1) dans le transcodage hors ligne de la VIDEO-STATION." " ( J ) Ändern Sie die Anzahl der Audiokanäle (5.1) in der Offline-Transkodierung der VIDEO-STATION." " ( J ) Modificare il numero di canali audio (5.1) nella transcodifica OffLine della VIDEO-STATION.")
text_configura_21=(" ( Z ) RETURN to MAIN menu." " ( Z ) VOLVER al menú PRINCIPAL." " ( Z ) VOLTAR ao menu PRINCIPAL." " ( Z ) RETOUR au menu PRINCIPAL." " ( Z ) ZURÜCK zum HAUPTMENÜ." " ( Z ) TORNA al menu PRINCIPALE.")
text_configura_22=("Do you wish to change the order of these audio's streams in the Advanced wrapper?" "¿Deseas cambiar el orden de estos flujos de audio en el Wrapper Avanzado?" "Deseja alterar a ordem desses fluxos de áudio no Advanced Wrapper?" "Voulez-vous modifier l'ordre de ces flux audio dans Advanced Wrapper?" "Möchten Sie die Reihenfolge dieser Audiostreams im Advanced Wrapper ändern?" "Vuoi cambiare l'ordine di questi flussi audio nel Wrapper avanzato?")
text_configura_23=("Please answer with the correct option writing: A or B or C or D or E or F or G or H or I or J. Write Z (for return to MAIN menu)." "Responda con la opción correcta escribiendo: A o B o C o D o E o F o G o H o I o J. Escriba Z (para volver al menú PRINCIPAL)." "Responda com a opção correta digitando: A ou B ou C ou D ou E ou F ou G ou H ou I ou J. Digite Z (para retornar ao menu PRINCIPAL)." "Répondez par l'option correcte en tapant : A ou B ou C ou D ou E ou F ou G ou H ou I ou J. Tapez Z (pour revenir au menu PRINCIPAL)." "Antworten Sie mit der richtigen Option, indem Sie Folgendes eingeben: A oder B oder C oder D oder E oder F oder G oder H oder I oder J. Geben Sie Z ein (um zum HAUPTMENÜ zurückzukehren)." "Rispondi con l'opzione corretta digitando: A o B o C o D o E o F o G o H o I o J. Digita Z (per tornare al menu PRINCIPALE).")
text_configura_24=("==================== Configuration of the Advanced Wrapper: COMPLETE ====================" "==================== Configuración del Wrapper Avanzado: COMPLETADA ====================" "==================== Configuração avançada do wrapper: CONCLUÍDO ====================" "==================== Configuration avancée de l'encapsuleur : TERMINÉE ====================" "==================== Erweiterte Wrapper-Konfiguration: ABGESCHLOSSEN ====================" "==================== Configurazione avanzata del wrapper: COMPLETATA ====================")
text_configura_25=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED so this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
text_configura_26=("Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams." "Por favor, Instala el Wrapper Avanzado y después podrás cambiar la configuración de los flujos de audio." "Por favor, instale o Advanced Wrapper e então você pode alterar as configurações dos fluxos de áudio." "Veuillez installer Advanced Wrapper et vous pourrez ensuite modifier les paramètres des flux audio." "Bitte installieren Sie den Advanced Wrapper und dann können Sie die Einstellungen der Audiostreams ändern." "Si prega di installare il wrapper avanzato e quindi è possibile modificare le impostazioni dei flussi audio.")

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
 	echo -e "${BLUE}${text_configura_11[$LANG]}"
 	echo -e "${BLUE}${text_configura_12[$LANG]}"
        echo ""
        echo -e "${PURPLE}${text_configura_21[$LANG]}"
   	while true; do
	echo -e "${GREEN}"
        read -p "${text_configura_22[$LANG]}" abcdefghijz
        case $abcdefghijz in
        [Aa] ) config_A; break;;
        [Bb] ) config_B; break;;
	[Cc] ) config_C; break;;
	[Dd] ) config_D; break;;
	[Ee] ) config_E; break;;
	[Ff] ) config_F; break;;
	[Gg] ) config_G; break;;
	[Hh] ) config_H; break;;
 	[Ii] ) config_I; break;;
 	[Jj] ) config_J; break;;
	[Zz] ) reloadstart; break;;
        * ) echo -e "${YELLOW}${text_configura_23[$LANG]}";;
        esac
        done
   
   echo -e "${BLUE}${text_configura_24[$LANG]}"
   info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
   exit 0

else
   info "${RED}${text_configura_25[$LANG]}"
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED so this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configura_26[$LANG]}"
   start
fi
}

################################
# EJECUCIÓN
################################
while getopts s: flag; do
  case "${flag}" in
    s) setup=${OPTARG};;
    *) echo "usage: $0 [-s install|autoinstall|uninstall|config|info]" >&2; exit 0;;
  esac
done

intro

titulo

check_root

welcome

check_versions

check_firmas

other_checks


case "$setup" in
  start) start;;
  install) install_advanced;;
  autoinstall) install_auto;;
  uninstall) uninstall_new;;
  config) configurator;;
  info) exit 0;;
esac
