#!/bin/bash

# Download the script called installer_OffLine.sh in /tmp/
curl -o /tmp/installer_OffLine.sh "https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation/main/installer_OffLine.sh"

# Give execution permissions to the downloaded script
chmod +x /tmp/installer_OffLine.sh

# Run installer_OffLine.sh passing the supplied arguments to the installer.sh script
/bin/bash /tmp/installer_OffLine.sh "$@"

# Delete the downloaded script
rm /tmp/installer_OffLine.sh
