#!/bin/bash

# Download the script called installer_OffLine.sh in /tmp/
curl -L --max-filesize 512000 -o /tmp/testing_OffLine.sh "https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation/main/testing_OffLine.sh"

# Give execution permissions to the downloaded script
chmod +x /tmp/testing_OffLine.sh

# Run installer.sh passing the supplied arguments to the installer_OffLine.sh script
/bin/bash /tmp/testing_OffLine.sh "$@"

# Delete the downloaded script
rm /tmp/testing_OffLine.sh
