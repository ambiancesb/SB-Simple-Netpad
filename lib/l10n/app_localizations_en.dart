// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonAppName => 'SB Simple Netpad';

  @override
  String get commonStandardName => 'Netpad Standard';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonConnect => 'Connect';

  @override
  String get commonHelp => 'Help';

  @override
  String get commonSettings => 'Settings';

  @override
  String get commonMore => 'More';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonAccept => 'Accept';

  @override
  String get commonReject => 'Reject';

  @override
  String get commonBlock => 'Block';

  @override
  String get commonUnblock => 'Unblock';

  @override
  String get commonRevoke => 'Revoke';

  @override
  String get commonRestore => 'Restore';

  @override
  String get commonRetry => 'Retry';

  @override
  String commonCouldNotOpenLabel(String label) {
    return 'Could not open $label';
  }

  @override
  String get commonEulaLabel => 'EULA';

  @override
  String get commonPrivacyPolicyLabel => 'privacy policy';

  @override
  String get commonEndUserLicenseAgreement => 'End User License Agreement';

  @override
  String get commonPrivacyPolicy => 'Privacy Policy';

  @override
  String commonVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get shellMenuFile => 'File';

  @override
  String get shellMenuEdit => 'Edit';

  @override
  String get shellMenuView => 'View';

  @override
  String get shellMenuHelp => 'Help';

  @override
  String get shellSaveToFile => 'Save to File…';

  @override
  String get shellOpenFileAsNewNote => 'Open File as New Note…';

  @override
  String get shellShareNote => 'Share Note';

  @override
  String get shellVersionHistory => 'Version History…';

  @override
  String get shellSettings => 'Settings…';

  @override
  String get shellExit => 'Exit';

  @override
  String get shellCut => 'Cut';

  @override
  String get shellCopy => 'Copy';

  @override
  String get shellPaste => 'Paste';

  @override
  String get shellFind => 'Find…';

  @override
  String get shellFindAndReplace => 'Find and Replace…';

  @override
  String get shellWordWrap => 'Word Wrap';

  @override
  String get shellWordWrapChecked => 'Word Wrap ✓';

  @override
  String get shellNotesPanel => 'Notes Panel';

  @override
  String get shellNotesPanelChecked => 'Notes Panel ✓';

  @override
  String get shellPeersPanel => 'Peers Panel';

  @override
  String get shellPeersPanelChecked => 'Peers Panel ✓';

  @override
  String get shellHelpItem => 'SB Simple Netpad Help';

  @override
  String get shellAboutItem => 'About SB Simple Netpad';

  @override
  String get shellHideNotesPanel => 'Hide notes panel';

  @override
  String shellShowNotesPanel(String mod) {
    return 'Show notes panel ($mod+N)';
  }

  @override
  String get shellHidePeersPanel => 'Hide peers panel';

  @override
  String shellShowPeersPanel(String mod) {
    return 'Show peers panel ($mod+P)';
  }

  @override
  String shellPeersTooltipConnected(int count, String action, String mod) {
    return '$count encrypted peer sessions · $action peers panel ($mod+P)';
  }

  @override
  String get shellPeersTooltipActionHide => 'hide';

  @override
  String get shellPeersTooltipActionShow => 'show';

  @override
  String shellFindInNote(String mod) {
    return 'Find in note ($mod+F)';
  }

  @override
  String shellSecurityChipConnected(int count) {
    return '$count peer sessions encrypted with WSS/TLS · tap for peers';
  }

  @override
  String get shellSecurityChipNone => 'No active peer sessions · tap for peers';

  @override
  String get shellMobileWordWrap => 'Word wrap';

  @override
  String get shellMobileSaveToFile => 'Save to file…';

  @override
  String get shellMobileOpenFileAsNewNote => 'Open file as new note…';

  @override
  String get shellMobileShareNote => 'Share note';

  @override
  String get shellMobileVersionHistory => 'Version history…';

  @override
  String get shellMobileSettings => 'Settings';

  @override
  String get shellMobileHelp => 'Help';

  @override
  String get shellMobileAbout => 'About SB Simple Netpad';

  @override
  String get shellListeningSnack => 'Listening… tap the mic again to stop';

  @override
  String get notesTitle => 'Notes';

  @override
  String get notesNewNote => 'New note';

  @override
  String get notesSearchHint => 'Search all notes';

  @override
  String get notesRenameTitle => 'Rename note';

  @override
  String get notesTitleLabel => 'Title';

  @override
  String notesDeleteTitle(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get notesDeleteSyncedBody =>
      'This removes the note for you and every connected peer.';

  @override
  String get notesDeleteLocalBody =>
      'This removes the note from this device only.';

  @override
  String get notesNoMatches => 'No matches';

  @override
  String get notesNoNotes => 'No notes';

  @override
  String get notesRename => 'Rename';

  @override
  String get notesVersionHistory => 'Version history';

  @override
  String get notesDelete => 'Delete';

  @override
  String get notesSyncWithPeers => 'Sync with peers';

  @override
  String get notesLocalOnly => 'Local only';

  @override
  String get notesEmptyNote => 'Empty note';

  @override
  String notesMatchCount(int count) {
    return '$count matches';
  }

  @override
  String notesLocalOnlyWithMatches(String matchLine) {
    return 'Local only · $matchLine';
  }

  @override
  String notesSearchSnippetMatches(String snippet, int count) {
    return '$snippet  ·  $count matches';
  }

  @override
  String get notesNoNoteSelected => 'No note selected';

  @override
  String historyTitle(String title) {
    return 'Version history · \"$title\"';
  }

  @override
  String get historyEmpty =>
      'No saved versions yet. Snapshots are kept automatically before remote edits replace your text.';

  @override
  String historyEntrySubtitle(String label, String time, int chars) {
    return '$label · $time · $chars chars';
  }

  @override
  String get historyRestore => 'Restore';

  @override
  String get historyRestoredSnack => 'Version restored';

  @override
  String get historyBeforeRemoteUpdate => 'Before remote update';

  @override
  String get historySnapshot => 'Snapshot';

  @override
  String get historyImportedFile => 'Imported file';

  @override
  String get editorFindHint => 'Find';

  @override
  String get editorReplaceHint => 'Replace with';

  @override
  String editorMatchCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get editorMatchNone => '0/0';

  @override
  String get editorPrevious => 'Previous';

  @override
  String get editorNext => 'Next';

  @override
  String editorShowReplace(String shortcut) {
    return 'Show replace ($shortcut)';
  }

  @override
  String editorHideReplace(String shortcut) {
    return 'Hide replace ($shortcut)';
  }

  @override
  String get editorClose => 'Close';

  @override
  String get editorReplace => 'Replace';

  @override
  String get editorReplaceAll => 'All';

  @override
  String get editorListening => 'Listening…';

  @override
  String get editorDictate => 'Dictate';

  @override
  String get editorStopDictation => 'Stop dictation';

  @override
  String get peersConnectByIp => 'Connect by IP';

  @override
  String get peersScanQr => 'Scan QR code';

  @override
  String get peersShowQrTooltip => 'Show QR code';

  @override
  String get peersConnected => 'Connected';

  @override
  String get peersNearby => 'Nearby';

  @override
  String get peersTrustedDevices => 'Trusted devices';

  @override
  String get peersBlocked => 'Blocked';

  @override
  String get peersConnectionLog => 'Connection log';

  @override
  String get peersNoActiveConnections => 'No active connections';

  @override
  String get peersNoTrustedDevices =>
      'No trusted devices — check Trust for auto-sync when accepting a pair';

  @override
  String get peersNoBlockedDevices => 'No blocked devices';

  @override
  String get peersNoConnectionEvents => 'No connection events yet';

  @override
  String get peersNoDiscoveredPeers =>
      'No discovered peers — devices must be on the same Wi‑Fi subnet as This device (check the address above), or use Connect by IP';

  @override
  String get peersDiscoveryPaused =>
      'Peer discovery is paused until you join a local network';

  @override
  String get peersDisconnect => 'Disconnect';

  @override
  String get peersTrustTooltip => 'Trust for auto-sync';

  @override
  String get peersTrustWaiting => 'Waiting…';

  @override
  String get peersTrustOfferFailed => 'Could not send trust offer';

  @override
  String get peersConnectNow => 'Connect now';

  @override
  String get peersConnect => 'Connect';

  @override
  String get peersResolving => 'Resolving…';

  @override
  String get peersBlockTooltip => 'Block';

  @override
  String peersBlockTitle(String peer) {
    return 'Block $peer?';
  }

  @override
  String get peersBlockBody =>
      'This disconnects the device, forgets its pinned certificate, and refuses future connection requests until you unblock it.';

  @override
  String peersRevokeTitle(String peer) {
    return 'Revoke $peer?';
  }

  @override
  String get peersRevokeBody =>
      'The next connection will require tapping Accept again. The security pin is kept so certificate checks still apply.';

  @override
  String get peersAutoSync => 'Auto-sync';

  @override
  String get peersCopiedOneLogEntry => 'Copied 1 log entry';

  @override
  String peersCopiedLogEntries(int count) {
    return 'Copied $count log entries';
  }

  @override
  String peersLogRevision(String time, String revision) {
    return '$time • revision $revision';
  }

  @override
  String peersStillResolving(String peer) {
    return 'Still resolving $peer…';
  }

  @override
  String peersResolveFailedSnack(String peer) {
    return 'Could not resolve $peer. Check that both devices are on the same subnet, or use Connect by IP.';
  }

  @override
  String peersPairingRequestSent(String peer) {
    return 'Pairing request sent to $peer';
  }

  @override
  String peersCouldNotConnect(String message) {
    return 'Could not connect: $message';
  }

  @override
  String peersManualHostPort(String host, int port) {
    return '$host:$port (manual)';
  }

  @override
  String get peersManual => 'Manual';

  @override
  String get peersResolveFailedSubtitle => 'Resolve failed — try Connect by IP';

  @override
  String get peersResolvingAddress => 'Resolving address…';

  @override
  String peersHostPort(String host, int port) {
    return '$host:$port';
  }

  @override
  String get peersNoAddressYet => 'No address yet';

  @override
  String peersEncryptedPinned(String code) {
    return 'Encrypted · pinned $code';
  }

  @override
  String get peersEncryptedWss => 'Encrypted (WSS/TLS)';

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
    return 'Paired $date · $status';
  }

  @override
  String get peersStatusConnected => 'Connected';

  @override
  String get peersStatusManualOnly => 'Manual only';

  @override
  String get peersStatusReconnecting => 'Reconnecting…';

  @override
  String peersStatusRetryIn(int seconds) {
    return 'Retry in ${seconds}s';
  }

  @override
  String get peersStatusNotOnNetwork => 'Not on network';

  @override
  String get peersStatusConnecting => 'Connecting…';

  @override
  String get peersStatusAutoReconnect => 'Auto-reconnect';

  @override
  String peersPresenceLineCol(int line, int column) {
    return 'line $line, col $column';
  }

  @override
  String peersPresenceInNote(String title, String position) {
    return '\"$title\" · $position';
  }

  @override
  String peersRoomLabel(String room) {
    return 'Room \"$room\"';
  }

  @override
  String get discoveryThisDevice => 'This device';

  @override
  String get discoveryCopyAddress => 'Copy address';

  @override
  String discoveryCopiedAddress(String address) {
    return 'Copied $address';
  }

  @override
  String get discoveryLocalNetworkRequired => 'Local network required';

  @override
  String get discoveryNotListeningTitle => 'Not listening';

  @override
  String get discoveryNotListeningBody =>
      'This device is not listening for peers yet. Wait a few seconds after joining Wi‑Fi, or tap Retry on a networking error banner.';

  @override
  String get discoveryModeTitle => 'Discovery mode';

  @override
  String get discoveryUnavailableTitle => 'Peer discovery unavailable';

  @override
  String get discoveryRetryTooltip => 'Retry discovery';

  @override
  String get peersSecuredSessions => 'Secured sessions';

  @override
  String peersSecurityBannerIdle(String code) {
    return 'This device advertises over WSS/TLS · code $code';
  }

  @override
  String peersSecurityBannerActive(int connectedCount, int pinnedCount) {
    return '$connectedCount encrypted sessions · $pinnedCount certificates pinned';
  }

  @override
  String peersSecurityCompactIdle(String code) {
    return 'WSS/TLS · code $code';
  }

  @override
  String peersSecurityCompactActive(int connectedCount, int pinnedCount) {
    return '$connectedCount encrypted · $pinnedCount pinned';
  }

  @override
  String peersSecurityTooltipPinned(String code) {
    return 'Encrypted (WSS/TLS) · pinned $code';
  }

  @override
  String get peersSecurityTooltipActive =>
      'Encrypted (WSS/TLS) · active session';

  @override
  String get pairingConnectionRequest => 'Connection request';

  @override
  String pairingAllowPeer(String peer) {
    return 'Allow $peer to connect and share this note?';
  }

  @override
  String get pairingVerificationCode => 'Verification code';

  @override
  String get pairingConfirmCode =>
      'Confirm this code matches on both devices before accepting.';

  @override
  String get pairingThisDeviceSecurityCode => 'This device security code';

  @override
  String get pairingOtherDevicePins =>
      'The other device pins this on first connect.';

  @override
  String get pairingTrustForAutoSync => 'Trust for auto-sync';

  @override
  String get pairingTrustForAutoSyncHint =>
      'Skip Accept on later reconnects. Optional — leave unchecked to require Accept each time.';

  @override
  String get pairingTrustOfferTitle => 'Trust request';

  @override
  String pairingTrustOfferBody(String peer) {
    return '$peer wants to trust this device for auto-sync. Future reconnects will skip Accept.';
  }

  @override
  String pairingTrustAcceptedSnack(String peer) {
    return 'Trusted $peer for auto-sync';
  }

  @override
  String pairingTrustDeclinedSnack(String peer) {
    return '$peer declined trust';
  }

  @override
  String get manualConnectTitle => 'Connect by address';

  @override
  String get manualConnectBody =>
      'Use when discovery cannot find peers on the same subnet. Only addresses on your active local network segment are allowed.';

  @override
  String get manualConnectHostLabel => 'Host or IP';

  @override
  String get manualConnectHostHint => '192.168.1.42';

  @override
  String get manualConnectPortLabel => 'Port';

  @override
  String get manualConnectPortHint => '54321';

  @override
  String get manualConnectLabelOptional => 'Label (optional)';

  @override
  String get manualConnectLabelHint => 'Living room PC';

  @override
  String get manualConnectInvalidHostPort =>
      'Enter a valid host and port (1–65535)';

  @override
  String get qrShowTitle => 'Connect with QR';

  @override
  String get qrShowBody =>
      'Have another device on the same Wi‑Fi scan this code to connect.';

  @override
  String get qrShowNotReady => 'Waiting for a local address…';

  @override
  String get qrScanTitle => 'Scan QR code';

  @override
  String get qrScanBody =>
      'Point the camera at a Netpad QR code, or choose a photo.';

  @override
  String get qrScanCameraUnavailable =>
      'Camera unavailable — choose a photo of the QR code instead.';

  @override
  String get qrScanPickImage => 'Choose photo';

  @override
  String get qrScanInvalid => 'Not a valid Netpad connection code';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDeviceSection => 'Device';

  @override
  String settingsDeviceHint(String mod) {
    return 'Device name and room require Save ($mod+S). Appearance and editor preferences save immediately.';
  }

  @override
  String get settingsDeviceName => 'Device name';

  @override
  String get settingsDeviceNameHint => 'Name shown to other devices';

  @override
  String get settingsSessionRoom => 'Session / room';

  @override
  String get settingsSessionRoomHint =>
      'Only peers in the same room are discovered';

  @override
  String get settingsListeningPort => 'Listening port';

  @override
  String get settingsStartingServer => 'Starting server…';

  @override
  String settingsAddressShare(String address) {
    return '$address (share this with manual connect)';
  }

  @override
  String get settingsCopyAddress => 'Copy address';

  @override
  String get settingsAddressCopied => 'Address copied to clipboard';

  @override
  String settingsSavedSnack(String name, String room) {
    return 'Settings saved · \"$name\" · room \"$room\"';
  }

  @override
  String get settingsAppearanceSection => 'Appearance';

  @override
  String get settingsMode => 'Mode';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsSkin => 'Skin';

  @override
  String get settingsSkinDefault => 'Default';

  @override
  String get settingsSkinOcean => 'Ocean';

  @override
  String get settingsSkinForest => 'Forest';

  @override
  String get settingsSkinSunset => 'Sunset';

  @override
  String get settingsSkinSlate => 'Slate';

  @override
  String settingsSkinStandardLabel(String skin) {
    return '$skin · Standard';
  }

  @override
  String get settingsStandardSection => 'Netpad Standard';

  @override
  String get settingsStandardUnlocked => 'Standard unlocked';

  @override
  String get settingsFree => 'Free';

  @override
  String get settingsStandardUnlockedSubtitle =>
      'Unlimited synced notes and peers, skins, history, auto-sync, and voice';

  @override
  String get settingsStandardBuySubtitle =>
      'One-time unlock via your app store';

  @override
  String get settingsPurchasesUnavailable =>
      'Purchases unavailable on this platform';

  @override
  String get settingsStandardStoreSubtitle =>
      'Get Standard from the App Store, Google Play, or Microsoft Store';

  @override
  String get settingsRestorePurchases => 'Restore purchases';

  @override
  String get settingsStandardRestored => 'Standard restored';

  @override
  String get settingsNoPreviousStandard =>
      'No previous Standard purchase found';

  @override
  String get settingsEditorSection => 'Editor';

  @override
  String get settingsWordWrap => 'Word wrap';

  @override
  String get settingsWordWrapSubtitle =>
      'Wrap long lines instead of horizontal scroll';

  @override
  String settingsFontSize(int size) {
    return 'Font size ($size pt)';
  }

  @override
  String get settingsLegalSection => 'Legal';

  @override
  String get settingsEulaSubtitleStandard =>
      'Standard · Opens EULA on GitHub Pages';

  @override
  String get settingsEulaSubtitleFree => 'Free · Opens EULA on GitHub Pages';

  @override
  String get settingsPrivacySubtitle => 'Opens privacy page on GitHub Pages';

  @override
  String get settingsDisclaimerTitle => 'Disclaimer and liability';

  @override
  String get settingsDisclaimerSubtitle => 'Use at your own risk';

  @override
  String get settingsDisclaimerP1 =>
      'This software is provided \"as is\", without warranties of any kind, express or implied, including merchantability, fitness for a particular purpose, and non-infringement.';

  @override
  String get settingsDisclaimerP2 =>
      'You are solely responsible for how you use this app and for compliance with all applicable laws, regulations, policies, and agreements.';

  @override
  String get settingsDisclaimerP3 =>
      'The copyright holder is not liable for any claims, damages, losses, data loss, business interruption, or other liability arising from use or misuse of this software.';

  @override
  String get settingsNoLegalAdviceTitle => 'No legal advice';

  @override
  String get settingsNoLegalAdviceSubtitle => 'Informational software only';

  @override
  String get settingsNoLegalAdviceP1 =>
      'This app and its documentation do not provide legal, regulatory, or professional advice.';

  @override
  String get settingsNoLegalAdviceP2 =>
      'If you need legal guidance for your use case, consult a qualified professional.';

  @override
  String get settingsCopyright => '© 2026 Spencer Beaumier';

  @override
  String get paywallTitle => 'Unlock Netpad Standard';

  @override
  String get paywallSubtitle =>
      'One-time purchase. Core editing and LAN sync stay free.';

  @override
  String get paywallBenefitUnlimitedNotes => 'Unlimited synced notes';

  @override
  String get paywallBenefitUnlimitedPeers => 'Unlimited connected peers';

  @override
  String get paywallBenefitUnlimitedLength => 'Unlimited note length';

  @override
  String get paywallBenefitSkins => 'Extra color skins';

  @override
  String get paywallBenefitHistory => 'Version history';

  @override
  String get paywallBenefitAutoSync => 'Trusted peer auto-sync';

  @override
  String get paywallBenefitVoice => 'Voice dictation';

  @override
  String get paywallPurchasesUnsupported =>
      'In-app purchases are not available on this platform. Open a store listing to unlock Standard.';

  @override
  String get paywallBuyStandard => 'Buy Standard';

  @override
  String paywallBuyStandardPrice(String price) {
    return 'Buy Standard · $price';
  }

  @override
  String get paywallGetFromStore => 'Get Standard from the store';

  @override
  String get paywallOpenAppStore => 'Open App Store';

  @override
  String get paywallOpenPlayStore => 'Open Google Play';

  @override
  String get paywallOpenMicrosoftStore => 'Open Microsoft Store';

  @override
  String get paywallCouldNotOpenStore => 'Could not open the store listing';

  @override
  String get paywallRestorePurchases => 'Restore purchases';

  @override
  String get paywallPurchaseNotCompleted => 'Purchase was not completed.';

  @override
  String get paywallPurchaseFailed => 'Purchase failed.';

  @override
  String get paywallStandardRestored => 'Standard restored';

  @override
  String get paywallNoPreviousStandard => 'No previous Standard purchase found';

  @override
  String get freeTierUsageTitle => 'Free plan usage';

  @override
  String freeTierUsageLine(
    int synced,
    int syncedLimit,
    int peers,
    int peerLimit,
    int chars,
    int charLimit,
  ) {
    return 'Synced notes $synced/$syncedLimit · Peers $peers/$peerLimit · This note $chars/$charLimit';
  }

  @override
  String standardHighlightNoteLimit(int limit) {
    return 'Free can sync up to $limit notes at a time. Unlock Standard for unlimited synced notes.';
  }

  @override
  String standardHighlightPeerLimit(int limit) {
    return 'Free includes up to $limit connected peers. Unlock Standard for unlimited peers.';
  }

  @override
  String standardHighlightCharLimit(int limit) {
    return 'Free notes are limited to $limit characters. Unlock Standard for unlimited length.';
  }

  @override
  String get standardHighlightVersionHistory =>
      'Version history is a Standard feature.';

  @override
  String get standardHighlightVoice => 'Voice dictation is a Standard feature.';

  @override
  String get standardHighlightAutoSync =>
      'Trusted peer auto-sync is a Standard feature.';

  @override
  String get standardHighlightSkins =>
      'Extra skins are included with Standard.';

  @override
  String get helpTitle => 'Help';

  @override
  String get helpIntro =>
      'A LAN notepad for plain-text notes. Devices on the same Wi‑Fi discover each other, pair once, then sync notes in real time.';

  @override
  String get helpAboutTile => 'About SB Simple Netpad';

  @override
  String get helpEulaSubtitle => 'Opens EULA on GitHub Pages';

  @override
  String get helpPrivacySubtitle => 'Opens privacy page on GitHub Pages';

  @override
  String get helpGettingStartedTitle => 'Getting started';

  @override
  String get helpGettingStarted1 =>
      'Join the same Wi‑Fi network as the devices you want to sync with.';

  @override
  String get helpGettingStarted2 =>
      'Open the Peers panel (lock icon or Peers drawer) and wait for nearby devices to appear.';

  @override
  String get helpGettingStarted3 =>
      'Copy your address from This device and share it if discovery is slow.';

  @override
  String get helpGettingStarted4 =>
      'Use Connect by IP when mDNS discovery does not find peers.';

  @override
  String get helpNotesTitle => 'Notes';

  @override
  String get helpNotes1 =>
      'Tap the menu icon (☰) or Notes panel to switch between notes.';

  @override
  String get helpNotes2 =>
      'Create, rename, reorder, and delete notes from the notes list.';

  @override
  String get helpNotes3 =>
      'Each note syncs independently — new notes start local-only; turn sync on when you want to share with peers.';

  @override
  String get helpNotes4 =>
      'Search within a note (Find) or across all notes from the editor.';

  @override
  String get helpNotes5 =>
      'Version history saves local snapshots you can restore later.';

  @override
  String get helpPeersTitle => 'Peers & pairing';

  @override
  String get helpPeers1 =>
      'Nearby lists discovered devices in the same room (see Settings).';

  @override
  String get helpPeers2 =>
      'Tap Connect on a peer — the other device must tap Accept.';

  @override
  String get helpPeers3 =>
      'Compare the pairing verification code before accepting.';

  @override
  String get helpPeers4 =>
      'Check Trust for auto-sync when accepting if you want later reconnects to skip Accept.';

  @override
  String get helpPeers5 =>
      'Trusted devices: toggle auto-sync or Revoke to require Accept again.';

  @override
  String get helpPeers6 =>
      'Block disconnects a device and refuses future pairing until unblocked.';

  @override
  String get helpPeers7 =>
      'Connected shows active sessions with address and cursor presence.';

  @override
  String get helpFileSharingTitle => 'File & sharing';

  @override
  String get helpFileSharing1Desktop =>
      'File menu: Save to File, Open File as New Note, Share Note, Version History, Settings, Exit.';

  @override
  String get helpFileSharing1Macos =>
      'File menu: Save to File, Open File as New Note, Share Note, Version History. Settings are under the app menu (Cmd+,); Quit ends the app.';

  @override
  String get helpFileSharing1Mobile =>
      'Overflow menu (⋮): save to file, open file as new note, share, version history, settings, and this help guide.';

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
  String get helpFileSharing4 =>
      'Share uses the OS share sheet when available; otherwise the note is copied to the clipboard.';

  @override
  String get helpSettingsTitle => 'Settings';

  @override
  String get helpSettings1 =>
      'Device name and room require Save — other options apply immediately.';

  @override
  String get helpSettings2 =>
      'Room ID groups peers: only devices in the same room are discovered.';

  @override
  String get helpSettings3 =>
      'Appearance and editor preferences (theme, skin, wrap, font) save as you change them.';

  @override
  String get helpDesktopShortcutsTitle => 'Desktop shortcuts';

  @override
  String get helpDesktopShortcuts1 => 'Ctrl/Cmd+S — Save to file';

  @override
  String get helpDesktopShortcuts2 => 'Ctrl/Cmd+O — Open file as new note';

  @override
  String get helpDesktopShortcuts3 => 'Ctrl/Cmd+F — Find in note';

  @override
  String get helpDesktopShortcuts4 =>
      'Ctrl+H (Windows) or Option+Cmd+F (macOS) — Find and replace';

  @override
  String get helpDesktopShortcuts5 => 'Ctrl/Cmd+N — Toggle notes panel';

  @override
  String get helpDesktopShortcuts6 => 'Ctrl/Cmd+P — Toggle peers panel';

  @override
  String get helpDesktopShortcuts7 =>
      'Ctrl/Cmd+Q — Exit (Windows); macOS uses Quit from the app menu';

  @override
  String get helpTroubleshootingTitle => 'Troubleshooting';

  @override
  String get helpTroubleshooting1 =>
      'No peers? Confirm same Wi‑Fi subnet and room ID; try Connect by IP.';

  @override
  String get helpTroubleshooting2 =>
      'Local network required banner means sync is paused until Wi‑Fi is up.';

  @override
  String get helpTroubleshooting3 =>
      'Allow the app through your firewall on first launch (desktop).';

  @override
  String get helpTroubleshooting4 =>
      'Ensure all devices are on the same Wi‑Fi subnet and that local network / firewall settings allow discovery.';

  @override
  String get helpTroubleshooting5 =>
      'Android: grant nearby Wi‑Fi permission when prompted.';

  @override
  String get helpTroubleshooting6 =>
      'iOS/macOS: allow Local Network access for SB Simple Netpad in System Settings if peers never appear.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutTagline =>
      'LAN notepad with peer discovery and shared editing.';

  @override
  String get aboutDescription =>
      'Write plain-text notes on your phone or computer and keep them in sync with other devices on the same Wi‑Fi. Peers discover each other on the local network, pair once with mutual approval, then share multiple named notes with encrypted peer sessions.';

  @override
  String get aboutPlatforms => 'Android · iOS · Windows · macOS';

  @override
  String get aboutStatus => 'Suitable for daily LAN use.';

  @override
  String get aboutEulaHeading => 'End User License Agreement';

  @override
  String aboutEulaBody(int noteLimit, int peerLimit) {
    return 'SB Simple Netpad is licensed under an EULA, not an open-source license. Core editing and LAN sync are free (unlimited local notes, up to $noteLimit synced notes and $peerLimit connected peers). Netpad Standard is a one-time unlock via the App Store, Google Play, or Microsoft Store.';
  }

  @override
  String get aboutViewEula => 'View EULA';

  @override
  String get aboutPrivacyPolicy => 'Privacy Policy';

  @override
  String get aboutHowToUse => 'How to use SB Simple Netpad';

  @override
  String get aboutCouldNotOpenPrivacy => 'Could not open privacy policy';

  @override
  String get aboutCouldNotOpenEula => 'Could not open EULA';

  @override
  String get aboutCopyright => '© 2026 Spencer Beaumier';

  @override
  String conflictLiveTitle(String title) {
    return 'Edit conflict in \"$title\"';
  }

  @override
  String conflictLiveBody(
    String peer,
    String revision,
    String localPreview,
    String remotePreview,
  ) {
    return '$peer edited the same note at the same time (revision $revision).\n\nYours:\n$localPreview\n\n$peer:\n$remotePreview\n\nWhich version should both devices keep?';
  }

  @override
  String conflictDivergedTitle(String title) {
    return '\"$title\" has diverged';
  }

  @override
  String conflictDivergedBody(
    String peer,
    String title,
    int localChars,
    int remoteChars,
  ) {
    return 'Your copy and $peer\'s copy of \"$title\" changed differently while disconnected.\n\nYours: $localChars characters\n$peer: $remoteChars characters\n\nWhich version should both devices keep?';
  }

  @override
  String conflictUsePeers(String peer) {
    return 'Use $peer\'s';
  }

  @override
  String get conflictKeepMine => 'Keep mine';

  @override
  String fileSavedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String fileCouldNotSave(String error) {
    return 'Could not save: $error';
  }

  @override
  String fileOpenedAsNewNote(String name) {
    return 'Opened $name as a new note';
  }

  @override
  String fileCouldNotOpen(String error) {
    return 'Could not open: $error';
  }

  @override
  String get fileNothingToShare => 'Nothing to share — the note is empty';

  @override
  String get fileShareFallbackClipboard =>
      'Sharing not available here — copied to clipboard';

  @override
  String get fileDefaultNoteName => 'netpad-note';
}
