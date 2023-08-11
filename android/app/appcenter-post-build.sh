#!/usr/bin/env bash
#Place this script in project/android/app/

# fail if any command fails
set -e
# debug log
set -x

echo $APPCENTER_OUTPUT_DIRECTORY

if [ "$APPCENTER_BRANCH" == "release_china" ] && [ "$AGENT_JOBSTATUS" == "Succeeded" ]; then
    FILEPATH=$APPCENTER_OUTPUT_DIRECTORY/${OBJECT_NAME}
    RESOURCE="/${OSS_BUCKET_NAME}/${OBJECT_NAME}"
    CONTENT_MD5=$(openssl dgst -md5 -binary "${FILEPATH}" | openssl enc -base64)
    DATE_VALUE="`TZ=GMT date +'%a, %d %b %Y %H:%M:%S GMT'`"
    STRING_TO_SIGN="PUT\n${CONTENT_MD5}\n${CONTENT_TYPE}\n${DATE_VALUE}\n${RESOURCE}"
    SIGNATURE=$(echo -e -n $STRING_TO_SIGN | openssl dgst -sha1 -binary -hmac $OSS_ACCESS_KEY_SECRET | openssl enc -base64)
    URL="https://${OSS_BUCKET_NAME}.${OSS_REGION}.aliyuncs.com/${OBJECT_NAME}"
    curl -i -q -X PUT -T "${FILEPATH}" \
      -H "Host: ${OSS_BUCKET_NAME}.${OSS_REGION}.aliyuncs.com" \
      -H "Date: ${DATE_VALUE}" \
      -H "Content-Type: ${CONTENT_TYPE}" \
      -H "Content-MD5: ${CONTENT_MD5}" \
      -H "Authorization: OSS ${OSS_ACCESS_KEY_ID}:${SIGNATURE}" \
      ${URL}

fi
