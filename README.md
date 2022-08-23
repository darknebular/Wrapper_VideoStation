# Wrapper_VideoStation for ffmpeg-wrapper and for DLNA Media Server. Standard version:
Synology VideoStation ffmpeg wrapper with DTS, EAC3 and TrueHD support. It enables hardware transcoding from Synology´s ffmpeg for video and transcoding DTS, HEVC, EAC3, AAC, True HD from the ffmpeg of the SynoCommunity. When you use this SynoCommunity´s ffmpeg, you will have AAC 5.1 512kbps Surround and another audio track 2.0 MP3 Stereo for Chromecast or GoogleTV or other clients that don´t accept 5.1 AAC.


Works fine the OffLine transcoding and the streaming of tipical extensions like: MKV, MP4, AVI ...

This wrapper is a fork of BenjaminPoncet rev.12 with a few changes, fixes and some improvements in his code.

************************************************************************

# INSTALL: For DSM 7.1: (VERSION 12.3.3 NOW WITH 5.1 AAC and Multi Audio Streams)

# INSTALL: Wrapper for Advance Codec Pack 2.0.X installed with ffmpeg41-wrapper-DSM7_1-12.3.3 file 

************************************************************************
**With this wrapper (ffmpeg41-wrapper_DSM7_1-12.3.3 file) you will be with the original Synology´s ffmpeg almost time and only you will use the ffmpeg 4.4.2-XX when is 100% necessary. You will need Putty or other SSH Client in order to connect.**

1) cd /var/packages/CodecPack/target/pack/bin

2) sudo mv /var/packages/CodecPack/target/pack/bin/ffmpeg41 /var/packages/CodecPack/target/pack/bin/ffmpeg41.orig

**You must select 3.a or 3.b steps:**

3.a) sudo vi ffmpeg41

----Push "i" key and then PASTE (right-click) the content of the file called ffmpeg41-wrapper-DSM7_1-12.3.3

----"ESC" key and then write :wq

**(Or you can do this if you don´t want to use VI command:)**

3.b) sudo touch ffmpeg41 | sudo wget https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation/main/ffmpeg41-wrapper-DSM7_1-12.3.3 -O /var/packages/CodecPack/target/pack/bin/ffmpeg41

4) sudo chmod 755 /var/packages/CodecPack/target/pack/bin/ffmpeg41



# Save VideoStation's libsynovte.so and DLNA Media server´s libsynovte.so

5) sudo cp -n /var/packages/VideoStation/target/lib/libsynovte.so /var/packages/VideoStation/target/lib/libsynovte.so.orig

6) sudo chown VideoStation:VideoStation /var/packages/VideoStation/target/lib/libsynovte.so.orig

7) sudo cp -n /var/packages/MediaServer/target/lib/libsynovte.so /var/packages/MediaServer/target/lib/libsynovte.so.orig

8) sudo chown MediaServer:MediaServer /var/packages/MediaServer/target/lib/libsynovte.so.orig

9) sudo chmod 644 libsynovte.so.orig


# Patch libsynovte.so to authorize DTS, EAC3 and TrueHD

10) sudo sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' /var/packages/VideoStation/target/lib/libsynovte.so

11) sudo sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' /var/packages/MediaServer/target/lib/libsynovte.so

12) sudo synopkg restart VideoStation


13) ¡¡¡¡¡ENJOY!!!!!


********************************************************************
# UNINSTALL FOR DSM 7.1:
********************************************************************
# Restore VideoStation's ffmpeg, libsynovte.so

sudo rm /var/packages/VideoStation/target/lib/libsynovte.so

sudo mv -f /var/packages/VideoStation/target/lib/libsynovte.so.orig /var/packages/VideoStation/target/lib/libsynovte.so

sudo rm /var/packages/MediaServer/target/lib/libsynovte.so

sudo mv -f /var/packages/MediaServer/target/lib/libsynovte.so.orig /var/packages/MediaServer/target/lib/libsynovte.so

sudo rm /var/packages/CodecPack/target/pack/bin/ffmpeg41

sudo mv /var/packages/CodecPack/target/pack/bin/ffmpeg41.orig /var/packages/CodecPack/target/pack/bin/ffmpeg41










************************************************************************

# INSTALL: For DSM 7.0: (DEPRECATED)

# INSTALL: Wrapper for Advance Codec Pack 1.X with installed ffmpeg41-wrapper-DSM7_0-12.2.1 file 

************************************************************************
**With this wrapper (ffmpeg41-wrapper-DSM7_0-12.2.1) you will be with the original ffmpeg almost time and only you will use the ffmpeg 4.31 when is 100% necessary**

1) cd /var/packages/CodecPack/target/bin

2) sudo mv /var/packages/CodecPack/target/bin/ffmpeg41 /var/packages/CodecPack/target/bin/ffmpeg41.orig

**You must select 3.a or 3.b steps:**

3.a) sudo vi ffmpeg41

----Push I key and then PASTE the content of the file called ffmpeg41-wrapper-DSM7_0-12.2.1

----ESC key and then write :wq

**Or you can do this if you don´t want to use VI command:**

3.b) sudo touch ffmpeg41 | sudo wget https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation/main/ffmpeg41-wrapper-DSM7_0-12.2.1 -O /var/packages/CodecPack/target/bin/ffmpeg41 
 

4) sudo chmod 755 /var/packages/CodecPack/target/bin/ffmpeg41



# Save VideoStation's libsynovte.so

5) sudo cp -n /var/packages/VideoStation/target/lib/libsynovte.so /var/packages/VideoStation/target/lib/libsynovte.so.orig

6) sudo chown VideoStation:VideoStation /var/packages/VideoStation/target/lib/libsynovte.so.orig


# Patch libsynovte.so to authorize DTS, EAC3 and TrueHD

7) sudo sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' /var/packages/VideoStation/target/lib/libsynovte.so

8) sudo synopkg restart VideoStation




********************************************************************
# UNINSTALL FOR DSM 7.0:
********************************************************************
# Restore VideoStation's ffmpeg, libsynovte.so

sudo rm /var/packages/VideoStation/target/lib/libsynovte.so

sudo mv -f /var/packages/VideoStation/target/lib/libsynovte.so.orig /var/packages/VideoStation/target/lib/libsynovte.so

sudo rm /var/packages/MediaServer/target/lib/libsynovte.so

sudo mv -f /var/packages/MediaServer/target/lib/libsynovte.so.orig /var/packages/MediaServer/target/lib/libsynovte.so

sudo rm /var/packages/CodecPack/target/bin/ffmpeg41

sudo mv /var/packages/CodecPack/target/bin/ffmpeg41.orig /var/packages/CodecPack/target/bin/ffmpeg41





********************************************************************
# INSTALL: Wrapper standard FOR DSM 6.2.X (DEPRECATED)
********************************************************************

# Save VideoStation's ffmpeg

sudo mv -n /var/packages/VideoStation/target/bin/ffmpeg /var/packages/VideoStation/target/bin/ffmpeg.orig

# Injecting the script:

 sudo touch ffmpeg | sudo wget https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation/main/ffmpeg-wrapper-DSM6_X-12.1 -O /var/packages/VideoStation/target/bin/ffmpeg 

# Change ownership and mode of the script

sudo chown root:VideoStation /var/packages/VideoStation/target/bin/ffmpeg

sudo chmod 750 /var/packages/VideoStation/target/bin/ffmpeg

sudo chmod u+s /var/packages/VideoStation/target/bin/ffmpeg


# Save VideoStation's libsynovte.so

sudo cp -n /var/packages/VideoStation/target/lib/libsynovte.so /var/packages/VideoStation/target/lib/libsynovte.so.orig

sudo chown VideoStation:VideoStation /var/packages/VideoStation/target/lib/libsynovte.so.orig


# Patch libsynovte.so to authorize DTS, EAC3 and TrueHD

sudo sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' /var/packages/VideoStation/target/lib/libsynovte.so


# Apply the WRAPPER to the decoder:

sudo mv /var/packages/CodecPack/target/bin/ffmpeg33 /var/packages/CodecPack/target/bin/ffmpeg33.orig

sudo cp /var/packages/VideoStation/target/bin/ffmpeg /var/packages/CodecPack/target/bin/ffmpeg33

sudo chmod 755 /var/packages/CodecPack/target/bin/ffmpeg33



# Restart VideoStation (Stop/Start in "Package Center")



********************************************************************
# UNINSTALL FOR DSM 6.2.X:
********************************************************************
# Restore VideoStation's ffmpeg, libsynovte.so

sudo rm /var/packages/VideoStation/target/bin/ffmpeg

sudo mv -f /var/packages/VideoStation/target/bin/ffmpeg.orig /var/packages/VideoStation/target/bin/ffmpeg

sudo rm /var/packages/VideoStation/target/lib/libsynovte.so

sudo mv -f /var/packages/VideoStation/target/lib/libsynovte.so.orig /var/packages/VideoStation/target/lib/libsynovte.so

sudo rm /var/packages/CodecPack/target/bin/ffmpeg33

sudo mv /var/packages/CodecPack/target/bin/ffmpeg33.orig /var/packages/CodecPack/target/bin/ffmpeg33





