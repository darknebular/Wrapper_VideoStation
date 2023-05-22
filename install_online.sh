#!/bin/bash

# Download the script called testing128.sh in /tmp/
curl -o /tmp/testing128.sh "https://raw.githubusercontent.com/darknebular/Wrapper_VideoStation/main/testing128.sh"

# Give execution permissions to the downloaded script
chmod +x /tmp/testing128.sh

# Run testing128.sh passing the supplied arguments to the install_online.sh script
/bin/bash /tmp/testing128.sh "$@"

# Delete the downloaded script
rm /tmp/testing128.sh
