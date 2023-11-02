#!/usr/bin/env bash
#Place this script in project/android/app/

cd ..

# fail if any command fails
set -e
# debug log
set -x

cd ..
git clone -b stable https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Note: there is a bug with Flutter 3.10.0 when the whole app rebuilds when we open keyboard
# version 3.7.12 => 4d9e56e694b656610ab87fcf2efbcd226e0ed8cf
cd flutter
git reset --hard 4d9e56e694b656610ab87fcf2efbcd226e0ed8cf
cd ..

flutter clean

# accepting all licenses
yes | flutter doctor --android-licenses

echo "Installed flutter to `pwd`/flutter"

touch assets/.env
echo "APPCENTER_SECRET_ANDROID=${APPCENTER_SECRET_ANDROID}" > assets/.env
echo "APPCENTER_DISTRIBUTION_GROUP_ID_ANDROID=${APPCENTER_DISTRIBUTION_GROUP_ID_ANDROID}" >> assets/.env

# build APK
# if you get "Execution failed for task ':app:lintVitalRelease'." error, uncomment next two lines
# flutter build apk --debug
# flutter build apk --profile
flutter build apk --flavor product --release

# copy the APK where AppCenter will find it
mkdir -p android/app/build/outputs/apk/; mv build/app/outputs/apk/product/release/axs-wallet.apk $_