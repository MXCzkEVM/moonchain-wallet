#!/usr/bin/env bash
#Place this script in project/ios/

# fail if any command fails
set -e
# debug log
set -x

cd ..
git clone -b stable https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

flutter clean

echo "Installed flutter to `pwd`/flutter"

# configure Firebase project
if [ ! -z "$FIREBASE_PROJECT" ]; then
  npm install -g firebase-tools

  dart pub global activate flutterfire_cli

  flutterfire configure -y \
    --android-package-name="com.mxc.datadashwallet" \
    --ios-bundle-id="com.mxc.datadashwallet" \
    --macos-bundle-id="com.mxc.datadashwallet" \
    --platforms="ios,android" \
    -p "$FIREBASE_PROJECT" \
    -t "$FIREBASE_TOKEN"
fi

cat > ~/.netrc <<- EOM
machine api.mapbox.com
   login mapbox
   password ${MAP_BOX_SECRET_KEY}
EOM

chmod 0600 ~/.netrc

flutter build ios --release --no-codesign
