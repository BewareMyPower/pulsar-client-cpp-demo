#!/bin/bash
set -e
cd `dirname $0`

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 base_url

The base_url is the download url of the file.
Make sure you have imported the key via 'gpg --import keys'
"
    exit 1
fi

URL=$1
BASENAME=$(basename $URL)

cd /tmp
curl -O -L $URL
curl -O -L $URL.asc
curl -O -L $URL.sha512
gpg --verify $BASENAME.asc
echo "[OK] GPG verified"

# Do not use -c xxx.sha512 to avoid the path is different
SHASUM=$(shasum -a 512 $BASENAME | awk '{print $1}')
EXPECTED_SHASUM=$(cat $BASENAME.sha512 | awk '{print $1}')
if [[ $SHASUM ==  $EXPECTED_SHASUM ]]; then
    echo "[OK] SHA512 verified"
else
    echo "[FAILED] SHA512 checksum: $SHASUM"
    echo "                expected: $EXPECTED_SHASUM"
fi
