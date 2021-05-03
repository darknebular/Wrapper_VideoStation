# Wrapper_VideoStation for ffmpeg-wrapper. Standard version:
Synology VideoStation ffmpeg wrapper with DTS, EAC3 and TrueHD support. It enables hardware transcoding from ffmpeg from Synology for video and transcoding DTS, EAC3, AAC from the ffmpeg of the SynoCommunity.

Works fine the OffLine transcoding and the streaming of tipical extensions like: MKV, MP4, AVI ...

This wrapper is a fork of BenjaminPoncet rev.12 with a few changes, fixes and some improvements in his code.


********************************************************************
INSTALL: Wrapper standard
********************************************************************

# Save VideoStation's ffmpeg

sudo mv -n /var/packages/VideoStation/target/bin/ffmpeg /var/packages/VideoStation/target/bin/ffmpeg.orig

# Injecting the script:

sudo wget -O - https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation/main/ffmpeg-wrapper > /var/packages/VideoStation/target/bin/ffmpeg

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
UNISTALL:
********************************************************************
# Restore VideoStation's ffmpeg, libsynovte.so

sudo rm /var/packages/VideoStation/target/bin/ffmpeg

sudo mv -f /var/packages/VideoStation/target/bin/ffmpeg.orig /var/packages/VideoStation/target/bin/ffmpeg

sudo rm /var/packages/VideoStation/target/lib/libsynovte.so

sudo mv -f /var/packages/VideoStation/target/lib/libsynovte.so.orig /var/packages/VideoStation/target/lib/libsynovte.so

sudo rm /var/packages/CodecPack/target/bin/ffmpeg33

sudo mv /var/packages/CodecPack/target/bin/ffmpeg33.orig /var/packages/CodecPack/target/bin/ffmpeg33




************************************************************************
INSTALL: Wrapper for Advance Codec Pack installed ffmpeg33-wrapper file
************************************************************************
# With this wrapper (ffmpeg33-wrapper file) you will be with the original ffmpeg almost time and only you will use the ffmpeg 4.31 when is 100% necessary

cd /var/packages/CodecPack/target/bin

sudo mv /var/packages/CodecPack/target/bin/ffmpeg33 /var/packages/CodecPack/target/bin/ffmpeg33.orig

sudo vi ffmpeg33

----Push I key and then COPY the content of the file called ffmpeg33-wrapper

----ESC key and then write :wq

sudo chmod 755 /var/packages/CodecPack/target/bin/ffmpeg33
sudo chmod u+s /var/packages/CodecPack/target/bin/ffmpeg33


# Save VideoStation's libsynovte.so

sudo cp -n /var/packages/VideoStation/target/lib/libsynovte.so /var/packages/VideoStation/target/lib/libsynovte.so.orig

sudo chown VideoStation:VideoStation /var/packages/VideoStation/target/lib/libsynovte.so.orig


# Patch libsynovte.so to authorize DTS, EAC3 and TrueHD

sudo sed -i -e 's/eac3/3cae/' -e 's/dts/std/' -e 's/truehd/dheurt/' /var/packages/VideoStation/target/lib/libsynovte.so



