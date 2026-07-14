// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get commonAppName => 'SB Simple Netpad';

  @override
  String get commonStandardName => 'Netpad Standard';

  @override
  String get commonCancel => 'Annuleren';

  @override
  String get commonClose => 'Sluiten';

  @override
  String get commonSave => 'Opslaan';

  @override
  String get commonDelete => 'Verwijderen';

  @override
  String get commonConnect => 'Verbinden';

  @override
  String get commonHelp => 'Help';

  @override
  String get commonSettings => 'Instellingen';

  @override
  String get commonMore => 'Meer';

  @override
  String get commonCopy => 'Kopiëren';

  @override
  String get commonClear => 'Wissen';

  @override
  String get commonAccept => 'Accepteren';

  @override
  String get commonReject => 'Weigeren';

  @override
  String get commonBlock => 'Blokkeren';

  @override
  String get commonUnblock => 'Deblokkeren';

  @override
  String get commonRevoke => 'Intrekken';

  @override
  String get commonRestore => 'Herstellen';

  @override
  String get commonRetry => 'Opnieuw proberen';

  @override
  String commonCouldNotOpenLabel(String label) {
    return 'Kon $label niet openen';
  }

  @override
  String get commonEulaLabel => 'EULA';

  @override
  String get commonPrivacyPolicyLabel => 'privacybeleid';

  @override
  String get commonEndUserLicenseAgreement =>
      'Eindgebruikerslicentieovereenkomst';

  @override
  String get commonPrivacyPolicy => 'Privacybeleid';

  @override
  String commonVersionLabel(String version) {
    return 'Versie $version';
  }

  @override
  String get shellMenuFile => 'Bestand';

  @override
  String get shellMenuEdit => 'Bewerken';

  @override
  String get shellMenuView => 'Weergave';

  @override
  String get shellMenuHelp => 'Help';

  @override
  String get shellSaveToFile => 'Opslaan als bestand…';

  @override
  String get shellOpenFileAsNewNote => 'Bestand openen als nieuwe notitie…';

  @override
  String get shellShareNote => 'Notitie delen';

  @override
  String get shellVersionHistory => 'Versiegeschiedenis…';

  @override
  String get shellSettings => 'Instellingen…';

  @override
  String get shellExit => 'Afsluiten';

  @override
  String get shellCut => 'Knippen';

  @override
  String get shellCopy => 'Kopiëren';

  @override
  String get shellPaste => 'Plakken';

  @override
  String get shellFind => 'Zoeken…';

  @override
  String get shellFindAndReplace => 'Zoeken en vervangen…';

  @override
  String get shellWordWrap => 'Tekstterugloop';

  @override
  String get shellWordWrapChecked => 'Tekstterugloop ✓';

  @override
  String get shellNotesPanel => 'Notitiesdeelvenster';

  @override
  String get shellNotesPanelChecked => 'Notitiesdeelvenster ✓';

  @override
  String get shellPeersPanel => 'Peer-deelvenster';

  @override
  String get shellPeersPanelChecked => 'Peer-deelvenster ✓';

  @override
  String get shellHelpItem => 'SB Simple Netpad Help';

  @override
  String get shellAboutItem => 'Over SB Simple Netpad';

  @override
  String get shellHideNotesPanel => 'Notitiesdeelvenster verbergen';

  @override
  String shellShowNotesPanel(String mod) {
    return 'Notitiesdeelvenster weergeven ($mod+N)';
  }

  @override
  String get shellHidePeersPanel => 'Peer-deelvenster verbergen';

  @override
  String shellShowPeersPanel(String mod) {
    return 'Peer-deelvenster weergeven ($mod+P)';
  }

  @override
  String shellPeersTooltipConnected(int count, String action, String mod) {
    return '$count versleutelde peer-sessies · peer-deelvenster $action ($mod+P)';
  }

  @override
  String get shellPeersTooltipActionHide => 'verbergen';

  @override
  String get shellPeersTooltipActionShow => 'weergeven';

  @override
  String shellFindInNote(String mod) {
    return 'Zoeken in notitie ($mod+F)';
  }

  @override
  String shellSecurityChipConnected(int count) {
    return '$count peer-sessies versleuteld met WSS/TLS · tik voor peers';
  }

  @override
  String get shellSecurityChipNone =>
      'Geen actieve peer-sessies · tik voor peers';

  @override
  String get shellMobileWordWrap => 'Tekstterugloop';

  @override
  String get shellMobileSaveToFile => 'Opslaan als bestand…';

  @override
  String get shellMobileOpenFileAsNewNote =>
      'Bestand openen als nieuwe notitie…';

  @override
  String get shellMobileShareNote => 'Notitie delen';

  @override
  String get shellMobileVersionHistory => 'Versiegeschiedenis…';

  @override
  String get shellMobileSettings => 'Instellingen';

  @override
  String get shellMobileHelp => 'Help';

  @override
  String get shellMobileAbout => 'Over SB Simple Netpad';

  @override
  String get shellListeningSnack =>
      'Luisteren… tik opnieuw op de microfoon om te stoppen';

  @override
  String get notesTitle => 'Notities';

  @override
  String get notesNewNote => 'Nieuwe notitie';

  @override
  String get notesSearchHint => 'Alle notities doorzoeken';

  @override
  String get notesRenameTitle => 'Notitie hernoemen';

  @override
  String get notesTitleLabel => 'Titel';

  @override
  String notesDeleteTitle(String title) {
    return '\"$title\" verwijderen?';
  }

  @override
  String get notesDeleteSyncedBody =>
      'Dit verwijdert de notitie voor u en alle verbonden peers.';

  @override
  String get notesDeleteLocalBody =>
      'Dit verwijdert de notitie alleen van dit apparaat.';

  @override
  String get notesNoMatches => 'Geen overeenkomsten';

  @override
  String get notesNoNotes => 'Geen notities';

  @override
  String get notesRename => 'Hernoemen';

  @override
  String get notesVersionHistory => 'Versiegeschiedenis';

  @override
  String get notesDelete => 'Verwijderen';

  @override
  String get notesSyncWithPeers => 'Synchroniseren met peers';

  @override
  String get notesLocalOnly => 'Alleen lokaal';

  @override
  String get notesEmptyNote => 'Lege notitie';

  @override
  String notesMatchCount(int count) {
    return '$count overeenkomsten';
  }

  @override
  String notesLocalOnlyWithMatches(String matchLine) {
    return 'Alleen lokaal · $matchLine';
  }

  @override
  String notesSearchSnippetMatches(String snippet, int count) {
    return '$snippet  ·  $count overeenkomsten';
  }

  @override
  String get notesNoNoteSelected => 'Geen notitie geselecteerd';

  @override
  String historyTitle(String title) {
    return 'Versiegeschiedenis · \"$title\"';
  }

  @override
  String get historyEmpty =>
      'Nog geen opgeslagen versies. Snapshots worden automatisch bewaard voordat externe bewerkingen uw tekst vervangen.';

  @override
  String historyEntrySubtitle(String label, String time, int chars) {
    return '$label · $time · $chars tekens';
  }

  @override
  String get historyRestore => 'Herstellen';

  @override
  String get historyRestoredSnack => 'Versie hersteld';

  @override
  String get historyBeforeRemoteUpdate => 'Voor externe update';

  @override
  String get historySnapshot => 'Snapshot';

  @override
  String get historyImportedFile => 'Geïmporteerd bestand';

  @override
  String get editorFindHint => 'Zoeken';

  @override
  String get editorReplaceHint => 'Vervangen door';

  @override
  String editorMatchCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get editorMatchNone => '0/0';

  @override
  String get editorPrevious => 'Vorige';

  @override
  String get editorNext => 'Volgende';

  @override
  String editorShowReplace(String shortcut) {
    return 'Vervangen weergeven ($shortcut)';
  }

  @override
  String editorHideReplace(String shortcut) {
    return 'Vervangen verbergen ($shortcut)';
  }

  @override
  String get editorClose => 'Sluiten';

  @override
  String get editorReplace => 'Vervangen';

  @override
  String get editorReplaceAll => 'Alles';

  @override
  String get editorListening => 'Luisteren…';

  @override
  String get editorDictate => 'Dicteren';

  @override
  String get editorStopDictation => 'Dictaat stoppen';

  @override
  String get peersConnectByIp => 'Verbinden via IP';

  @override
  String get peersConnected => 'Verbonden';

  @override
  String get peersNearby => 'In de buurt';

  @override
  String get peersTrustedDevices => 'Vertrouwde apparaten';

  @override
  String get peersBlocked => 'Geblokkeerd';

  @override
  String get peersConnectionLog => 'Verbindingslogboek';

  @override
  String get peersNoActiveConnections => 'Geen actieve verbindingen';

  @override
  String get peersNoTrustedDevices =>
      'Geen vertrouwde apparaten — vink Vertrouwen voor auto-sync aan bij accepteren';

  @override
  String get peersNoBlockedDevices => 'Geen geblokkeerde apparaten';

  @override
  String get peersNoConnectionEvents => 'Nog geen verbindingsgebeurtenissen';

  @override
  String get peersNoDiscoveredPeers =>
      'Geen peers ontdekt — Linux moet zich op hetzelfde Wi‑Fi-subnet bevinden als Dit apparaat (controleer het adres hierboven), of gebruik Verbinden via IP';

  @override
  String get peersDiscoveryPaused =>
      'Peer-detectie is gepauzeerd totdat u lid wordt van een lokaal netwerk';

  @override
  String get peersDisconnect => 'Verbinding verbreken';

  @override
  String get peersConnectNow => 'Nu verbinden';

  @override
  String get peersConnect => 'Verbinden';

  @override
  String get peersResolving => 'Oplossen…';

  @override
  String get peersBlockTooltip => 'Blokkeren';

  @override
  String peersBlockTitle(String peer) {
    return '$peer blokkeren?';
  }

  @override
  String get peersBlockBody =>
      'Dit verbreekt de verbinding met het apparaat, vergeet het vastgemaakte certificaat en weigert toekomstige verbindingsverzoeken totdat u het deblokkert.';

  @override
  String peersRevokeTitle(String peer) {
    return '$peer intrekken?';
  }

  @override
  String get peersRevokeBody =>
      'De volgende verbinding vereist opnieuw tikken op Accepteren. De beveiligingspincode wordt bewaard zodat certificaatcontroles nog steeds van toepassing zijn.';

  @override
  String get peersAutoSync => 'Automatisch synchroniseren';

  @override
  String get peersCopiedOneLogEntry => '1 logboekitem gekopieerd';

  @override
  String peersCopiedLogEntries(int count) {
    return '$count logboekitems gekopieerd';
  }

  @override
  String peersLogRevision(String time, String revision) {
    return '$time • revisie $revision';
  }

  @override
  String peersStillResolving(String peer) {
    return '$peer nog steeds oplossen…';
  }

  @override
  String peersResolveFailedSnack(String peer) {
    return 'Kon $peer niet oplossen. Controleer Avahi en hetzelfde subnet, of gebruik Verbinden via IP.';
  }

  @override
  String peersPairingRequestSent(String peer) {
    return 'Koppelverzoek verzonden naar $peer';
  }

  @override
  String peersCouldNotConnect(String message) {
    return 'Kon niet verbinden: $message';
  }

  @override
  String peersManualHostPort(String host, int port) {
    return '$host:$port (handmatig)';
  }

  @override
  String get peersManual => 'Handmatig';

  @override
  String get peersResolveFailedSubtitle =>
      'Oplossen mislukt — probeer Verbinden via IP';

  @override
  String get peersResolvingAddress => 'Adres oplossen…';

  @override
  String peersHostPort(String host, int port) {
    return '$host:$port';
  }

  @override
  String get peersNoAddressYet => 'Nog geen adres';

  @override
  String peersEncryptedPinned(String code) {
    return 'Versleuteld · vastgemaakt $code';
  }

  @override
  String get peersEncryptedWss => 'Versleuteld (WSS/TLS)';

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
    return 'Gekoppeld $date · $status';
  }

  @override
  String get peersStatusConnected => 'Verbonden';

  @override
  String get peersStatusManualOnly => 'Alleen handmatig';

  @override
  String get peersStatusReconnecting => 'Opnieuw verbinden…';

  @override
  String peersStatusRetryIn(int seconds) {
    return 'Opnieuw proberen over ${seconds}s';
  }

  @override
  String get peersStatusNotOnNetwork => 'Niet op netwerk';

  @override
  String get peersStatusConnecting => 'Verbinding maken…';

  @override
  String get peersStatusAutoReconnect => 'Automatisch herverbinden';

  @override
  String peersPresenceLineCol(int line, int column) {
    return 'regel $line, kol $column';
  }

  @override
  String peersPresenceInNote(String title, String position) {
    return '\"$title\" · $position';
  }

  @override
  String peersRoomLabel(String room) {
    return 'Ruimte \"$room\"';
  }

  @override
  String get discoveryThisDevice => 'Dit apparaat';

  @override
  String get discoveryCopyAddress => 'Adres kopiëren';

  @override
  String discoveryCopiedAddress(String address) {
    return 'Gekopieerd $address';
  }

  @override
  String get discoveryLocalNetworkRequired => 'Lokaal netwerk vereist';

  @override
  String get discoveryNotListeningTitle => 'Niet luisterend';

  @override
  String get discoveryNotListeningBody =>
      'Dit apparaat luistert nog niet naar peers. Wacht een paar seconden na verbinden met Wi‑Fi, of tik op Opnieuw proberen op een netwerkfoutbanner.';

  @override
  String get discoveryModeTitle => 'Detectiemodus';

  @override
  String get discoveryUnavailableTitle => 'Peer-detectie niet beschikbaar';

  @override
  String get discoveryRetryTooltip => 'Detectie opnieuw proberen';

  @override
  String get peersSecuredSessions => 'Beveiligde sessies';

  @override
  String peersSecurityBannerIdle(String code) {
    return 'Dit apparaat adverteert via WSS/TLS · code $code';
  }

  @override
  String peersSecurityBannerActive(int connectedCount, int pinnedCount) {
    return '$connectedCount versleutelde sessies · $pinnedCount certificaten vastgemaakt';
  }

  @override
  String peersSecurityCompactIdle(String code) {
    return 'WSS/TLS · code $code';
  }

  @override
  String peersSecurityCompactActive(int connectedCount, int pinnedCount) {
    return '$connectedCount versleuteld · $pinnedCount vastgemaakt';
  }

  @override
  String peersSecurityTooltipPinned(String code) {
    return 'Versleuteld (WSS/TLS) · vastgemaakt $code';
  }

  @override
  String get peersSecurityTooltipActive =>
      'Versleuteld (WSS/TLS) · actieve sessie';

  @override
  String get pairingConnectionRequest => 'Verbindingsverzoek';

  @override
  String pairingAllowPeer(String peer) {
    return '$peer toestaan verbinding te maken en deze notitie te delen?';
  }

  @override
  String get pairingVerificationCode => 'Verificatiecode';

  @override
  String get pairingConfirmCode =>
      'Bevestig dat deze code overeenkomt op beide apparaten voordat u accepteert.';

  @override
  String get pairingThisDeviceSecurityCode =>
      'Beveiligingscode van dit apparaat';

  @override
  String get pairingOtherDevicePins =>
      'Het andere apparaat maakt dit vast bij de eerste verbinding.';

  @override
  String get pairingTrustForAutoSync => 'Vertrouwen voor auto-sync';

  @override
  String get pairingTrustForAutoSyncHint =>
      'Accepteren overslaan bij latere herverbindingen. Optioneel — uitgeschakeld laten om elke keer Accepteren te vereisen.';

  @override
  String get manualConnectTitle => 'Verbinden via adres';

  @override
  String get manualConnectBody =>
      'Gebruik dit wanneer detectie geen peers op hetzelfde subnet kan vinden. Alleen adressen op uw actieve lokale netwerksegment zijn toegestaan.';

  @override
  String get manualConnectHostLabel => 'Host of IP';

  @override
  String get manualConnectHostHint => '192.168.1.42';

  @override
  String get manualConnectPortLabel => 'Poort';

  @override
  String get manualConnectPortHint => '54321';

  @override
  String get manualConnectLabelOptional => 'Label (optioneel)';

  @override
  String get manualConnectLabelHint => 'Woonkamer-pc';

  @override
  String get manualConnectInvalidHostPort =>
      'Voer een geldige host en poort in (1–65535)';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get settingsDeviceSection => 'Apparaat';

  @override
  String settingsDeviceHint(String mod) {
    return 'Apparaatnaam en ruimte vereisen Opslaan ($mod+S). Uiterlijk- en editorvoorkeuren worden direct opgeslagen.';
  }

  @override
  String get settingsDeviceName => 'Apparaatnaam';

  @override
  String get settingsDeviceNameHint => 'Naam weergegeven aan andere apparaten';

  @override
  String get settingsSessionRoom => 'Sessie / ruimte';

  @override
  String get settingsSessionRoomHint =>
      'Alleen peers in dezelfde ruimte worden ontdekt';

  @override
  String get settingsListeningPort => 'Luisterpoort';

  @override
  String get settingsStartingServer => 'Server starten…';

  @override
  String settingsAddressShare(String address) {
    return '$address (deel dit voor handmatige verbinding)';
  }

  @override
  String get settingsCopyAddress => 'Adres kopiëren';

  @override
  String get settingsAddressCopied => 'Adres gekopieerd naar klembord';

  @override
  String settingsSavedSnack(String name, String room) {
    return 'Instellingen opgeslagen · \"$name\" · ruimte \"$room\"';
  }

  @override
  String get settingsAppearanceSection => 'Uiterlijk';

  @override
  String get settingsMode => 'Modus';

  @override
  String get settingsThemeSystem => 'Systeem';

  @override
  String get settingsThemeLight => 'Licht';

  @override
  String get settingsThemeDark => 'Donker';

  @override
  String get settingsSkin => 'Skin';

  @override
  String get settingsSkinDefault => 'Standaard';

  @override
  String get settingsSkinOcean => 'Oceaan';

  @override
  String get settingsSkinForest => 'Woud';

  @override
  String get settingsSkinSunset => 'Zonsondergang';

  @override
  String get settingsSkinSlate => 'Leisteen';

  @override
  String settingsSkinStandardLabel(String skin) {
    return '$skin · Standard';
  }

  @override
  String get settingsStandardSection => 'Netpad Standard';

  @override
  String get settingsStandardUnlocked => 'Standard ontgrendeld';

  @override
  String get settingsFree => 'Gratis';

  @override
  String get settingsStandardUnlockedSubtitle =>
      'Onbeperkt gesynchroniseerde notities en peers, skins, geschiedenis, automatisch synchroniseren en spraak';

  @override
  String get settingsStandardBuySubtitle =>
      'Eenmalig ontgrendelen via uw app store';

  @override
  String get settingsPurchasesUnavailable =>
      'Aankopen niet beschikbaar op dit platform';

  @override
  String get settingsRestorePurchases => 'Aankopen herstellen';

  @override
  String get settingsStandardRestored => 'Standard hersteld';

  @override
  String get settingsNoPreviousStandard =>
      'Geen eerdere Standard-aankoop gevonden';

  @override
  String get settingsEditorSection => 'Editor';

  @override
  String get settingsWordWrap => 'Tekstterugloop';

  @override
  String get settingsWordWrapSubtitle =>
      'Lange regels afbreken in plaats van horizontaal scrollen';

  @override
  String settingsFontSize(int size) {
    return 'Tekengrootte ($size pt)';
  }

  @override
  String get settingsLegalSection => 'Juridisch';

  @override
  String get settingsEulaSubtitleStandard =>
      'Standard · Opent EULA op GitHub Pages';

  @override
  String get settingsEulaSubtitleFree => 'Gratis · Opent EULA op GitHub Pages';

  @override
  String get settingsPrivacySubtitle => 'Opent privacypagina op GitHub Pages';

  @override
  String get settingsDisclaimerTitle => 'Disclaimer en aansprakelijkheid';

  @override
  String get settingsDisclaimerSubtitle => 'Gebruik op eigen risico';

  @override
  String get settingsDisclaimerP1 =>
      'Deze software wordt geleverd \"zoals het is\", zonder garanties van welke aard dan ook, expliciet of impliciet, inclusief verhandelbaarheid, geschiktheid voor een bepaald doel en niet-inbreuk.';

  @override
  String get settingsDisclaimerP2 =>
      'U bent als enige verantwoordelijk voor hoe u deze app gebruikt en voor naleving van alle toepasselijke wetten, regelgeving, beleidsregels en overeenkomsten.';

  @override
  String get settingsDisclaimerP3 =>
      'De auteursrechthebbende is niet aansprakelijk voor claims, schade, verlies, gegevensverlies, bedrijfsonderbreking of andere aansprakelijkheid die voortvloeit uit het gebruik of misbruik van deze software.';

  @override
  String get settingsNoLegalAdviceTitle => 'Geen juridisch advies';

  @override
  String get settingsNoLegalAdviceSubtitle => 'Alleen informatieve software';

  @override
  String get settingsNoLegalAdviceP1 =>
      'Deze app en de bijbehorende documentatie bieden geen juridisch, regelgevend of professioneel advies.';

  @override
  String get settingsNoLegalAdviceP2 =>
      'Als u juridische begeleiding nodig heeft voor uw gebruik, raadpleeg dan een gekwalificeerde professional.';

  @override
  String get settingsCopyright => '© 2026 Spencer Beaumier';

  @override
  String get paywallTitle => 'Netpad Standard ontgrendelen';

  @override
  String get paywallSubtitle =>
      'Eenmalige aankoop. Kernbewerking en LAN-synchronisatie blijven gratis.';

  @override
  String get paywallBenefitUnlimitedNotes =>
      'Onbeperkt gesynchroniseerde notities';

  @override
  String get paywallBenefitUnlimitedPeers => 'Onbeperkte verbonden peers';

  @override
  String get paywallBenefitSkins => 'Extra kleurskins';

  @override
  String get paywallBenefitHistory => 'Versiegeschiedenis';

  @override
  String get paywallBenefitAutoSync =>
      'Automatisch synchroniseren van vertrouwde peers';

  @override
  String get paywallBenefitVoice => 'Spraakdictaat';

  @override
  String get paywallPurchasesUnsupported =>
      'In-app aankopen zijn niet beschikbaar op dit platform. Installeer vanuit de App Store, Google Play of Microsoft Store om Standard te ontgrendelen.';

  @override
  String get paywallBuyStandard => 'Standard kopen';

  @override
  String paywallBuyStandardPrice(String price) {
    return 'Standard kopen · $price';
  }

  @override
  String get paywallRestorePurchases => 'Aankopen herstellen';

  @override
  String get paywallPurchaseNotCompleted => 'Aankoop is niet voltooid.';

  @override
  String get paywallPurchaseFailed => 'Aankoop mislukt.';

  @override
  String get paywallStandardRestored => 'Standard hersteld';

  @override
  String get paywallNoPreviousStandard =>
      'Geen eerdere Standard-aankoop gevonden';

  @override
  String standardHighlightNoteLimit(int limit) {
    return 'De gratis versie kan tot $limit notities tegelijk synchroniseren. Ontgrendel Standard voor onbeperkt gesynchroniseerde notities.';
  }

  @override
  String standardHighlightPeerLimit(int limit) {
    return 'De gratis versie bevat tot $limit verbonden peers. Ontgrendel Standard voor onbeperkte peers.';
  }

  @override
  String get standardHighlightVersionHistory =>
      'Versiegeschiedenis is een Standard-functie.';

  @override
  String get standardHighlightVoice => 'Spraakdictaat is een Standard-functie.';

  @override
  String get standardHighlightAutoSync =>
      'Automatisch synchroniseren van vertrouwde peers is een Standard-functie.';

  @override
  String get standardHighlightSkins =>
      'Extra skins zijn inbegrepen bij Standard.';

  @override
  String get helpTitle => 'Help';

  @override
  String get helpIntro =>
      'Een LAN-kladblok voor notities in platte tekst. Apparaten op hetzelfde Wi‑Fi ontdekken elkaar, koppelen eenmalig en synchroniseren notities daarna in realtime.';

  @override
  String get helpAboutTile => 'Over SB Simple Netpad';

  @override
  String get helpEulaSubtitle => 'Opent EULA op GitHub Pages';

  @override
  String get helpPrivacySubtitle => 'Opent privacypagina op GitHub Pages';

  @override
  String get helpGettingStartedTitle => 'Aan de slag';

  @override
  String get helpGettingStarted1 =>
      'Verbind met hetzelfde Wi‑Fi-netwerk als de apparaten waarmee u wilt synchroniseren.';

  @override
  String get helpGettingStarted2 =>
      'Open het peer-deelvenster (slotpictogram of peers-lade) en wacht tot nabijgelegen apparaten verschijnen.';

  @override
  String get helpGettingStarted3 =>
      'Kopieer uw adres van Dit apparaat en deel het als detectie traag is.';

  @override
  String get helpGettingStarted4 =>
      'Gebruik Verbinden via IP wanneer mDNS-detectie geen peers vindt.';

  @override
  String get helpNotesTitle => 'Notities';

  @override
  String get helpNotes1 =>
      'Tik op het menupictogram (☰) of het notitiesdeelvenster om tussen notities te wisselen.';

  @override
  String get helpNotes2 =>
      'Maak notities aan, hernoem, herorden en verwijder ze vanuit de notitieslijst.';

  @override
  String get helpNotes3 =>
      'Elke notitie synchroniseert onafhankelijk — nieuwe notities starten lokaal; zet sync aan om met peers te delen.';

  @override
  String get helpNotes4 =>
      'Zoek binnen een notitie (Zoeken) of in alle notities vanuit de editor.';

  @override
  String get helpNotes5 =>
      'Versiegeschiedenis slaat lokale snapshots op die u later kunt herstellen.';

  @override
  String get helpPeersTitle => 'Peers en koppelen';

  @override
  String get helpPeers1 =>
      'In de buurt toont ontdekte apparaten in dezelfde ruimte (zie Instellingen).';

  @override
  String get helpPeers2 =>
      'Tik op Verbinden bij een peer — het andere apparaat moet op Accepteren tikken.';

  @override
  String get helpPeers3 =>
      'Vergelijk de koppelingsverificatiecode voordat u accepteert.';

  @override
  String get helpPeers4 =>
      'Vink Vertrouwen voor auto-sync aan bij accepteren als latere herverbindingen Accepteren moeten overslaan.';

  @override
  String get helpPeers5 =>
      'Vertrouwde apparaten: schakel automatisch synchroniseren in/uit of Intrekken om opnieuw Accepteren te vereisen.';

  @override
  String get helpPeers6 =>
      'Blokkeren verbreekt de verbinding met een apparaat en weigert toekomstige koppelingen totdat het gedeblokkerd is.';

  @override
  String get helpPeers7 =>
      'Verbonden toont actieve sessies met adres en cursorpositie.';

  @override
  String get helpFileSharingTitle => 'Bestanden en delen';

  @override
  String get helpFileSharing1Desktop =>
      'Menu Bestand: Opslaan als bestand, Bestand openen als nieuwe notitie, Notitie delen, Versiegeschiedenis, Instellingen, Afsluiten.';

  @override
  String get helpFileSharing1Macos =>
      'File menu: Save to File, Open File as New Note, Share Note, Version History. Settings are under the app menu (Cmd+,); Quit ends the app.';

  @override
  String get helpFileSharing1Mobile =>
      'Menu (⋮): opslaan als bestand, bestand openen als nieuwe notitie, delen, versiegeschiedenis, instellingen en deze helpgids.';

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
      'Delen gebruikt het OS-deelblad; Linux gebruikt het klembord als fallback.';

  @override
  String get helpSettingsTitle => 'Instellingen';

  @override
  String get helpSettings1 =>
      'Apparaatnaam en ruimte vereisen Opslaan — andere opties worden direct toegepast.';

  @override
  String get helpSettings2 =>
      'Ruimte-ID groepeert peers: alleen apparaten in dezelfde ruimte worden ontdekt.';

  @override
  String get helpSettings3 =>
      'Uiterlijk- en editorvoorkeuren (thema, skin, terugloop, lettertype) worden opgeslagen bij wijziging.';

  @override
  String get helpDesktopShortcutsTitle => 'Bureaubladsneltoetsen';

  @override
  String get helpDesktopShortcuts1 => 'Ctrl/Cmd+S — Opslaan als bestand';

  @override
  String get helpDesktopShortcuts2 =>
      'Ctrl/Cmd+O — Bestand openen als nieuwe notitie';

  @override
  String get helpDesktopShortcuts3 => 'Ctrl/Cmd+F — Zoeken in notitie';

  @override
  String get helpDesktopShortcuts4 =>
      'Ctrl+H (Windows/Linux) or Option+Cmd+F (macOS) — Find and replace';

  @override
  String get helpDesktopShortcuts5 =>
      'Ctrl/Cmd+N — Notitiesdeelvenster in-/uitschakelen';

  @override
  String get helpDesktopShortcuts6 =>
      'Ctrl/Cmd+P — Peer-deelvenster in-/uitschakelen';

  @override
  String get helpDesktopShortcuts7 =>
      'Ctrl/Cmd+Q — Exit (Windows/Linux); macOS uses Quit from the app menu';

  @override
  String get helpTroubleshootingTitle => 'Probleemoplossing';

  @override
  String get helpTroubleshooting1 =>
      'Geen peers? Bevestig hetzelfde Wi‑Fi-subnet en ruimte-ID; probeer Verbinden via IP.';

  @override
  String get helpTroubleshooting2 =>
      'De banner lokaal netwerk vereist betekent dat synchronisatie is gepauzeerd totdat Wi‑Fi actief is.';

  @override
  String get helpTroubleshooting3 =>
      'Sta de app toe via uw firewall bij de eerste start (desktop).';

  @override
  String get helpTroubleshooting4 =>
      'Linux: installeer dbus en avahi-daemon als detectie nooit start.';

  @override
  String get helpTroubleshooting5 =>
      'Android: verleen de nabijgelegen Wi‑Fi-machtiging wanneer gevraagd.';

  @override
  String get helpTroubleshooting6 =>
      'iOS/macOS: allow Local Network access for SB Simple Netpad in System Settings if peers never appear.';

  @override
  String get aboutTitle => 'Over';

  @override
  String get aboutTagline =>
      'LAN-kladblok met peer-detectie en gedeeld bewerken.';

  @override
  String get aboutDescription =>
      'Schrijf notities in platte tekst op uw telefoon of computer en houd ze gesynchroniseerd met andere apparaten op hetzelfde Wi‑Fi. Peers ontdekken elkaar op het lokale netwerk, koppelen eenmalig met wederzijdse goedkeuring en delen vervolgens meerdere benoemde notities met versleutelde peer-sessies.';

  @override
  String get aboutPlatforms => 'Android · iOS · Windows · macOS · Linux';

  @override
  String get aboutStatus => 'Beta — geschikt voor dagelijks LAN-gebruik.';

  @override
  String get aboutEulaHeading => 'Eindgebruikerslicentieovereenkomst';

  @override
  String aboutEulaBody(int noteLimit, int peerLimit) {
    return 'SB Simple Netpad is gelicentieerd onder een EULA, geen open-source licentie. Kernbewerking en LAN-synchronisatie zijn gratis (onbeperkt lokale notities, tot $noteLimit gesynchroniseerde notities en $peerLimit verbonden peers). Netpad Standard is een eenmalig ontgrendelen via de App Store, Google Play of Microsoft Store.';
  }

  @override
  String get aboutViewEula => 'EULA bekijken';

  @override
  String get aboutPrivacyPolicy => 'Privacybeleid';

  @override
  String get aboutHowToUse => 'Hoe SB Simple Netpad te gebruiken';

  @override
  String get aboutCouldNotOpenPrivacy => 'Kon privacybeleid niet openen';

  @override
  String get aboutCouldNotOpenEula => 'Kon EULA niet openen';

  @override
  String get aboutCopyright => '© 2026 Spencer Beaumier';

  @override
  String conflictLiveTitle(String title) {
    return 'Bewerkingsconflict in \"$title\"';
  }

  @override
  String conflictLiveBody(
    String peer,
    String revision,
    String localPreview,
    String remotePreview,
  ) {
    return '$peer heeft dezelfde notitie tegelijkertijd bewerkt (revisie $revision).\n\nUw versie:\n$localPreview\n\n$peer:\n$remotePreview\n\nWelke versie moeten beide apparaten bewaren?';
  }

  @override
  String conflictDivergedTitle(String title) {
    return '\"$title\" is afgeweken';
  }

  @override
  String conflictDivergedBody(
    String peer,
    String title,
    int localChars,
    int remoteChars,
  ) {
    return 'Uw kopie en de kopie van $peer van \"$title\" zijn anders gewijzigd terwijl de verbinding was verbroken.\n\nUw versie: $localChars tekens\n$peer: $remoteChars tekens\n\nWelke versie moeten beide apparaten bewaren?';
  }

  @override
  String conflictUsePeers(String peer) {
    return 'Die van $peer gebruiken';
  }

  @override
  String get conflictKeepMine => 'Mijn versie bewaren';

  @override
  String fileSavedTo(String path) {
    return 'Opgeslagen in $path';
  }

  @override
  String fileCouldNotSave(String error) {
    return 'Kon niet opslaan: $error';
  }

  @override
  String fileOpenedAsNewNote(String name) {
    return '$name geopend als nieuwe notitie';
  }

  @override
  String fileCouldNotOpen(String error) {
    return 'Kon niet openen: $error';
  }

  @override
  String get fileNothingToShare => 'Niets te delen — de notitie is leeg';

  @override
  String get fileShareFallbackClipboard =>
      'Delen niet beschikbaar hier — gekopieerd naar klembord';

  @override
  String get fileDefaultNoteName => 'netpad-note';
}
