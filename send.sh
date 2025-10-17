#!/bin/bash
set -e

# JSON 파일 경로 설정
CONFIG_FILE="./info.json"
PAYLOAD_FILE="./payload.json"

# JSON 파일에서 값을 읽어와 변수에 저장
TEAM_ID=$(jq -r '.team_id' "$CONFIG_FILE")
TOKEN_KEY_FILE_NAME=$(jq -r '.token_key_file_name' "$CONFIG_FILE")
AUTH_KEY_ID=$(jq -r '.auth_key_id' "$CONFIG_FILE")
TOPIC=$(jq -r '.topic' "$CONFIG_FILE")
DEVICE_TOKEN=$(jq -r '.device_token' "$CONFIG_FILE")
ENVIRONMENT=$(jq -r '.environment' "$CONFIG_FILE")
PAYLOAD=$(cat "$PAYLOAD_FILE")

if [ "$ENVIRONMENT" == "production" ]; then
    APNS_HOST_NAME="api.push.apple.com"
elif [ "$ENVIRONMENT" == "sandbox" ]; then
    APNS_HOST_NAME="api.sandbox.push.apple.com"
fi

JWT_ISSUE_TIME=$(date +%s)
JWT_HEADER=$(printf '{ "alg": "ES256", "kid": "%s" }' "${AUTH_KEY_ID}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
JWT_CLAIMS=$(printf '{ "iss": "%s", "iat": %d }' "${TEAM_ID}" "${JWT_ISSUE_TIME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
JWT_HEADER_CLAIMS="${JWT_HEADER}.${JWT_CLAIMS}"
JWT_SIGNED_HEADER_CLAIMS=$(printf "${JWT_HEADER_CLAIMS}" | openssl dgst -binary -sha256 -sign "${TOKEN_KEY_FILE_NAME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
AUTHENTICATION_TOKEN="${JWT_HEADER}.${JWT_CLAIMS}.${JWT_SIGNED_HEADER_CLAIMS}"


curl -v --header "apns-topic: $TOPIC" --header "apns-push-type: alert" --header "authorization: bearer $AUTHENTICATION_TOKEN" --data "${PAYLOAD}" --http2 https://${APNS_HOST_NAME}/3/device/${DEVICE_TOKEN}