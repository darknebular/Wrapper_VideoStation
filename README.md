<p align="center">
  <img src="https://github.com/darknebular/Wrapper_VideoStation/blob/main/images/logoIntro.png?raw=true" height=300px alt="intro">
</p>
<p align="center">
  <img src="https://github.com/darknebular/Wrapper_VideoStation/blob/main/images/logo.png?raw=true" height=200px alt="logo">
</p>

## THE MOST ADVANCED WRAPPER, THE FIRST AND UNIQUE WRAPPER IN INTERNET HAVING 5.1 TRANSCODING. YOU WILL HAVE FULL CONTROL OF THE CODEC USING THE CONFIGURATOR TOOL INTO THE INSTALLER.

# Wrapper for VideoStation and DLNA MediaServer for DTS, EAC3 and TrueHD with 5.1 support:
Synology VideoStation and MediaServer FFmpeg (and GStreamer) Wrapper with DTS, EAC3 and TrueHD support. It enables hardware transcoding from Synology´s ffmpeg for video and transcoding DTS, HEVC, EAC3, AAC, True HD from the ffmpeg of the SynoCommunity. When you use this SynoCommunity´s ffmpeg, you will have AAC 5.1 512kbps Surround and another audio track MP3 2.0 256kbps Stereo for Chromecast or GoogleTV or other clients that don´t accept 5.1 AAC.


Works fine the OffLine transcoding and the streaming of tipical extensions like: MKV, MP4, AVI... Works fine the thumbnails in VideoStation.

This wrapper is a fork of BenjaminPoncet rev.12 with a some changes, fixes and some improvements in his code.

# VideoStation and DLNA MediaServer FFMPEG-Wrapper, now with Installer and Codecs CONFIGURATOR: 

This installer is designed to simplify the installation steps and enable **DTS**, **EAC3** and **TrueHD** support to Synology VideoStation and MediaServer by replacing the ffmpeg binary files by a wrapper using SynoCommunity ffmpeg, (only when It´s necessary).
You will can change the order of the audio codecs in the Wrapper, install the most Advanced Wrapper with 5.1 or the Simplest one, patch DLNA MediaServer and VideoStation, all in the SAME Installer.

The Installer has Multi Language support (English, Spanish, Portuguese, French, German, Italian).

# Now the Installer has the AME's License Fix: 
This enables the AAC and HEVC codecs and its license in the AME package, until DSM 7.2.
This patcher enables Advanced Media Extensions 3.0 for you, without having to login account (You still need a valid S/N. If you need to spoof the S/N, please use the synocodectools). When you install this License's patch, the Wrapper must be uninstalled and you must to re-install it again.
This is not mandatory to have it installed for installing the Wrapper.

*(Use at your own risk, although it has been done to be as safe as possible, there could be errors. (Crack for XPEnology and Synology without AME's license).*

## Dependencies:
- DSM 7.0-41890 (and above)
- Video Station 2.4.6-1594 (and above)
- SynoCommunity FFMPEG 6.0.2. (and above) ([help](https://synocommunity.com/#easy-install))
- Advanced Media Extensions 1.0.0-50001 (and above). (The licence in AME must be LOADED and ACTIVATED.)

## Optional Packages:
- MediaServer 1.1.0-0201 (and above) (OPTIONAL)

## Supported / Unsupported scenarios:
- DTS or EAC3 or TrueHD or AAC + Any non standard video format: ✅
- no DTS, no EAC3, no TrueHD, no AAC + HEVC: ✅
- DTS or EAC3 or TrueHD or AAC (5.1 or 7.1) + HEVC: ✅
- DSM 7.X.X: ✅
- With DS-XXX PLAY Appliances or Low Powered Devices: ✅ *(I recommend install the Simplest Wrapper. The Advanced needs better CPU or have a GPU available for FFmpeg binary for HEVC decoding.)*
- DSM 6.2: ⚠️ The installer doesn´t support this version.

*(In low powered devices you only will have remux of the audio or only be able to play it without transcoding.)*

## Instructions:
- Check that you meet the required dependencies
- Install SynoCommunity ffmpeg ([help](https://synocommunity.com/#easy-install))
- Connect to your NAS using SSH (admin user required) *(I recommend maximizing the window to read it better.)* ([help](https://www.synology.com/en-global/knowledgebase/DSM/tutorial/General_Setup/How_to_login_to_DSM_with_root_permission_via_SSH_Telnet))
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
| autoinstall  | No       | This install the Advanced/Simplest Wrapper without prompts (Automatic Mode)     |  
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
