<p align="center">
  <img src="https://github.com/darknebular/Wrapper_VideoStation/blob/main/images/logoIntro.png?raw=true" height=300px alt="intro">
</p>
<p align="center">
  <img src="https://github.com/darknebular/Wrapper_VideoStation/blob/main/images/logo.png?raw=true" height=200px alt="logo">
</p>

## THE MOST ADVANCED WRAPPER, THE FIRST AND UNIQUE WRAPPER IN INTERNET HAVING 5.1 TRANSCODING. YOU WILL HAVE FULL CONTROL OF THE CODEC USING THE CONFIGURATOR TOOL INTO THE INSTALLER.

# Wrapper for VideoStation and DLNA MediaServer for DTS, EAC3 and TrueHD with 5.1 support:
Synology VideoStation and MediaServer ffmpeg wrapper with DTS, EAC3 and TrueHD support. It enables hardware transcoding from Synology´s ffmpeg for video and transcoding DTS, HEVC, EAC3, AAC, True HD from the ffmpeg of the SynoCommunity. When you use this SynoCommunity´s ffmpeg, you will have AAC 5.1 512kbps Surround and another audio track MP3 2.0 256kbps Stereo for Chromecast or GoogleTV or other clients that don´t accept 5.1 AAC.


Works fine the OffLine transcoding and the streaming of tipical extensions like: MKV, MP4, AVI... Works fine the thumbnails in VideoStation.

This wrapper is a fork of BenjaminPoncet rev.12 with a few changes, fixes and some improvements in his code.

# VideoStation and DLNA MediaServer FFMPEG-Wrapper, now with Installer and Codecs CONFIGURATOR: 

This installer is designed to simplify the installation steps and enable **DTS**, **EAC3** and **TrueHD** support to Synology VideoStation by replacing the ffmpeg binary files by a wrapper using SynoCommunity ffmpeg, (only when It´s necessary).
You will can change the order of the audio codecs in the wrapper, install the most advanced wrapper with 5.1 or the simplest one, patch DLNA MediaServer and VideoStation, all in the SAME Installer.

The Installer has Multi Language support (English, Spanish, Portuguese, French, German, Italian).


## Dependencies:
- DSM 7.0-41890 (and above)
- Video Station 2.4.6-1594 (and above)
- SynoCommunity ffmpeg 4.4.3-48 (For the moment VideoStation It's not compatible with 5.X and 6.X) ([help](https://synocommunity.com/#easy-install))
- Advanced Media Extensions 1.0.0-50001 (and above). (The licence in AME must be LOADED.)

## Optional Packages:
- MediaServer 1.1.0-0201 (and above) (OPTIONAL)

## Supported / Unsupported scenarios:
- DTS or EAC3 or TrueHD + Any non standard video format: ✅
- no DTS, no EAC3, no TrueHD + HEVC: ✅
- DTS or EAC3 or TrueHD + HEVC: ✅
- DSM 7.X: ✅
- With DS-XXX PLAY Appliances or Low Powered Devices: ⚠️ I recommend install the Simplest Wrapper. The Advanced needs better CPU or have a GPU available for ffmpeg binary.
- DSM 6.2: ⚠️ The installer doesn´t support this version.
- DTS HD-MA: ⚠️ The Wrapper could play it, but there will not be transcoding of this audio codec. 

(In low powered devices you only will have remux of the audio.)

## Instructions:
- Check that you meet the required dependencies
- Install SynoCommunity ffmpeg ([help](https://synocommunity.com/#easy-install))
- Connect to your NAS using SSH (admin user required) ([help](https://www.synology.com/en-global/knowledgebase/DSM/tutorial/General_Setup/How_to_login_to_DSM_with_root_permission_via_SSH_Telnet))
- Use the command `sudo -i` to switch to root user
- Use the following command (Basic command) to execute the patch
- You'll have to re-run the patcher everytime you update VideoStation, Advanced Media Extensions and DSM

# USAGE:
Basic Installation command:  
`bash -c "$(curl "https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation/main/installer.sh")"`

.

With options:  
`bash -c "$(curl "https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation/main/installer.sh")" -- -s <Flags>`

| Flags        | Required | Description                                                                     |
|--------------|----------|---------------------------------------------------------------------------------|
| start        | No       | The default flag going to the MAIN Menu.                                        |   
| install      | No       | This install the Advanced Wrapper.                                              |  
| autoinstall  | No       | This install the Advanced Wrapper without prompts (Automatic Mode)              |  
| uninstall    | No       | This flag uninstall the patch. (Simplest or the Advanced one).                  |
| config       | No       | Change the behaviour of the audio codecs for the Advanced Wrapper               |
| info         | No       | Show the general info of the Installer                                          |




## Tests Wrappers:
<p align="center">
  <img src="https://github.com/darknebular/Wrapper_VideoStation/blob/main/images/test_results.png?raw=true" alt="wrappers">
</p>


## Tests Installers:
<p align="center">
  <img src="https://github.com/darknebular/Wrapper_VideoStation/blob/main/images/test_installers.png?raw=true" alt="installers">
</p>
