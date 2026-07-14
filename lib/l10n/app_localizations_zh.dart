// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get commonAppName => 'SB Simple Netpad';

  @override
  String get commonStandardName => 'Netpad Standard';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClose => '关闭';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonConnect => '连接';

  @override
  String get commonHelp => '帮助';

  @override
  String get commonSettings => '设置';

  @override
  String get commonMore => '更多';

  @override
  String get commonCopy => '复制';

  @override
  String get commonClear => '清除';

  @override
  String get commonAccept => '接受';

  @override
  String get commonReject => '拒绝';

  @override
  String get commonBlock => '屏蔽';

  @override
  String get commonUnblock => '取消屏蔽';

  @override
  String get commonRevoke => '撤销';

  @override
  String get commonRestore => '恢复';

  @override
  String get commonRetry => '重试';

  @override
  String commonCouldNotOpenLabel(String label) {
    return '无法打开 $label';
  }

  @override
  String get commonEulaLabel => 'EULA';

  @override
  String get commonPrivacyPolicyLabel => '隐私政策';

  @override
  String get commonEndUserLicenseAgreement => '最终用户许可协议';

  @override
  String get commonPrivacyPolicy => '隐私政策';

  @override
  String commonVersionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get shellMenuFile => '文件';

  @override
  String get shellMenuEdit => '编辑';

  @override
  String get shellMenuView => '视图';

  @override
  String get shellMenuHelp => '帮助';

  @override
  String get shellSaveToFile => '保存到文件…';

  @override
  String get shellOpenFileAsNewNote => '打开文件作为新笔记…';

  @override
  String get shellShareNote => '分享笔记';

  @override
  String get shellVersionHistory => '版本历史…';

  @override
  String get shellSettings => '设置…';

  @override
  String get shellExit => '退出';

  @override
  String get shellCut => '剪切';

  @override
  String get shellCopy => '复制';

  @override
  String get shellPaste => '粘贴';

  @override
  String get shellFind => '查找…';

  @override
  String get shellFindAndReplace => '查找和替换…';

  @override
  String get shellWordWrap => '自动换行';

  @override
  String get shellWordWrapChecked => '自动换行 ✓';

  @override
  String get shellNotesPanel => '笔记面板';

  @override
  String get shellNotesPanelChecked => '笔记面板 ✓';

  @override
  String get shellPeersPanel => '节点面板';

  @override
  String get shellPeersPanelChecked => '节点面板 ✓';

  @override
  String get shellHelpItem => 'SB Simple Netpad 帮助';

  @override
  String get shellAboutItem => '关于 SB Simple Netpad';

  @override
  String get shellHideNotesPanel => '隐藏笔记面板';

  @override
  String shellShowNotesPanel(String mod) {
    return '显示笔记面板 ($mod+N)';
  }

  @override
  String get shellHidePeersPanel => '隐藏节点面板';

  @override
  String shellShowPeersPanel(String mod) {
    return '显示节点面板 ($mod+P)';
  }

  @override
  String shellPeersTooltipConnected(int count, String action, String mod) {
    return '$count 个加密节点会话 · $action节点面板 ($mod+P)';
  }

  @override
  String get shellPeersTooltipActionHide => '隐藏';

  @override
  String get shellPeersTooltipActionShow => '显示';

  @override
  String shellFindInNote(String mod) {
    return '在笔记中查找 ($mod+F)';
  }

  @override
  String shellSecurityChipConnected(int count) {
    return '$count 个节点会话已通过 WSS/TLS 加密 · 点击查看节点';
  }

  @override
  String get shellSecurityChipNone => '无活跃节点会话 · 点击查看节点';

  @override
  String get shellMobileWordWrap => '自动换行';

  @override
  String get shellMobileSaveToFile => '保存到文件…';

  @override
  String get shellMobileOpenFileAsNewNote => '打开文件作为新笔记…';

  @override
  String get shellMobileShareNote => '分享笔记';

  @override
  String get shellMobileVersionHistory => '版本历史…';

  @override
  String get shellMobileSettings => '设置';

  @override
  String get shellMobileHelp => '帮助';

  @override
  String get shellMobileAbout => '关于 SB Simple Netpad';

  @override
  String get shellListeningSnack => '正在聆听… 再次点击麦克风停止';

  @override
  String get notesTitle => '笔记';

  @override
  String get notesNewNote => '新笔记';

  @override
  String get notesSearchHint => '搜索所有笔记';

  @override
  String get notesRenameTitle => '重命名笔记';

  @override
  String get notesTitleLabel => '标题';

  @override
  String notesDeleteTitle(String title) {
    return '删除 \"$title\"？';
  }

  @override
  String get notesDeleteSyncedBody => '这将为您和所有连接的节点删除该笔记。';

  @override
  String get notesDeleteLocalBody => '这仅从此设备删除笔记。';

  @override
  String get notesNoMatches => '无匹配结果';

  @override
  String get notesNoNotes => '无笔记';

  @override
  String get notesRename => '重命名';

  @override
  String get notesVersionHistory => '版本历史';

  @override
  String get notesDelete => '删除';

  @override
  String get notesSyncWithPeers => '与节点同步';

  @override
  String get notesLocalOnly => '仅本地';

  @override
  String get notesEmptyNote => '空笔记';

  @override
  String notesMatchCount(int count) {
    return '$count 个匹配';
  }

  @override
  String notesLocalOnlyWithMatches(String matchLine) {
    return '仅本地 · $matchLine';
  }

  @override
  String notesSearchSnippetMatches(String snippet, int count) {
    return '$snippet  ·  $count 个匹配';
  }

  @override
  String get notesNoNoteSelected => '未选择笔记';

  @override
  String historyTitle(String title) {
    return '版本历史 · \"$title\"';
  }

  @override
  String get historyEmpty => '暂无保存的版本。在远程编辑替换您的文字之前，快照会自动保留。';

  @override
  String historyEntrySubtitle(String label, String time, int chars) {
    return '$label · $time · $chars 个字符';
  }

  @override
  String get historyRestore => '恢复';

  @override
  String get historyRestoredSnack => '版本已恢复';

  @override
  String get historyBeforeRemoteUpdate => '远程更新前';

  @override
  String get historySnapshot => '快照';

  @override
  String get historyImportedFile => '导入的文件';

  @override
  String get editorFindHint => '查找';

  @override
  String get editorReplaceHint => '替换为';

  @override
  String editorMatchCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get editorMatchNone => '0/0';

  @override
  String get editorPrevious => '上一个';

  @override
  String get editorNext => '下一个';

  @override
  String editorShowReplace(String shortcut) {
    return '显示替换 ($shortcut)';
  }

  @override
  String editorHideReplace(String shortcut) {
    return '隐藏替换 ($shortcut)';
  }

  @override
  String get editorClose => '关闭';

  @override
  String get editorReplace => '替换';

  @override
  String get editorReplaceAll => '全部';

  @override
  String get editorListening => '正在聆听…';

  @override
  String get editorDictate => '听写';

  @override
  String get editorStopDictation => '停止听写';

  @override
  String get peersConnectByIp => '通过 IP 连接';

  @override
  String get peersConnected => '已连接';

  @override
  String get peersNearby => '附近设备';

  @override
  String get peersTrustedDevices => '受信任设备';

  @override
  String get peersBlocked => '已屏蔽';

  @override
  String get peersConnectionLog => '连接日志';

  @override
  String get peersNoActiveConnections => '无活跃连接';

  @override
  String get peersNoTrustedDevices => '无受信任设备 — 接受配对时勾选“信任以自动同步”';

  @override
  String get peersNoBlockedDevices => '无屏蔽设备';

  @override
  String get peersNoConnectionEvents => '暂无连接事件';

  @override
  String get peersNoDiscoveredPeers =>
      '未发现节点 — Linux 必须与此设备处于同一 Wi‑Fi 子网（检查上方地址），或使用通过 IP 连接';

  @override
  String get peersDiscoveryPaused => '节点发现已暂停，直到加入本地网络';

  @override
  String get peersDisconnect => '断开连接';

  @override
  String get peersTrustTooltip => '信任以自动同步';

  @override
  String get peersTrustWaiting => '等待中…';

  @override
  String get peersTrustOfferFailed => '无法发送信任请求';

  @override
  String get peersConnectNow => '立即连接';

  @override
  String get peersConnect => '连接';

  @override
  String get peersResolving => '解析中…';

  @override
  String get peersBlockTooltip => '屏蔽';

  @override
  String peersBlockTitle(String peer) {
    return '屏蔽 $peer？';
  }

  @override
  String get peersBlockBody => '这将断开该设备的连接，忘记其固定证书，并拒绝未来的连接请求直至您取消屏蔽。';

  @override
  String peersRevokeTitle(String peer) {
    return '撤销 $peer？';
  }

  @override
  String get peersRevokeBody => '下次连接将需要再次点击接受。安全 PIN 将被保留，以便证书检查仍然适用。';

  @override
  String get peersAutoSync => '自动同步';

  @override
  String get peersCopiedOneLogEntry => '已复制 1 条日志条目';

  @override
  String peersCopiedLogEntries(int count) {
    return '已复制 $count 条日志条目';
  }

  @override
  String peersLogRevision(String time, String revision) {
    return '$time • 修订版 $revision';
  }

  @override
  String peersStillResolving(String peer) {
    return '仍在解析 $peer…';
  }

  @override
  String peersResolveFailedSnack(String peer) {
    return '无法解析 $peer。请检查 Avahi 和相同子网，或使用通过 IP 连接。';
  }

  @override
  String peersPairingRequestSent(String peer) {
    return '已向 $peer 发送配对请求';
  }

  @override
  String peersCouldNotConnect(String message) {
    return '无法连接: $message';
  }

  @override
  String peersManualHostPort(String host, int port) {
    return '$host:$port（手动）';
  }

  @override
  String get peersManual => '手动';

  @override
  String get peersResolveFailedSubtitle => '解析失败 — 请尝试通过 IP 连接';

  @override
  String get peersResolvingAddress => '正在解析地址…';

  @override
  String peersHostPort(String host, int port) {
    return '$host:$port';
  }

  @override
  String get peersNoAddressYet => '暂无地址';

  @override
  String peersEncryptedPinned(String code) {
    return '已加密 · 已固定 $code';
  }

  @override
  String get peersEncryptedWss => '已加密 (WSS/TLS)';

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
    return '$date 已配对 · $status';
  }

  @override
  String get peersStatusConnected => '已连接';

  @override
  String get peersStatusManualOnly => '仅手动';

  @override
  String get peersStatusReconnecting => '重新连接中…';

  @override
  String peersStatusRetryIn(int seconds) {
    return '$seconds秒后重试';
  }

  @override
  String get peersStatusNotOnNetwork => '不在网络中';

  @override
  String get peersStatusConnecting => '连接中…';

  @override
  String get peersStatusAutoReconnect => '自动重连';

  @override
  String peersPresenceLineCol(int line, int column) {
    return '第 $line 行，第 $column 列';
  }

  @override
  String peersPresenceInNote(String title, String position) {
    return '\"$title\" · $position';
  }

  @override
  String peersRoomLabel(String room) {
    return '房间 \"$room\"';
  }

  @override
  String get discoveryThisDevice => '此设备';

  @override
  String get discoveryCopyAddress => '复制地址';

  @override
  String discoveryCopiedAddress(String address) {
    return '已复制 $address';
  }

  @override
  String get discoveryLocalNetworkRequired => '需要本地网络';

  @override
  String get discoveryNotListeningTitle => '未在监听';

  @override
  String get discoveryNotListeningBody =>
      '此设备尚未监听节点。加入 Wi‑Fi 后等待几秒，或点击网络错误横幅上的重试。';

  @override
  String get discoveryModeTitle => '发现模式';

  @override
  String get discoveryUnavailableTitle => '节点发现不可用';

  @override
  String get discoveryRetryTooltip => '重试发现';

  @override
  String get peersSecuredSessions => '安全会话';

  @override
  String peersSecurityBannerIdle(String code) {
    return '此设备通过 WSS/TLS 广播 · 代码 $code';
  }

  @override
  String peersSecurityBannerActive(int connectedCount, int pinnedCount) {
    return '$connectedCount 个加密会话 · $pinnedCount 个证书已固定';
  }

  @override
  String peersSecurityCompactIdle(String code) {
    return 'WSS/TLS · 代码 $code';
  }

  @override
  String peersSecurityCompactActive(int connectedCount, int pinnedCount) {
    return '$connectedCount 个已加密 · $pinnedCount 个已固定';
  }

  @override
  String peersSecurityTooltipPinned(String code) {
    return '已加密 (WSS/TLS) · 已固定 $code';
  }

  @override
  String get peersSecurityTooltipActive => '已加密 (WSS/TLS) · 活跃会话';

  @override
  String get pairingConnectionRequest => '连接请求';

  @override
  String pairingAllowPeer(String peer) {
    return '允许 $peer 连接并共享此笔记？';
  }

  @override
  String get pairingVerificationCode => '验证码';

  @override
  String get pairingConfirmCode => '接受前请确认此代码在两台设备上匹配。';

  @override
  String get pairingThisDeviceSecurityCode => '此设备安全码';

  @override
  String get pairingOtherDevicePins => '另一台设备在首次连接时固定此代码。';

  @override
  String get pairingTrustForAutoSync => '信任以自动同步';

  @override
  String get pairingTrustForAutoSyncHint => '之后重新连接时可跳过接受。可选 — 不勾选则每次都需接受。';

  @override
  String get pairingTrustOfferTitle => '信任请求';

  @override
  String pairingTrustOfferBody(String peer) {
    return '$peer 想要信任此设备以进行自动同步。以后重新连接时将跳过接受。';
  }

  @override
  String pairingTrustAcceptedSnack(String peer) {
    return '已信任 $peer 以进行自动同步';
  }

  @override
  String pairingTrustDeclinedSnack(String peer) {
    return '$peer 拒绝了信任';
  }

  @override
  String get manualConnectTitle => '通过地址连接';

  @override
  String get manualConnectBody => '当发现无法在同一子网上找到节点时使用。仅允许活跃本地网络段上的地址。';

  @override
  String get manualConnectHostLabel => '主机或 IP';

  @override
  String get manualConnectHostHint => '192.168.1.42';

  @override
  String get manualConnectPortLabel => '端口';

  @override
  String get manualConnectPortHint => '54321';

  @override
  String get manualConnectLabelOptional => '标签（可选）';

  @override
  String get manualConnectLabelHint => '客厅电脑';

  @override
  String get manualConnectInvalidHostPort => '请输入有效的主机和端口（1–65535）';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsDeviceSection => '设备';

  @override
  String settingsDeviceHint(String mod) {
    return '设备名称和房间需要保存 ($mod+S)。外观和编辑器偏好立即保存。';
  }

  @override
  String get settingsDeviceName => '设备名称';

  @override
  String get settingsDeviceNameHint => '显示给其他设备的名称';

  @override
  String get settingsSessionRoom => '会话 / 房间';

  @override
  String get settingsSessionRoomHint => '仅发现同一房间中的节点';

  @override
  String get settingsListeningPort => '监听端口';

  @override
  String get settingsStartingServer => '正在启动服务器…';

  @override
  String settingsAddressShare(String address) {
    return '$address（分享此地址用于手动连接）';
  }

  @override
  String get settingsCopyAddress => '复制地址';

  @override
  String get settingsAddressCopied => '地址已复制到剪贴板';

  @override
  String settingsSavedSnack(String name, String room) {
    return '设置已保存 · \"$name\" · 房间 \"$room\"';
  }

  @override
  String get settingsAppearanceSection => '外观';

  @override
  String get settingsMode => '模式';

  @override
  String get settingsThemeSystem => '系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsSkin => '皮肤';

  @override
  String get settingsSkinDefault => '默认';

  @override
  String get settingsSkinOcean => '海洋';

  @override
  String get settingsSkinForest => '森林';

  @override
  String get settingsSkinSunset => '日落';

  @override
  String get settingsSkinSlate => '石板';

  @override
  String settingsSkinStandardLabel(String skin) {
    return '$skin · Standard';
  }

  @override
  String get settingsStandardSection => 'Netpad Standard';

  @override
  String get settingsStandardUnlocked => 'Standard 已解锁';

  @override
  String get settingsFree => '免费';

  @override
  String get settingsStandardUnlockedSubtitle => '无限同步笔记和节点、皮肤、历史、自动同步和语音';

  @override
  String get settingsStandardBuySubtitle => '通过您的应用商店一次性解锁';

  @override
  String get settingsPurchasesUnavailable => '此平台上购买不可用';

  @override
  String get settingsRestorePurchases => '恢复购买';

  @override
  String get settingsStandardRestored => 'Standard 已恢复';

  @override
  String get settingsNoPreviousStandard => '未找到之前的 Standard 购买记录';

  @override
  String get settingsEditorSection => '编辑器';

  @override
  String get settingsWordWrap => '自动换行';

  @override
  String get settingsWordWrapSubtitle => '换行长行而不是水平滚动';

  @override
  String settingsFontSize(int size) {
    return '字体大小（$size pt）';
  }

  @override
  String get settingsLegalSection => '法律';

  @override
  String get settingsEulaSubtitleStandard =>
      'Standard · 在 GitHub Pages 上打开 EULA';

  @override
  String get settingsEulaSubtitleFree => '免费 · 在 GitHub Pages 上打开 EULA';

  @override
  String get settingsPrivacySubtitle => '在 GitHub Pages 上打开隐私页面';

  @override
  String get settingsDisclaimerTitle => '免责声明和责任';

  @override
  String get settingsDisclaimerSubtitle => '使用风险自负';

  @override
  String get settingsDisclaimerP1 =>
      '本软件按\"原样\"提供，不提供任何形式的明示或暗示保证，包括适销性、特定用途适用性和非侵权性。';

  @override
  String get settingsDisclaimerP2 => '您对使用本应用的方式以及遵守所有适用法律、法规、政策和协议负全责。';

  @override
  String get settingsDisclaimerP3 =>
      '版权持有人对因使用或滥用本软件而产生的任何索赔、损害、损失、数据丢失、业务中断或其他责任不承担任何责任。';

  @override
  String get settingsNoLegalAdviceTitle => '无法律建议';

  @override
  String get settingsNoLegalAdviceSubtitle => '仅为信息软件';

  @override
  String get settingsNoLegalAdviceP1 => '本应用及其文档不提供法律、监管或专业建议。';

  @override
  String get settingsNoLegalAdviceP2 => '如果您需要针对使用情况的法律指导，请咨询合格的专业人士。';

  @override
  String get settingsCopyright => '© 2026 Spencer Beaumier';

  @override
  String get paywallTitle => '解锁 Netpad Standard';

  @override
  String get paywallSubtitle => '一次性购买。核心编辑和 LAN 同步保持免费。';

  @override
  String get paywallBenefitUnlimitedNotes => '无限同步笔记';

  @override
  String get paywallBenefitUnlimitedPeers => '无限连接节点';

  @override
  String get paywallBenefitSkins => '额外颜色皮肤';

  @override
  String get paywallBenefitHistory => '版本历史';

  @override
  String get paywallBenefitAutoSync => '受信任节点自动同步';

  @override
  String get paywallBenefitVoice => '语音听写';

  @override
  String get paywallPurchasesUnsupported =>
      '此平台上无法进行应用内购买。请从 App Store、Google Play 或 Microsoft Store 安装以解锁 Standard。';

  @override
  String get paywallBuyStandard => '购买 Standard';

  @override
  String paywallBuyStandardPrice(String price) {
    return '购买 Standard · $price';
  }

  @override
  String get paywallRestorePurchases => '恢复购买';

  @override
  String get paywallPurchaseNotCompleted => '购买未完成。';

  @override
  String get paywallPurchaseFailed => '购买失败。';

  @override
  String get paywallStandardRestored => 'Standard 已恢复';

  @override
  String get paywallNoPreviousStandard => '未找到之前的 Standard 购买记录';

  @override
  String standardHighlightNoteLimit(int limit) {
    return '免费版最多可同时同步 $limit 条笔记。解锁 Standard 获得无限同步笔记。';
  }

  @override
  String standardHighlightPeerLimit(int limit) {
    return '免费版最多包含 $limit 个连接节点。解锁 Standard 获得无限节点。';
  }

  @override
  String get standardHighlightVersionHistory => '版本历史是 Standard 功能。';

  @override
  String get standardHighlightVoice => '语音听写是 Standard 功能。';

  @override
  String get standardHighlightAutoSync => '受信任节点自动同步是 Standard 功能。';

  @override
  String get standardHighlightSkins => '额外皮肤包含在 Standard 中。';

  @override
  String get helpTitle => '帮助';

  @override
  String get helpIntro => '用于纯文本笔记的 LAN 记事本。同一 Wi‑Fi 上的设备相互发现，配对一次，然后实时同步笔记。';

  @override
  String get helpAboutTile => '关于 SB Simple Netpad';

  @override
  String get helpEulaSubtitle => '在 GitHub Pages 上打开 EULA';

  @override
  String get helpPrivacySubtitle => '在 GitHub Pages 上打开隐私页面';

  @override
  String get helpGettingStartedTitle => '入门指南';

  @override
  String get helpGettingStarted1 => '加入与要同步的设备相同的 Wi‑Fi 网络。';

  @override
  String get helpGettingStarted2 => '打开节点面板（锁图标或节点抽屉），等待附近设备出现。';

  @override
  String get helpGettingStarted3 => '从此设备复制您的地址，如果发现速度慢则分享它。';

  @override
  String get helpGettingStarted4 => '当 mDNS 发现找不到节点时，使用通过 IP 连接。';

  @override
  String get helpNotesTitle => '笔记';

  @override
  String get helpNotes1 => '点击菜单图标（☰）或笔记面板以切换笔记。';

  @override
  String get helpNotes2 => '从笔记列表创建、重命名、重新排序和删除笔记。';

  @override
  String get helpNotes3 => '每条笔记独立同步 — 新笔记默认为仅本地；需要与节点共享时再打开同步。';

  @override
  String get helpNotes4 => '在笔记内搜索（查找）或从编辑器搜索所有笔记。';

  @override
  String get helpNotes5 => '版本历史保存可以稍后恢复的本地快照。';

  @override
  String get helpPeersTitle => '节点和配对';

  @override
  String get helpPeers1 => '附近设备列出同一房间中发现的设备（参见设置）。';

  @override
  String get helpPeers2 => '点击节点上的连接 — 另一台设备必须点击接受。';

  @override
  String get helpPeers3 => '接受前比较配对验证码。';

  @override
  String get helpPeers4 => '若希望之后重新连接跳过接受，请在接受时勾选“信任以自动同步”。';

  @override
  String get helpPeers5 => '受信任设备: 切换自动同步或撤销以再次要求接受。';

  @override
  String get helpPeers6 => '屏蔽会断开设备连接并拒绝未来配对直至取消屏蔽。';

  @override
  String get helpPeers7 => '已连接显示包含地址和光标位置的活跃会话。';

  @override
  String get helpFileSharingTitle => '文件和分享';

  @override
  String get helpFileSharing1Desktop =>
      '文件菜单: 保存到文件、打开文件作为新笔记、分享笔记、版本历史、设置、退出。';

  @override
  String get helpFileSharing1Macos =>
      'File menu: Save to File, Open File as New Note, Share Note, Version History. Settings are under the app menu (Cmd+,); Quit ends the app.';

  @override
  String get helpFileSharing1Mobile =>
      '菜单（⋮）: 保存到文件、打开文件作为新笔记、分享、版本历史、设置和此帮助指南。';

  @override
  String get helpFileSharing1Ios =>
      'Overflow menu (⋮): share note, version history, settings, and this help guide. Use Share to export text — Save/Open file are not available on iOS.';

  @override
  String get helpFileSharing2 =>
      'Save to file exports the active note as .txt or .md (desktop and Android).';

  @override
  String get helpFileSharing3 =>
      'Open file imports text into a new local-only note; turn on sync if you want peers to receive it (desktop and Android).';

  @override
  String get helpFileSharing4 => '分享使用系统分享表单；Linux 回退到剪贴板。';

  @override
  String get helpSettingsTitle => '设置';

  @override
  String get helpSettings1 => '设备名称和房间需要保存 — 其他选项立即生效。';

  @override
  String get helpSettings2 => '房间 ID 对节点进行分组: 仅发现同一房间中的设备。';

  @override
  String get helpSettings3 => '外观和编辑器偏好（主题、皮肤、换行、字体）在更改时保存。';

  @override
  String get helpDesktopShortcutsTitle => '桌面快捷键';

  @override
  String get helpDesktopShortcuts1 => 'Ctrl/Cmd+S — 保存到文件';

  @override
  String get helpDesktopShortcuts2 => 'Ctrl/Cmd+O — 打开文件作为新笔记';

  @override
  String get helpDesktopShortcuts3 => 'Ctrl/Cmd+F — 在笔记中查找';

  @override
  String get helpDesktopShortcuts4 =>
      'Ctrl+H (Windows/Linux) or Option+Cmd+F (macOS) — Find and replace';

  @override
  String get helpDesktopShortcuts5 => 'Ctrl/Cmd+N — 切换笔记面板';

  @override
  String get helpDesktopShortcuts6 => 'Ctrl/Cmd+P — 切换节点面板';

  @override
  String get helpDesktopShortcuts7 =>
      'Ctrl/Cmd+Q — Exit (Windows/Linux); macOS uses Quit from the app menu';

  @override
  String get helpTroubleshootingTitle => '故障排除';

  @override
  String get helpTroubleshooting1 => '没有节点？确认相同的 Wi‑Fi 子网和房间 ID；尝试通过 IP 连接。';

  @override
  String get helpTroubleshooting2 => '需要本地网络横幅表示同步已暂停，直到 Wi‑Fi 连接。';

  @override
  String get helpTroubleshooting3 => '首次启动时允许应用通过防火墙（桌面）。';

  @override
  String get helpTroubleshooting4 => 'Linux: 如果发现从未启动，请安装 dbus 和 avahi-daemon。';

  @override
  String get helpTroubleshooting5 => 'Android: 提示时授予附近 Wi‑Fi 权限。';

  @override
  String get helpTroubleshooting6 =>
      'iOS/macOS: allow Local Network access for SB Simple Netpad in System Settings if peers never appear.';

  @override
  String get aboutTitle => '关于';

  @override
  String get aboutTagline => '具有节点发现和共享编辑功能的 LAN 记事本。';

  @override
  String get aboutDescription =>
      '在手机或电脑上写纯文本笔记，与同一 Wi‑Fi 上的其他设备保持同步。节点在本地网络上相互发现，通过相互批准配对一次，然后通过加密节点会话共享多个命名笔记。';

  @override
  String get aboutPlatforms => 'Android · iOS · Windows · macOS · Linux';

  @override
  String get aboutStatus => '测试版 — 适合日常 LAN 使用。';

  @override
  String get aboutEulaHeading => '最终用户许可协议';

  @override
  String aboutEulaBody(int noteLimit, int peerLimit) {
    return 'SB Simple Netpad 根据 EULA 而非开源许可证进行授权。核心编辑和 LAN 同步免费（本地笔记不限量，最多 $noteLimit 条同步笔记和 $peerLimit 个连接节点）。Netpad Standard 通过 App Store、Google Play 或 Microsoft Store 一次性解锁。';
  }

  @override
  String get aboutViewEula => '查看 EULA';

  @override
  String get aboutPrivacyPolicy => '隐私政策';

  @override
  String get aboutHowToUse => '如何使用 SB Simple Netpad';

  @override
  String get aboutCouldNotOpenPrivacy => '无法打开隐私政策';

  @override
  String get aboutCouldNotOpenEula => '无法打开 EULA';

  @override
  String get aboutCopyright => '© 2026 Spencer Beaumier';

  @override
  String conflictLiveTitle(String title) {
    return '\"$title\" 中的编辑冲突';
  }

  @override
  String conflictLiveBody(
    String peer,
    String revision,
    String localPreview,
    String remotePreview,
  ) {
    return '$peer 同时编辑了相同的笔记（修订版 $revision）。\n\n您的版本:\n$localPreview\n\n$peer:\n$remotePreview\n\n两台设备应保留哪个版本？';
  }

  @override
  String conflictDivergedTitle(String title) {
    return '\"$title\" 已分歧';
  }

  @override
  String conflictDivergedBody(
    String peer,
    String title,
    int localChars,
    int remoteChars,
  ) {
    return '您的副本和 $peer 的 \"$title\" 副本在断开连接期间发生了不同的变化。\n\n您的版本: $localChars 个字符\n$peer: $remoteChars 个字符\n\n两台设备应保留哪个版本？';
  }

  @override
  String conflictUsePeers(String peer) {
    return '使用 $peer 的版本';
  }

  @override
  String get conflictKeepMine => '保留我的';

  @override
  String fileSavedTo(String path) {
    return '已保存到 $path';
  }

  @override
  String fileCouldNotSave(String error) {
    return '无法保存: $error';
  }

  @override
  String fileOpenedAsNewNote(String name) {
    return '已将 $name 作为新笔记打开';
  }

  @override
  String fileCouldNotOpen(String error) {
    return '无法打开: $error';
  }

  @override
  String get fileNothingToShare => '无内容可分享 — 笔记为空';

  @override
  String get fileShareFallbackClipboard => '此处分享不可用 — 已复制到剪贴板';

  @override
  String get fileDefaultNoteName => 'netpad-note';
}
