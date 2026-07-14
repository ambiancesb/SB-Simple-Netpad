// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get commonAppName => 'SB Simple Netpad';

  @override
  String get commonStandardName => 'Netpad Standard';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonSave => 'Salva';

  @override
  String get commonDelete => 'Elimina';

  @override
  String get commonConnect => 'Connetti';

  @override
  String get commonHelp => 'Guida';

  @override
  String get commonSettings => 'Impostazioni';

  @override
  String get commonMore => 'Altro';

  @override
  String get commonCopy => 'Copia';

  @override
  String get commonClear => 'Cancella';

  @override
  String get commonAccept => 'Accetta';

  @override
  String get commonReject => 'Rifiuta';

  @override
  String get commonBlock => 'Blocca';

  @override
  String get commonUnblock => 'Sblocca';

  @override
  String get commonRevoke => 'Revoca';

  @override
  String get commonRestore => 'Ripristina';

  @override
  String get commonRetry => 'Riprova';

  @override
  String commonCouldNotOpenLabel(String label) {
    return 'Impossibile aprire $label';
  }

  @override
  String get commonEulaLabel => 'EULA';

  @override
  String get commonPrivacyPolicyLabel => 'informativa sulla privacy';

  @override
  String get commonEndUserLicenseAgreement =>
      'Contratto di Licenza con l\'Utente Finale';

  @override
  String get commonPrivacyPolicy => 'Informativa sulla Privacy';

  @override
  String commonVersionLabel(String version) {
    return 'Versione $version';
  }

  @override
  String get shellMenuFile => 'File';

  @override
  String get shellMenuEdit => 'Modifica';

  @override
  String get shellMenuView => 'Visualizza';

  @override
  String get shellMenuHelp => 'Guida';

  @override
  String get shellSaveToFile => 'Salva su file…';

  @override
  String get shellOpenFileAsNewNote => 'Apri file come nuova nota…';

  @override
  String get shellShareNote => 'Condividi nota';

  @override
  String get shellVersionHistory => 'Cronologia versioni…';

  @override
  String get shellSettings => 'Impostazioni…';

  @override
  String get shellExit => 'Esci';

  @override
  String get shellCut => 'Taglia';

  @override
  String get shellCopy => 'Copia';

  @override
  String get shellPaste => 'Incolla';

  @override
  String get shellFind => 'Trova…';

  @override
  String get shellFindAndReplace => 'Trova e sostituisci…';

  @override
  String get shellWordWrap => 'A capo automatico';

  @override
  String get shellWordWrapChecked => 'A capo automatico ✓';

  @override
  String get shellNotesPanel => 'Pannello note';

  @override
  String get shellNotesPanelChecked => 'Pannello note ✓';

  @override
  String get shellPeersPanel => 'Pannello peer';

  @override
  String get shellPeersPanelChecked => 'Pannello peer ✓';

  @override
  String get shellHelpItem => 'Guida di SB Simple Netpad';

  @override
  String get shellAboutItem => 'Informazioni su SB Simple Netpad';

  @override
  String get shellHideNotesPanel => 'Nascondi pannello note';

  @override
  String shellShowNotesPanel(String mod) {
    return 'Mostra pannello note ($mod+N)';
  }

  @override
  String get shellHidePeersPanel => 'Nascondi pannello peer';

  @override
  String shellShowPeersPanel(String mod) {
    return 'Mostra pannello peer ($mod+P)';
  }

  @override
  String shellPeersTooltipConnected(int count, String action, String mod) {
    return '$count sessioni peer crittografate · $action pannello peer ($mod+P)';
  }

  @override
  String get shellPeersTooltipActionHide => 'nascondi';

  @override
  String get shellPeersTooltipActionShow => 'mostra';

  @override
  String shellFindInNote(String mod) {
    return 'Trova nella nota ($mod+F)';
  }

  @override
  String shellSecurityChipConnected(int count) {
    return '$count sessioni peer crittografate con WSS/TLS · tocca per i peer';
  }

  @override
  String get shellSecurityChipNone =>
      'Nessuna sessione peer attiva · tocca per i peer';

  @override
  String get shellMobileWordWrap => 'A capo automatico';

  @override
  String get shellMobileSaveToFile => 'Salva su file…';

  @override
  String get shellMobileOpenFileAsNewNote => 'Apri file come nuova nota…';

  @override
  String get shellMobileShareNote => 'Condividi nota';

  @override
  String get shellMobileVersionHistory => 'Cronologia versioni…';

  @override
  String get shellMobileSettings => 'Impostazioni';

  @override
  String get shellMobileHelp => 'Guida';

  @override
  String get shellMobileAbout => 'Informazioni su SB Simple Netpad';

  @override
  String get shellListeningSnack =>
      'In ascolto… tocca di nuovo il microfono per interrompere';

  @override
  String get notesTitle => 'Note';

  @override
  String get notesNewNote => 'Nuova nota';

  @override
  String get notesSearchHint => 'Cerca in tutte le note';

  @override
  String get notesRenameTitle => 'Rinomina nota';

  @override
  String get notesTitleLabel => 'Titolo';

  @override
  String notesDeleteTitle(String title) {
    return 'Eliminare \"$title\"?';
  }

  @override
  String get notesDeleteSyncedBody =>
      'Questo rimuove la nota per te e per tutti i peer connessi.';

  @override
  String get notesDeleteLocalBody =>
      'Questo rimuove la nota solo da questo dispositivo.';

  @override
  String get notesNoMatches => 'Nessuna corrispondenza';

  @override
  String get notesNoNotes => 'Nessuna nota';

  @override
  String get notesRename => 'Rinomina';

  @override
  String get notesVersionHistory => 'Cronologia versioni';

  @override
  String get notesDelete => 'Elimina';

  @override
  String get notesSyncWithPeers => 'Sincronizza con i peer';

  @override
  String get notesLocalOnly => 'Solo locale';

  @override
  String get notesEmptyNote => 'Nota vuota';

  @override
  String notesMatchCount(int count) {
    return '$count corrispondenze';
  }

  @override
  String notesLocalOnlyWithMatches(String matchLine) {
    return 'Solo locale · $matchLine';
  }

  @override
  String notesSearchSnippetMatches(String snippet, int count) {
    return '$snippet  ·  $count corrispondenze';
  }

  @override
  String get notesNoNoteSelected => 'Nessuna nota selezionata';

  @override
  String historyTitle(String title) {
    return 'Cronologia versioni · \"$title\"';
  }

  @override
  String get historyEmpty =>
      'Nessuna versione salvata ancora. Gli snapshot vengono conservati automaticamente prima che le modifiche remote sostituiscano il tuo testo.';

  @override
  String historyEntrySubtitle(String label, String time, int chars) {
    return '$label · $time · $chars caratteri';
  }

  @override
  String get historyRestore => 'Ripristina';

  @override
  String get historyRestoredSnack => 'Versione ripristinata';

  @override
  String get historyBeforeRemoteUpdate => 'Prima dell\'aggiornamento remoto';

  @override
  String get historySnapshot => 'Snapshot';

  @override
  String get historyImportedFile => 'File importato';

  @override
  String get editorFindHint => 'Trova';

  @override
  String get editorReplaceHint => 'Sostituisci con';

  @override
  String editorMatchCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get editorMatchNone => '0/0';

  @override
  String get editorPrevious => 'Precedente';

  @override
  String get editorNext => 'Successivo';

  @override
  String editorShowReplace(String shortcut) {
    return 'Mostra sostituzione ($shortcut)';
  }

  @override
  String editorHideReplace(String shortcut) {
    return 'Nascondi sostituzione ($shortcut)';
  }

  @override
  String get editorClose => 'Chiudi';

  @override
  String get editorReplace => 'Sostituisci';

  @override
  String get editorReplaceAll => 'Tutto';

  @override
  String get editorListening => 'In ascolto…';

  @override
  String get editorDictate => 'Dettatura';

  @override
  String get editorStopDictation => 'Interrompi dettatura';

  @override
  String get peersConnectByIp => 'Connetti tramite IP';

  @override
  String get peersConnected => 'Connesso';

  @override
  String get peersNearby => 'Nelle vicinanze';

  @override
  String get peersTrustedDevices => 'Dispositivi attendibili';

  @override
  String get peersBlocked => 'Bloccati';

  @override
  String get peersConnectionLog => 'Registro connessioni';

  @override
  String get peersNoActiveConnections => 'Nessuna connessione attiva';

  @override
  String get peersNoTrustedDevices =>
      'Nessun dispositivo attendibile — seleziona Affida per auto-sync quando accetti';

  @override
  String get peersNoBlockedDevices => 'Nessun dispositivo bloccato';

  @override
  String get peersNoConnectionEvents => 'Nessun evento di connessione ancora';

  @override
  String get peersNoDiscoveredPeers =>
      'Nessun peer scoperto — i dispositivi devono essere nella stessa sottorete Wi‑Fi di Questo dispositivo (controlla l\'indirizzo sopra), o usa Connetti tramite IP';

  @override
  String get peersDiscoveryPaused =>
      'La ricerca dei peer è in pausa finché non ti unisci a una rete locale';

  @override
  String get peersDisconnect => 'Disconnetti';

  @override
  String get peersTrustTooltip => 'Affida per auto-sync';

  @override
  String get peersTrustWaiting => 'In attesa…';

  @override
  String get peersTrustOfferFailed =>
      'Impossibile inviare l’offerta di fiducia';

  @override
  String get peersConnectNow => 'Connetti ora';

  @override
  String get peersConnect => 'Connetti';

  @override
  String get peersResolving => 'Risoluzione in corso…';

  @override
  String get peersBlockTooltip => 'Blocca';

  @override
  String peersBlockTitle(String peer) {
    return 'Bloccare $peer?';
  }

  @override
  String get peersBlockBody =>
      'Questo disconnette il dispositivo, dimentica il certificato associato e rifiuta le future richieste di connessione fino a quando non lo sblocchi.';

  @override
  String peersRevokeTitle(String peer) {
    return 'Revocare $peer?';
  }

  @override
  String get peersRevokeBody =>
      'La prossima connessione richiederà di toccare di nuovo Accetta. Il PIN di sicurezza viene mantenuto in modo che le verifiche dei certificati si applichino ancora.';

  @override
  String get peersAutoSync => 'Sincronizzazione automatica';

  @override
  String get peersCopiedOneLogEntry => '1 voce del registro copiata';

  @override
  String peersCopiedLogEntries(int count) {
    return '$count voci del registro copiate';
  }

  @override
  String peersLogRevision(String time, String revision) {
    return '$time • revisione $revision';
  }

  @override
  String peersStillResolving(String peer) {
    return 'Risoluzione di $peer in corso…';
  }

  @override
  String peersResolveFailedSnack(String peer) {
    return 'Impossibile risolvere $peer. Controlla che siano sulla stessa sottorete, o usa Connetti tramite IP.';
  }

  @override
  String peersPairingRequestSent(String peer) {
    return 'Richiesta di abbinamento inviata a $peer';
  }

  @override
  String peersCouldNotConnect(String message) {
    return 'Impossibile connettersi: $message';
  }

  @override
  String peersManualHostPort(String host, int port) {
    return '$host:$port (manuale)';
  }

  @override
  String get peersManual => 'Manuale';

  @override
  String get peersResolveFailedSubtitle =>
      'Risoluzione fallita — prova Connetti tramite IP';

  @override
  String get peersResolvingAddress => 'Risoluzione indirizzo…';

  @override
  String peersHostPort(String host, int port) {
    return '$host:$port';
  }

  @override
  String get peersNoAddressYet => 'Nessun indirizzo ancora';

  @override
  String peersEncryptedPinned(String code) {
    return 'Crittografato · associato $code';
  }

  @override
  String get peersEncryptedWss => 'Crittografato (WSS/TLS)';

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
    return 'Abbinato il $date · $status';
  }

  @override
  String get peersStatusConnected => 'Connesso';

  @override
  String get peersStatusManualOnly => 'Solo manuale';

  @override
  String get peersStatusReconnecting => 'Riconnessione…';

  @override
  String peersStatusRetryIn(int seconds) {
    return 'Riprova tra ${seconds}s';
  }

  @override
  String get peersStatusNotOnNetwork => 'Non in rete';

  @override
  String get peersStatusConnecting => 'Connessione…';

  @override
  String get peersStatusAutoReconnect => 'Riconnessione automatica';

  @override
  String peersPresenceLineCol(int line, int column) {
    return 'riga $line, col $column';
  }

  @override
  String peersPresenceInNote(String title, String position) {
    return '\"$title\" · $position';
  }

  @override
  String peersRoomLabel(String room) {
    return 'Stanza \"$room\"';
  }

  @override
  String get discoveryThisDevice => 'Questo dispositivo';

  @override
  String get discoveryCopyAddress => 'Copia indirizzo';

  @override
  String discoveryCopiedAddress(String address) {
    return 'Copiato $address';
  }

  @override
  String get discoveryLocalNetworkRequired => 'Rete locale richiesta';

  @override
  String get discoveryNotListeningTitle => 'Non in ascolto';

  @override
  String get discoveryNotListeningBody =>
      'Questo dispositivo non è ancora in ascolto per i peer. Attendi qualche secondo dopo esserti connesso al Wi‑Fi, o tocca Riprova su un banner di errore di rete.';

  @override
  String get discoveryModeTitle => 'Modalità di ricerca';

  @override
  String get discoveryUnavailableTitle => 'Ricerca peer non disponibile';

  @override
  String get discoveryRetryTooltip => 'Riprova ricerca';

  @override
  String get peersSecuredSessions => 'Sessioni sicure';

  @override
  String peersSecurityBannerIdle(String code) {
    return 'Questo dispositivo si annuncia via WSS/TLS · codice $code';
  }

  @override
  String peersSecurityBannerActive(int connectedCount, int pinnedCount) {
    return '$connectedCount sessioni crittografate · $pinnedCount certificati associati';
  }

  @override
  String peersSecurityCompactIdle(String code) {
    return 'WSS/TLS · codice $code';
  }

  @override
  String peersSecurityCompactActive(int connectedCount, int pinnedCount) {
    return '$connectedCount crittografate · $pinnedCount associate';
  }

  @override
  String peersSecurityTooltipPinned(String code) {
    return 'Crittografato (WSS/TLS) · associato $code';
  }

  @override
  String get peersSecurityTooltipActive =>
      'Crittografato (WSS/TLS) · sessione attiva';

  @override
  String get pairingConnectionRequest => 'Richiesta di connessione';

  @override
  String pairingAllowPeer(String peer) {
    return 'Permettere a $peer di connettersi e condividere questa nota?';
  }

  @override
  String get pairingVerificationCode => 'Codice di verifica';

  @override
  String get pairingConfirmCode =>
      'Conferma che questo codice corrisponda su entrambi i dispositivi prima di accettare.';

  @override
  String get pairingThisDeviceSecurityCode =>
      'Codice di sicurezza di questo dispositivo';

  @override
  String get pairingOtherDevicePins =>
      'L\'altro dispositivo associa questo alla prima connessione.';

  @override
  String get pairingTrustForAutoSync => 'Affida per auto-sync';

  @override
  String get pairingTrustForAutoSyncHint =>
      'Salta Accetta alle riconnessioni successive. Facoltativo: lascia deselezionato per richiedere Accetta ogni volta.';

  @override
  String get pairingTrustOfferTitle => 'Richiesta di fiducia';

  @override
  String pairingTrustOfferBody(String peer) {
    return '$peer vuole fidarsi di questo dispositivo per l’auto-sync. Le riconnessioni future salteranno Accetta.';
  }

  @override
  String pairingTrustAcceptedSnack(String peer) {
    return 'Affidato $peer per auto-sync';
  }

  @override
  String pairingTrustDeclinedSnack(String peer) {
    return '$peer ha rifiutato la fiducia';
  }

  @override
  String get manualConnectTitle => 'Connetti tramite indirizzo';

  @override
  String get manualConnectBody =>
      'Da usare quando la ricerca non riesce a trovare peer sulla stessa sottorete. Sono consentiti solo indirizzi nel segmento di rete locale attivo.';

  @override
  String get manualConnectHostLabel => 'Host o IP';

  @override
  String get manualConnectHostHint => '192.168.1.42';

  @override
  String get manualConnectPortLabel => 'Porta';

  @override
  String get manualConnectPortHint => '54321';

  @override
  String get manualConnectLabelOptional => 'Etichetta (opzionale)';

  @override
  String get manualConnectLabelHint => 'PC del salotto';

  @override
  String get manualConnectInvalidHostPort =>
      'Inserisci un host e una porta validi (1–65535)';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsDeviceSection => 'Dispositivo';

  @override
  String settingsDeviceHint(String mod) {
    return 'Il nome del dispositivo e la stanza richiedono Salva ($mod+S). Le preferenze di aspetto ed editor vengono salvate immediatamente.';
  }

  @override
  String get settingsDeviceName => 'Nome dispositivo';

  @override
  String get settingsDeviceNameHint => 'Nome mostrato agli altri dispositivi';

  @override
  String get settingsSessionRoom => 'Sessione / stanza';

  @override
  String get settingsSessionRoomHint =>
      'Solo i peer nella stessa stanza vengono scoperti';

  @override
  String get settingsListeningPort => 'Porta di ascolto';

  @override
  String get settingsStartingServer => 'Avvio server…';

  @override
  String settingsAddressShare(String address) {
    return '$address (condividi per la connessione manuale)';
  }

  @override
  String get settingsCopyAddress => 'Copia indirizzo';

  @override
  String get settingsAddressCopied => 'Indirizzo copiato negli appunti';

  @override
  String settingsSavedSnack(String name, String room) {
    return 'Impostazioni salvate · \"$name\" · stanza \"$room\"';
  }

  @override
  String get settingsAppearanceSection => 'Aspetto';

  @override
  String get settingsMode => 'Modalità';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Chiaro';

  @override
  String get settingsThemeDark => 'Scuro';

  @override
  String get settingsSkin => 'Skin';

  @override
  String get settingsSkinDefault => 'Predefinito';

  @override
  String get settingsSkinOcean => 'Oceano';

  @override
  String get settingsSkinForest => 'Foresta';

  @override
  String get settingsSkinSunset => 'Tramonto';

  @override
  String get settingsSkinSlate => 'Ardesia';

  @override
  String settingsSkinStandardLabel(String skin) {
    return '$skin · Standard';
  }

  @override
  String get settingsStandardSection => 'Netpad Standard';

  @override
  String get settingsStandardUnlocked => 'Standard sbloccato';

  @override
  String get settingsFree => 'Gratuito';

  @override
  String get settingsStandardUnlockedSubtitle =>
      'Note sincronizzate e peer illimitati, skin, cronologia, sincronizzazione automatica e voce';

  @override
  String get settingsStandardBuySubtitle =>
      'Sblocco una tantum tramite il tuo app store';

  @override
  String get settingsPurchasesUnavailable =>
      'Acquisti non disponibili su questa piattaforma';

  @override
  String get settingsStandardStoreSubtitle =>
      'Ottieni Standard da App Store, Google Play o Microsoft Store';

  @override
  String get settingsRestorePurchases => 'Ripristina acquisti';

  @override
  String get settingsStandardRestored => 'Standard ripristinato';

  @override
  String get settingsNoPreviousStandard =>
      'Nessun acquisto Standard precedente trovato';

  @override
  String get settingsEditorSection => 'Editor';

  @override
  String get settingsWordWrap => 'A capo automatico';

  @override
  String get settingsWordWrapSubtitle =>
      'Vai a capo nelle righe lunghe anziché scorrere orizzontalmente';

  @override
  String settingsFontSize(int size) {
    return 'Dimensione carattere ($size pt)';
  }

  @override
  String get settingsLegalSection => 'Legale';

  @override
  String get settingsEulaSubtitleStandard =>
      'Standard · Apre EULA su GitHub Pages';

  @override
  String get settingsEulaSubtitleFree => 'Gratuito · Apre EULA su GitHub Pages';

  @override
  String get settingsPrivacySubtitle =>
      'Apre la pagina privacy su GitHub Pages';

  @override
  String get settingsDisclaimerTitle =>
      'Dichiarazione di non responsabilità e responsabilità';

  @override
  String get settingsDisclaimerSubtitle => 'Usa a tuo rischio e pericolo';

  @override
  String get settingsDisclaimerP1 =>
      'Questo software è fornito \"così com\'è\", senza garanzie di alcun tipo, esplicite o implicite, incluse commerciabilità, idoneità per uno scopo particolare e non violazione.';

  @override
  String get settingsDisclaimerP2 =>
      'Sei il solo responsabile di come utilizzi questa app e del rispetto di tutte le leggi, normative, politiche e accordi applicabili.';

  @override
  String get settingsDisclaimerP3 =>
      'Il titolare del copyright non è responsabile di eventuali rivendicazioni, danni, perdite, perdita di dati, interruzioni dell\'attività o altra responsabilità derivante dall\'uso o dall\'abuso di questo software.';

  @override
  String get settingsNoLegalAdviceTitle => 'Nessuna consulenza legale';

  @override
  String get settingsNoLegalAdviceSubtitle => 'Solo software informativo';

  @override
  String get settingsNoLegalAdviceP1 =>
      'Questa app e la sua documentazione non forniscono consulenza legale, normativa o professionale.';

  @override
  String get settingsNoLegalAdviceP2 =>
      'Se hai bisogno di una guida legale per il tuo caso d\'uso, consulta un professionista qualificato.';

  @override
  String get settingsCopyright => '© 2026 Spencer Beaumier';

  @override
  String get paywallTitle => 'Sblocca Netpad Standard';

  @override
  String get paywallSubtitle =>
      'Acquisto unico. Modifica base e sincronizzazione LAN rimangono gratuite.';

  @override
  String get paywallBenefitUnlimitedNotes => 'Note sincronizzate illimitate';

  @override
  String get paywallBenefitUnlimitedPeers => 'Peer connessi illimitati';

  @override
  String get paywallBenefitUnlimitedLength => 'Lunghezza nota illimitata';

  @override
  String get paywallBenefitSkins => 'Skin colori extra';

  @override
  String get paywallBenefitHistory => 'Cronologia versioni';

  @override
  String get paywallBenefitAutoSync =>
      'Sincronizzazione automatica peer attendibili';

  @override
  String get paywallBenefitVoice => 'Dettatura vocale';

  @override
  String get paywallPurchasesUnsupported =>
      'Gli acquisti in-app non sono disponibili su questa piattaforma. Apri una scheda dello store per sbloccare Standard.';

  @override
  String get paywallBuyStandard => 'Acquista Standard';

  @override
  String paywallBuyStandardPrice(String price) {
    return 'Acquista Standard · $price';
  }

  @override
  String get paywallGetFromStore => 'Ottieni Standard dallo store';

  @override
  String get paywallOpenAppStore => 'Apri App Store';

  @override
  String get paywallOpenPlayStore => 'Apri Google Play';

  @override
  String get paywallOpenMicrosoftStore => 'Apri Microsoft Store';

  @override
  String get paywallCouldNotOpenStore =>
      'Impossibile aprire la scheda dello store';

  @override
  String get paywallRestorePurchases => 'Ripristina acquisti';

  @override
  String get paywallPurchaseNotCompleted =>
      'L\'acquisto non è stato completato.';

  @override
  String get paywallPurchaseFailed => 'Acquisto fallito.';

  @override
  String get paywallStandardRestored => 'Standard ripristinato';

  @override
  String get paywallNoPreviousStandard =>
      'Nessun acquisto Standard precedente trovato';

  @override
  String get freeTierUsageTitle => 'Utilizzo del piano Free';

  @override
  String freeTierUsageLine(
    int synced,
    int syncedLimit,
    int peers,
    int peerLimit,
    int chars,
    int charLimit,
  ) {
    return 'Note sincronizzate $synced/$syncedLimit · Peer $peers/$peerLimit · Questa nota $chars/$charLimit';
  }

  @override
  String standardHighlightNoteLimit(int limit) {
    return 'La versione gratuita può sincronizzare fino a $limit note alla volta. Sblocca Standard per note sincronizzate illimitate.';
  }

  @override
  String standardHighlightPeerLimit(int limit) {
    return 'La versione gratuita include fino a $limit peer connessi. Sblocca Standard per peer illimitati.';
  }

  @override
  String standardHighlightCharLimit(int limit) {
    return 'Le note Free sono limitate a $limit caratteri. Sblocca Standard per lunghezza illimitata.';
  }

  @override
  String get standardHighlightVersionHistory =>
      'La cronologia versioni è una funzione Standard.';

  @override
  String get standardHighlightVoice =>
      'La dettatura vocale è una funzione Standard.';

  @override
  String get standardHighlightAutoSync =>
      'La sincronizzazione automatica dei peer attendibili è una funzione Standard.';

  @override
  String get standardHighlightSkins =>
      'Le skin extra sono incluse con Standard.';

  @override
  String get helpTitle => 'Guida';

  @override
  String get helpIntro =>
      'Un blocco note LAN per note in testo normale. I dispositivi sulla stessa rete Wi‑Fi si scoprono, si abbinano una volta e poi sincronizzano le note in tempo reale.';

  @override
  String get helpAboutTile => 'Informazioni su SB Simple Netpad';

  @override
  String get helpEulaSubtitle => 'Apre EULA su GitHub Pages';

  @override
  String get helpPrivacySubtitle => 'Apre la pagina privacy su GitHub Pages';

  @override
  String get helpGettingStartedTitle => 'Per iniziare';

  @override
  String get helpGettingStarted1 =>
      'Connettiti alla stessa rete Wi‑Fi dei dispositivi con cui vuoi sincronizzare.';

  @override
  String get helpGettingStarted2 =>
      'Apri il pannello peer (icona lucchetto o cassetto Peer) e aspetta che appaiano i dispositivi nelle vicinanze.';

  @override
  String get helpGettingStarted3 =>
      'Copia il tuo indirizzo da Questo dispositivo e condividilo se la ricerca è lenta.';

  @override
  String get helpGettingStarted4 =>
      'Usa Connetti tramite IP quando la ricerca mDNS non trova peer.';

  @override
  String get helpNotesTitle => 'Note';

  @override
  String get helpNotes1 =>
      'Tocca l\'icona del menu (☰) o il pannello note per passare tra le note.';

  @override
  String get helpNotes2 =>
      'Crea, rinomina, riordina ed elimina note dall\'elenco note.';

  @override
  String get helpNotes3 =>
      'Ogni nota si sincronizza indipendentemente — le nuove note partono solo locali; attiva la sync per condividere con i peer.';

  @override
  String get helpNotes4 =>
      'Cerca all\'interno di una nota (Trova) o in tutte le note dall\'editor.';

  @override
  String get helpNotes5 =>
      'La cronologia versioni salva snapshot locali che puoi ripristinare in seguito.';

  @override
  String get helpPeersTitle => 'Peer e abbinamento';

  @override
  String get helpPeers1 =>
      'Nelle vicinanze elenca i dispositivi scoperti nella stessa stanza (vedi Impostazioni).';

  @override
  String get helpPeers2 =>
      'Tocca Connetti su un peer — l\'altro dispositivo deve toccare Accetta.';

  @override
  String get helpPeers3 =>
      'Confronta il codice di verifica dell\'abbinamento prima di accettare.';

  @override
  String get helpPeers4 =>
      'Seleziona Affida per auto-sync quando accetti se vuoi che le riconnessioni saltino Accetta.';

  @override
  String get helpPeers5 =>
      'Dispositivi attendibili: attiva/disattiva la sincronizzazione automatica o Revoca per richiedere di nuovo Accetta.';

  @override
  String get helpPeers6 =>
      'Blocca disconnette un dispositivo e rifiuta i futuri abbinamenti fino allo sblocco.';

  @override
  String get helpPeers7 =>
      'Connesso mostra le sessioni attive con indirizzo e posizione del cursore.';

  @override
  String get helpFileSharingTitle => 'File e condivisione';

  @override
  String get helpFileSharing1Desktop =>
      'Menu File: Salva su file, Apri file come nuova nota, Condividi nota, Cronologia versioni, Impostazioni, Esci.';

  @override
  String get helpFileSharing1Macos =>
      'File menu: Save to File, Open File as New Note, Share Note, Version History. Settings are under the app menu (Cmd+,); Quit ends the app.';

  @override
  String get helpFileSharing1Mobile =>
      'Menu (⋮): salva su file, apri file come nuova nota, condividi, cronologia versioni, impostazioni e questa guida.';

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
      'Condividi usa il foglio di condivisione del sistema operativo quando disponibile; altrimenti la nota viene copiata negli appunti.';

  @override
  String get helpSettingsTitle => 'Impostazioni';

  @override
  String get helpSettings1 =>
      'Il nome del dispositivo e la stanza richiedono Salva — le altre opzioni si applicano immediatamente.';

  @override
  String get helpSettings2 =>
      'L\'ID stanza raggruppa i peer: solo i dispositivi nella stessa stanza vengono scoperti.';

  @override
  String get helpSettings3 =>
      'Le preferenze di aspetto ed editor (tema, skin, a capo, carattere) vengono salvate al cambio.';

  @override
  String get helpDesktopShortcutsTitle => 'Scorciatoie desktop';

  @override
  String get helpDesktopShortcuts1 => 'Ctrl/Cmd+S — Salva su file';

  @override
  String get helpDesktopShortcuts2 => 'Ctrl/Cmd+O — Apri file come nuova nota';

  @override
  String get helpDesktopShortcuts3 => 'Ctrl/Cmd+F — Trova nella nota';

  @override
  String get helpDesktopShortcuts4 =>
      'Ctrl+H (Windows) or Option+Cmd+F (macOS) — Find and replace';

  @override
  String get helpDesktopShortcuts5 =>
      'Ctrl/Cmd+N — Attiva/disattiva pannello note';

  @override
  String get helpDesktopShortcuts6 =>
      'Ctrl/Cmd+P — Attiva/disattiva pannello peer';

  @override
  String get helpDesktopShortcuts7 =>
      'Ctrl/Cmd+Q — Exit (Windows); macOS uses Quit from the app menu';

  @override
  String get helpTroubleshootingTitle => 'Risoluzione dei problemi';

  @override
  String get helpTroubleshooting1 =>
      'Nessun peer? Conferma la stessa sottorete Wi‑Fi e l\'ID stanza; prova Connetti tramite IP.';

  @override
  String get helpTroubleshooting2 =>
      'Il banner rete locale richiesta significa che la sincronizzazione è in pausa finché il Wi‑Fi non è attivo.';

  @override
  String get helpTroubleshooting3 =>
      'Consenti l\'app attraverso il firewall al primo avvio (desktop).';

  @override
  String get helpTroubleshooting4 =>
      'Assicurati che tutti i dispositivi siano sulla stessa sottorete Wi‑Fi e che rete locale / firewall consentano la scoperta.';

  @override
  String get helpTroubleshooting5 =>
      'Android: concedi il permesso Wi‑Fi nelle vicinanze quando richiesto.';

  @override
  String get helpTroubleshooting6 =>
      'iOS/macOS: allow Local Network access for SB Simple Netpad in System Settings if peers never appear.';

  @override
  String get aboutTitle => 'Informazioni';

  @override
  String get aboutTagline =>
      'Blocco note LAN con scoperta peer e modifica condivisa.';

  @override
  String get aboutDescription =>
      'Scrivi note in testo normale sul tuo telefono o computer e mantienile sincronizzate con altri dispositivi sulla stessa rete Wi‑Fi. I peer si scoprono sulla rete locale, si abbinano una volta con approvazione reciproca, poi condividono più note con nome tramite sessioni peer crittografate.';

  @override
  String get aboutPlatforms => 'Android · iOS · Windows · macOS';

  @override
  String get aboutStatus => 'Beta — adatto all\'uso LAN quotidiano.';

  @override
  String get aboutEulaHeading => 'Contratto di Licenza con l\'Utente Finale';

  @override
  String aboutEulaBody(int noteLimit, int peerLimit) {
    return 'SB Simple Netpad è concesso in licenza ai sensi di un EULA, non una licenza open source. La modifica base e la sincronizzazione LAN sono gratuite (note locali illimitate, fino a $noteLimit note sincronizzate e $peerLimit peer connessi). Netpad Standard è uno sblocco una tantum tramite App Store, Google Play o Microsoft Store.';
  }

  @override
  String get aboutViewEula => 'Visualizza EULA';

  @override
  String get aboutPrivacyPolicy => 'Informativa sulla Privacy';

  @override
  String get aboutHowToUse => 'Come usare SB Simple Netpad';

  @override
  String get aboutCouldNotOpenPrivacy =>
      'Impossibile aprire l\'informativa sulla privacy';

  @override
  String get aboutCouldNotOpenEula => 'Impossibile aprire EULA';

  @override
  String get aboutCopyright => '© 2026 Spencer Beaumier';

  @override
  String conflictLiveTitle(String title) {
    return 'Conflitto di modifica in \"$title\"';
  }

  @override
  String conflictLiveBody(
    String peer,
    String revision,
    String localPreview,
    String remotePreview,
  ) {
    return '$peer ha modificato la stessa nota nello stesso momento (revisione $revision).\n\nLa tua:\n$localPreview\n\n$peer:\n$remotePreview\n\nQuale versione devono mantenere entrambi i dispositivi?';
  }

  @override
  String conflictDivergedTitle(String title) {
    return '\"$title\" ha divergito';
  }

  @override
  String conflictDivergedBody(
    String peer,
    String title,
    int localChars,
    int remoteChars,
  ) {
    return 'La tua copia e la copia di $peer di \"$title\" sono cambiate in modo diverso durante la disconnessione.\n\nLa tua: $localChars caratteri\n$peer: $remoteChars caratteri\n\nQuale versione devono mantenere entrambi i dispositivi?';
  }

  @override
  String conflictUsePeers(String peer) {
    return 'Usa quella di $peer';
  }

  @override
  String get conflictKeepMine => 'Mantieni la mia';

  @override
  String fileSavedTo(String path) {
    return 'Salvato in $path';
  }

  @override
  String fileCouldNotSave(String error) {
    return 'Impossibile salvare: $error';
  }

  @override
  String fileOpenedAsNewNote(String name) {
    return '$name aperto come nuova nota';
  }

  @override
  String fileCouldNotOpen(String error) {
    return 'Impossibile aprire: $error';
  }

  @override
  String get fileNothingToShare => 'Nulla da condividere — la nota è vuota';

  @override
  String get fileShareFallbackClipboard =>
      'Condivisione non disponibile qui — copiato negli appunti';

  @override
  String get fileDefaultNoteName => 'netpad-note';
}
