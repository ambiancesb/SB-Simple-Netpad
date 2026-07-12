// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get commonAppName => 'SB Simple Netpad';

  @override
  String get commonStandardName => 'Netpad Standard';

  @override
  String get commonCancel => '취소';

  @override
  String get commonClose => '닫기';

  @override
  String get commonSave => '저장';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonConnect => '연결';

  @override
  String get commonHelp => '도움말';

  @override
  String get commonSettings => '설정';

  @override
  String get commonMore => '더보기';

  @override
  String get commonCopy => '복사';

  @override
  String get commonClear => '지우기';

  @override
  String get commonAccept => '수락';

  @override
  String get commonReject => '거절';

  @override
  String get commonBlock => '차단';

  @override
  String get commonUnblock => '차단 해제';

  @override
  String get commonRevoke => '취소';

  @override
  String get commonRestore => '복원';

  @override
  String get commonRetry => '재시도';

  @override
  String commonCouldNotOpenLabel(String label) {
    return '$label을(를) 열 수 없습니다';
  }

  @override
  String get commonEulaLabel => 'EULA';

  @override
  String get commonPrivacyPolicyLabel => '개인정보처리방침';

  @override
  String get commonEndUserLicenseAgreement => '최종 사용자 라이선스 계약';

  @override
  String get commonPrivacyPolicy => '개인정보처리방침';

  @override
  String commonVersionLabel(String version) {
    return '버전 $version';
  }

  @override
  String get shellMenuFile => '파일';

  @override
  String get shellMenuEdit => '편집';

  @override
  String get shellMenuView => '보기';

  @override
  String get shellMenuHelp => '도움말';

  @override
  String get shellSaveToFile => '파일로 저장…';

  @override
  String get shellOpenFileAsNewNote => '파일을 새 메모로 열기…';

  @override
  String get shellShareNote => '메모 공유';

  @override
  String get shellVersionHistory => '버전 기록…';

  @override
  String get shellSettings => '설정…';

  @override
  String get shellExit => '종료';

  @override
  String get shellCut => '잘라내기';

  @override
  String get shellCopy => '복사';

  @override
  String get shellPaste => '붙여넣기';

  @override
  String get shellFind => '찾기…';

  @override
  String get shellFindAndReplace => '찾기 및 바꾸기…';

  @override
  String get shellWordWrap => '자동 줄 바꿈';

  @override
  String get shellWordWrapChecked => '자동 줄 바꿈 ✓';

  @override
  String get shellNotesPanel => '메모 패널';

  @override
  String get shellNotesPanelChecked => '메모 패널 ✓';

  @override
  String get shellPeersPanel => '피어 패널';

  @override
  String get shellPeersPanelChecked => '피어 패널 ✓';

  @override
  String get shellHelpItem => 'SB Simple Netpad 도움말';

  @override
  String get shellAboutItem => 'SB Simple Netpad 정보';

  @override
  String get shellHideNotesPanel => '메모 패널 숨기기';

  @override
  String get shellShowNotesPanel => '메모 패널 표시 (Ctrl+N)';

  @override
  String get shellHidePeersPanel => '피어 패널 숨기기';

  @override
  String get shellShowPeersPanel => '피어 패널 표시 (Ctrl+P)';

  @override
  String shellPeersTooltipConnected(int count, String action) {
    return '$count개의 암호화된 피어 세션 · 피어 패널 $action (Ctrl+P)';
  }

  @override
  String get shellPeersTooltipActionHide => '숨기기';

  @override
  String get shellPeersTooltipActionShow => '표시';

  @override
  String get shellFindInNote => '메모에서 찾기 (Ctrl+F)';

  @override
  String shellSecurityChipConnected(int count) {
    return 'WSS/TLS로 암호화된 $count개의 피어 세션 · 피어 보기 탭';
  }

  @override
  String get shellSecurityChipNone => '활성 피어 세션 없음 · 피어 보기 탭';

  @override
  String get shellMobileWordWrap => '자동 줄 바꿈';

  @override
  String get shellMobileSaveToFile => '파일로 저장…';

  @override
  String get shellMobileOpenFileAsNewNote => '파일을 새 메모로 열기…';

  @override
  String get shellMobileShareNote => '메모 공유';

  @override
  String get shellMobileVersionHistory => '버전 기록…';

  @override
  String get shellMobileSettings => '설정';

  @override
  String get shellMobileHelp => '도움말';

  @override
  String get shellMobileAbout => 'SB Simple Netpad 정보';

  @override
  String get shellListeningSnack => '듣고 있습니다… 마이크를 다시 탭하여 중지';

  @override
  String get notesTitle => '메모';

  @override
  String get notesNewNote => '새 메모';

  @override
  String get notesSearchHint => '모든 메모 검색';

  @override
  String get notesRenameTitle => '메모 이름 바꾸기';

  @override
  String get notesTitleLabel => '제목';

  @override
  String notesDeleteTitle(String title) {
    return '\"$title\"을(를) 삭제하시겠습니까?';
  }

  @override
  String get notesDeleteSyncedBody => '이렇게 하면 귀하와 연결된 모든 피어에서 메모가 제거됩니다.';

  @override
  String get notesDeleteLocalBody => '이렇게 하면 이 기기에서만 메모가 제거됩니다.';

  @override
  String get notesNoMatches => '일치 없음';

  @override
  String get notesNoNotes => '메모 없음';

  @override
  String get notesRename => '이름 바꾸기';

  @override
  String get notesVersionHistory => '버전 기록';

  @override
  String get notesDelete => '삭제';

  @override
  String get notesSyncWithPeers => '피어와 동기화';

  @override
  String get notesLocalOnly => '로컬 전용';

  @override
  String get notesEmptyNote => '빈 메모';

  @override
  String notesMatchCount(int count) {
    return '$count개 일치';
  }

  @override
  String notesLocalOnlyWithMatches(String matchLine) {
    return '로컬 전용 · $matchLine';
  }

  @override
  String notesSearchSnippetMatches(String snippet, int count) {
    return '$snippet  ·  $count개 일치';
  }

  @override
  String get notesNoNoteSelected => '선택된 메모 없음';

  @override
  String historyTitle(String title) {
    return '버전 기록 · \"$title\"';
  }

  @override
  String get historyEmpty =>
      '아직 저장된 버전이 없습니다. 원격 편집이 텍스트를 교체하기 전에 스냅샷이 자동으로 보관됩니다.';

  @override
  String historyEntrySubtitle(String label, String time, int chars) {
    return '$label · $time · $chars자';
  }

  @override
  String get historyRestore => '복원';

  @override
  String get historyRestoredSnack => '버전이 복원되었습니다';

  @override
  String get historyBeforeRemoteUpdate => '원격 업데이트 이전';

  @override
  String get historySnapshot => '스냅샷';

  @override
  String get historyImportedFile => '가져온 파일';

  @override
  String get editorFindHint => '찾기';

  @override
  String get editorReplaceHint => '바꿀 내용';

  @override
  String editorMatchCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get editorMatchNone => '0/0';

  @override
  String get editorPrevious => '이전';

  @override
  String get editorNext => '다음';

  @override
  String get editorShowReplace => '바꾸기 표시 (Ctrl+H)';

  @override
  String get editorHideReplace => '바꾸기 숨기기 (Ctrl+H)';

  @override
  String get editorClose => '닫기';

  @override
  String get editorReplace => '바꾸기';

  @override
  String get editorReplaceAll => '모두';

  @override
  String get editorListening => '듣고 있습니다…';

  @override
  String get editorDictate => '받아쓰기';

  @override
  String get editorStopDictation => '받아쓰기 중지';

  @override
  String get peersConnectByIp => 'IP로 연결';

  @override
  String get peersConnected => '연결됨';

  @override
  String get peersNearby => '근처 기기';

  @override
  String get peersTrustedDevices => '신뢰할 수 있는 기기';

  @override
  String get peersBlocked => '차단됨';

  @override
  String get peersConnectionLog => '연결 로그';

  @override
  String get peersNoActiveConnections => '활성 연결 없음';

  @override
  String get peersNoTrustedDevices => '신뢰할 수 있는 기기 없음 — 한 번 페어링하여 자동 동기화 사용';

  @override
  String get peersNoBlockedDevices => '차단된 기기 없음';

  @override
  String get peersNoConnectionEvents => '아직 연결 이벤트 없음';

  @override
  String get peersNoDiscoveredPeers =>
      '발견된 피어 없음 — Linux는 이 기기와 같은 Wi‑Fi 서브넷에 있어야 합니다（위 주소 확인）, 또는 IP로 연결 사용';

  @override
  String get peersDiscoveryPaused => '로컬 네트워크에 연결할 때까지 피어 검색이 일시 중지됩니다';

  @override
  String get peersDisconnect => '연결 끊기';

  @override
  String get peersConnectNow => '지금 연결';

  @override
  String get peersConnect => '연결';

  @override
  String get peersResolving => '확인 중…';

  @override
  String get peersBlockTooltip => '차단';

  @override
  String peersBlockTitle(String peer) {
    return '$peer을(를) 차단하시겠습니까?';
  }

  @override
  String get peersBlockBody =>
      '이렇게 하면 기기의 연결이 끊기고, 고정된 인증서가 삭제되며, 차단 해제할 때까지 향후 연결 요청이 거부됩니다.';

  @override
  String peersRevokeTitle(String peer) {
    return '$peer을(를) 취소하시겠습니까?';
  }

  @override
  String get peersRevokeBody =>
      '다음 연결에서 수락을 다시 탭해야 합니다. 인증서 확인이 계속 적용되도록 보안 PIN은 유지됩니다.';

  @override
  String get peersAutoSync => '자동 동기화';

  @override
  String get peersCopiedOneLogEntry => '로그 항목 1개 복사됨';

  @override
  String peersCopiedLogEntries(int count) {
    return '로그 항목 $count개 복사됨';
  }

  @override
  String peersLogRevision(String time, String revision) {
    return '$time • 수정 $revision';
  }

  @override
  String peersStillResolving(String peer) {
    return '아직 $peer 확인 중…';
  }

  @override
  String peersResolveFailedSnack(String peer) {
    return '$peer을(를) 확인할 수 없습니다. Avahi 및 동일 서브넷을 확인하거나 IP로 연결을 사용하세요.';
  }

  @override
  String peersPairingRequestSent(String peer) {
    return '$peer에 페어링 요청을 보냈습니다';
  }

  @override
  String peersCouldNotConnect(String message) {
    return '연결할 수 없습니다: $message';
  }

  @override
  String peersManualHostPort(String host, int port) {
    return '$host:$port (수동)';
  }

  @override
  String get peersManual => '수동';

  @override
  String get peersResolveFailedSubtitle => '확인 실패 — IP로 연결 시도';

  @override
  String get peersResolvingAddress => '주소 확인 중…';

  @override
  String peersHostPort(String host, int port) {
    return '$host:$port';
  }

  @override
  String get peersNoAddressYet => '아직 주소 없음';

  @override
  String peersEncryptedPinned(String code) {
    return '암호화됨 · 고정됨 $code';
  }

  @override
  String get peersEncryptedWss => '암호화됨 (WSS/TLS)';

  @override
  String peersSubtitleWithPresence(String subtitle, String presence) {
    return '$subtitle • $presence';
  }

  @override
  String peersSubtitleWithSecurity(String subtitle, String security) {
    return '$subtitle • $security';
  }

  @override
  String peersPairedStatus(String date, String status) {
    return '$date 페어링됨 · $status';
  }

  @override
  String get peersStatusConnected => '연결됨';

  @override
  String get peersStatusManualOnly => '수동 전용';

  @override
  String get peersStatusReconnecting => '재연결 중…';

  @override
  String peersStatusRetryIn(int seconds) {
    return '$seconds초 후 재시도';
  }

  @override
  String get peersStatusNotOnNetwork => '네트워크 없음';

  @override
  String get peersStatusConnecting => '연결 중…';

  @override
  String get peersStatusAutoReconnect => '자동 재연결';

  @override
  String peersPresenceLineCol(int line, int column) {
    return '$line번째 줄, $column번째 열';
  }

  @override
  String peersPresenceInNote(String title, String position) {
    return '\"$title\" · $position';
  }

  @override
  String peersRoomLabel(String room) {
    return '방 \"$room\"';
  }

  @override
  String get discoveryThisDevice => '이 기기';

  @override
  String get discoveryCopyAddress => '주소 복사';

  @override
  String discoveryCopiedAddress(String address) {
    return '$address 복사됨';
  }

  @override
  String get discoveryLocalNetworkRequired => '로컬 네트워크 필요';

  @override
  String get discoveryNotListeningTitle => '대기 중이 아님';

  @override
  String get discoveryNotListeningBody =>
      '이 기기는 아직 피어를 대기하고 있지 않습니다. Wi‑Fi 연결 후 몇 초 기다리거나, 네트워크 오류 배너에서 재시도를 탭하세요.';

  @override
  String get discoveryModeTitle => '검색 모드';

  @override
  String get discoveryUnavailableTitle => '피어 검색을 사용할 수 없음';

  @override
  String get discoveryRetryTooltip => '검색 재시도';

  @override
  String get peersSecuredSessions => '보안 세션';

  @override
  String peersSecurityBannerIdle(String code) {
    return '이 기기는 WSS/TLS를 통해 광고 중 · 코드 $code';
  }

  @override
  String peersSecurityBannerActive(int connectedCount, int pinnedCount) {
    return '$connectedCount개의 암호화된 세션 · $pinnedCount개의 인증서 고정됨';
  }

  @override
  String peersSecurityCompactIdle(String code) {
    return 'WSS/TLS · 코드 $code';
  }

  @override
  String peersSecurityCompactActive(int connectedCount, int pinnedCount) {
    return '$connectedCount개 암호화됨 · $pinnedCount개 고정됨';
  }

  @override
  String peersSecurityTooltipPinned(String code) {
    return '암호화됨 (WSS/TLS) · 고정됨 $code';
  }

  @override
  String get peersSecurityTooltipActive => '암호화됨 (WSS/TLS) · 활성 세션';

  @override
  String get pairingConnectionRequest => '연결 요청';

  @override
  String pairingAllowPeer(String peer) {
    return '$peer이(가) 연결하고 이 메모를 공유하도록 허용하시겠습니까?';
  }

  @override
  String get pairingVerificationCode => '인증 코드';

  @override
  String get pairingConfirmCode => '수락하기 전에 이 코드가 두 기기에서 일치하는지 확인하세요.';

  @override
  String get pairingThisDeviceSecurityCode => '이 기기의 보안 코드';

  @override
  String get pairingOtherDevicePins => '다른 기기는 첫 번째 연결 시 이것을 고정합니다.';

  @override
  String get manualConnectTitle => '주소로 연결';

  @override
  String get manualConnectBody =>
      '검색이 같은 서브넷의 피어를 찾지 못할 때 사용합니다. 활성 로컬 네트워크 세그먼트의 주소만 허용됩니다.';

  @override
  String get manualConnectHostLabel => '호스트 또는 IP';

  @override
  String get manualConnectHostHint => '192.168.1.42';

  @override
  String get manualConnectPortLabel => '포트';

  @override
  String get manualConnectPortHint => '54321';

  @override
  String get manualConnectLabelOptional => '레이블 (선택 사항)';

  @override
  String get manualConnectLabelHint => '거실 PC';

  @override
  String get manualConnectInvalidHostPort => '유효한 호스트와 포트를 입력하세요 (1–65535)';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsDeviceSection => '기기';

  @override
  String get settingsDeviceHint =>
      '기기 이름과 방은 저장 (Ctrl+S)이 필요합니다. 외관 및 편집기 설정은 즉시 저장됩니다.';

  @override
  String get settingsDeviceName => '기기 이름';

  @override
  String get settingsDeviceNameHint => '다른 기기에 표시되는 이름';

  @override
  String get settingsSessionRoom => '세션 / 방';

  @override
  String get settingsSessionRoomHint => '같은 방의 피어만 검색됩니다';

  @override
  String get settingsListeningPort => '수신 포트';

  @override
  String get settingsStartingServer => '서버 시작 중…';

  @override
  String settingsAddressShare(String address) {
    return '$address (수동 연결을 위해 공유)';
  }

  @override
  String get settingsCopyAddress => '주소 복사';

  @override
  String get settingsAddressCopied => '주소가 클립보드에 복사되었습니다';

  @override
  String settingsSavedSnack(String name, String room) {
    return '설정 저장됨 · \"$name\" · 방 \"$room\"';
  }

  @override
  String get settingsAppearanceSection => '외관';

  @override
  String get settingsMode => '모드';

  @override
  String get settingsThemeSystem => '시스템';

  @override
  String get settingsThemeLight => '라이트';

  @override
  String get settingsThemeDark => '다크';

  @override
  String get settingsSkin => '스킨';

  @override
  String get settingsSkinDefault => '기본';

  @override
  String get settingsSkinOcean => '오션';

  @override
  String get settingsSkinForest => '포레스트';

  @override
  String get settingsSkinSunset => '선셋';

  @override
  String get settingsSkinSlate => '슬레이트';

  @override
  String settingsSkinStandardLabel(String skin) {
    return '$skin · Standard';
  }

  @override
  String get settingsStandardSection => 'Netpad Standard';

  @override
  String get settingsStandardUnlocked => 'Standard 잠금 해제됨';

  @override
  String get settingsFree => '무료';

  @override
  String get settingsStandardUnlockedSubtitle =>
      '무제한 동기화 메모 및 피어, 스킨, 기록, 자동 동기화, 음성';

  @override
  String get settingsStandardBuySubtitle => '앱 스토어를 통해 한 번만 잠금 해제';

  @override
  String get settingsPurchasesUnavailable => '이 플랫폼에서는 구매를 사용할 수 없습니다';

  @override
  String get settingsRestorePurchases => '구매 복원';

  @override
  String get settingsStandardRestored => 'Standard 복원됨';

  @override
  String get settingsNoPreviousStandard => '이전 Standard 구매 내역을 찾을 수 없습니다';

  @override
  String get settingsEditorSection => '편집기';

  @override
  String get settingsWordWrap => '자동 줄 바꿈';

  @override
  String get settingsWordWrapSubtitle => '가로 스크롤 대신 긴 줄 줄 바꿈';

  @override
  String settingsFontSize(int size) {
    return '글꼴 크기 ($size pt)';
  }

  @override
  String get settingsLegalSection => '법적 정보';

  @override
  String get settingsEulaSubtitleStandard =>
      'Standard · GitHub Pages에서 EULA 열기';

  @override
  String get settingsEulaSubtitleFree => '무료 · GitHub Pages에서 EULA 열기';

  @override
  String get settingsPrivacySubtitle => 'GitHub Pages에서 개인정보 페이지 열기';

  @override
  String get settingsDisclaimerTitle => '면책 조항 및 책임';

  @override
  String get settingsDisclaimerSubtitle => '사용자 책임 하에 사용';

  @override
  String get settingsDisclaimerP1 =>
      '이 소프트웨어는 상품성, 특정 목적 적합성 및 비침해를 포함한 어떠한 종류의 명시적 또는 묵시적 보증 없이 \"있는 그대로\" 제공됩니다.';

  @override
  String get settingsDisclaimerP2 =>
      '귀하는 이 앱을 사용하는 방법과 모든 적용 가능한 법률, 규정, 정책 및 계약 준수에 대한 전적인 책임을 집니다.';

  @override
  String get settingsDisclaimerP3 =>
      '저작권 보유자는 이 소프트웨어의 사용 또는 오용으로 인한 어떠한 청구, 손해, 손실, 데이터 손실, 사업 중단 또는 기타 책임에 대해서도 책임을 지지 않습니다.';

  @override
  String get settingsNoLegalAdviceTitle => '법적 조언 없음';

  @override
  String get settingsNoLegalAdviceSubtitle => '정보 제공 소프트웨어만';

  @override
  String get settingsNoLegalAdviceP1 =>
      '이 앱과 해당 문서는 법적, 규제적 또는 전문적 조언을 제공하지 않습니다.';

  @override
  String get settingsNoLegalAdviceP2 =>
      '사용 사례에 대한 법적 지침이 필요한 경우 자격을 갖춘 전문가에게 문의하세요.';

  @override
  String get settingsCopyright => '© 2026 Spencer Beaumier';

  @override
  String get paywallTitle => 'Netpad Standard 잠금 해제';

  @override
  String get paywallSubtitle => '일회성 구매. 핵심 편집 및 LAN 동기화는 무료로 유지됩니다.';

  @override
  String get paywallBenefitUnlimitedNotes => '무제한 동기화 메모';

  @override
  String get paywallBenefitUnlimitedPeers => '무제한 연결 피어';

  @override
  String get paywallBenefitSkins => '추가 색상 스킨';

  @override
  String get paywallBenefitHistory => '버전 기록';

  @override
  String get paywallBenefitAutoSync => '신뢰할 수 있는 피어 자동 동기화';

  @override
  String get paywallBenefitVoice => '음성 받아쓰기';

  @override
  String get paywallPurchasesUnsupported =>
      '이 플랫폼에서는 인앱 구매를 사용할 수 없습니다. Standard를 잠금 해제하려면 App Store, Google Play 또는 Microsoft Store에서 설치하세요.';

  @override
  String get paywallBuyStandard => 'Standard 구매';

  @override
  String paywallBuyStandardPrice(String price) {
    return 'Standard 구매 · $price';
  }

  @override
  String get paywallRestorePurchases => '구매 복원';

  @override
  String get paywallPurchaseNotCompleted => '구매가 완료되지 않았습니다.';

  @override
  String get paywallPurchaseFailed => '구매에 실패했습니다.';

  @override
  String get paywallStandardRestored => 'Standard 복원됨';

  @override
  String get paywallNoPreviousStandard => '이전 Standard 구매 내역을 찾을 수 없습니다';

  @override
  String standardHighlightNoteLimit(int limit) {
    return '무료 버전은 한 번에 최대 $limit개의 메모를 동기화할 수 있습니다. 무제한 동기화 메모를 위해 Standard를 잠금 해제하세요.';
  }

  @override
  String standardHighlightPeerLimit(int limit) {
    return '무료 버전에는 최대 $limit개의 연결 피어가 포함됩니다. 무제한 피어를 위해 Standard를 잠금 해제하세요.';
  }

  @override
  String get standardHighlightVersionHistory => '버전 기록은 Standard 기능입니다.';

  @override
  String get standardHighlightVoice => '음성 받아쓰기는 Standard 기능입니다.';

  @override
  String get standardHighlightAutoSync => '신뢰할 수 있는 피어 자동 동기화는 Standard 기능입니다.';

  @override
  String get standardHighlightSkins => '추가 스킨은 Standard에 포함되어 있습니다.';

  @override
  String get helpTitle => '도움말';

  @override
  String get helpIntro =>
      '일반 텍스트 메모를 위한 LAN 메모장. 같은 Wi‑Fi의 기기들이 서로를 발견하고, 한 번 페어링한 후 실시간으로 메모를 동기화합니다.';

  @override
  String get helpAboutTile => 'SB Simple Netpad 정보';

  @override
  String get helpEulaSubtitle => 'GitHub Pages에서 EULA 열기';

  @override
  String get helpPrivacySubtitle => 'GitHub Pages에서 개인정보 페이지 열기';

  @override
  String get helpGettingStartedTitle => '시작하기';

  @override
  String get helpGettingStarted1 => '동기화하려는 기기와 같은 Wi‑Fi 네트워크에 연결합니다.';

  @override
  String get helpGettingStarted2 =>
      '피어 패널(자물쇠 아이콘 또는 피어 드로어)을 열고 근처 기기가 나타날 때까지 기다립니다.';

  @override
  String get helpGettingStarted3 => '이 기기에서 주소를 복사하고 검색이 느리면 공유합니다.';

  @override
  String get helpGettingStarted4 => 'mDNS 검색이 피어를 찾지 못하면 IP로 연결을 사용합니다.';

  @override
  String get helpNotesTitle => '메모';

  @override
  String get helpNotes1 => '메뉴 아이콘(☰) 또는 메모 패널을 탭하여 메모 간에 전환합니다.';

  @override
  String get helpNotes2 => '메모 목록에서 메모를 만들고, 이름을 바꾸고, 순서를 변경하고, 삭제합니다.';

  @override
  String get helpNotes3 =>
      '각 메모는 독립적으로 동기화됩니다 — 새 메모는 로컬 전용으로 시작하며, 피어와 공유할 때 동기화를 켭니다.';

  @override
  String get helpNotes4 => '편집기에서 메모 내에서(찾기) 또는 모든 메모에서 검색합니다.';

  @override
  String get helpNotes5 => '버전 기록은 나중에 복원할 수 있는 로컬 스냅샷을 저장합니다.';

  @override
  String get helpPeersTitle => '피어 및 페어링';

  @override
  String get helpPeers1 => '근처 기기에는 같은 방에서 발견된 기기가 나열됩니다(설정 참조).';

  @override
  String get helpPeers2 => '피어에서 연결을 탭합니다 — 다른 기기에서 수락을 탭해야 합니다.';

  @override
  String get helpPeers3 => '수락하기 전에 페어링 인증 코드를 비교합니다.';

  @override
  String get helpPeers4 => '첫 번째 수락 후, 신뢰할 수 있는 기기는 자동으로 재연결할 수 있습니다.';

  @override
  String get helpPeers5 => '신뢰할 수 있는 기기: 자동 동기화를 전환하거나 취소하여 다시 수락이 필요하게 합니다.';

  @override
  String get helpPeers6 => '차단하면 기기의 연결이 끊기고 차단 해제할 때까지 향후 페어링이 거부됩니다.';

  @override
  String get helpPeers7 => '연결됨에는 주소와 커서 위치가 포함된 활성 세션이 표시됩니다.';

  @override
  String get helpFileSharingTitle => '파일 및 공유';

  @override
  String get helpFileSharing1Desktop =>
      '파일 메뉴: 파일로 저장, 파일을 새 메모로 열기, 메모 공유, 버전 기록, 설정, 종료.';

  @override
  String get helpFileSharing1Mobile =>
      '메뉴(⋮): 파일로 저장, 파일을 새 메모로 열기, 공유, 버전 기록, 설정, 이 도움말 가이드.';

  @override
  String get helpFileSharing2 => '파일로 저장은 활성 메모를 .txt 또는 .md로 내보냅니다.';

  @override
  String get helpFileSharing3 =>
      '파일 열기는 텍스트를 로컬 전용 새 메모로 가져옵니다. 피어가 받도록 하려면 동기화를 켜세요.';

  @override
  String get helpFileSharing4 => '공유는 OS 공유 시트를 사용합니다. Linux는 클립보드로 대체됩니다.';

  @override
  String get helpSettingsTitle => '설정';

  @override
  String get helpSettings1 => '기기 이름과 방은 저장이 필요합니다 — 다른 옵션은 즉시 적용됩니다.';

  @override
  String get helpSettings2 => '방 ID로 피어 그룹화: 같은 방의 기기만 검색됩니다.';

  @override
  String get helpSettings3 => '외관 및 편집기 설정(테마, 스킨, 줄 바꿈, 글꼴)은 변경 시 저장됩니다.';

  @override
  String get helpDesktopShortcutsTitle => '데스크톱 단축키';

  @override
  String get helpDesktopShortcuts1 => 'Ctrl/Cmd+S — 파일로 저장';

  @override
  String get helpDesktopShortcuts2 => 'Ctrl/Cmd+O — 파일을 새 메모로 열기';

  @override
  String get helpDesktopShortcuts3 => 'Ctrl/Cmd+F — 메모에서 찾기';

  @override
  String get helpDesktopShortcuts4 => 'Ctrl/Cmd+H — 찾기 및 바꾸기';

  @override
  String get helpDesktopShortcuts5 => 'Ctrl/Cmd+N — 메모 패널 전환';

  @override
  String get helpDesktopShortcuts6 => 'Ctrl/Cmd+P — 피어 패널 전환';

  @override
  String get helpDesktopShortcuts7 => 'Ctrl/Cmd+Q — 종료 (Windows/Linux)';

  @override
  String get helpTroubleshootingTitle => '문제 해결';

  @override
  String get helpTroubleshooting1 =>
      '피어가 없나요? 같은 Wi‑Fi 서브넷 및 방 ID를 확인하고, IP로 연결을 시도하세요.';

  @override
  String get helpTroubleshooting2 =>
      '로컬 네트워크 필요 배너는 Wi‑Fi가 활성화될 때까지 동기화가 일시 중지되었음을 의미합니다.';

  @override
  String get helpTroubleshooting3 => '첫 번째 실행 시 방화벽을 통해 앱을 허용하세요(데스크톱).';

  @override
  String get helpTroubleshooting4 =>
      'Linux: 검색이 시작되지 않으면 dbus 및 avahi-daemon을 설치하세요.';

  @override
  String get helpTroubleshooting5 => 'Android: 메시지가 표시되면 근처 Wi‑Fi 권한을 부여하세요.';

  @override
  String get aboutTitle => '정보';

  @override
  String get aboutTagline => '피어 검색 및 공유 편집 기능이 있는 LAN 메모장.';

  @override
  String get aboutDescription =>
      '전화기나 컴퓨터에서 일반 텍스트 메모를 작성하고 같은 Wi‑Fi의 다른 기기와 동기화합니다. 피어는 로컬 네트워크에서 서로를 발견하고, 상호 승인으로 한 번 페어링한 후, 암호화된 피어 세션으로 여러 명명된 메모를 공유합니다.';

  @override
  String get aboutPlatforms => 'Android · iOS · Windows · macOS · Linux';

  @override
  String get aboutStatus => '베타 — 일상적인 LAN 사용에 적합합니다.';

  @override
  String get aboutEulaHeading => '최종 사용자 라이선스 계약';

  @override
  String aboutEulaBody(int noteLimit, int peerLimit) {
    return 'SB Simple Netpad는 오픈 소스 라이선스가 아닌 EULA 하에 라이선스됩니다. 핵심 편집 및 LAN 동기화는 무료입니다(로컬 메모 무제한, 동기화 메모 최대 $noteLimit개, 연결 피어 $peerLimit개). Netpad Standard는 App Store, Google Play 또는 Microsoft Store를 통한 일회성 잠금 해제입니다.';
  }

  @override
  String get aboutViewEula => 'EULA 보기';

  @override
  String get aboutPrivacyPolicy => '개인정보처리방침';

  @override
  String get aboutHowToUse => 'SB Simple Netpad 사용 방법';

  @override
  String get aboutCouldNotOpenPrivacy => '개인정보처리방침을 열 수 없습니다';

  @override
  String get aboutCouldNotOpenEula => 'EULA를 열 수 없습니다';

  @override
  String get aboutCopyright => '© 2026 Spencer Beaumier';

  @override
  String conflictLiveTitle(String title) {
    return '\"$title\"에서 편집 충돌';
  }

  @override
  String conflictLiveBody(
    String peer,
    String revision,
    String localPreview,
    String remotePreview,
  ) {
    return '$peer이(가) 동시에 같은 메모를 편집했습니다 (수정 $revision).\n\n내 버전:\n$localPreview\n\n$peer:\n$remotePreview\n\n두 기기가 어느 버전을 유지해야 합니까?';
  }

  @override
  String conflictDivergedTitle(String title) {
    return '\"$title\"이(가) 분기되었습니다';
  }

  @override
  String conflictDivergedBody(
    String peer,
    String title,
    int localChars,
    int remoteChars,
  ) {
    return '귀하의 사본과 $peer의 \"$title\" 사본이 연결이 끊긴 동안 다르게 변경되었습니다.\n\n내 버전: $localChars자\n$peer: $remoteChars자\n\n두 기기가 어느 버전을 유지해야 합니까?';
  }

  @override
  String conflictUsePeers(String peer) {
    return '$peer의 버전 사용';
  }

  @override
  String get conflictKeepMine => '내 것 유지';

  @override
  String fileSavedTo(String path) {
    return '$path에 저장됨';
  }

  @override
  String fileCouldNotSave(String error) {
    return '저장할 수 없습니다: $error';
  }

  @override
  String fileOpenedAsNewNote(String name) {
    return '$name을(를) 새 메모로 열었습니다';
  }

  @override
  String fileCouldNotOpen(String error) {
    return '열 수 없습니다: $error';
  }

  @override
  String get fileNothingToShare => '공유할 것이 없습니다 — 메모가 비어 있습니다';

  @override
  String get fileShareFallbackClipboard => '여기서는 공유를 사용할 수 없습니다 — 클립보드에 복사됨';

  @override
  String get fileDefaultNoteName => 'netpad-note';
}
