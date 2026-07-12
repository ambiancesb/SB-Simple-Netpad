// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get commonAppName => 'SB Simple Netpad';

  @override
  String get commonProName => 'Netpad Pro';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '削除';

  @override
  String get commonConnect => '接続';

  @override
  String get commonHelp => 'ヘルプ';

  @override
  String get commonSettings => '設定';

  @override
  String get commonMore => 'もっと見る';

  @override
  String get commonCopy => 'コピー';

  @override
  String get commonClear => 'クリア';

  @override
  String get commonAccept => '承認';

  @override
  String get commonReject => '拒否';

  @override
  String get commonBlock => 'ブロック';

  @override
  String get commonUnblock => 'ブロック解除';

  @override
  String get commonRevoke => '取り消し';

  @override
  String get commonRestore => '復元';

  @override
  String get commonRetry => '再試行';

  @override
  String commonCouldNotOpenLabel(String label) {
    return '$label を開けませんでした';
  }

  @override
  String get commonEulaLabel => 'EULA';

  @override
  String get commonPrivacyPolicyLabel => 'プライバシーポリシー';

  @override
  String get commonEndUserLicenseAgreement => 'エンドユーザーライセンス契約';

  @override
  String get commonPrivacyPolicy => 'プライバシーポリシー';

  @override
  String commonVersionLabel(String version) {
    return 'バージョン $version';
  }

  @override
  String get shellMenuFile => 'ファイル';

  @override
  String get shellMenuEdit => '編集';

  @override
  String get shellMenuView => '表示';

  @override
  String get shellMenuHelp => 'ヘルプ';

  @override
  String get shellSaveToFile => 'ファイルに保存…';

  @override
  String get shellOpenFileAsNewNote => 'ファイルを新しいメモとして開く…';

  @override
  String get shellShareNote => 'メモを共有';

  @override
  String get shellVersionHistory => 'バージョン履歴…';

  @override
  String get shellSettings => '設定…';

  @override
  String get shellExit => '終了';

  @override
  String get shellCut => '切り取り';

  @override
  String get shellCopy => 'コピー';

  @override
  String get shellPaste => '貼り付け';

  @override
  String get shellFind => '検索…';

  @override
  String get shellFindAndReplace => '検索と置換…';

  @override
  String get shellWordWrap => '折り返し';

  @override
  String get shellWordWrapChecked => '折り返し ✓';

  @override
  String get shellNotesPanel => 'メモパネル';

  @override
  String get shellNotesPanelChecked => 'メモパネル ✓';

  @override
  String get shellPeersPanel => 'ピアパネル';

  @override
  String get shellPeersPanelChecked => 'ピアパネル ✓';

  @override
  String get shellHelpItem => 'SB Simple Netpad ヘルプ';

  @override
  String get shellAboutItem => 'SB Simple Netpad について';

  @override
  String get shellHideNotesPanel => 'メモパネルを非表示';

  @override
  String get shellShowNotesPanel => 'メモパネルを表示 (Ctrl+N)';

  @override
  String get shellHidePeersPanel => 'ピアパネルを非表示';

  @override
  String get shellShowPeersPanel => 'ピアパネルを表示 (Ctrl+P)';

  @override
  String shellPeersTooltipConnected(int count, String action) {
    return '$count 件の暗号化されたピアセッション · ピアパネルを$action (Ctrl+P)';
  }

  @override
  String get shellPeersTooltipActionHide => '非表示';

  @override
  String get shellPeersTooltipActionShow => '表示';

  @override
  String get shellFindInNote => 'メモ内を検索 (Ctrl+F)';

  @override
  String shellSecurityChipConnected(int count) {
    return 'WSS/TLS で暗号化された $count 件のピアセッション · タップしてピアを確認';
  }

  @override
  String get shellSecurityChipNone => 'アクティブなピアセッションなし · タップしてピアを確認';

  @override
  String get shellMobileWordWrap => '折り返し';

  @override
  String get shellMobileSaveToFile => 'ファイルに保存…';

  @override
  String get shellMobileOpenFileAsNewNote => 'ファイルを新しいメモとして開く…';

  @override
  String get shellMobileShareNote => 'メモを共有';

  @override
  String get shellMobileVersionHistory => 'バージョン履歴…';

  @override
  String get shellMobileSettings => '設定';

  @override
  String get shellMobileHelp => 'ヘルプ';

  @override
  String get shellMobileAbout => 'SB Simple Netpad について';

  @override
  String get shellListeningSnack => '聴取中… もう一度マイクをタップして停止';

  @override
  String get notesTitle => 'メモ';

  @override
  String get notesNewNote => '新しいメモ';

  @override
  String get notesSearchHint => 'すべてのメモを検索';

  @override
  String get notesRenameTitle => 'メモの名前を変更';

  @override
  String get notesTitleLabel => 'タイトル';

  @override
  String notesDeleteTitle(String title) {
    return '\"$title\" を削除しますか？';
  }

  @override
  String get notesDeleteSyncedBody => 'これにより、あなたとすべての接続されたピアからメモが削除されます。';

  @override
  String get notesDeleteLocalBody => 'これにより、このデバイスからのみメモが削除されます。';

  @override
  String get notesNoMatches => '一致なし';

  @override
  String get notesNoNotes => 'メモなし';

  @override
  String get notesRename => '名前を変更';

  @override
  String get notesVersionHistory => 'バージョン履歴';

  @override
  String get notesDelete => '削除';

  @override
  String get notesSyncWithPeers => 'ピアと同期';

  @override
  String get notesLocalOnly => 'ローカルのみ';

  @override
  String get notesEmptyNote => '空のメモ';

  @override
  String notesMatchCount(int count) {
    return '$count 件の一致';
  }

  @override
  String notesLocalOnlyWithMatches(String matchLine) {
    return 'ローカルのみ · $matchLine';
  }

  @override
  String notesSearchSnippetMatches(String snippet, int count) {
    return '$snippet  ·  $count 件の一致';
  }

  @override
  String get notesNoNoteSelected => 'メモが選択されていません';

  @override
  String historyTitle(String title) {
    return 'バージョン履歴 · \"$title\"';
  }

  @override
  String get historyEmpty =>
      'まだ保存されたバージョンはありません。リモートの編集がテキストを置き換える前に、スナップショットが自動的に保持されます。';

  @override
  String historyEntrySubtitle(String label, String time, int chars) {
    return '$label · $time · $chars 文字';
  }

  @override
  String get historyRestore => '復元';

  @override
  String get historyRestoredSnack => 'バージョンを復元しました';

  @override
  String get historyBeforeRemoteUpdate => 'リモート更新前';

  @override
  String get historySnapshot => 'スナップショット';

  @override
  String get historyImportedFile => 'インポートされたファイル';

  @override
  String get editorFindHint => '検索';

  @override
  String get editorReplaceHint => '置換後の文字列';

  @override
  String editorMatchCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get editorMatchNone => '0/0';

  @override
  String get editorPrevious => '前へ';

  @override
  String get editorNext => '次へ';

  @override
  String get editorShowReplace => '置換を表示 (Ctrl+H)';

  @override
  String get editorHideReplace => '置換を非表示 (Ctrl+H)';

  @override
  String get editorClose => '閉じる';

  @override
  String get editorReplace => '置換';

  @override
  String get editorReplaceAll => 'すべて';

  @override
  String get editorListening => '聴取中…';

  @override
  String get editorDictate => 'ディクテーション';

  @override
  String get editorStopDictation => 'ディクテーションを停止';

  @override
  String get peersConnectByIp => 'IPで接続';

  @override
  String get peersConnected => '接続済み';

  @override
  String get peersNearby => '近くのデバイス';

  @override
  String get peersTrustedDevices => '信頼済みデバイス';

  @override
  String get peersBlocked => 'ブロック済み';

  @override
  String get peersConnectionLog => '接続ログ';

  @override
  String get peersNoActiveConnections => 'アクティブな接続なし';

  @override
  String get peersNoTrustedDevices => '信頼済みデバイスなし — 一度ペアリングして自動同期を有効化';

  @override
  String get peersNoBlockedDevices => 'ブロックされたデバイスなし';

  @override
  String get peersNoConnectionEvents => 'まだ接続イベントなし';

  @override
  String get peersNoDiscoveredPeers =>
      'ピアが見つかりません — Linuxはこのデバイスと同じWi‑Fiサブネット上にある必要があります（上記のアドレスを確認）、またはIPで接続を使用してください';

  @override
  String get peersDiscoveryPaused => 'ローカルネットワークに参加するまでピア探索は一時停止中です';

  @override
  String get peersDisconnect => '切断';

  @override
  String get peersConnectNow => '今すぐ接続';

  @override
  String get peersConnect => '接続';

  @override
  String get peersResolving => '解決中…';

  @override
  String get peersBlockTooltip => 'ブロック';

  @override
  String peersBlockTitle(String peer) {
    return '$peer をブロックしますか？';
  }

  @override
  String get peersBlockBody =>
      'これによりデバイスが切断され、固定された証明書が削除され、ブロック解除するまで今後の接続要求が拒否されます。';

  @override
  String peersRevokeTitle(String peer) {
    return '$peer を取り消しますか？';
  }

  @override
  String get peersRevokeBody =>
      '次の接続では再度「承認」をタップする必要があります。セキュリティPINは保持されるため、証明書の確認は引き続き適用されます。';

  @override
  String get peersAutoSync => '自動同期';

  @override
  String get peersCopiedOneLogEntry => 'ログエントリを1件コピーしました';

  @override
  String peersCopiedLogEntries(int count) {
    return 'ログエントリを $count 件コピーしました';
  }

  @override
  String peersLogRevision(String time, String revision) {
    return '$time • リビジョン $revision';
  }

  @override
  String peersStillResolving(String peer) {
    return '$peer を解決中…';
  }

  @override
  String peersResolveFailedSnack(String peer) {
    return '$peer を解決できませんでした。Avahi と同じサブネットを確認するか、IPで接続を使用してください。';
  }

  @override
  String peersPairingRequestSent(String peer) {
    return '$peer にペアリングリクエストを送信しました';
  }

  @override
  String peersCouldNotConnect(String message) {
    return '接続できませんでした: $message';
  }

  @override
  String peersManualHostPort(String host, int port) {
    return '$host:$port (手動)';
  }

  @override
  String get peersManual => '手動';

  @override
  String get peersResolveFailedSubtitle => '解決失敗 — IPで接続を試してください';

  @override
  String get peersResolvingAddress => 'アドレスを解決中…';

  @override
  String peersHostPort(String host, int port) {
    return '$host:$port';
  }

  @override
  String get peersNoAddressYet => 'まだアドレスなし';

  @override
  String peersEncryptedPinned(String code) {
    return '暗号化済み · 固定 $code';
  }

  @override
  String get peersEncryptedWss => '暗号化済み (WSS/TLS)';

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
    return '$date にペアリング済み · $status';
  }

  @override
  String get peersStatusConnected => '接続済み';

  @override
  String get peersStatusManualOnly => '手動のみ';

  @override
  String get peersStatusReconnecting => '再接続中…';

  @override
  String peersStatusRetryIn(int seconds) {
    return '$seconds秒後に再試行';
  }

  @override
  String get peersStatusNotOnNetwork => 'ネットワーク未接続';

  @override
  String get peersStatusConnecting => '接続中…';

  @override
  String get peersStatusAutoReconnect => '自動再接続';

  @override
  String peersPresenceLineCol(int line, int column) {
    return '$line行目、$column列目';
  }

  @override
  String peersPresenceInNote(String title, String position) {
    return '\"$title\" · $position';
  }

  @override
  String peersRoomLabel(String room) {
    return 'ルーム \"$room\"';
  }

  @override
  String get discoveryThisDevice => 'このデバイス';

  @override
  String get discoveryCopyAddress => 'アドレスをコピー';

  @override
  String discoveryCopiedAddress(String address) {
    return '$address をコピーしました';
  }

  @override
  String get discoveryLocalNetworkRequired => 'ローカルネットワークが必要';

  @override
  String get discoveryNotListeningTitle => '待機していません';

  @override
  String get discoveryNotListeningBody =>
      'このデバイスはまだピアを待機していません。Wi‑Fi接続後に数秒待つか、ネットワークエラーバナーで再試行をタップしてください。';

  @override
  String get discoveryModeTitle => '探索モード';

  @override
  String get discoveryUnavailableTitle => 'ピア探索は利用できません';

  @override
  String get discoveryRetryTooltip => '探索を再試行';

  @override
  String get peersSecuredSessions => 'セキュアなセッション';

  @override
  String peersSecurityBannerIdle(String code) {
    return 'このデバイスは WSS/TLS でアドバタイズしています · コード $code';
  }

  @override
  String peersSecurityBannerActive(int connectedCount, int pinnedCount) {
    return '$connectedCount 件の暗号化されたセッション · $pinnedCount 件の証明書を固定済み';
  }

  @override
  String peersSecurityCompactIdle(String code) {
    return 'WSS/TLS · コード $code';
  }

  @override
  String peersSecurityCompactActive(int connectedCount, int pinnedCount) {
    return '$connectedCount 件暗号化 · $pinnedCount 件固定';
  }

  @override
  String peersSecurityTooltipPinned(String code) {
    return '暗号化済み (WSS/TLS) · 固定 $code';
  }

  @override
  String get peersSecurityTooltipActive => '暗号化済み (WSS/TLS) · アクティブセッション';

  @override
  String get pairingConnectionRequest => '接続リクエスト';

  @override
  String pairingAllowPeer(String peer) {
    return '$peer がこのメモに接続して共有することを許可しますか？';
  }

  @override
  String get pairingVerificationCode => '確認コード';

  @override
  String get pairingConfirmCode => '承認する前に、このコードが両方のデバイスで一致することを確認してください。';

  @override
  String get pairingThisDeviceSecurityCode => 'このデバイスのセキュリティコード';

  @override
  String get pairingOtherDevicePins => '相手のデバイスは初回接続時にこれを固定します。';

  @override
  String get manualConnectTitle => 'アドレスで接続';

  @override
  String get manualConnectBody =>
      '同じサブネット上でピアが見つからない場合に使用します。アクティブなローカルネットワークセグメントのアドレスのみ許可されます。';

  @override
  String get manualConnectHostLabel => 'ホストまたはIP';

  @override
  String get manualConnectHostHint => '192.168.1.42';

  @override
  String get manualConnectPortLabel => 'ポート';

  @override
  String get manualConnectPortHint => '54321';

  @override
  String get manualConnectLabelOptional => 'ラベル（任意）';

  @override
  String get manualConnectLabelHint => 'リビングのPC';

  @override
  String get manualConnectInvalidHostPort => '有効なホストとポート（1〜65535）を入力してください';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsDeviceSection => 'デバイス';

  @override
  String get settingsDeviceHint =>
      'デバイス名とルームには保存 (Ctrl+S) が必要です。外観とエディタの設定はすぐに保存されます。';

  @override
  String get settingsDeviceName => 'デバイス名';

  @override
  String get settingsDeviceNameHint => '他のデバイスに表示される名前';

  @override
  String get settingsSessionRoom => 'セッション / ルーム';

  @override
  String get settingsSessionRoomHint => '同じルームのピアのみ探索されます';

  @override
  String get settingsListeningPort => '待機ポート';

  @override
  String get settingsStartingServer => 'サーバーを起動中…';

  @override
  String settingsAddressShare(String address) {
    return '$address（手動接続用に共有）';
  }

  @override
  String get settingsCopyAddress => 'アドレスをコピー';

  @override
  String get settingsAddressCopied => 'アドレスをクリップボードにコピーしました';

  @override
  String settingsSavedSnack(String name, String room) {
    return '設定を保存しました · \"$name\" · ルーム \"$room\"';
  }

  @override
  String get settingsAppearanceSection => '外観';

  @override
  String get settingsMode => 'モード';

  @override
  String get settingsThemeSystem => 'システム';

  @override
  String get settingsThemeLight => 'ライト';

  @override
  String get settingsThemeDark => 'ダーク';

  @override
  String get settingsSkin => 'スキン';

  @override
  String get settingsSkinDefault => 'デフォルト';

  @override
  String get settingsSkinOcean => 'オーシャン';

  @override
  String get settingsSkinForest => 'フォレスト';

  @override
  String get settingsSkinSunset => 'サンセット';

  @override
  String get settingsSkinSlate => 'スレート';

  @override
  String settingsSkinProLabel(String skin) {
    return '$skin · Pro';
  }

  @override
  String get settingsProSection => 'Netpad Pro';

  @override
  String get settingsProUnlocked => 'Pro 解除済み';

  @override
  String get settingsFree => '無料';

  @override
  String get settingsProUnlockedSubtitle => '無制限のメモとピア、スキン、履歴、自動同期、音声';

  @override
  String get settingsProBuySubtitle => 'アプリストアで一度だけ解除';

  @override
  String get settingsPurchasesUnavailable => 'このプラットフォームでは購入できません';

  @override
  String get settingsRestorePurchases => '購入を復元';

  @override
  String get settingsProRestored => 'Pro を復元しました';

  @override
  String get settingsNoPreviousPro => '以前の Pro 購入が見つかりません';

  @override
  String get settingsEditorSection => 'エディタ';

  @override
  String get settingsWordWrap => '折り返し';

  @override
  String get settingsWordWrapSubtitle => '横スクロールの代わりに長い行を折り返す';

  @override
  String settingsFontSize(int size) {
    return 'フォントサイズ（$size pt）';
  }

  @override
  String get settingsLegalSection => '法的情報';

  @override
  String get settingsEulaSubtitlePro => 'Pro · GitHub Pages で EULA を開く';

  @override
  String get settingsEulaSubtitleFree => '無料 · GitHub Pages で EULA を開く';

  @override
  String get settingsPrivacySubtitle => 'GitHub Pages でプライバシーページを開く';

  @override
  String get settingsDisclaimerTitle => '免責事項と責任';

  @override
  String get settingsDisclaimerSubtitle => '自己責任でご使用ください';

  @override
  String get settingsDisclaimerP1 =>
      '本ソフトウェアは、商品性、特定目的への適合性、非侵害性を含むいかなる種類の保証もなく「現状のまま」提供されます。';

  @override
  String get settingsDisclaimerP2 =>
      'このアプリの使用方法、および適用されるすべての法律、規制、ポリシー、契約の遵守については、お客様が単独で責任を負います。';

  @override
  String get settingsDisclaimerP3 =>
      '著作権者は、本ソフトウェアの使用または誤用から生じるいかなる請求、損害、損失、データ損失、業務中断、その他の責任についても一切責任を負いません。';

  @override
  String get settingsNoLegalAdviceTitle => '法的アドバイスなし';

  @override
  String get settingsNoLegalAdviceSubtitle => '情報提供のみのソフトウェア';

  @override
  String get settingsNoLegalAdviceP1 =>
      'このアプリとそのドキュメントは、法的、規制的、または専門的なアドバイスを提供するものではありません。';

  @override
  String get settingsNoLegalAdviceP2 =>
      'ご使用目的に法的なガイダンスが必要な場合は、資格のある専門家にご相談ください。';

  @override
  String get settingsCopyright => '© 2026 Spencer Beaumier';

  @override
  String get paywallTitle => 'Netpad Pro を解除';

  @override
  String get paywallSubtitle => '一度の購入。基本的な編集とLAN同期は無料のまま。';

  @override
  String get paywallBenefitUnlimitedNotes => '無制限のメモ';

  @override
  String get paywallBenefitUnlimitedPeers => '無制限の接続ピア';

  @override
  String get paywallBenefitSkins => '追加カラースキン';

  @override
  String get paywallBenefitHistory => 'バージョン履歴';

  @override
  String get paywallBenefitAutoSync => '信頼済みピアの自動同期';

  @override
  String get paywallBenefitVoice => '音声ディクテーション';

  @override
  String get paywallPurchasesUnsupported =>
      'このプラットフォームではアプリ内購入はご利用いただけません。Pro を解除するには App Store、Google Play、または Microsoft Store からインストールしてください。';

  @override
  String get paywallBuyPro => 'Pro を購入';

  @override
  String paywallBuyProPrice(String price) {
    return 'Pro を購入 · $price';
  }

  @override
  String get paywallRestorePurchases => '購入を復元';

  @override
  String get paywallPurchaseNotCompleted => '購入が完了しませんでした。';

  @override
  String get paywallPurchaseFailed => '購入に失敗しました。';

  @override
  String get paywallProRestored => 'Pro を復元しました';

  @override
  String get paywallNoPreviousPro => '以前の Pro 購入が見つかりません';

  @override
  String proHighlightNoteLimit(int limit) {
    return '無料版は最大 $limit 件のメモが含まれます。無制限のメモには Pro を解除してください。';
  }

  @override
  String proHighlightPeerLimit(int limit) {
    return '無料版は最大 $limit 件の接続ピアが含まれます。無制限のピアには Pro を解除してください。';
  }

  @override
  String get proHighlightVersionHistory => 'バージョン履歴は Pro の機能です。';

  @override
  String get proHighlightVoice => '音声ディクテーションは Pro の機能です。';

  @override
  String get proHighlightAutoSync => '信頼済みピアの自動同期は Pro の機能です。';

  @override
  String get proHighlightSkins => '追加スキンは Pro に含まれています。';

  @override
  String get helpTitle => 'ヘルプ';

  @override
  String get helpIntro =>
      'プレーンテキストメモ用のLANメモ帳。同じWi‑Fi上のデバイスが互いを検出し、一度ペアリングして、リアルタイムでメモを同期します。';

  @override
  String get helpAboutTile => 'SB Simple Netpad について';

  @override
  String get helpEulaSubtitle => 'GitHub Pages で EULA を開く';

  @override
  String get helpPrivacySubtitle => 'GitHub Pages でプライバシーページを開く';

  @override
  String get helpGettingStartedTitle => 'はじめに';

  @override
  String get helpGettingStarted1 => '同期したいデバイスと同じWi‑Fiネットワークに接続します。';

  @override
  String get helpGettingStarted2 =>
      'ピアパネル（鍵アイコンまたはピアドロワー）を開き、近くのデバイスが表示されるのを待ちます。';

  @override
  String get helpGettingStarted3 => 'このデバイスからアドレスをコピーし、探索が遅い場合は共有します。';

  @override
  String get helpGettingStarted4 => 'mDNS探索でピアが見つからない場合はIPで接続を使用します。';

  @override
  String get helpNotesTitle => 'メモ';

  @override
  String get helpNotes1 => 'メニューアイコン（☰）またはメモパネルをタップしてメモを切り替えます。';

  @override
  String get helpNotes2 => 'メモリストからメモを作成、名前変更、並び替え、削除します。';

  @override
  String get helpNotes3 => '各メモは独立して同期します — 必要に応じてメモごとに同期を切り替えます。';

  @override
  String get helpNotes4 => 'メモ内（検索）またはエディタからすべてのメモを検索します。';

  @override
  String get helpNotes5 => 'バージョン履歴は後で復元できるローカルスナップショットを保存します。';

  @override
  String get helpPeersTitle => 'ピアとペアリング';

  @override
  String get helpPeers1 => '近くのデバイスに同じルームで検出されたデバイスが一覧表示されます（設定を参照）。';

  @override
  String get helpPeers2 => 'ピアの「接続」をタップ — 相手のデバイスが「承認」をタップする必要があります。';

  @override
  String get helpPeers3 => '承認する前にペアリングの確認コードを比較してください。';

  @override
  String get helpPeers4 => '最初の「承認」後、信頼済みデバイスは自動的に再接続できます。';

  @override
  String get helpPeers5 => '信頼済みデバイス: 自動同期を切り替えるか、「取り消し」で再度「承認」が必要になります。';

  @override
  String get helpPeers6 => 'ブロックするとデバイスが切断され、解除するまで今後のペアリングが拒否されます。';

  @override
  String get helpPeers7 => '「接続済み」にはアドレスとカーソルの存在を含むアクティブセッションが表示されます。';

  @override
  String get helpFileSharingTitle => 'ファイルと共有';

  @override
  String get helpFileSharing1Desktop =>
      'ファイルメニュー: ファイルに保存、ファイルを新しいメモとして開く、メモを共有、バージョン履歴、設定、終了。';

  @override
  String get helpFileSharing1Mobile =>
      'メニュー（⋮）: ファイルに保存、ファイルを新しいメモとして開く、共有、バージョン履歴、設定、このヘルプガイド。';

  @override
  String get helpFileSharing2 =>
      'ファイルに保存すると、アクティブなメモが .txt または .md としてエクスポートされます。';

  @override
  String get helpFileSharing3 => 'ファイルを開くと、テキストが他のメモと同様に同期する新しいメモにインポートされます。';

  @override
  String get helpFileSharing4 => '共有はOSの共有シートを使用します。Linuxではクリップボードにフォールバックします。';

  @override
  String get helpSettingsTitle => '設定';

  @override
  String get helpSettings1 => 'デバイス名とルームには保存が必要です — 他のオプションはすぐに適用されます。';

  @override
  String get helpSettings2 => 'ルームIDでピアをグループ化: 同じルームのデバイスのみ探索されます。';

  @override
  String get helpSettings3 => '外観とエディタの設定（テーマ、スキン、折り返し、フォント）は変更時に保存されます。';

  @override
  String get helpDesktopShortcutsTitle => 'デスクトップショートカット';

  @override
  String get helpDesktopShortcuts1 => 'Ctrl/Cmd+S — ファイルに保存';

  @override
  String get helpDesktopShortcuts2 => 'Ctrl/Cmd+O — ファイルを新しいメモとして開く';

  @override
  String get helpDesktopShortcuts3 => 'Ctrl/Cmd+F — メモ内を検索';

  @override
  String get helpDesktopShortcuts4 => 'Ctrl/Cmd+H — 検索と置換';

  @override
  String get helpDesktopShortcuts5 => 'Ctrl/Cmd+N — メモパネルを切り替え';

  @override
  String get helpDesktopShortcuts6 => 'Ctrl/Cmd+P — ピアパネルを切り替え';

  @override
  String get helpDesktopShortcuts7 => 'Ctrl/Cmd+Q — 終了（Windows/Linux）';

  @override
  String get helpTroubleshootingTitle => 'トラブルシューティング';

  @override
  String get helpTroubleshooting1 =>
      'ピアが見つからない場合: 同じWi‑FiサブネットとルームIDを確認し、IPで接続を試してください。';

  @override
  String get helpTroubleshooting2 =>
      '「ローカルネットワークが必要」のバナーは、Wi‑Fiが有効になるまで同期が一時停止していることを意味します。';

  @override
  String get helpTroubleshooting3 => '初回起動時にファイアウォールでアプリを許可してください（デスクトップ）。';

  @override
  String get helpTroubleshooting4 =>
      'Linux: 探索が開始されない場合は dbus と avahi-daemon をインストールしてください。';

  @override
  String get helpTroubleshooting5 =>
      'Android: プロンプトが表示されたら、近くのWi‑Fi権限を付与してください。';

  @override
  String get aboutTitle => 'について';

  @override
  String get aboutTagline => 'ピア探索と共有編集機能を持つLANメモ帳。';

  @override
  String get aboutDescription =>
      'スマートフォンやパソコンでプレーンテキストのメモを書き、同じWi‑Fi上の他のデバイスと同期します。ピアはローカルネットワークで互いを検出し、相互承認で一度ペアリングし、暗号化されたピアセッションで複数の名前付きメモを共有します。';

  @override
  String get aboutPlatforms => 'Android · iOS · Windows · macOS · Linux';

  @override
  String get aboutStatus => 'ベータ版 — 日常的なLAN使用に適しています。';

  @override
  String get aboutEulaHeading => 'エンドユーザーライセンス契約';

  @override
  String aboutEulaBody(int noteLimit, int peerLimit) {
    return 'SB Simple Netpad はオープンソースライセンスではなく EULA の下でライセンスされています。基本的な編集とLAN同期は無料です（最大 $noteLimit 件のメモと $peerLimit 件の接続ピア）。Netpad Pro は App Store、Google Play、または Microsoft Store を通じた一度きりの解除です。';
  }

  @override
  String get aboutViewEula => 'EULA を表示';

  @override
  String get aboutPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get aboutHowToUse => 'SB Simple Netpad の使い方';

  @override
  String get aboutCouldNotOpenPrivacy => 'プライバシーポリシーを開けませんでした';

  @override
  String get aboutCouldNotOpenEula => 'EULA を開けませんでした';

  @override
  String get aboutCopyright => '© 2026 Spencer Beaumier';

  @override
  String conflictLiveTitle(String title) {
    return '\"$title\" で編集の競合が発生';
  }

  @override
  String conflictLiveBody(
    String peer,
    String revision,
    String localPreview,
    String remotePreview,
  ) {
    return '$peer が同時に同じメモを編集しました（リビジョン $revision）。\n\nあなたのバージョン:\n$localPreview\n\n$peer:\n$remotePreview\n\nどちらのバージョンを両方のデバイスで保持しますか？';
  }

  @override
  String conflictDivergedTitle(String title) {
    return '\"$title\" が分岐しています';
  }

  @override
  String conflictDivergedBody(
    String peer,
    String title,
    int localChars,
    int remoteChars,
  ) {
    return 'あなたのコピーと $peer の \"$title\" のコピーが切断中に異なる変更が加えられました。\n\nあなたのバージョン: $localChars 文字\n$peer: $remoteChars 文字\n\nどちらのバージョンを両方のデバイスで保持しますか？';
  }

  @override
  String conflictUsePeers(String peer) {
    return '$peer のバージョンを使用';
  }

  @override
  String get conflictKeepMine => '自分のバージョンを保持';

  @override
  String fileSavedTo(String path) {
    return '$path に保存しました';
  }

  @override
  String fileCouldNotSave(String error) {
    return '保存できませんでした: $error';
  }

  @override
  String fileOpenedAsNewNote(String name) {
    return '$name を新しいメモとして開きました';
  }

  @override
  String fileCouldNotOpen(String error) {
    return '開けませんでした: $error';
  }

  @override
  String get fileNothingToShare => '共有するものがありません — メモは空です';

  @override
  String get fileShareFallbackClipboard => 'ここでは共有できません — クリップボードにコピーしました';

  @override
  String get fileDefaultNoteName => 'netpad-note';
}
