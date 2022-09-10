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
# SCPT_1.17: Added Multi-Language Support. Aesthetic improvements in the logging of the Wrappers. Clean the code.

##############################################################


###############################
# VARIABLES GLOBALES
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
firma_cp="DkNbul"
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
 text_ckck_depen1=("MISSING $dependencia Package." "FALTA el paquete $dependencia" "pacote $dependencia está FALTANDO" "le paquet $dependencia est MANQUANT" "Paket $dependencia fehlt" "il pacchetto $dependencia è MANCANTE")
 text_ckck_depen2=("You have ALL necessary packages Installed, GOOD." "Tienes TODOS los paquetes necesarios ya instalados, BIEN." "Você tem TODOS os pacotes necessários já instalados, BOM." "Vous avez TOUS les packages nécessaires déjà installés, BON." "Sie haben ALLE notwendigen Pakete bereits installiert, GUT." "Hai già installato TUTTI i pacchetti necessari, BUONO.")
text_ckck_depen3=("At least you need $npacks package/s to Install, please Install the dependencies and RE-RUN the Installer again." "Al menos necesitas $npacks paquete/s por instalar, por favor, Instala las dependencias y EJECUTA el Instalador otra vez." "Você precisa de pelo menos $npacks pacote(s) para instalar, por favor, instale as dependências e execute o instalador novamente." "Vous avez besoin d'au moins $npacks package(s) pour l'installation, veuillez installer les dépendances et exécuter à nouveau le programme d'installation." "Sie benötigen mindestens $npacks-Pakete zur Installation, bitte installieren Sie die Abhängigkeiten und führen Sie das Installationsprogramm erneut aus." "Sono necessari almeno $npacks pacchetti per l'installazione, installare le dipendenze ed eseguire nuovamente il programma di installazione.")
for dependencia in "${dependencias[@]}"; do
    if [[ ! -d "/var/packages/${dependencia[@]}" ]]; then
      error "${text_ckck_depen1[$LANG]}" 
      error "MISSING $dependencia Package." >> $logfile
    let "npacks=npacks+1"

    fi
done

if [[ npacks -eq control ]]; then
echo -e  "${GREEN}${text_ckck_depen2[$LANG]}"
fi
#else
if [[ npacks -ne control ]]; then
echo -e  "${RED}${text_ckck_depen3[$LANG]}"
exit 1
fi

}
function welcome() {
  text_welcome_1=("FFMPEG WRAPPER INSTALLER version: $version" "INSTALADOR DEL FFMPEG WRAPPER version: $version" "FFMPEG WRAPPER INSTALLER versão: $version" "Version de l'INSTALLATEUR D'EMBALLAGE FFMPEG : $version" "FFMPEG WRAPPER INSTALLER-Version: $version" "FFMPEG WRAPPER INSTALLER versione: $version")
  echo -e "${YELLOW}${text_welcome_1[$LANG]}"

  welcome=$(curl -s -L "$repo_url/main/texts/welcome_$LANG.txt")
  if [ "${#welcome}" -ge 1 ]; then
    echo ""
    echo -e "${GREEN}	$welcome"
    echo ""
  fi
}

function config_A() {
    text_configA_1=("Changing to use FIRST STREAM= MP3 2.0 256kbps, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) in VIDEO-STATION." "Cambiando para usar PRIMER FLUJO= MP3 2.0 256kbps, SEGUNDO FLUJO= AAC 5.1 512kbps (o AC3 5.1 640kbps) en VIDEO-STATION." "Mudando para usar FIRST STREAM= MP3 2.0 256kbps, SECOND STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps) na VIDEO-STATION." "Commutation pour utiliser PREMIER FLUX = MP3 2.0 256kbps, SECOND FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps) sur VIDEO-STATION." "Umschalten zur Verwendung des ERSTEN STREAM= MP3 2.0 256 kbps, ZWEITER STREAM= AAC 5.1 512 kbps (oder AC3 5.1 640 kbps) auf VIDEO-STATION." "Passaggio all'uso del PRIMO STREAM= MP3 2.0 256 kbps, SECONDO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps) su VIDEO-STATION.")
    text_configA_2=("Sucesfully changed the audio stream's order to: 1) MP3 2.0 256kbps and 2) AAC 5.1 512kbps (or AC3 5.1 640kbps) in VIDEO-STATION." "Cambiado correctamente el orden de los flujos de audio a: 1) MP3 2.0 256kbps y 2) AAC 5.1 512kbps (o AC3 5.1 640kbps) en VIDEO-STATION." "Alterou corretamente a ordem dos fluxos de áudio para: 1) MP3 2.0 256kbps e 2) AAC 5.1 512kbps (ou AC3 5.1 640kbps) no VIDEO-STATION." "Changement correct de l'ordre des flux audio en : 1) MP3 2.0 256kbps et 2) AAC 5.1 512kbps (ou AC3 5.1 640kbps) sur VIDEO-STATION." "Die Reihenfolge der Audiostreams wurde auf VIDEO-STATION korrekt geändert in: 1) MP3 2.0 256 kbps und 2) AAC 5.1 512 kbps (oder AC3 5.1 640 kbps)." "Modificato correttamente l'ordine dei flussi audio in: 1) MP3 2.0 256kbps e 2) AAC 5.1 512kbps (o AC3 5.1 640kbps) su VIDEO-STATION.")
    text_configA_3=("==================== Configuration of the Advanced Wrapper: COMPLETE ====================" "==================== Configuración del Wrapper Avanzado: COMPLETADA ====================" "==================== Configuração avançada do wrapper: CONCLUÍDO ====================" "==================== Configuration avancée de l'encapsuleur : TERMINÉE ====================" "==================== Erweiterte Wrapper-Konfiguration: ABGESCHLOSSEN ====================" "==================== Configurazione avanzata del wrapper: COMPLETATA ====================")
    text_configA_4=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
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
     exit 1   
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
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configA_5[$LANG]}"
   
   start
   
   fi
}

function config_B() {
text_configB_1=("Changing to use FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps in VIDEO-STATION." "Cambiando para usar PRIMER FLUJO= AAC 5.1 512kbps (o AC3 5.1 640kbps), SEGUNDO FLUJO= MP3 2.0 256kbps en VIDEO-STATION." "Mudando para usar FIRST STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps na VIDEO-STATION." "Commutation pour utiliser PREMIER FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps), SECOND FLUX = MP3 2.0 256kbps sur VIDEO-STATION." "Umschalten zur Verwendung des ERSTEN STREAM= AAC 5.1 512 kbps (oder AC3 5.1 640 kbps), ZWEITER STREAM= MP3 2.0 256 kbps auf VIDEO-STATION." "Passaggio all'uso del PRIMO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps), SECONDO STREAM= MP3 2.0 256 kbps su VIDEO-STATION.")
text_configB_2=("Sucesfully changed the audio stream's order to: 1) AAC 5.1 512kbps (or AC3 5.1 640kbps) and 2) MP3 2.0 256kbps in VIDEO-STATION." "Cambiado correctamente el orden de los flujos de audio a: 1) AAC 5.1 512kbps (o AC3 5.1 640kbps) y 2) MP3 2.0 256kbps en VIDEO-STATION." "Alterou corretamente a ordem dos fluxos de áudio para: 1) AAC 5.1 512kbps (ou AC3 5.1 640kbps) e 2) MP3 2.0 256kbps no VIDEO-STATION." "Changement correct de l'ordre des flux audio en : 1) AAC 5.1 512kbps (ou AC3 5.1 640kbps) et 2) MP3 2.0 256kbps sur VIDEO-STATION." "Die Reihenfolge der Audiostreams wurde auf VIDEO-STATION korrekt geändert in: 1) AAC 5.1 512 kbps (oder AC3 5.1 640 kbps) und 2) MP3 2.0 256 kbps." "Modificato correttamente l'ordine dei flussi audio in: 1) AAC 5.1 512kbps (o AC3 5.1 640kbps) e 2) MP3 2.0 256kbps su VIDEO-STATION.")
text_configB_3=("==================== Configuration of the Advanced Wrapper: COMPLETE ====================" "==================== Configuración del Wrapper Avanzado: COMPLETADA ====================" "==================== Configuração avançada do wrapper: CONCLUÍDO ====================" "==================== Configuration avancée de l'encapsuleur : TERMINÉE ====================" "==================== Erweiterte Wrapper-Konfiguration: ABGESCHLOSSEN ====================" "==================== Configurazione avanzata del wrapper: COMPLETATA ====================")
text_configB_4=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
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
    exit 1   
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
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configB_5[$LANG]}"
   
   start
fi
}

function config_C() {
text_configC_1=("Changing the 5.1 audio codec from AAC 512kbps to AC3 640kbps regardless of the order of its audio streams in VIDEO-STATION." "Cambiando el codec de audio 5.1 de AAC 512kbps a AC3 640kbps independientemente del orden de sus flujos de audio en VIDEO-STATION." "Alterando o codec de áudio 5.1 de AAC 512kbps para AC3 640kbps, independentemente da ordem de seus fluxos de áudio em VIDEO-STATION." "Changement du codec audio 5.1 de AAC 512kbps à AC3 640kbps quel que soit l'ordre de ses flux audio dans VIDEO-STATION." "Ändern des 5.1-Audiocodecs von AAC 512kbps auf AC3 640kbps, unabhängig von der Reihenfolge seiner Audiostreams in VIDEO-STATION." "Modifica del codec audio 5.1 da AAC 512kbps ad AC3 640kbps indipendentemente dall'ordine dei suoi flussi audio in VIDEO-STATION.")
text_configC_2=("Sucesfully changed the 5.1 audio's codec from AAC 512kbps to AC3 640kbps in VIDEO-STATION." "Cambiado correctamente el codec de audio 5.1 de AAC 512kbps a AC3 640kbps en VIDEO-STATION." "Mudou com sucesso o codec de áudio 5.1 de AAC 512kbps para AC3 640kbps no VIDEO-STATION." "Changement réussi du codec audio 5.1 de AAC 512kbps à AC3 640kbps sur VIDEO-STATION." "Der 5.1-Audio-Codec wurde erfolgreich von AAC 512 kbps auf AC3 640 kbps auf VIDEO-STATION geändert." "Modificato con successo il codec audio 5.1 da AAC 512kbps a AC3 640kbps su VIDEO-STATION.")
text_configC_3=("==================== Configuration of the Advanced Wrapper: COMPLETE ====================" "==================== Configuración del Wrapper Avanzado: COMPLETADA ====================" "==================== Configuração avançada do wrapper: CONCLUÍDO ====================" "==================== Configuration avancée de l'encapsuleur : TERMINÉE ====================" "==================== Erweiterte Wrapper-Konfiguration: ABGESCHLOSSEN ====================" "==================== Configurazione avanzata del wrapper: COMPLETATA ====================")
text_configC_4=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
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
    exit 1  
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
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configC_5[$LANG]}"
   
   start
fi   
}

function config_D() {
text_configD_1=("Changing to use FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps in DLNA MediaServer." "Cambiando para usar PRIMER FLUJO= AAC 5.1 512kbps (o AC3 5.1 640kbps), SEGUNDO FLUJO= MP3 2.0 256kbps en DLNA MediaServer." "Mudando para usar FIRST STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps na DLNA MediaServer." "Commutation pour utiliser PREMIER FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps), SECOND FLUX = MP3 2.0 256kbps sur DLNA MediaServer." "Umschalten zur Verwendung des ERSTEN STREAM= AAC 5.1 512 kbps (oder AC3 5.1 640 kbps), ZWEITER STREAM= MP3 2.0 256 kbps auf DLNA MediaServer." "Passaggio all'uso del PRIMO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps), SECONDO STREAM= MP3 2.0 256 kbps su DLNA MediaServer.")
text_configD_2=("Sucesfully changed the audio stream's order to: 1) AAC 5.1 512kbps (or AC3 5.1 640kbps) and 2) MP3 2.0 256kbps in DLNA MediaServer." "Cambiado correctamente el orden de los flujos de audio a: 1) AAC 5.1 512kbps (o AC3 5.1 640kbps) y 2) MP3 2.0 256kbps en DLNA MediaServer." "Alterou corretamente a ordem dos fluxos de áudio para: 1) AAC 5.1 512kbps (ou AC3 5.1 640kbps) e 2) MP3 2.0 256kbps no DLNA MediaServer." "Changement correct de l'ordre des flux audio en : 1) AAC 5.1 512kbps (ou AC3 5.1 640kbps) et 2) MP3 2.0 256kbps sur DLNA MediaServer." "Die Reihenfolge der Audiostreams wurde auf DLNA MediaServer korrekt geändert in: 1) AAC 5.1 512 kbps (oder AC3 5.1 640 kbps) und 2) MP3 2.0 256 kbps." "Modificato correttamente l'ordine dei flussi audio in: 1) AAC 5.1 512kbps (o AC3 5.1 640kbps) e 2) MP3 2.0 256kbps su DLNA MediaServer.")
text_configD_3=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
text_configD_4=("Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams." "Por favor, Instala el Wrapper Avanzado y después podrás cambiar la configuración de los flujos de audio." "Por favor, instale o Advanced Wrapper e então você pode alterar as configurações dos fluxos de áudio." "Veuillez installer Advanced Wrapper et vous pourrez ensuite modifier les paramètres des flux audio." "Bitte installieren Sie den Advanced Wrapper und dann können Sie die Einstellungen der Audiostreams ändern." "Si prega di installare il wrapper avanzato e quindi è possibile modificare le impostazioni dei flussi audio.")
text_configD_5=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED in DLNA MediaServer and this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO en DLNA MediaServer y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O ADVANCED WRAPPER INSTALADO no DLNA MediaServer e este Codec Configurator NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS ADVANCED WRAPPER INSTALLÉ sur DLNA MediaServer et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit KEINEN ADVANCED WRAPPER auf dem DLNA MediaServer INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI WRAPPER AVANZATO INSTALLATO su DLNA MediaServer e questo configuratore di codec NON PUÒ modificare nulla.")    

if [[ "$check_amrif" == "$firma2" ]]; then 
   info "${RED}${text_configD_5[$LANG]}"
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED in DLNA MediaServer and this codec Configurator CAN'T change anything." >> $logfile
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
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configD_4[$LANG]}"
   start
fi	
}

function config_E() {
text_configE_1=("Changing to use FIRST STREAM= MP3 2.0 256kbps, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) in DLNA MediaServer." "Cambiando para usar PRIMER FLUJO= MP3 2.0 256kbps, SEGUNDO FLUJO= AAC 5.1 512kbps (o AC3 5.1 640kbps) en DLNA MediaServer." "Mudando para usar FIRST STREAM= MP3 2.0 256kbps, SECOND STREAM= AAC 5.1 512kbps (o AC3 5.1 640kbps) na DLNA MediaServer." "Commutation pour utiliser PREMIER FLUX = MP3 2.0 256kbps, SECOND FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps) sur DLNA MediaServer." "Umschalten zur Verwendung des ERSTEN STREAM= MP3 2.0 256 kbps, ZWEITER STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps) auf DLNA MediaServer." "Passaggio all'uso del PRIMO STREAM= MP3 2.0 256 kbps, SECONDO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps) su DLNA MediaServer.")
text_configE_2=("Sucesfully changed the audio stream's order to: 1) MP3 2.0 256kbps and 2) AAC 5.1 512kbps (or AC3 5.1 640kbps) in DLNA MediaServer." "Cambiado correctamente el orden de los flujos de audio a: 1) MP3 2.0 256kbps y 2) AAC 5.1 512kbps (o AC3 5.1 640kbps) en DLNA MediaServer." "Alterou corretamente a ordem dos fluxos de áudio para: 1) MP3 2.0 256kbps e 2) AAC 5.1 512kbps (ou AC3 5.1 640kbps) no DLNA MediaServer." "Changement correct de l'ordre des flux audio en : 1) MP3 2.0 256kbps et 2) AAC 5.1 512kbps (ou AC3 5.1 640kbps) sur DLNA MediaServer." "Die Reihenfolge der Audiostreams wurde auf DLNA MediaServer korrekt geändert in: 1) MP3 2.0 256 kbps und 2) AAC 5.1 512 kbps (oder AC3 5.1 640 kbps)." "Modificato correttamente l'ordine dei flussi audio in: 1) MP3 2.0 256kbps e 2) AAC 5.1 512kbps (o AC3 5.1 640kbps) su DLNA MediaServer.")
text_configE_3=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
text_configE_4=("Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams." "Por favor, Instala el Wrapper Avanzado y después podrás cambiar la configuración de los flujos de audio." "Por favor, instale o Advanced Wrapper e então você pode alterar as configurações dos fluxos de áudio." "Veuillez installer Advanced Wrapper et vous pourrez ensuite modifier les paramètres des flux audio." "Bitte installieren Sie den Advanced Wrapper und dann können Sie die Einstellungen der Audiostreams ändern." "Si prega di installare il wrapper avanzato e quindi è possibile modificare le impostazioni dei flussi audio.")
text_configE_5=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED in DLNA MediaServer and this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO en DLNA MediaServer y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O ADVANCED WRAPPER INSTALADO no DLNA MediaServer e este Codec Configurator NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS ADVANCED WRAPPER INSTALLÉ sur DLNA MediaServer et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit KEINEN ADVANCED WRAPPER auf dem DLNA MediaServer INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI WRAPPER AVANZATO INSTALLATO su DLNA MediaServer e questo configuratore di codec NON PUÒ modificare nulla.")    


if [[ "$check_amrif" == "$firma2" ]]; then 
   info "${RED}${text_configE_5[$LANG]}"
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED in DLNA MediaServer and this codec Configurator CAN'T change anything." >> $logfile
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
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configE_4[$LANG]}"
   start
fi	
}

function config_F() {
text_configF_1=("Changing the 5.1 audio codec from AC3 640kbps to AAC 512kbps regardless of the order of its audio streams in VIDEO-STATION." "Cambiando el codec de audio 5.1 de AC3 640kbps a AAC 512kbps independientemente del orden de sus flujos de audio en VIDEO-STATION." "Alterando o codec de áudio 5.1 de AC3 640kbps para AAC 512kbps, independentemente da ordem de seus fluxos de áudio em VIDEO-STATION." "Changement du codec audio 5.1 de AC3 640kbps à AAC 512kbps quel que soit l'ordre de ses flux audio dans VIDEO-STATION." "Ändern des 5.1-Audiocodecs von AC3 640kbps auf AAC 512kbps, unabhängig von der Reihenfolge seiner Audiostreams in VIDEO-STATION." "Modifica del codec audio 5.1 da AC3 640kbps ad AAC 512kbps indipendentemente dall'ordine dei suoi flussi audio in VIDEO-STATION.")
text_configF_2=("Sucesfully changed the 5.1 audio's codec from AC3 640kbps to AAC 512kbps in VIDEO-STATION." "Cambiado correctamente el codec de audio 5.1 de AC3 640kbps a AAC 512kbps en VIDEO-STATION." "Mudou com sucesso o codec de áudio 5.1 de AC3 640kbps para AAC 512kbps no VIDEO-STATION." "Changement réussi du codec audio 5.1 de AC3 640kbps à AAC 512kbps sur VIDEO-STATION." "Der 5.1-Audio-Codec wurde erfolgreich von AC3 640 kbps auf AAC 512 kbps auf VIDEO-STATION geändert." "Modificato con successo il codec audio 5.1 da AC3 640kbps a AAC 512kbps su VIDEO-STATION.")
text_configF_3=("==================== Configuration of the Advanced Wrapper: COMPLETE ====================" "==================== Configuración del Wrapper Avanzado: COMPLETADA ====================" "==================== Configuração avançada do wrapper: CONCLUÍDO ====================" "==================== Configuration avancée de l'encapsuleur : TERMINÉE ====================" "==================== Erweiterte Wrapper-Konfiguration: ABGESCHLOSSEN ====================" "==================== Configurazione avanzata del wrapper: COMPLETATA ====================")
text_configF_4=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
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
    exit 1  
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
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configF_5[$LANG]}"
   start
fi  
}

function config_G() {
text_configG_1=("Changing to use only an Unique Audio's Stream in VIDEO-STATION (the first stream you had selected before) for save the system resources in low powered devices." "Cambiando para usar un único flujo de audio en VIDEO-STATION (el primer flujo que se haya seleccionado antes) para ahorrar recursos de sistema en dispositivos poco potentes." "Mudar para usar um único fluxo de áudio em VIDEO-STATION (o primeiro fluxo selecionado antes) para economizar recursos do sistema em dispositivos menos potentes." "Commutation pour utiliser un seul flux audio dans VIDEO-STATION (le premier flux sélectionné auparavant) pour économiser les ressources système sur les appareils moins puissants." "Umschalten auf die Verwendung eines einzelnen Audiostreams in VIDEO-STATION (der erste Stream, der zuvor ausgewählt wurde), um Systemressourcen auf weniger leistungsstarken Geräten zu sparen." "Passaggio all'utilizzo di un unico flusso audio in VIDEO-STATION (il primo flusso selezionato in precedenza) per risparmiare risorse di sistema su dispositivi meno potenti.")
text_configG_2=("Sucesfully changed to use only an Unique Audio's Stream in VIDEO-STATION (the first stream you had selected before) for save the system resources in low powered devices." "Cambiado correctamente para usar un único flujo de audio en VIDEO-STATION (el primer flujo que se haya seleccionado antes) para ahorrar recursos de sistema en dispositivos poco potentes." "Corretamente alterado para usar um único fluxo de áudio no VIDEO-STATION (o primeiro fluxo selecionado antes) para economizar recursos do sistema em dispositivos menos potentes." "Correctement changé pour utiliser un seul flux audio sur VIDEO-STATION (le premier flux sélectionné auparavant) pour économiser les ressources système sur les appareils moins puissants." "Korrekterweise geändert, um einen einzelnen Audiostream auf VIDEO-STATION (der erste zuvor ausgewählte Stream) zu verwenden, um Systemressourcen auf weniger leistungsstarken Geräten zu sparen." "Modificato correttamente per utilizzare un unico flusso audio su VIDEO-STATION (il primo flusso selezionato prima) per risparmiare risorse di sistema su dispositivi meno potenti.")
text_configG_3=("==================== Configuration of the Advanced Wrapper: COMPLETE ====================" "==================== Configuración del Wrapper Avanzado: COMPLETADA ====================" "==================== Configuração avançada do wrapper: CONCLUÍDO ====================" "==================== Configuration avancée de l'encapsuleur : TERMINÉE ====================" "==================== Erweiterte Wrapper-Konfiguration: ABGESCHLOSSEN ====================" "==================== Configurazione avanzata del wrapper: COMPLETATA ====================")
text_configG_4=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
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
    exit 1  
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
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configG_5[$LANG]}"
   start
fi  
}

function config_H() {
text_configH_1=("Changing to use only an Unique Audio's Stream in DLNA MediaServer (the first stream you had selected before) for save the system resources in low powered devices." "Cambiando para usar un único flujo de audio en DLNA MediaServer (el primer flujo que se haya seleccionado antes) para ahorrar recursos de sistema en dispositivos poco potentes." "Mudar para usar um único fluxo de áudio em DLNA MediaServer (o primeiro fluxo selecionado antes) para economizar recursos do sistema em dispositivos menos potentes." "Commutation pour utiliser un seul flux audio dans DLNA MediaServer (le premier flux sélectionné auparavant) pour économiser les ressources système sur les appareils moins puissants." "Umschalten auf die Verwendung eines einzelnen Audiostreams in DLNA MediaServer (der erste Stream, der zuvor ausgewählt wurde), um Systemressourcen auf weniger leistungsstarken Geräten zu sparen." "Passaggio all'utilizzo di un unico flusso audio in DLNA MediaServer (il primo flusso selezionato in precedenza) per risparmiare risorse di sistema su dispositivi meno potenti.")
text_configH_2=("Sucesfully changed to use only an Unique Audio's Stream in DLNA MediaServer (the first stream you had selected before) for save the system resources in low powered devices." "Cambiado correctamente para usar un único flujo de audio en DLNA MediaServer (el primer flujo que se haya seleccionado antes) para ahorrar recursos de sistema en dispositivos poco potentes." "Corretamente alterado para usar um único fluxo de áudio no DLNA MediaServer (o primeiro fluxo selecionado antes) para economizar recursos do sistema em dispositivos menos potentes." "Correctement changé pour utiliser un seul flux audio sur DLNA MediaServer (le premier flux sélectionné auparavant) pour économiser les ressources système sur les appareils moins puissants." "Korrekterweise geändert, um einen einzelnen Audiostream auf DLNA MediaServer (der erste zuvor ausgewählte Stream) zu verwenden, um Systemressourcen auf weniger leistungsstarken Geräten zu sparen." "Modificato correttamente per utilizzare un unico flusso audio su DLNA MediaServer (il primo flusso selezionato prima) per risparmiare risorse di sistema su dispositivi meno potenti.")
text_configH_3=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
text_configH_4=("Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams." "Por favor, Instala el Wrapper Avanzado y después podrás cambiar la configuración de los flujos de audio." "Por favor, instale o Advanced Wrapper e então você pode alterar as configurações dos fluxos de áudio." "Veuillez installer Advanced Wrapper et vous pourrez ensuite modifier les paramètres des flux audio." "Bitte installieren Sie den Advanced Wrapper und dann können Sie die Einstellungen der Audiostreams ändern." "Si prega di installare il wrapper avanzato e quindi è possibile modificare le impostazioni dei flussi audio.")
text_configH_5=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED in DLNA MediaServer and this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO en DLNA MediaServer y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O ADVANCED WRAPPER INSTALADO no DLNA MediaServer e este Codec Configurator NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS ADVANCED WRAPPER INSTALLÉ sur DLNA MediaServer et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit KEINEN ADVANCED WRAPPER auf dem DLNA MediaServer INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI WRAPPER AVANZATO INSTALLATO su DLNA MediaServer e questo configuratore di codec NON PUÒ modificare nulla.")    


if [[ "$check_amrif" == "$firma2" ]]; then 
   info "${RED}${text_configH_5[$LANG]}"
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED in DLNA MediaServer and this codec Configurator CAN'T change anything." >> $logfile
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
    info "${GREEN}${text_configH_6[$LANG]}"
    echo ""
 else
   info "${RED}${text_configH_3[$LANG]}"
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configH_4[$LANG]}"
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
text_start_9=("Please answer I or Install | S or Simple | U or Uninstall | C or Config | L or Language | Z for Exit." "Por favor responda I o Instalar | S o Simple | U o Uninstall | C o Configuración | L o Lengua | Z para Salir." "Por favor, responda I ou Instalar | S ou Simples | U ou Uninstall | C ou Configuração | L ou Língua | Z para Sair." "Veuillez répondre I ou Installer | S ou Simple | U ou Uninstall | C ou Configuration | L ou Langue | Z pour quitter." "Bitte antworten Sie I oder Installieren Sie | S oder Simple | U oder Uninstall | C oder Config | L oder Language | Z zum Beenden." "Per favore rispondi I o Installa | S o Semplice | U o Uninstall | C o Configurazione | L o Lingua | Z per uscire.")

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
        [Uu]* ) uninstall;;
	[Cc]* ) configurator;;
	[Ll]* ) language;;
      	[Zz]* ) exit;;
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
}

function check_versions() {
# NO SE TRADUCE

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

function language() {
 clear
 text_language_1=("PLEASE, CHOOSE YOUR LANGUAGE:" "POR FAVOR, ELIGE TU IDIOMA:" "ESCOLHA O SEU IDIOMA:" "S'IL VOUS PLAÎT CHOISISSEZ VOTRE LANGUE:" "BITTE WÄHLEN SIE IHRE SPRACHE:" "SCEGLI LA TUA LINGUA:")
 echo -e "${YELLOW}${text_language_1[$LANG]}"
 text_language_2=("RETURN to MAIN menu." "VOLVER al MENU Principal." "VOLTAR ao MENU Principal." "RETOUR au MENU Principal." "ZURÜCK zum Hauptmenü." "INDIETRO al menù principale.")
 text_language_3=("Do you wish to change the language in this Installer?" "¿Deseas cambiar el idioma en este Instalador?" "Deseja alterar o idioma deste Instalador?" "Voulez-vous changer la langue de ce programme d'installation ?" "Möchten Sie die Sprache in diesem Installationsprogramm ändern?" "Vuoi cambiare la lingua in questo programma di installazione?")
 text_language_4=("Please answer with the correct option writing: A or B or C or D or E or F. Write Z (for return to MAIN menu)." "Por favor, responda con la opción correcta escribiendo: A o B o C o D o E o F. Escribe Z (para volver al menú PRINCIPAL)." "Por favor responda com a opção correta escrevendo: A ou B ou C ou D ou E ou F. Escreva Z (para retornar ao menu PRINCIPAL)." "Veuillez répondre avec l'option correcte en écrivant : A ou B ou C ou D ou E ou F. Écrivez Z (pour retourner au menu PRINCIPAL)." "Bitte antworten Sie mit der richtigen Schreibweise: A oder B oder C oder D oder E oder F. Schreiben Sie Z (für die Rückkehr zum HAUPTMENÜ)." "Rispondi con l'opzione corretta scrivendo: A o B o C o D o E o F. Scrivi Z (per tornare al menu PRINCIPALE).")
 text_language_5=("==================== Configuration of the Language in this Installer ====================" "==================== Configuración del idioma en este instalador ====================" "==================== Configurando o idioma neste instalador =====================" "==================== Réglage de la langue dans ce programme d'installation ====================" "==================== Einstellen der Sprache in diesem Installationsprogramm ====================" "===================== Impostazione della lingua in questo programma di installazione ====================")	
	echo ""
        echo -e "${BLUE}${text_language_5[$LANG]}"
	info "${BLUE}==================== Configuration of the Language in this Installer ====================" >> $logfile
	echo ""
	echo ""
        echo -e "${BLUE} ( A ) English."
        echo -e "${BLUE} ( B ) Castellano." 
        echo -e "${BLUE} ( C ) Português."
        echo -e "${BLUE} ( D ) Français."
        echo -e "${BLUE} ( E ) Deutsch."
        echo -e "${BLUE} ( F ) Italiano."
	echo -e ""
        echo -e "${PURPLE} ( Z ) ${text_language_2[$LANG]}"
   	while true; do
	echo -e "${GREEN}"
        read -p "${text_language_3[$LANG]}" abcdefz
        case $abcdefz in
        [Aa] ) language_A; break;;
        [Bb] ) language_B; break;;
	[Cc] ) language_C; break;;
	[Dd] ) language_D; break;;
	[Ee] ) language_E; break;;
	[Ff] ) language_F; break;;
	[Zz] ) start; break;;
        * ) echo -e "${YELLOW}${text_language_4[$LANG]}";;  
        esac
	done
}

function language_A() {
LANG="0"
clear
titulo
welcome
check_dependencias
check_licence_AME
check_versions
check_firmas
start
}

function language_B() {
LANG="1"
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
LANG="2"
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
LANG="3"
clear
titulo
welcome
check_dependencias
check_licence_AME
check_versions
check_firmas
start
}
function language_E() {
LANG="4"
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
LANG="5"
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
  injector="simplest"
  install
}
function install_advanced() {
  mode="Advanced"
  install
}

################################
# PROCEDIMIENTOS DEL PATCH
################################

function install() {
if [[ "$mode" == "Simplest" ]]
text_install_1=("==================== Installation of the Simplest Wrapper: START ====================" "==================== Instalación del Wrapper más Simple: INICIO ====================" "==================== Instalando o wrapper mais simples: START =====================" "==================== Installation de l'encapsuleur le plus simple : DÉMARRER ====================" "==================== Installation des einfachsten Wrappers: START ====================" "===================== Installazione del wrapper più semplice: START ====================")
info "${BLUE}==================== Installation of the Simplest Wrapper: START ====================" >> $logfile
fi
if [[ "$mode" == "Advanced" ]]
text_install_1=("==================== Installation of the Advanced Wrapper: START ====================" "==================== Instalación del Advanced Wrapper: INICIO ====================" "==================== Instalando o Wrapper Avançado: START =====================" "==================== Installation de l'encapsuleur avancé : DÉMARRER ====================" "==================== Installation des Advanced Wrappers: START ====================" "===================== Installazione del wrapper avanzato: START ====================")
info "${BLUE}==================== Installation of the Advanced Wrapper: START ====================" >> $logfile
fi

  
  text_install_2=("You are running DSM $dsm_version" "Estás ejecutando DSM $dsm_version" "Você está executando o DSM $dsm_version" "Vous utilisez DSM $dsm_version" "Sie führen DSM $dsm_version aus" "Stai eseguendo DSM $dsm_version")
  text_install_3=("DSM $dsm_version is supported for this installer and the installer will tuned for your DSM" "DSM $dsm_version es compatible con este instalador y el instalador se ajustará a su DSM" "O DSM $dsm_version é compatível com este instalador e o instalador corresponderá ao seu DSM" "DSM $dsm_version est compatible avec ce programme d'installation et le programme d'installation correspondra à votre DSM" "DSM $dsm_version ist mit diesem Installationsprogramm kompatibel und das Installationsprogramm passt zu Ihrem DSM" "DSM $dsm_version è compatibile con questo programma di installazione e il programma di installazione corrisponderà al tuo DSM")
  text_install_4=("DSM $dsm_version is using this path: $cp_bin_path" "DSM $dsm_version está utilizando esta ruta: $cp_bin_path" "O DSM $dsm_version está usando este caminho: $cp_bin_path" "DSM $dsm_version utilise ce chemin : $cp_bin_path" "DSM $dsm_version verwendet diesen Pfad: $cp_bin_path" "DSM $dsm_version utilizza questo percorso: $cp_bin_path")
  text_install_5=("DSM $dsm_version is using this injector: $injector" "DSM $dsm_version está utilizando este inyector: $injector" "O DSM $dsm_version está usando este injetor: $injector" "DSM $dsm_version utilise cet injecteur : $injector" "DSM $dsm_version verwendet diesen Injektor: $injector" "DSM $dsm_version utilizza questo iniettore: $injector")
  
  info "${BLUE}${text_install_1[$LANG]}"
   echo ""
   info "${BLUE}${text_install_2[$LANG]}"
   info "${BLUE}${text_install_3[$LANG]}"
   info "${BLUE}${text_install_4[$LANG]}"
   info "${BLUE}${text_install_5[$LANG]}"

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
	
	if [[ "$mode" == "Simplest" ]]
	info "${GREEN}Installed correctly the Simplest Wrapper in Video Station."
	fi
	if [[ "$mode" == "Advanced" ]]
	info "${GREEN}Installed correctly the Advanced Wrapper in VideoStation."
	fi
	
	break
		
fi
done

if [ ! -f "$ms_path/bin/ffmpeg.KEY" ] && [ -d "$ms_path" ]; then

		info "${YELLOW}Adding of the KEY of this Wrapper in DLNA MediaServer."
		info "${YELLOW}Adding of the KEY of this Wrapper in DLNA MediaServer." >> $logfile
		touch $ms_path/bin/ffmpeg.KEY
		echo -e "# DarkNebular´s $mode Wrapper" >> $ms_path/bin/ffmpeg.KEY
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
		
		if [[ "$mode" == "Simplest" ]]
		info "${GREEN}Installed correctly the Simplest Wrapper in Media Server."
		fi
		if [[ "$mode" == "Advanced" ]]
		info "${GREEN}Installed correctly the Advanced Wrapper in Media Server."
		fi
		
		   
fi

	
restart_packages

if [[ "$mode" == "Simplest" ]]
info "${BLUE}==================== Installation of the Simplest Wrapper: COMPLETE ===================="
info "${BLUE}==================== Installation of the Simplest Wrapper: COMPLETE ====================" >> $logfile
echo ""
fi

if [[ "$mode" == "Advanced" ]]
info "${BLUE}==================== Installation of the Advanced Wrapper: COMPLETE ===================="
info "${BLUE}==================== Installation of the Advanced Wrapper: COMPLETE ====================" >> $logfile
echo ""   
fi

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
  
if [[ "$mode" == "Simplest" ]]
  info "${PURPLE}====================CONTINUING With installation of the Simplest Wrapper...===================="
  info "${PURPLE}====================CONTINUING With installation of the Simplest Wrapper...====================" >> $logfile
  echo ""
fi

if [[ "$mode" == "Advanced" ]]
  info "${PURPLE}====================CONTINUING With installation of the Advanced Wrapper...===================="
  info "${PURPLE}====================CONTINUING With installation of the Advanced Wrapper...====================" >> $logfile
  echo "" 
fi

  
  install
  
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
YELLOW_BLUEMS="\u001b[33m"
RED_BLUEMS="\u001b[31m"
fi

if [[ "$check_amrif" == "$firma" ]]; then
YELLOW_BLUEMS="\u001b[36m"
RED_BLUEMS="\u001b[36m"
fi

if [[ "$check_amrif_1" == "$firma_cp" ]]; then

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
        echo -e "${YELLOW_BLUEMS} ( C ) Change the 5.1 audio's codec from AAC 512kbps to AC3 640kbps independently of its audio's streams order in both."
        echo -e "${RED_BLUEMS} ( D ) FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps when It needs to do transcoding in DLNA MediaServer. (DEFAULT ORDER DLNA)"
        echo -e "${RED_BLUEMS} ( E ) FIRST STREAM= MP3 2.0 256kbpss, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) when It needs to do transcoding in DLNA MediaServer."
        echo -e "${YELLOW_BLUEMS} ( F ) Change the 5.1 audio's codec from AC3 640kbps to AAC 512kbps independently of its audio's streams order in both."
	echo -e "${BLUE} ( G ) Use only an Unique Audio's Stream in VIDEO-STATION (the first stream you had selected before) for save the system resources in low powered devices."
	echo -e "${RED_BLUEMS} ( H ) Use only an Unique Audio's Stream in DLNA MediaServer (the first stream you had selected before) for save the system resources in low powered devices."
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
