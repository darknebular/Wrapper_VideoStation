#!/bin/bash

##############################################################
version="SCPT_2.1"
# Changes:
# SCPT_1.X: See these changes in the releases notes in my Repository in Github. (Deprecated)
# SCPT_2.0: Initial new major Release. Clean the code from last versions. (Deprecated migrated to SCPT_2.1)
# SCPT_2.1: Added Multi-Language Support (English, Spanish, Portuguese, French, German, Italian). Aesthetic improvements in the logging of the Wrappers. Adding a ASCII Intro.

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
        [Uu]* ) uninstall_new;;
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
	[Zz]* ) start; break;;
        * ) echo -e "${YELLOW}${text_language_4[$LANG]}";;  
        esac
	done
}

function language_E() {
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

function language_C() {
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
function language_P() {
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
function language_F() {
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
function language_D() {
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
function language_I() {
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
fi

  
  text_install_2=("You are running DSM $dsm_version" "Estás ejecutando DSM $dsm_version" "Você está executando o DSM $dsm_version" "Vous utilisez DSM $dsm_version" "Sie führen DSM $dsm_version aus" "Stai eseguendo DSM $dsm_version")
  text_install_3=("DSM $dsm_version is supported for this installer and the installer will tuned for your DSM" "DSM $dsm_version es compatible con este instalador y el instalador se ajustará a su DSM" "O DSM $dsm_version é compatível com este instalador e o instalador corresponderá ao seu DSM" "DSM $dsm_version est compatible avec ce programme d'installation et le programme d'installation correspondra à votre DSM" "DSM $dsm_version ist mit diesem Installationsprogramm kompatibel und das Installationsprogramm passt zu Ihrem DSM" "DSM $dsm_version è compatibile con questo programma di installazione e il programma di installazione corrisponderà al tuo DSM")
  text_install_4=("DSM $dsm_version is using this path: $cp_bin_path" "DSM $dsm_version está utilizando esta ruta: $cp_bin_path" "O DSM $dsm_version está usando este caminho: $cp_bin_path" "DSM $dsm_version utilise ce chemin : $cp_bin_path" "DSM $dsm_version verwendet diesen Pfad: $cp_bin_path" "DSM $dsm_version utilizza questo percorso: $cp_bin_path")
  text_install_5=("DSM $dsm_version is using this injector: $injector" "DSM $dsm_version está utilizando este inyector: $injector" "O DSM $dsm_version está usando este injetor: $injector" "DSM $dsm_version utilise cet injecteur : $injector" "DSM $dsm_version verwendet diesen Injektor: $injector" "DSM $dsm_version utilizza questo iniettore: $injector")
  text_install_6=("Actually you have a OLD or OTHER patch applied in your system, please UNINSTALL OLDER Wrapper first." "Actualmente tienes un parche VIEJO u OTRO parche aplicado en tu sistema, por favor, DESINSTALA primero el Wrapper MÁS VIEJO." "Você atualmente tem um patch ANTIGO ou OUTRO aplicado ao seu sistema, por favor, DESINSTALE o Wrapper ANTIGO primeiro." "Vous avez actuellement un ANCIEN ou UN AUTRE correctif appliqué à votre système, veuillez d'abord DÉSINSTALLER l'ANCIEN Wrapper." "Sie haben derzeit einen ALTEN oder ANDEREN Patch auf Ihr System angewendet, bitte DEINSTALLIEREN Sie zuerst den ÄLTEREN Wrapper." "Attualmente hai una patch VECCHIA o UN'ALTRA applicata al tuo sistema, per favore DISINSTALLA prima il wrapper VECCHIO.")
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
  text_install_20=("Patching $vs_libsynovte_file for compatibility with DTS, EAC3 and TrueHD" "Parcheando $vs_libsynovte_file para compatibilidad con DTS, EAC3 y TrueHD" "Corrigindo $vs_libsynovte_file para compatibilidade com DTS, EAC3 e TrueHD" "Correction de $vs_libsynovte_file pour la compatibilité DTS, EAC3 et TrueHD" "Patchen von $vs_libsynovte_file für DTS-, EAC3- und TrueHD-Kompatibilität" "Patching $vs_libsynovte_file per la compatibilità DTS, EAC3 e TrueHD")
  text_install_21=("Modified correctly the file $vs_libsynovte_file" "Modificado correctamente el fichero $vs_libsynovte_file" "Modificou corretamente o arquivo $vs_libsynovte_file" "Correctement modifié le fichier $vs_libsynovte_file" "Die Datei $vs_libsynovte_file wurde korrekt geändert" "Modificato correttamente il file $vs_libsynovte_file")
    
  info "${BLUE}${text_install_1[$LANG]}"
   echo ""
   info "${BLUE}${text_install_2[$LANG]}"
   info "${BLUE}${text_install_3[$LANG]}"
   info "${BLUE}${text_install_4[$LANG]}"
   info "${BLUE}${text_install_5[$LANG]}"

for losorig in "${all_files[@]}"; do
if [[ -f "$losorig" ]]; then
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
	
	break
		
fi
done

if [ ! -f "$ms_path/bin/ffmpeg.KEY" ] && [ -d "$ms_path" ]; then
text_install_23=("Adding of the KEY of this Wrapper in DLNA MediaServer." "Añadiendo la CLAVE de este Wrapper en DLNA MediaServer." "Adicionando a KEY deste Wrapper no DLNA MediaServer." "Ajout de la clé de ce wrapper dans DLNA MediaServer." "Hinzufügen des SCHLÜSSELS dieses Wrappers in DLNA MediaServer." "Aggiunta della chiave di questo wrapper in DLNA MediaServer.")
text_install_24=("Installed correctly the wrapper41 in $ms_path/bin" "Instalado correctamente el wrapper41 en $ms_path/bin" "Wrapper41 instalado com sucesso em $ms_path/bin" "Wrapper41 installé avec succès dans $ms_path/bin" "Wrapper41 erfolgreich in $ms_path/bin installiert" "Wrapper41 installato correttamente in $ms_path/bin")
text_install_25=("Backup the original libsynovte.so in MediaServer as libsynovte.so.orig." "Copia de seguridad del fichero libsynovte.so como libsynovte.so.orig en MediaServer." "Faça backup do arquivo libsynovte.so como libsynovte.so.orig no MediaServer." "Sauvegardez le fichier libsynovte.so sous libsynovte.so.orig sur MediaServer." "Sichern Sie die Datei libsynovte.so als libsynovte.so.orig auf MediaServer." "Eseguire il backup del file libsynovte.so come libsynovte.so.orig su MediaServer.")
text_install_26=("Fixing permissions of $ms_libsynovte_file.orig" "Arreglando los permisos de $ms_libsynovte_file.orig" "Corrigindo as permissões de $ms_libsynovte_file.orig" "Correction des autorisations de $ms_libsynovte_file.orig" "Korrigieren der Berechtigungen von $ms_libsynovte_file.orig" "Correzione dei permessi di $ms_libsynovte_file.orig")
text_install_27=("Patching $ms_libsynovte_file for compatibility with DTS, EAC3 and TrueHD" "Parcheando $ms_libsynovte_file para compatibilidad con DTS, EAC3 y TrueHD" "Corrigindo $ms_libsynovte_file para compatibilidade com DTS, EAC3 e TrueHD" "Correction de $ms_libsynovte_file pour la compatibilité DTS, EAC3 et TrueHD" "Patchen von $ms_libsynovte_file für DTS-, EAC3- und TrueHD-Kompatibilität" "Patching $ms_libsynovte_file per la compatibilità DTS, EAC3 e TrueHD")
text_install_28=("Modified correctly the file $ms_libsynovte_file" "Modificado correctamente el fichero $ms_libsynovte_file" "Modificou corretamente o arquivo $ms_libsynovte_file" "Correctement modifié le fichier $ms_libsynovte_file" "Die Datei $ms_libsynovte_file wurde korrekt geändert" "Modificato correttamente il file $ms_libsynovte_file")
    

		info "${YELLOW}${text_install_23[$LANG]}"
		info "${YELLOW}Adding of the KEY of this Wrapper in DLNA MediaServer." >> $logfile
		touch $ms_path/bin/ffmpeg.KEY
		echo -e "# DarkNebular´s $mode Wrapper" >> $ms_path/bin/ffmpeg.KEY
		info "${GREEN}${text_install_24[$LANG]}"
		
		info "${YELLOW}${text_install_25[$LANG]}"
		info "${YELLOW}Backup the original libsynovte.so in MediaServer as libsynovte.so.orig." >> $logfile
		cp -n $ms_libsynovte_file $ms_libsynovte_file.orig 2>> $logfile
	  info "${YELLOW}${text_install_26[$LANG]}"
	  info "${YELLOW}Fixing permissions of $ms_libsynovte_file.orig" >> $logfile
		chown MediaServer:MediaServer $ms_libsynovte_file.orig 2>> $logfile
		chmod 644 $ms_libsynovte_file.orig 2>> $logfile
	  info "${YELLOW}${text_install_27[$LANG]}"
	  info "${YELLOW}Patching $ms_libsynovte_file for compatibility with DTS, EAC3 and TrueHD" >> $logfile
		sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' $ms_libsynovte_file 2>> $logfile
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
info "${BLUE}${GREEN}${text_install_30[$LANG]}"
info "${BLUE}==================== Installation of the Simplest Wrapper: COMPLETE ====================" >> $logfile
echo ""
fi

if [[ "$mode" == "Advanced" ]]; then
text_install_30=("==================== Installation of the Advanced Wrapper: COMPLETE ====================" "==================== Instalación del Wrapper Avanzado: COMPLETADO ====================" "==================== Instalação Avançada do Wrapper: COMPLETA =====================" "==================== Installation de l'encapsuleur avancé : COMPLET ====================" "==================== Installation des Advanced Wrappers: VOLLSTÄNDIG ====================" "===================== Installazione del wrapper avanzato: COMPLETO ====================")
info "${BLUE}${GREEN}${text_install_30[$LANG]}"
info "${BLUE}==================== Installation of the Advanced Wrapper: COMPLETE ====================" >> $logfile
echo ""   
fi

exit 1
}

function uninstall() {
  clear
  
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
for losorig in "${all_files[@]}"; do
  if [[ -f "$losorig" ]]; then
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
  
  info "${YELLOW}${text_uninstall_14[$LANG]}"
	touch "$logfile"
	rm "$logfile"

  restart_packages
  
  info "${GREEN}${text_uninstall_15[$LANG]}"

  echo ""
  info "${BLUE}${text_uninstall_16[$LANG]}"
  exit 1
  
  else
  
  info "${RED}${text_uninstall_17[$LANG]}"
  exit 1
  
  fi
  done
fi

}

function configurator() {
clear

text_configura_1=("==================== Configuration of the Advanced Wrapper: START ====================" "==================== Configuración para el Wrapper Avanzado: INICIO ====================" "==================== Configurações para o Wrapper Avançado: HOME =====================" "==================== Paramètres de l'encapsuleur avancé : ACCUEIL ====================" "==================== Einstellungen für den Advanced Wrapper: HOME ====================" "===================== Impostazioni per il wrapper avanzato: HOME ====================")
text_configura_2=("REMEMBER: If you change the order in VIDEO-STATION you will have ALWAYS AAC 5.1 512kbps (or AC3 5.1 640kbps) in first audio stream and some devices not compatibles with 5.1 neigther multi audio streams like Chromecast will not work" "RECUERDA: Si cambias el orden en VIDEO-STATION tendrás SIEMPRE AAC 5.1 512kbps (o AC3 5.1 640kbps) en la primera transmisión de audio y algunos dispositivos no compatibles con 5.1 ni transmisiones múltiples de audio como Chromecast no funcionarán" "LEMBRE-SE: Se você alterar a ordem em VIDEO-STATION, SEMPRE terá AAC 5.1 512kbps (ou AC3 5.1 640kbps) no primeiro fluxo de áudio e alguns dispositivos não compatíveis com 5.1 ou vários fluxos de áudio como o Chromecast não funcionarão" "N'OUBLIEZ PAS : Si vous modifiez l'ordre dans VIDEO-STATION, vous aurez TOUJOURS AAC 5.1 512kbps (ou AC3 5.1 640kbps) sur le premier flux audio et certains appareils non compatibles avec 5.1 ou plusieurs flux audio comme Chromecast ne fonctionneront pas" "BEACHTEN SIE: Wenn Sie die Reihenfolge in VIDEO-STATION ändern, haben Sie IMMER AAC 5.1 512 kbps (oder AC3 5.1 640 kbps) im ersten Audiostream und einige Geräte, die nicht mit 5.1 kompatibel sind, oder mehrere Audiostreams wie Chromecast funktionieren nicht" "RICORDA: Se modifichi l'ordine in VIDEO-STATION avrai SEMPRE AAC 5.1 512kbps (o AC3 5.1 640kbps) sul primo flusso audio e alcuni dispositivi non compatibili con 5.1 o più flussi audio come Chromecast non funzioneranno")
text_configura_3=("Now you can change the audio's codec from from AAC 512kbps to AC3 640kbps independently of its audio's streams order." "Ahora puede cambiar el códec de audio de AAC 512 kbps a AC3 640 kbps independientemente del orden de las transmisiones de audio." "Agora você pode alterar o codec de áudio de AAC 512 kbps para AC3 640 kbps, independentemente da ordem dos fluxos de áudio." "Vous pouvez maintenant changer le codec audio de AAC 512 kbps à AC3 640 kbps quel que soit l'ordre des flux audio." "Sie können jetzt den Audiocodec unabhängig von der Reihenfolge der Audiostreams von AAC 512 kbps auf AC3 640 kbps ändern." "È ora possibile modificare il codec audio da AAC 512 kbps a AC3 640 kbps indipendentemente dall'ordine dei flussi audio.")
text_configura_4=("AC3 640kbps has a little bit less quality and worse performance than AAC but is more compatible with LEGACY devices." "AC3 640kbps tiene un poco menos de calidad y peor rendimiento que AAC pero es más compatible con dispositivos LEGACY." "AC3 640kbps tem qualidade ligeiramente inferior e desempenho inferior ao AAC, mas é mais compatível com dispositivos LEGACY." "AC3 640kbps a une qualité légèrement inférieure et des performances inférieures à AAC mais est plus compatible avec les appareils LEGACY." "AC3 640kbps hat eine etwas geringere Qualität und schlechtere Leistung als AAC, ist aber besser mit LEGACY-Geräten kompatibel." "AC3 640kbps ha una qualità leggermente inferiore e prestazioni inferiori rispetto a AAC ma è più compatibile con i dispositivi LEGACY.")
text_configura_5=("Changing the audio stream's order automatically will put again 2 audio Streams." "Cambiando el orden de los flujos de audio hará que vuelvan a ponerse otra vez 2 flujos de audio automáticamente." "Alterar a ordem dos fluxos de áudio retornará automaticamente para 2 fluxos de áudio." "Changer l'ordre des flux audio reviendra automatiquement à 2 flux audio." "Wenn Sie die Reihenfolge der Audiostreams ändern, wird automatisch wieder auf 2 Audiostreams umgeschaltet." "La modifica dell'ordine dei flussi audio tornerà automaticamente a 2 flussi audio.")
text_configura_6=("THIS IS THE CONFIGURATOR TOOL MENU, PLEASE CHOOSE YOUR SELECTION:" "ESTE ES EL MENÚ DE LA HERRAMIENTA DEL CONFIGURADOR, POR FAVOR ELIJA SU SELECCIÓN:" "ESTE É O MENU DA FERRAMENTA DO CONFIGURADOR, FAÇA SUA SELEÇÃO:" "VOICI LE MENU DE L'OUTIL CONFIGURATEUR, VEUILLEZ FAIRE VOTRE SÉLECTION :" "DAS IST DAS MENÜ DES KONFIGURATOR-TOOLS, BITTE TREFFEN SIE IHRE AUSWAHL:" "QUESTO È IL MENU DELLO STRUMENTO DI CONFIGURAZIONE, SI PREGA DI SELEZIONARE:")
text_configura_7=(" ( A ) FIRST STREAM= MP3 2.0 256kbps, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) when It needs to do transcoding in VIDEO-STATION. (DEFAULT ORDER VIDEO-STATION)" " ( A ) PRIMER FLUJO= MP3 2.0 256kbps, SEGUNDO FLUJO= AAC 5.1 512kbps (or AC3 5.1 640kbps) cuando se necesite transcodificar en VIDEO-STATION. (ORDEN POR DEFECTO en VIDEO-STATION)" " ( A ) PRIMEIRO STREAM= MP3 2.0 256kbps, SEGUNDO STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps) quando a transcodificação é necessária em VIDEO-STATION. (PEDIDO PADRÃO na ESTAÇÃO DE VÍDEO)" " ( A ) PREMIER FLUX = MP3 2.0 256kbps, DEUXIÈME FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps) lorsque le transcodage est nécessaire sur VIDEO-STATION. (ORDRE PAR DEFAUT dans VIDEO-STATION)" " ( A ) ERSTER STREAM = MP3 2.0 256 kbps, ZWEITER STREAM = AAC 5.1 512 kbps (oder AC3 5.1 640 kbps), wenn eine Transcodierung auf VIDEO-STATION erforderlich ist. (STANDARDREIHENFOLGE in VIDEO-STATION)" " ( A ) PRIMO STREAM= MP3 2.0 256 kbps, SECONDO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps) quando è necessaria la transcodifica su VIDEO-STATION. (ORDINE PREDEFINITO in VIDEO-STATION)")
text_configura_8=(" ( B ) FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps when It needs to do transcoding in VIDEO-STATION." " ( B ) PRIMER FLUJO= AAC 5.1 512kbps (or AC3 5.1 640kbps), SEGUNDO FLUJO= MP3 2.0 256kbps cuando se necesite transcodificar en VIDEO-STATION." " ( B ) PRIMEIRO STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps), SEGUNDO STREAM= MP3 2.0 256kbps quando a transcodificação é necessária em VIDEO-STATION." " ( B ) PREMIER FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps), DEUXIÈME FLUX = MP3 2.0 256kbps lorsque le transcodage est nécessaire sur VIDEO-STATION." " ( B ) ERSTER STREAM = AAC 5.1 512 kbps (oder AC3 5.1 640 kbps), ZWEITER STREAM = MP3 2.0 256 kbps, wenn eine Transcodierung auf VIDEO-STATION erforderlich ist." " ( B ) PRIMO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps), SECONDO STREAM= MP3 2.0 256 kbps quando è necessaria la transcodifica su VIDEO-STATION.")
text_configura_9=(" ( C ) Change the 5.1 audio's codec from AAC 512kbps to AC3 640kbps independently of its audio's streams order in both." " ( C ) Cambiar el codec de audio 5.1 de AAC 512 kbps a AC3 640kbps independientemente del orden de los flujos de audio en ambos." " ( C ) Altere o codec de áudio 5.1 de AAC 512kbps para AC3 640kbps, independentemente da ordem dos fluxos de áudio em ambos." " ( C ) Modifiez le codec audio 5.1 de AAC 512kbps à AC3 640kbps quel que soit l'ordre des flux audio dans les deux." " ( C ) Ändern Sie den 5.1-Audiocodec von AAC 512 kbps auf AC3 640 kbps, unabhängig von der Reihenfolge der Audiostreams in beiden." " ( C ) Modificare il codec audio 5.1 da AAC 512 kbps a AC3 640 kbps indipendentemente dall'ordine dei flussi audio in entrambi.")
text_configura_10=(" ( D ) FIRST STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps), SECOND STREAM= MP3 2.0 256kbps when It needs to do transcoding in DLNA MediaServer. (DEFAULT ORDER in DLNA)" " ( D ) PRIMER FLUJO= AAC 5.1 512kbps (or AC3 5.1 640kbps), SEGUNDO FLUJO= MP3 2.0 256kbps cuando se necesite transcodificar en DLNA MediaServer. (ORDEN POR DEFECTO en DLNA)" " ( D ) PRIMEIRO STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps), SEGUNDO STREAM= MP3 2.0 256kbps quando a transcodificação é necessária em DLNA MediaServer. (PEDIDO PADRÃO na DLNA)" " ( D ) PREMIER FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps), DEUXIÈME FLUX = MP3 2.0 256kbps lorsque le transcodage est nécessaire sur DLNA MediaServer. (ORDRE PAR DEFAUT dans DLNA)" " ( D ) ERSTER STREAM = AAC 5.1 512 kbps (oder AC3 5.1 640 kbps), ZWEITER STREAM = MP3 2.0 256 kbps, wenn eine Transcodierung auf DLNA MediaServer erforderlich ist. (STANDARDREIHENFOLGE in DLNA)" " ( D ) PRIMO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps), SECONDO STREAM= MP3 2.0 256 kbps quando è necessaria la transcodifica su DLNA MediaServer. (ORDINE PREDEFINITO in DLNA)")
text_configura_11=(" ( E ) FIRST STREAM= MP3 2.0 256kbps, SECOND STREAM= AAC 5.1 512kbps (or AC3 5.1 640kbps) when It needs to do transcoding in DLNA MediaServer." " ( E ) PRIMER FLUJO= MP3 2.0 256kbps, SEGUNDO FLUJO= AAC 5.1 512kbps (or AC3 5.1 640kbps) cuando se necesite transcodificar en DLNA MediaServer." " ( E ) PRIMEIRO STREAM= MP3 2.0 256kbps, SEGUNDO STREAM= AAC 5.1 512kbps (ou AC3 5.1 640kbps) quando a transcodificação é necessária em DLNA MediaServer." " ( E ) PREMIER FLUX = MP3 2.0 256kbps, DEUXIÈME FLUX = AAC 5.1 512kbps (ou AC3 5.1 640kbps) lorsque le transcodage est nécessaire sur DLNA MediaServer." " ( E ) ERSTER STREAM = MP3 2.0 256 kbps, ZWEITER STREAM = AAC 5.1 512 kbps (oder AC3 5.1 640 kbps), wenn eine Transcodierung auf DLNA MediaServer erforderlich ist." " ( E ) PRIMO STREAM= MP3 2.0 256 kbps, SECONDO STREAM= AAC 5.1 512 kbps (o AC3 5.1 640 kbps) quando è necessaria la transcodifica su DLNA MediaServer.")
text_configura_12=(" ( F ) Change the 5.1 audio's codec from AC3 640kbps to AAC 512kbps independently of its audio's streams order in both." " ( F ) Cambiar el codec de audio 5.1 de AC3 640kbps a AAC 512 kbps independientemente del orden de los flujos de audio en ambos." " ( F ) Altere o codec de áudio 5.1 de AC3 640kbps para AAC 512kbps, independentemente da ordem dos fluxos de áudio em ambos." " ( F ) Modifiez le codec audio 5.1 de AC3 640kbps à AAC 512kbps quel que soit l'ordre des flux audio dans les deux." " ( F ) Ändern Sie den 5.1-Audiocodec von AC3 640 kbps auf AAC 512 kbps, unabhängig von der Reihenfolge der Audiostreams in beiden." " ( F ) Modificare il codec audio 5.1 da AC3 640 kbps a AAC 512 kbps indipendentemente dall'ordine dei flussi audio in entrambi.")
text_configura_13=(" ( G ) Use only an Unique Audio's Stream in VIDEO-STATION (the first stream you had selected before) for save the system resources in low powered devices." " ( G ) Usar un único flujo de audio en VIDEO-STATION (el primer flujo que se haya seleccionado antes) para ahorrar recursos de sistema en dispositivos poco potentes." " ( G ) Use um único fluxo de áudio no VIDEO-STATION (o primeiro fluxo selecionado acima) para economizar recursos do sistema em dispositivos menos potentes." " ( G ) Utilisez un seul flux audio sur VIDEO-STATION (le premier flux sélectionné ci-dessus) pour économiser les ressources système sur les appareils moins puissants." " ( G ) Verwenden Sie einen einzelnen Audiostream auf VIDEO-STATION (den ersten oben ausgewählten Stream), um Systemressourcen auf weniger leistungsstarken Geräten zu sparen." " ( G ) Utilizzare un unico flusso audio su VIDEO-STATION (il primo flusso selezionato sopra) per risparmiare risorse di sistema su dispositivi meno potenti.")
text_configura_14=(" ( H ) Use only an Unique Audio's Stream in DLNA MediaServer (the first stream you had selected before) for save the system resources in low powered devices." " ( H ) Usar un único flujo de audio en DLNA MediaServer (el primer flujo que se haya seleccionado antes) para ahorrar recursos de sistema en dispositivos poco potentes." " ( H ) Use um único fluxo de áudio no DLNA MediaServer (o primeiro fluxo selecionado acima) para economizar recursos do sistema em dispositivos menos potentes." " ( H ) Utilisez un seul flux audio sur DLNA MediaServer (le premier flux sélectionné ci-dessus) pour économiser les ressources système sur les appareils moins puissants." " ( H ) Verwenden Sie einen einzelnen Audiostream auf DLNA MediaServer (den ersten oben ausgewählten Stream), um Systemressourcen auf weniger leistungsstarken Geräten zu sparen." " ( H ) Utilizzare un unico flusso audio su DLNA MediaServer (il primo flusso selezionato sopra) per risparmiare risorse di sistema su dispositivi meno potenti.")
text_configura_15=(" ( Z ) RETURN to MAIN menu." " ( Z ) VOLVER al menú PRINCIPAL." " ( Z ) VOLTAR ao menu PRINCIPAL." " ( Z ) RETOUR au menu PRINCIPAL." " ( Z ) ZURÜCK zum HAUPTMENÜ." " ( Z ) TORNA al menu PRINCIPALE.")
text_configura_16=("Do you wish to change the order of these audio stream in the Advanced wrapper?" "¿Deseas cambiar el orden de estos flujos de audio en el Wrapper Avanzado?" "Deseja alterar a ordem desses fluxos de áudio no Advanced Wrapper?" "Voulez-vous modifier l'ordre de ces flux audio dans Advanced Wrapper?" "Möchten Sie die Reihenfolge dieser Audiostreams im Advanced Wrapper ändern?" "Vuoi cambiare l'ordine di questi flussi audio nel Wrapper avanzato?")
text_configura_17=("Please answer with the correct option writing: A or B or C or D or E or F or G or H. Write Z (for return to MAIN menu)." "Responda con la opción correcta escribiendo: A o B o C o D o E o F o G o H. Escriba Z (para volver al menú PRINCIPAL)." "Responda com a opção correta digitando: A ou B ou C ou D ou E ou F ou G ou H. Digite Z (para retornar ao menu PRINCIPAL)." "Répondez par l'option correcte en tapant : A ou B ou C ou D ou E ou F ou G ou H. Tapez Z (pour revenir au menu PRINCIPAL)." "Antworten Sie mit der richtigen Option, indem Sie Folgendes eingeben: A oder B oder C oder D oder E oder F oder G oder H. Geben Sie Z ein (um zum HAUPTMENÜ zurückzukehren)." "Rispondi con l'opzione corretta digitando: A o B o C o D o E o F o G o H. Digita Z (per tornare al menu PRINCIPALE).")
text_configura_18=("==================== Configuration of the Advanced Wrapper: COMPLETE ====================" "==================== Configuración del Wrapper Avanzado: COMPLETADA ====================" "==================== Configuração avançada do wrapper: CONCLUÍDO ====================" "==================== Configuration avancée de l'encapsuleur : TERMINÉE ====================" "==================== Erweiterte Wrapper-Konfiguration: ABGESCHLOSSEN ====================" "==================== Configurazione avanzata del wrapper: COMPLETATA ====================")
text_configura_19=("Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." "Actualmente NO TIENES EL WRAPPER AVANZADO INSTALADO y este Configurador de codec NO PUEDE cambiar nada." "Atualmente, você NÃO TEM O WRAPPER AVANÇADO INSTALADO e este Configurador de Codec NÃO PODE alterar nada." "Actuellement, vous N'AVEZ PAS INSTALLÉ LE WRAPPER AVANCÉ et ce configurateur de codec NE PEUT PAS changer quoi que ce soit." "Sie haben derzeit den ADVANCED WRAPPER NICHT INSTALLIERT und dieser Codec-Konfigurator kann NICHTS ändern." "Al momento NON HAI INSTALLATO IL WRAPPER AVANZATO e questo configuratore di codec NON PUÒ modificare nulla.")
text_configura_20=("Please, Install the Advanced Wrapper first and then you will can change the config for audio's streams." "Por favor, Instala el Wrapper Avanzado y después podrás cambiar la configuración de los flujos de audio." "Por favor, instale o Advanced Wrapper e então você pode alterar as configurações dos fluxos de áudio." "Veuillez installer Advanced Wrapper et vous pourrez ensuite modifier les paramètres des flux audio." "Bitte installieren Sie den Advanced Wrapper und dann können Sie die Einstellungen der Audiostreams ändern." "Si prega di installare il wrapper avanzato e quindi è possibile modificare le impostazioni dei flussi audio.")

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
	echo ""
        echo -e "${YELLOW}${text_configura_2[$LANG]}"
        echo -e "${GREEN}${text_configura_3[$LANG]}"
	echo -e "${GREEN}${text_configura_4[$LANG]}"
	echo -e "${GREEN}${text_configura_5[$LANG]}"
	echo ""
        echo ""
        echo -e "${YELLOW}${text_configura_6[$LANG]}"
        echo ""
        echo -e "${BLUE}${text_configura_7[$LANG]}"
        echo -e "${BLUE}${text_configura_8[$LANG]}" 
        echo -e "${YELLOW_BLUEMS}${text_configura_9[$LANG]}"
        echo -e "${RED_BLUEMS}${text_configura_10[$LANG]}"
        echo -e "${RED_BLUEMS}${text_configura_11[$LANG]}"
        echo -e "${YELLOW_BLUEMS}${text_configura_12[$LANG]}"
	echo -e "${BLUE}${text_configura_13[$LANG]}"
	echo -e "${RED_BLUEMS}${text_configura_14[$LANG]}"
        echo ""
        echo -e "${PURPLE}${text_configura_15[$LANG]}"
   	while true; do
	echo -e "${GREEN}"
        read -p "${text_configura_16[$LANG]}" abcdefghz
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
        * ) echo -e "${YELLOW}${text_configura_17[$LANG]}";;
        esac
        done
   
   echo -e "${BLUE}${text_configura_18[$LANG]}"
   info "${BLUE}==================== Configuration of the Advanced Wrapper: COMPLETE ====================" >> $logfile
   exit 1

else
   info "${RED}${text_configura_19[$LANG]}"
   info "${RED}Actually You HAVEN'T THE ADVANCED WRAPPER INSTALLED and this codec Configurator CAN'T change anything." >> $logfile
   info "${BLUE}${text_configura_20[$LANG]}"
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
  uninstall) uninstall_new;;
  config) configurator;;
  info) exit 1;;
esac
