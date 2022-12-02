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
shasum -a 512 -c $BASENAME.sha512
echo "[OK] SHA512 verified"
