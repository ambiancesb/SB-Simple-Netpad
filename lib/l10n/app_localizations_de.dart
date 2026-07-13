// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get commonAppName => 'SB Simple Netpad';

  @override
  String get commonStandardName => 'Netpad Standard';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonConnect => 'Verbinden';

  @override
  String get commonHelp => 'Hilfe';

  @override
  String get commonSettings => 'Einstellungen';

  @override
  String get commonMore => 'Mehr';

  @override
  String get commonCopy => 'Kopieren';

  @override
  String get commonClear => 'Leeren';

  @override
  String get commonAccept => 'Akzeptieren';

  @override
  String get commonReject => 'Ablehnen';

  @override
  String get commonBlock => 'Sperren';

  @override
  String get commonUnblock => 'Entsperren';

  @override
  String get commonRevoke => 'Widerrufen';

  @override
  String get commonRestore => 'Wiederherstellen';

  @override
  String get commonRetry => 'Wiederholen';

  @override
  String commonCouldNotOpenLabel(String label) {
    return '$label konnte nicht geöffnet werden';
  }

  @override
  String get commonEulaLabel => 'EULA';

  @override
  String get commonPrivacyPolicyLabel => 'Datenschutzrichtlinie';

  @override
  String get commonEndUserLicenseAgreement => 'Endbenutzer-Lizenzvertrag';

  @override
  String get commonPrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String commonVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get shellMenuFile => 'Datei';

  @override
  String get shellMenuEdit => 'Bearbeiten';

  @override
  String get shellMenuView => 'Ansicht';

  @override
  String get shellMenuHelp => 'Hilfe';

  @override
  String get shellSaveToFile => 'In Datei speichern…';

  @override
  String get shellOpenFileAsNewNote => 'Datei als neue Notiz öffnen…';

  @override
  String get shellShareNote => 'Notiz teilen';

  @override
  String get shellVersionHistory => 'Versionsverlauf…';

  @override
  String get shellSettings => 'Einstellungen…';

  @override
  String get shellExit => 'Beenden';

  @override
  String get shellCut => 'Ausschneiden';

  @override
  String get shellCopy => 'Kopieren';

  @override
  String get shellPaste => 'Einfügen';

  @override
  String get shellFind => 'Suchen…';

  @override
  String get shellFindAndReplace => 'Suchen und Ersetzen…';

  @override
  String get shellWordWrap => 'Zeilenumbruch';

  @override
  String get shellWordWrapChecked => 'Zeilenumbruch ✓';

  @override
  String get shellNotesPanel => 'Notizenbereich';

  @override
  String get shellNotesPanelChecked => 'Notizenbereich ✓';

  @override
  String get shellPeersPanel => 'Peer-Bereich';

  @override
  String get shellPeersPanelChecked => 'Peer-Bereich ✓';

  @override
  String get shellHelpItem => 'SB Simple Netpad Hilfe';

  @override
  String get shellAboutItem => 'Über SB Simple Netpad';

  @override
  String get shellHideNotesPanel => 'Notizenbereich ausblenden';

  @override
  String get shellShowNotesPanel => 'Notizenbereich anzeigen (Ctrl+N)';

  @override
  String get shellHidePeersPanel => 'Peer-Bereich ausblenden';

  @override
  String get shellShowPeersPanel => 'Peer-Bereich anzeigen (Ctrl+P)';

  @override
  String shellPeersTooltipConnected(int count, String action) {
    return '$count verschlüsselte Peer-Sitzungen · Peer-Bereich $action (Ctrl+P)';
  }

  @override
  String get shellPeersTooltipActionHide => 'ausblenden';

  @override
  String get shellPeersTooltipActionShow => 'anzeigen';

  @override
  String get shellFindInNote => 'In Notiz suchen (Ctrl+F)';

  @override
  String shellSecurityChipConnected(int count) {
    return '$count Peer-Sitzungen mit WSS/TLS verschlüsselt · tippen für Peers';
  }

  @override
  String get shellSecurityChipNone =>
      'Keine aktiven Peer-Sitzungen · tippen für Peers';

  @override
  String get shellMobileWordWrap => 'Zeilenumbruch';

  @override
  String get shellMobileSaveToFile => 'In Datei speichern…';

  @override
  String get shellMobileOpenFileAsNewNote => 'Datei als neue Notiz öffnen…';

  @override
  String get shellMobileShareNote => 'Notiz teilen';

  @override
  String get shellMobileVersionHistory => 'Versionsverlauf…';

  @override
  String get shellMobileSettings => 'Einstellungen';

  @override
  String get shellMobileHelp => 'Hilfe';

  @override
  String get shellMobileAbout => 'Über SB Simple Netpad';

  @override
  String get shellListeningSnack =>
      'Aufnahme läuft… tippe erneut auf das Mikrofon, um zu stoppen';

  @override
  String get notesTitle => 'Notizen';

  @override
  String get notesNewNote => 'Neue Notiz';

  @override
  String get notesSearchHint => 'Alle Notizen durchsuchen';

  @override
  String get notesRenameTitle => 'Notiz umbenennen';

  @override
  String get notesTitleLabel => 'Titel';

  @override
  String notesDeleteTitle(String title) {
    return '\"$title\" löschen?';
  }

  @override
  String get notesDeleteSyncedBody =>
      'Dadurch wird die Notiz für Sie und alle verbundenen Peers entfernt.';

  @override
  String get notesDeleteLocalBody =>
      'Dadurch wird die Notiz nur von diesem Gerät entfernt.';

  @override
  String get notesNoMatches => 'Keine Treffer';

  @override
  String get notesNoNotes => 'Keine Notizen';

  @override
  String get notesRename => 'Umbenennen';

  @override
  String get notesVersionHistory => 'Versionsverlauf';

  @override
  String get notesDelete => 'Löschen';

  @override
  String get notesSyncWithPeers => 'Mit Peers synchronisieren';

  @override
  String get notesLocalOnly => 'Nur lokal';

  @override
  String get notesEmptyNote => 'Leere Notiz';

  @override
  String notesMatchCount(int count) {
    return '$count Treffer';
  }

  @override
  String notesLocalOnlyWithMatches(String matchLine) {
    return 'Nur lokal · $matchLine';
  }

  @override
  String notesSearchSnippetMatches(String snippet, int count) {
    return '$snippet  ·  $count Treffer';
  }

  @override
  String get notesNoNoteSelected => 'Keine Notiz ausgewählt';

  @override
  String historyTitle(String title) {
    return 'Versionsverlauf · \"$title\"';
  }

  @override
  String get historyEmpty =>
      'Noch keine gespeicherten Versionen. Snapshots werden automatisch gespeichert, bevor Remote-Bearbeitungen Ihren Text ersetzen.';

  @override
  String historyEntrySubtitle(String label, String time, int chars) {
    return '$label · $time · $chars Zeichen';
  }

  @override
  String get historyRestore => 'Wiederherstellen';

  @override
  String get historyRestoredSnack => 'Version wiederhergestellt';

  @override
  String get historyBeforeRemoteUpdate => 'Vor Remote-Update';

  @override
  String get historySnapshot => 'Snapshot';

  @override
  String get historyImportedFile => 'Importierte Datei';

  @override
  String get editorFindHint => 'Suchen';

  @override
  String get editorReplaceHint => 'Ersetzen durch';

  @override
  String editorMatchCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get editorMatchNone => '0/0';

  @override
  String get editorPrevious => 'Vorheriger';

  @override
  String get editorNext => 'Nächster';

  @override
  String get editorShowReplace => 'Ersetzen anzeigen (Ctrl+H)';

  @override
  String get editorHideReplace => 'Ersetzen ausblenden (Ctrl+H)';

  @override
  String get editorClose => 'Schließen';

  @override
  String get editorReplace => 'Ersetzen';

  @override
  String get editorReplaceAll => 'Alle';

  @override
  String get editorListening => 'Aufnahme läuft…';

  @override
  String get editorDictate => 'Diktieren';

  @override
  String get editorStopDictation => 'Diktat stoppen';

  @override
  String get peersConnectByIp => 'Per IP verbinden';

  @override
  String get peersConnected => 'Verbunden';

  @override
  String get peersNearby => 'In der Nähe';

  @override
  String get peersTrustedDevices => 'Vertrauenswürdige Geräte';

  @override
  String get peersBlocked => 'Gesperrt';

  @override
  String get peersConnectionLog => 'Verbindungsprotokoll';

  @override
  String get peersNoActiveConnections => 'Keine aktiven Verbindungen';

  @override
  String get peersNoTrustedDevices =>
      'Keine vertrauenswürdigen Geräte — bei Akzeptieren „Für Auto-Sync vertrauen“ aktivieren';

  @override
  String get peersNoBlockedDevices => 'Keine gesperrten Geräte';

  @override
  String get peersNoConnectionEvents => 'Noch keine Verbindungsereignisse';

  @override
  String get peersNoDiscoveredPeers =>
      'Keine Peers gefunden — Linux muss sich im gleichen Wi‑Fi-Subnetz wie Dieses Gerät befinden (Adresse oben prüfen), oder Per IP verbinden verwenden';

  @override
  String get peersDiscoveryPaused =>
      'Peer-Erkennung ist pausiert, bis Sie einem lokalen Netzwerk beitreten';

  @override
  String get peersDisconnect => 'Trennen';

  @override
  String get peersConnectNow => 'Jetzt verbinden';

  @override
  String get peersConnect => 'Verbinden';

  @override
  String get peersResolving => 'Wird aufgelöst…';

  @override
  String get peersBlockTooltip => 'Sperren';

  @override
  String peersBlockTitle(String peer) {
    return '$peer sperren?';
  }

  @override
  String get peersBlockBody =>
      'Dadurch wird das Gerät getrennt, sein angeheftetes Zertifikat vergessen und zukünftige Verbindungsanfragen abgelehnt, bis Sie es entsperren.';

  @override
  String peersRevokeTitle(String peer) {
    return '$peer widerrufen?';
  }

  @override
  String get peersRevokeBody =>
      'Die nächste Verbindung erfordert erneutes Tippen auf Akzeptieren. Der Sicherheits-PIN bleibt erhalten, sodass Zertifikatsprüfungen weiterhin gelten.';

  @override
  String get peersAutoSync => 'Automatische Synchronisierung';

  @override
  String get peersCopiedOneLogEntry => '1 Protokolleintrag kopiert';

  @override
  String peersCopiedLogEntries(int count) {
    return '$count Protokolleinträge kopiert';
  }

  @override
  String peersLogRevision(String time, String revision) {
    return '$time • Revision $revision';
  }

  @override
  String peersStillResolving(String peer) {
    return '$peer wird noch aufgelöst…';
  }

  @override
  String peersResolveFailedSnack(String peer) {
    return '$peer konnte nicht aufgelöst werden. Avahi und gleiches Subnetz prüfen, oder Per IP verbinden verwenden.';
  }

  @override
  String peersPairingRequestSent(String peer) {
    return 'Kopplungsanfrage an $peer gesendet';
  }

  @override
  String peersCouldNotConnect(String message) {
    return 'Verbindung fehlgeschlagen: $message';
  }

  @override
  String peersManualHostPort(String host, int port) {
    return '$host:$port (manuell)';
  }

  @override
  String get peersManual => 'Manuell';

  @override
  String get peersResolveFailedSubtitle =>
      'Auflösung fehlgeschlagen — Per IP verbinden versuchen';

  @override
  String get peersResolvingAddress => 'Adresse wird aufgelöst…';

  @override
  String peersHostPort(String host, int port) {
    return '$host:$port';
  }

  @override
  String get peersNoAddressYet => 'Noch keine Adresse';

  @override
  String peersEncryptedPinned(String code) {
    return 'Verschlüsselt · angeheftet $code';
  }

  @override
  String get peersEncryptedWss => 'Verschlüsselt (WSS/TLS)';

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
    return 'Gekoppelt $date · $status';
  }

  @override
  String get peersStatusConnected => 'Verbunden';

  @override
  String get peersStatusManualOnly => 'Nur manuell';

  @override
  String get peersStatusReconnecting => 'Verbindung wird wiederhergestellt…';

  @override
  String peersStatusRetryIn(int seconds) {
    return 'Wiederholen in ${seconds}s';
  }

  @override
  String get peersStatusNotOnNetwork => 'Nicht im Netzwerk';

  @override
  String get peersStatusConnecting => 'Verbindung wird hergestellt…';

  @override
  String get peersStatusAutoReconnect => 'Automatisch verbinden';

  @override
  String peersPresenceLineCol(int line, int column) {
    return 'Zeile $line, Sp. $column';
  }

  @override
  String peersPresenceInNote(String title, String position) {
    return '\"$title\" · $position';
  }

  @override
  String peersRoomLabel(String room) {
    return 'Raum \"$room\"';
  }

  @override
  String get discoveryThisDevice => 'Dieses Gerät';

  @override
  String get discoveryCopyAddress => 'Adresse kopieren';

  @override
  String discoveryCopiedAddress(String address) {
    return 'Kopiert $address';
  }

  @override
  String get discoveryLocalNetworkRequired => 'Lokales Netzwerk erforderlich';

  @override
  String get discoveryNotListeningTitle => 'Nicht aktiv';

  @override
  String get discoveryNotListeningBody =>
      'Dieses Gerät lauscht noch nicht nach Peers. Warten Sie einige Sekunden nach dem Wi‑Fi-Beitritt, oder tippen Sie auf Wiederholen bei einem Netzwerkfehler-Banner.';

  @override
  String get discoveryModeTitle => 'Erkennungsmodus';

  @override
  String get discoveryUnavailableTitle => 'Peer-Erkennung nicht verfügbar';

  @override
  String get discoveryRetryTooltip => 'Erkennung wiederholen';

  @override
  String get peersSecuredSessions => 'Gesicherte Sitzungen';

  @override
  String peersSecurityBannerIdle(String code) {
    return 'Dieses Gerät kündigt über WSS/TLS an · Code $code';
  }

  @override
  String peersSecurityBannerActive(int connectedCount, int pinnedCount) {
    return '$connectedCount verschlüsselte Sitzungen · $pinnedCount Zertifikate angeheftet';
  }

  @override
  String peersSecurityCompactIdle(String code) {
    return 'WSS/TLS · Code $code';
  }

  @override
  String peersSecurityCompactActive(int connectedCount, int pinnedCount) {
    return '$connectedCount verschlüsselt · $pinnedCount angeheftet';
  }

  @override
  String peersSecurityTooltipPinned(String code) {
    return 'Verschlüsselt (WSS/TLS) · angeheftet $code';
  }

  @override
  String get peersSecurityTooltipActive =>
      'Verschlüsselt (WSS/TLS) · aktive Sitzung';

  @override
  String get pairingConnectionRequest => 'Verbindungsanfrage';

  @override
  String pairingAllowPeer(String peer) {
    return '$peer erlauben, sich zu verbinden und diese Notiz zu teilen?';
  }

  @override
  String get pairingVerificationCode => 'Bestätigungscode';

  @override
  String get pairingConfirmCode =>
      'Bestätigen Sie, dass dieser Code auf beiden Geräten übereinstimmt, bevor Sie akzeptieren.';

  @override
  String get pairingThisDeviceSecurityCode => 'Sicherheitscode dieses Geräts';

  @override
  String get pairingOtherDevicePins =>
      'Das andere Gerät heftet dies bei der ersten Verbindung an.';

  @override
  String get pairingTrustForAutoSync => 'Für Auto-Sync vertrauen';

  @override
  String get pairingTrustForAutoSyncHint =>
      'Accept bei späteren Verbindungen überspringen. Optional — deaktiviert lassen, um jedes Mal Accept zu verlangen.';

  @override
  String get manualConnectTitle => 'Per Adresse verbinden';

  @override
  String get manualConnectBody =>
      'Verwenden Sie dies, wenn die Erkennung keine Peers im gleichen Subnetz findet. Nur Adressen in Ihrem aktiven lokalen Netzwerksegment sind zulässig.';

  @override
  String get manualConnectHostLabel => 'Host oder IP';

  @override
  String get manualConnectHostHint => '192.168.1.42';

  @override
  String get manualConnectPortLabel => 'Port';

  @override
  String get manualConnectPortHint => '54321';

  @override
  String get manualConnectLabelOptional => 'Bezeichnung (optional)';

  @override
  String get manualConnectLabelHint => 'Wohnzimmer-PC';

  @override
  String get manualConnectInvalidHostPort =>
      'Gültigen Host und Port eingeben (1–65535)';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsDeviceSection => 'Gerät';

  @override
  String get settingsDeviceHint =>
      'Gerätename und Raum erfordern Speichern (Ctrl+S). Darstellungs- und Editoreinstellungen werden sofort gespeichert.';

  @override
  String get settingsDeviceName => 'Gerätename';

  @override
  String get settingsDeviceNameHint =>
      'Name, der anderen Geräten angezeigt wird';

  @override
  String get settingsSessionRoom => 'Sitzung / Raum';

  @override
  String get settingsSessionRoomHint =>
      'Nur Peers im gleichen Raum werden erkannt';

  @override
  String get settingsListeningPort => 'Lauschport';

  @override
  String get settingsStartingServer => 'Server wird gestartet…';

  @override
  String settingsAddressShare(String address) {
    return '$address (für manuelle Verbindung teilen)';
  }

  @override
  String get settingsCopyAddress => 'Adresse kopieren';

  @override
  String get settingsAddressCopied => 'Adresse in Zwischenablage kopiert';

  @override
  String settingsSavedSnack(String name, String room) {
    return 'Einstellungen gespeichert · \"$name\" · Raum \"$room\"';
  }

  @override
  String get settingsAppearanceSection => 'Darstellung';

  @override
  String get settingsMode => 'Modus';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsSkin => 'Design';

  @override
  String get settingsSkinDefault => 'Standard';

  @override
  String get settingsSkinOcean => 'Ozean';

  @override
  String get settingsSkinForest => 'Wald';

  @override
  String get settingsSkinSunset => 'Sonnenuntergang';

  @override
  String get settingsSkinSlate => 'Schiefer';

  @override
  String settingsSkinStandardLabel(String skin) {
    return '$skin · Standard';
  }

  @override
  String get settingsStandardSection => 'Netpad Standard';

  @override
  String get settingsStandardUnlocked => 'Standard freigeschaltet';

  @override
  String get settingsFree => 'Kostenlos';

  @override
  String get settingsStandardUnlockedSubtitle =>
      'Unbegrenzte synchronisierte Notizen und Peers, Designs, Verlauf, automatische Synchronisierung und Sprache';

  @override
  String get settingsStandardBuySubtitle =>
      'Einmalige Freischaltung über Ihren App-Store';

  @override
  String get settingsPurchasesUnavailable =>
      'Käufe auf dieser Plattform nicht verfügbar';

  @override
  String get settingsRestorePurchases => 'Käufe wiederherstellen';

  @override
  String get settingsStandardRestored => 'Standard wiederhergestellt';

  @override
  String get settingsNoPreviousStandard =>
      'Kein früherer Standard-Kauf gefunden';

  @override
  String get settingsEditorSection => 'Editor';

  @override
  String get settingsWordWrap => 'Zeilenumbruch';

  @override
  String get settingsWordWrapSubtitle =>
      'Lange Zeilen umbrechen statt horizontal scrollen';

  @override
  String settingsFontSize(int size) {
    return 'Schriftgröße ($size pt)';
  }

  @override
  String get settingsLegalSection => 'Rechtliches';

  @override
  String get settingsEulaSubtitleStandard =>
      'Standard · Öffnet EULA auf GitHub Pages';

  @override
  String get settingsEulaSubtitleFree =>
      'Kostenlos · Öffnet EULA auf GitHub Pages';

  @override
  String get settingsPrivacySubtitle =>
      'Öffnet Datenschutzseite auf GitHub Pages';

  @override
  String get settingsDisclaimerTitle => 'Haftungsausschluss und Haftung';

  @override
  String get settingsDisclaimerSubtitle => 'Verwendung auf eigenes Risiko';

  @override
  String get settingsDisclaimerP1 =>
      'Diese Software wird \"wie besehen\" ohne Garantien jeglicher Art bereitgestellt, weder ausdrücklich noch stillschweigend, einschließlich Marktgängigkeit, Eignung für einen bestimmten Zweck und Nichtverletzung.';

  @override
  String get settingsDisclaimerP2 =>
      'Sie sind allein verantwortlich für die Art und Weise, wie Sie diese App verwenden, und für die Einhaltung aller geltenden Gesetze, Vorschriften, Richtlinien und Vereinbarungen.';

  @override
  String get settingsDisclaimerP3 =>
      'Der Urheberrechtsinhaber haftet nicht für Ansprüche, Schäden, Verluste, Datenverlust, Betriebsunterbrechungen oder andere Haftung, die aus der Nutzung oder dem Missbrauch dieser Software entstehen.';

  @override
  String get settingsNoLegalAdviceTitle => 'Kein Rechtsrat';

  @override
  String get settingsNoLegalAdviceSubtitle => 'Nur informative Software';

  @override
  String get settingsNoLegalAdviceP1 =>
      'Diese App und ihre Dokumentation bieten keine rechtliche, regulatorische oder professionelle Beratung.';

  @override
  String get settingsNoLegalAdviceP2 =>
      'Wenn Sie rechtliche Beratung für Ihren Anwendungsfall benötigen, wenden Sie sich an einen qualifizierten Fachmann.';

  @override
  String get settingsCopyright => '© 2026 Spencer Beaumier';

  @override
  String get paywallTitle => 'Netpad Standard freischalten';

  @override
  String get paywallSubtitle =>
      'Einmaliger Kauf. Grundlegende Bearbeitung und LAN-Synchronisierung bleiben kostenlos.';

  @override
  String get paywallBenefitUnlimitedNotes =>
      'Unbegrenzt synchronisierte Notizen';

  @override
  String get paywallBenefitUnlimitedPeers => 'Unbegrenzte verbundene Peers';

  @override
  String get paywallBenefitSkins => 'Zusätzliche Farbdesigns';

  @override
  String get paywallBenefitHistory => 'Versionsverlauf';

  @override
  String get paywallBenefitAutoSync =>
      'Automatische Synchronisierung vertrauenswürdiger Peers';

  @override
  String get paywallBenefitVoice => 'Sprachdiktat';

  @override
  String get paywallPurchasesUnsupported =>
      'In-App-Käufe sind auf dieser Plattform nicht verfügbar. Installieren Sie aus dem App Store, Google Play oder Microsoft Store, um Standard freizuschalten.';

  @override
  String get paywallBuyStandard => 'Standard kaufen';

  @override
  String paywallBuyStandardPrice(String price) {
    return 'Standard kaufen · $price';
  }

  @override
  String get paywallRestorePurchases => 'Käufe wiederherstellen';

  @override
  String get paywallPurchaseNotCompleted => 'Kauf wurde nicht abgeschlossen.';

  @override
  String get paywallPurchaseFailed => 'Kauf fehlgeschlagen.';

  @override
  String get paywallStandardRestored => 'Standard wiederhergestellt';

  @override
  String get paywallNoPreviousStandard =>
      'Kein früherer Standard-Kauf gefunden';

  @override
  String standardHighlightNoteLimit(int limit) {
    return 'Die kostenlose Version kann bis zu $limit Notizen gleichzeitig synchronisieren. Schalten Sie Standard für unbegrenzte Sync-Notizen frei.';
  }

  @override
  String standardHighlightPeerLimit(int limit) {
    return 'Die kostenlose Version enthält bis zu $limit verbundene Peers. Schalten Sie Standard für unbegrenzte Peers frei.';
  }

  @override
  String get standardHighlightVersionHistory =>
      'Versionsverlauf ist eine Standard-Funktion.';

  @override
  String get standardHighlightVoice =>
      'Sprachdiktat ist eine Standard-Funktion.';

  @override
  String get standardHighlightAutoSync =>
      'Automatische Synchronisierung vertrauenswürdiger Peers ist eine Standard-Funktion.';

  @override
  String get standardHighlightSkins =>
      'Zusätzliche Designs sind in Standard enthalten.';

  @override
  String get helpTitle => 'Hilfe';

  @override
  String get helpIntro =>
      'Ein LAN-Notizblock für reine Textnotizen. Geräte im gleichen Wi‑Fi entdecken einander, koppeln einmalig und synchronisieren Notizen dann in Echtzeit.';

  @override
  String get helpAboutTile => 'Über SB Simple Netpad';

  @override
  String get helpEulaSubtitle => 'Öffnet EULA auf GitHub Pages';

  @override
  String get helpPrivacySubtitle => 'Öffnet Datenschutzseite auf GitHub Pages';

  @override
  String get helpGettingStartedTitle => 'Erste Schritte';

  @override
  String get helpGettingStarted1 =>
      'Verbinden Sie sich mit dem gleichen Wi‑Fi-Netzwerk wie die Geräte, mit denen Sie synchronisieren möchten.';

  @override
  String get helpGettingStarted2 =>
      'Öffnen Sie den Peer-Bereich (Schloss-Symbol oder Peers-Schublade) und warten Sie, bis Geräte in der Nähe erscheinen.';

  @override
  String get helpGettingStarted3 =>
      'Kopieren Sie Ihre Adresse von Dieses Gerät und teilen Sie sie, wenn die Erkennung langsam ist.';

  @override
  String get helpGettingStarted4 =>
      'Verwenden Sie Per IP verbinden, wenn die mDNS-Erkennung keine Peers findet.';

  @override
  String get helpNotesTitle => 'Notizen';

  @override
  String get helpNotes1 =>
      'Tippen Sie auf das Menüsymbol (☰) oder den Notizenbereich, um zwischen Notizen zu wechseln.';

  @override
  String get helpNotes2 =>
      'Erstellen, umbenennen, neu anordnen und löschen Sie Notizen aus der Notizenliste.';

  @override
  String get helpNotes3 =>
      'Jede Notiz synchronisiert unabhängig — neue Notizen starten lokal; aktivieren Sie Sync, um mit Peers zu teilen.';

  @override
  String get helpNotes4 =>
      'Suchen Sie innerhalb einer Notiz (Suchen) oder über alle Notizen im Editor.';

  @override
  String get helpNotes5 =>
      'Der Versionsverlauf speichert lokale Snapshots, die Sie später wiederherstellen können.';

  @override
  String get helpPeersTitle => 'Peers und Kopplung';

  @override
  String get helpPeers1 =>
      'In der Nähe listet entdeckte Geräte im gleichen Raum auf (siehe Einstellungen).';

  @override
  String get helpPeers2 =>
      'Tippen Sie auf Verbinden bei einem Peer — das andere Gerät muss auf Akzeptieren tippen.';

  @override
  String get helpPeers3 =>
      'Vergleichen Sie den Kopplungsbestätigungscode vor dem Akzeptieren.';

  @override
  String get helpPeers4 =>
      'Aktivieren Sie „Für Auto-Sync vertrauen“ beim Akzeptieren, wenn spätere Verbindungen Accept überspringen sollen.';

  @override
  String get helpPeers5 =>
      'Vertrauenswürdige Geräte: automatische Synchronisierung umschalten oder Widerrufen, um erneut Akzeptieren zu erfordern.';

  @override
  String get helpPeers6 =>
      'Sperren trennt ein Gerät und verweigert zukünftige Kopplung bis zum Entsperren.';

  @override
  String get helpPeers7 =>
      'Verbunden zeigt aktive Sitzungen mit Adresse und Cursor-Präsenz.';

  @override
  String get helpFileSharingTitle => 'Dateien und Teilen';

  @override
  String get helpFileSharing1Desktop =>
      'Dateimenü: In Datei speichern, Datei als neue Notiz öffnen, Notiz teilen, Versionsverlauf, Einstellungen, Beenden.';

  @override
  String get helpFileSharing1Mobile =>
      'Überlaufmenü (⋮): In Datei speichern, Datei als neue Notiz öffnen, Teilen, Versionsverlauf, Einstellungen und dieser Hilfeleitfaden.';

  @override
  String get helpFileSharing2 =>
      'In Datei speichern exportiert die aktive Notiz als .txt oder .md.';

  @override
  String get helpFileSharing3 =>
      'Datei öffnen importiert Text in eine neue lokale Notiz; Sync aktivieren, wenn Peers sie erhalten sollen.';

  @override
  String get helpFileSharing4 =>
      'Teilen verwendet die OS-Teilen-Oberfläche; Linux weicht auf die Zwischenablage aus.';

  @override
  String get helpSettingsTitle => 'Einstellungen';

  @override
  String get helpSettings1 =>
      'Gerätename und Raum erfordern Speichern — andere Optionen werden sofort angewendet.';

  @override
  String get helpSettings2 =>
      'Raum-ID gruppiert Peers: nur Geräte im gleichen Raum werden erkannt.';

  @override
  String get helpSettings3 =>
      'Darstellungs- und Editoreinstellungen (Design, Skin, Umbruch, Schrift) werden beim Ändern gespeichert.';

  @override
  String get helpDesktopShortcutsTitle => 'Desktop-Tastenkürzel';

  @override
  String get helpDesktopShortcuts1 => 'Ctrl/Cmd+S — In Datei speichern';

  @override
  String get helpDesktopShortcuts2 =>
      'Ctrl/Cmd+O — Datei als neue Notiz öffnen';

  @override
  String get helpDesktopShortcuts3 => 'Ctrl/Cmd+F — In Notiz suchen';

  @override
  String get helpDesktopShortcuts4 => 'Ctrl/Cmd+H — Suchen und Ersetzen';

  @override
  String get helpDesktopShortcuts5 => 'Ctrl/Cmd+N — Notizenbereich umschalten';

  @override
  String get helpDesktopShortcuts6 => 'Ctrl/Cmd+P — Peer-Bereich umschalten';

  @override
  String get helpDesktopShortcuts7 => 'Ctrl/Cmd+Q — Beenden (Windows/Linux)';

  @override
  String get helpTroubleshootingTitle => 'Fehlerbehebung';

  @override
  String get helpTroubleshooting1 =>
      'Keine Peers? Gleiches Wi‑Fi-Subnetz und Raum-ID bestätigen; Per IP verbinden versuchen.';

  @override
  String get helpTroubleshooting2 =>
      'Das Banner lokales Netzwerk erforderlich bedeutet, dass die Synchronisierung pausiert, bis Wi‑Fi aktiv ist.';

  @override
  String get helpTroubleshooting3 =>
      'App beim ersten Start durch Ihre Firewall erlauben (Desktop).';

  @override
  String get helpTroubleshooting4 =>
      'Linux: dbus und avahi-daemon installieren, wenn die Erkennung nie startet.';

  @override
  String get helpTroubleshooting5 =>
      'Android: Wi‑Fi in der Nähe-Berechtigung erteilen, wenn aufgefordert.';

  @override
  String get aboutTitle => 'Über';

  @override
  String get aboutTagline =>
      'LAN-Notizblock mit Peer-Erkennung und gemeinsamem Bearbeiten.';

  @override
  String get aboutDescription =>
      'Schreiben Sie reine Textnotizen auf Ihrem Telefon oder Computer und halten Sie sie mit anderen Geräten im gleichen Wi‑Fi synchronisiert. Peers entdecken einander im lokalen Netzwerk, koppeln einmalig mit gegenseitiger Genehmigung und teilen dann mehrere benannte Notizen mit verschlüsselten Peer-Sitzungen.';

  @override
  String get aboutPlatforms => 'Android · iOS · Windows · macOS · Linux';

  @override
  String get aboutStatus => 'Beta — geeignet für den täglichen LAN-Einsatz.';

  @override
  String get aboutEulaHeading => 'Endbenutzer-Lizenzvertrag';

  @override
  String aboutEulaBody(int noteLimit, int peerLimit) {
    return 'SB Simple Netpad ist unter einem EULA lizenziert, nicht unter einer Open-Source-Lizenz. Grundlegende Bearbeitung und LAN-Synchronisierung sind kostenlos (unbegrenzte lokale Notizen, bis zu $noteLimit synchronisierte Notizen und $peerLimit verbundene Peers). Netpad Standard ist eine einmalige Freischaltung über App Store, Google Play oder Microsoft Store.';
  }

  @override
  String get aboutViewEula => 'EULA anzeigen';

  @override
  String get aboutPrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get aboutHowToUse => 'So verwenden Sie SB Simple Netpad';

  @override
  String get aboutCouldNotOpenPrivacy =>
      'Datenschutzrichtlinie konnte nicht geöffnet werden';

  @override
  String get aboutCouldNotOpenEula => 'EULA konnte nicht geöffnet werden';

  @override
  String get aboutCopyright => '© 2026 Spencer Beaumier';

  @override
  String conflictLiveTitle(String title) {
    return 'Bearbeitungskonflikt in \"$title\"';
  }

  @override
  String conflictLiveBody(
    String peer,
    String revision,
    String localPreview,
    String remotePreview,
  ) {
    return '$peer hat die gleiche Notiz zur gleichen Zeit bearbeitet (Revision $revision).\n\nIhre Version:\n$localPreview\n\n$peer:\n$remotePreview\n\nWelche Version sollen beide Geräte behalten?';
  }

  @override
  String conflictDivergedTitle(String title) {
    return '\"$title\" hat sich verzweigt';
  }

  @override
  String conflictDivergedBody(
    String peer,
    String title,
    int localChars,
    int remoteChars,
  ) {
    return 'Ihre Kopie und die Kopie von $peer von \"$title\" wurden während der Trennung unterschiedlich geändert.\n\nIhre Version: $localChars Zeichen\n$peer: $remoteChars Zeichen\n\nWelche Version sollen beide Geräte behalten?';
  }

  @override
  String conflictUsePeers(String peer) {
    return 'Version von $peer verwenden';
  }

  @override
  String get conflictKeepMine => 'Meine behalten';

  @override
  String fileSavedTo(String path) {
    return 'Gespeichert in $path';
  }

  @override
  String fileCouldNotSave(String error) {
    return 'Konnte nicht speichern: $error';
  }

  @override
  String fileOpenedAsNewNote(String name) {
    return '$name als neue Notiz geöffnet';
  }

  @override
  String fileCouldNotOpen(String error) {
    return 'Konnte nicht öffnen: $error';
  }

  @override
  String get fileNothingToShare => 'Nichts zu teilen — die Notiz ist leer';

  @override
  String get fileShareFallbackClipboard =>
      'Teilen hier nicht verfügbar — in Zwischenablage kopiert';

  @override
  String get fileDefaultNoteName => 'netpad-note';
}
