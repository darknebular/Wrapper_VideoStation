<p align="center">
  <img src="https://github.com/darknebular/Wrapper_VideoStation/blob/main/logo.png?raw=true" height=200px alt="logo">
</p>
# Wrapper for VideoStation and DLNA MediaServer for DTS, EAC3 and TrueHD with AAC 5.1:
Synology VideoStation and MediaServer ffmpeg wrapper with DTS, EAC3 and TrueHD support. It enables hardware transcoding from Synology´s ffmpeg for video and transcoding DTS, HEVC, EAC3, AAC, True HD from the ffmpeg of the SynoCommunity. When you use this SynoCommunity´s ffmpeg, you will have AAC 5.1 512kbps Surround and another audio track MP3 2.0 256kbps Stereo for Chromecast or GoogleTV or other clients that don´t accept 5.1 AAC.


Works fine the OffLine transcoding and the streaming of tipical extensions like: MKV, MP4, AVI ...

This wrapper is a fork of BenjaminPoncet rev.12 with a few changes, fixes and some improvements in his code.

# VideoStation and MediaServer FFMPEG-Wrapper, now with Installer: 

This installer is designed to simplify the installation steps and enable **DTS**, **EAC3** and **TrueHD** support to Synology VideoStation by replacing the ffmpeg library files by a wrapper using SynoCommunity ffmpeg, only when It´s necessary.


## Dependencies
- DSM 7.0-41890 (and above)
- Video Station 2.4.6-1594 (and above)
- SynoCommunity ffmpeg 4.2.1-23 (and above) ([help](https://synocommunity.com/#easy-install))

## Supported / Unsupported scenarios
- DTS or EAC3 or TrueHD + Any non standard video format: ✅
- no DTS, no EAC3, no TrueHD + HEVC: ✅
- DTS or EAC3 or TrueHD + HEVC: ✅
- DSM 7.X: ✅
- DSM 6.2: ⚠️ The installer doesn´t support this version, you will need do a Manual procedure.

## Instructions
- Check that you meet the required 
- Install SynoCommunity ffmpeg ([help](https://synocommunity.com/#easy-install))
- Connect to your NAS using SSH (admin user required) ([help](https://www.synology.com/en-global/knowledgebase/DSM/tutorial/General_Setup/How_to_login_to_DSM_with_root_permission_via_SSH_Telnet))
- Use the command `sudo -i` to switch to root user
- Use the following command (Basic command) to execute the patch
- You'll have to re-run the patcher everytime you update VideoStation, Advanced Media Extensions and DSM

## Usage
Basic command:  
`curl https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation/main/installer.sh | bash`   
With options:  
`curl https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation/main/installer.sh | bash -s --<flags>`

| Flags        | Required | Description                                                                     |
|--------------|----------|---------------------------------------------------------------------------------|
| install      | No       | The default flag, this install the patch.                                       |                            
| uninstall    | No       | This flag uninstall the patch.                                                  |      




