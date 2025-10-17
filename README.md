# 로컬 APNs 푸시 전송기

제공된 스크립트와 샘플 페이로드를 이용해 토큰 기반 APNs 푸시를 보내는 방법을 정리했습니다.

## 파일 구성
- `send.sh`: JWT 자격 증명을 생성하고 APNs로 HTTP/2 요청을 보냅니다.
- `info.json`: Apple 팀/앱 정보와 대상 디바이스 토큰을 저장합니다.
- `payload.json`: 테스트용 알림 본문으로, 필요에 맞게 수정할 수 있습니다.

## 사전 준비
- `bash`, `curl`, `openssl`, `jq`가 설치된 macOS 또는 Linux 환경.
- Apple Developer에서 다운로드한 APNs Auth Key `.p8` 파일(이 폴더 안에 보관).
- 타깃 빌드에서 획득한 디바이스 토큰(샌드박스 토큰과 프로덕션 토큰은 다릅니다).

## `info.json` 설정
다음 항목을 실행 전에 반드시 채워 넣으세요.
- `team_id`: 10자리 Apple Developer 팀 ID.
- `token_key_file_name`: `.p8` 키의 파일명 또는 상대 경로(예: `AuthKey_ABC123XYZ.p8`).
- `auth_key_id`: Apple Developer 콘솔에서 키 옆에 표시되는 Key ID.
- `topic`: 대상 iOS 앱의 번들 식별자(예: `com.example.MyApp`).
- `device_token`: 디바이스 로그에서 복사한 64자리 APNs 토큰.
- `environment`: 디버그/테스트 빌드는 `sandbox`, 앱스토어 빌드는 `production`.

## 페이로드 수정
`payload.json`을 열어 알림 내용을 다음 항목 위주로 조정하세요.
- `aps.alert.title`: 알림 제목.
- `aps.alert.body`: 알림 본문.
- `dfn.img`: 알림에 표시할 이미지 URL(예: CDN에 저장된 썸네일 주소).
- `dfn.is_f`: `1`이면 앱이 포그라운드에서도 알림 배너가 뜨고, `0`이면 포그라운드일 때 표시되지 않습니다.
- `dfn.click_act.act_type`: `Deeplink`이면 딥링크를 열고, `AppOpen`이면 앱만 실행합니다.
- `dfn.click_act.uri`: `scheme://path` 형태의 딥링크 URL.
나머지 필드는 필요에 따라 유지하거나 수정하면 됩니다. 자세한 내용은 [디파이너리 개발가 가이드 명세서](https://docs.dfinery.ai/developer-guide/common/specification/ios-push-payload)를 참고해주세

## 푸시 전송 절차
1. 스크립트가 실행 권한이 없으면 `chmod +x send.sh`를 한 번 실행합니다.
2. `./send.sh`를 실행합니다.
3. 스크립트는 `.p8` 키로 새 JWT를 서명하고, `environment` 값에 맞는 APNs 호스트를 선택한 뒤 페이로드를 대상 디바이스 토큰으로 전송합니다.

## 문제 해결 팁
- `curl: (60)` 등의 TLS 오류는 HTTP/2 트래픽이 차단된 경우가 많으니 다른 네트워크에서 재시도하세요.
- APNs 응답이 `BadDeviceToken`이면 토큰 종류와 `environment` 값이 일치하는지 확인하세요.
- `InvalidProviderToken`(403)이 반환되면 `info.json`에 입력한 팀/키 정보 또는 `.p8` 파일 경로가 잘못된 것입니다.
