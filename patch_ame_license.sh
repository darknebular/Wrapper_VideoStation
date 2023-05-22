#!/bin/bash

patch_ame_license() {
    r=("669066909066906690" "B801000000" "30")
    s=("0x1F28 0" "0x48F5 1" "0x4921 1" "0x4953 1" "0x4975 1" "0x9AC8 2")

    prefix="/var/packages/CodecPack/target/usr"
    so="$prefix/lib/libsynoame-license.so"

    echo "Patching"
    if ! md5sum_result=$(md5sum "$so"); then
        echo "Failed to compute MD5 hash"
        exit 1
    fi

    read -r md5sum _ <<< "$md5sum_result"
    if [[ $md5sum != "fcc1084f4eadcf5855e6e8494fb79e23" ]]; then
        echo "MD5 mismatch"
        exit 1
    fi

    for x in "${s[@]}"; do
        addr=${x%% *}
        index=${x#* }
        offset=$((0x8000 + $addr))
        printf -v hex_val "%X" "0x${r[$index]}"
        echo -n "$hex_val" | xxd -r -p | dd of="$so" bs=1 seek="$offset" conv=notrunc 2>/dev/null
    done

    lic="/usr/syno/etc/license/data/ame/offline_license.json"
    mkdir -p "$(dirname "$lic")"

    cat > "$lic" <<EOF
[
    {
        "appType": 14,
        "appName": "ame",
        "follow": ["device"],
        "server_time": 1666000000,
        "registered_at": 1651000000,
        "expireTime": 0,
        "status": "valid",
        "firstActTime": 1651000001,
        "extension_gid": null,
        "licenseCode": "0",
        "duration": 1576800000,
        "attribute": {"codec": "hevc", "type": "free"},
        "licenseContent": 1
    },
    {
        "appType": 14,
        "appName": "ame",
        "follow": ["device"],
        "server_time": 1666000000,
        "registered_at": 1651000000,
        "expireTime": 0,
        "status": "valid",
        "firstActTime": 1651000001,
        "extension_gid": null,
        "licenseCode": "0",
        "duration": 1576800000,
        "attribute": {"codec": "aac", "type": "free"},
        "licenseContent": 1
    }
]
EOF

    echo "Checking whether patch is successful..."
    if synoame_bin_check_license="$prefix/bin/synoame-bin-check-license"; "$synoame_bin_check_license"; then
        echo "Successful, updating codecs..."
        synoame_bin_auto_install_needed_codec="$prefix/bin/synoame-bin-auto-install-needed-codec"
        "$synoame_bin_auto_install_needed_codec"
        echo "Done"
    else
        echo "Patch is unsuccessful"
    fi
}

patch_ame_license
