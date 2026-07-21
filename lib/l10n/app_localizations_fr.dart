// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get commonAppName => 'SB Simple Netpad';

  @override
  String get commonStandardName => 'Netpad Standard';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonConnect => 'Connecter';

  @override
  String get commonHelp => 'Aide';

  @override
  String get commonSettings => 'Paramètres';

  @override
  String get commonMore => 'Plus';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonClear => 'Effacer';

  @override
  String get commonAccept => 'Accepter';

  @override
  String get commonReject => 'Refuser';

  @override
  String get commonBlock => 'Bloquer';

  @override
  String get commonUnblock => 'Débloquer';

  @override
  String get commonRevoke => 'Révoquer';

  @override
  String get commonRestore => 'Restaurer';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String commonCouldNotOpenLabel(String label) {
    return 'Impossible d\'ouvrir $label';
  }

  @override
  String get commonEulaLabel => 'EULA';

  @override
  String get commonPrivacyPolicyLabel => 'politique de confidentialité';

  @override
  String get commonEndUserLicenseAgreement =>
      'Contrat de licence utilisateur final';

  @override
  String get commonPrivacyPolicy => 'Politique de confidentialité';

  @override
  String commonVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get shellMenuFile => 'Fichier';

  @override
  String get shellMenuEdit => 'Éditer';

  @override
  String get shellMenuView => 'Affichage';

  @override
  String get shellMenuHelp => 'Aide';

  @override
  String get shellSaveToFile => 'Enregistrer dans un fichier…';

  @override
  String get shellOpenFileAsNewNote => 'Ouvrir un fichier comme nouvelle note…';

  @override
  String get shellShareNote => 'Partager la note';

  @override
  String get shellVersionHistory => 'Historique des versions…';

  @override
  String get shellSettings => 'Paramètres…';

  @override
  String get shellExit => 'Quitter';

  @override
  String get shellCut => 'Couper';

  @override
  String get shellCopy => 'Copier';

  @override
  String get shellPaste => 'Coller';

  @override
  String get shellFind => 'Rechercher…';

  @override
  String get shellFindAndReplace => 'Rechercher et remplacer…';

  @override
  String get shellWordWrap => 'Retour à la ligne';

  @override
  String get shellWordWrapChecked => 'Retour à la ligne ✓';

  @override
  String get shellNotesPanel => 'Panneau de notes';

  @override
  String get shellNotesPanelChecked => 'Panneau de notes ✓';

  @override
  String get shellPeersPanel => 'Panneau des pairs';

  @override
  String get shellPeersPanelChecked => 'Panneau des pairs ✓';

  @override
  String get shellHelpItem => 'Aide de SB Simple Netpad';

  @override
  String get shellAboutItem => 'À propos de SB Simple Netpad';

  @override
  String get shellHideNotesPanel => 'Masquer le panneau de notes';

  @override
  String shellShowNotesPanel(String mod) {
    return 'Afficher le panneau de notes ($mod+N)';
  }

  @override
  String get shellHidePeersPanel => 'Masquer le panneau des pairs';

  @override
  String shellShowPeersPanel(String mod) {
    return 'Afficher le panneau des pairs ($mod+P)';
  }

  @override
  String shellPeersTooltipConnected(int count, String action, String mod) {
    return '$count sessions de pairs chiffrées · $action le panneau des pairs ($mod+P)';
  }

  @override
  String get shellPeersTooltipActionHide => 'masquer';

  @override
  String get shellPeersTooltipActionShow => 'afficher';

  @override
  String shellFindInNote(String mod) {
    return 'Rechercher dans la note ($mod+F)';
  }

  @override
  String shellSecurityChipConnected(int count) {
    return '$count sessions de pairs chiffrées avec WSS/TLS · appuyez pour voir les pairs';
  }

  @override
  String get shellSecurityChipNone =>
      'Aucune session de pairs active · appuyez pour voir les pairs';

  @override
  String get shellMobileWordWrap => 'Retour à la ligne';

  @override
  String get shellMobileSaveToFile => 'Enregistrer dans un fichier…';

  @override
  String get shellMobileOpenFileAsNewNote =>
      'Ouvrir un fichier comme nouvelle note…';

  @override
  String get shellMobileShareNote => 'Partager la note';

  @override
  String get shellMobileVersionHistory => 'Historique des versions…';

  @override
  String get shellMobileSettings => 'Paramètres';

  @override
  String get shellMobileHelp => 'Aide';

  @override
  String get shellMobileAbout => 'À propos de SB Simple Netpad';

  @override
  String get shellListeningSnack =>
      'Écoute en cours… appuyez à nouveau sur le micro pour arrêter';

  @override
  String get notesTitle => 'Notes';

  @override
  String get notesNewNote => 'Nouvelle note';

  @override
  String get notesSearchHint => 'Rechercher dans toutes les notes';

  @override
  String get notesRenameTitle => 'Renommer la note';

  @override
  String get notesTitleLabel => 'Titre';

  @override
  String notesDeleteTitle(String title) {
    return 'Supprimer \"$title\" ?';
  }

  @override
  String get notesDeleteSyncedBody =>
      'Cela supprime la note pour vous et tous les pairs connectés.';

  @override
  String get notesDeleteLocalBody =>
      'Cela supprime la note uniquement sur cet appareil.';

  @override
  String get notesNoMatches => 'Aucun résultat';

  @override
  String get notesNoNotes => 'Aucune note';

  @override
  String get notesRename => 'Renommer';

  @override
  String get notesVersionHistory => 'Historique des versions';

  @override
  String get notesDelete => 'Supprimer';

  @override
  String get notesSyncWithPeers => 'Synchroniser avec les pairs';

  @override
  String get notesLocalOnly => 'Local uniquement';

  @override
  String get notesEmptyNote => 'Note vide';

  @override
  String notesMatchCount(int count) {
    return '$count correspondances';
  }

  @override
  String notesLocalOnlyWithMatches(String matchLine) {
    return 'Local uniquement · $matchLine';
  }

  @override
  String notesSearchSnippetMatches(String snippet, int count) {
    return '$snippet  ·  $count correspondances';
  }

  @override
  String get notesNoNoteSelected => 'Aucune note sélectionnée';

  @override
  String historyTitle(String title) {
    return 'Historique des versions · \"$title\"';
  }

  @override
  String get historyEmpty =>
      'Aucune version enregistrée pour l\'instant. Les instantanés sont conservés automatiquement avant que les modifications distantes ne remplacent votre texte.';

  @override
  String historyEntrySubtitle(String label, String time, int chars) {
    return '$label · $time · $chars caractères';
  }

  @override
  String get historyRestore => 'Restaurer';

  @override
  String get historyRestoredSnack => 'Version restaurée';

  @override
  String get historyBeforeRemoteUpdate => 'Avant la mise à jour distante';

  @override
  String get historySnapshot => 'Instantané';

  @override
  String get historyImportedFile => 'Fichier importé';

  @override
  String get editorFindHint => 'Rechercher';

  @override
  String get editorReplaceHint => 'Remplacer par';

  @override
  String editorMatchCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get editorMatchNone => '0/0';

  @override
  String get editorPrevious => 'Précédent';

  @override
  String get editorNext => 'Suivant';

  @override
  String editorShowReplace(String shortcut) {
    return 'Afficher le remplacement ($shortcut)';
  }

  @override
  String editorHideReplace(String shortcut) {
    return 'Masquer le remplacement ($shortcut)';
  }

  @override
  String get editorClose => 'Fermer';

  @override
  String get editorReplace => 'Remplacer';

  @override
  String get editorReplaceAll => 'Tout';

  @override
  String get editorListening => 'Écoute en cours…';

  @override
  String get editorDictate => 'Dicter';

  @override
  String get editorStopDictation => 'Arrêter la dictée';

  @override
  String get peersConnectByIp => 'Connecter par IP';

  @override
  String get peersConnected => 'Connecté';

  @override
  String get peersNearby => 'À proximité';

  @override
  String get peersTrustedDevices => 'Appareils de confiance';

  @override
  String get peersBlocked => 'Bloqués';

  @override
  String get peersConnectionLog => 'Journal de connexion';

  @override
  String get peersNoActiveConnections => 'Aucune connexion active';

  @override
  String get peersNoTrustedDevices =>
      'Aucun appareil de confiance — cochez Faire confiance pour la synchro auto à l\'acceptation';

  @override
  String get peersNoBlockedDevices => 'Aucun appareil bloqué';

  @override
  String get peersNoConnectionEvents =>
      'Aucun événement de connexion pour l\'instant';

  @override
  String get peersNoDiscoveredPeers =>
      'Aucun pair découvert — les appareils doivent être sur le même sous-réseau Wi‑Fi que Cet appareil (vérifiez l\'adresse ci-dessus), ou utilisez Connecter par IP';

  @override
  String get peersDiscoveryPaused =>
      'La découverte de pairs est suspendue jusqu\'à ce que vous rejoigniez un réseau local';

  @override
  String get peersDisconnect => 'Déconnecter';

  @override
  String get peersTrustTooltip => 'Faire confiance pour la synchro auto';

  @override
  String get peersTrustWaiting => 'En attente…';

  @override
  String get peersTrustOfferFailed =>
      'Impossible d’envoyer la demande de confiance';

  @override
  String get peersConnectNow => 'Connecter maintenant';

  @override
  String get peersConnect => 'Connecter';

  @override
  String get peersResolving => 'Résolution en cours…';

  @override
  String get peersBlockTooltip => 'Bloquer';

  @override
  String peersBlockTitle(String peer) {
    return 'Bloquer $peer ?';
  }

  @override
  String get peersBlockBody =>
      'Cela déconnecte l\'appareil, oublie son certificat épinglé et refuse les futures demandes de connexion jusqu\'à ce que vous le débloquiez.';

  @override
  String peersRevokeTitle(String peer) {
    return 'Révoquer $peer ?';
  }

  @override
  String get peersRevokeBody =>
      'La prochaine connexion nécessitera d\'appuyer à nouveau sur Accepter. Le code PIN de sécurité est conservé pour que les vérifications de certificat s\'appliquent toujours.';

  @override
  String get peersAutoSync => 'Synchronisation automatique';

  @override
  String get peersCopiedOneLogEntry => '1 entrée de journal copiée';

  @override
  String peersCopiedLogEntries(int count) {
    return '$count entrées de journal copiées';
  }

  @override
  String peersLogRevision(String time, String revision) {
    return '$time • révision $revision';
  }

  @override
  String peersStillResolving(String peer) {
    return 'Résolution de $peer en cours…';
  }

  @override
  String peersResolveFailedSnack(String peer) {
    return 'Impossible de résoudre $peer. Vérifiez qu\'ils sont sur le même sous-réseau, ou utilisez Connecter par IP.';
  }

  @override
  String peersPairingRequestSent(String peer) {
    return 'Demande d\'association envoyée à $peer';
  }

  @override
  String peersCouldNotConnect(String message) {
    return 'Impossible de se connecter : $message';
  }

  @override
  String peersManualHostPort(String host, int port) {
    return '$host:$port (manuel)';
  }

  @override
  String get peersManual => 'Manuel';

  @override
  String get peersResolveFailedSubtitle =>
      'Résolution échouée — essayez Connecter par IP';

  @override
  String get peersResolvingAddress => 'Résolution de l\'adresse…';

  @override
  String peersHostPort(String host, int port) {
    return '$host:$port';
  }

  @override
  String get peersNoAddressYet => 'Pas encore d\'adresse';

  @override
  String peersEncryptedPinned(String code) {
    return 'Chiffré · épinglé $code';
  }

  @override
  String get peersEncryptedWss => 'Chiffré (WSS/TLS)';

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
    return 'Associé le $date · $status';
  }

  @override
  String get peersStatusConnected => 'Connecté';

  @override
  String get peersStatusManualOnly => 'Manuel uniquement';

  @override
  String get peersStatusReconnecting => 'Reconnexion…';

  @override
  String peersStatusRetryIn(int seconds) {
    return 'Réessayer dans ${seconds}s';
  }

  @override
  String get peersStatusNotOnNetwork => 'Pas sur le réseau';

  @override
  String get peersStatusConnecting => 'Connexion…';

  @override
  String get peersStatusAutoReconnect => 'Reconnexion automatique';

  @override
  String peersPresenceLineCol(int line, int column) {
    return 'ligne $line, col $column';
  }

  @override
  String peersPresenceInNote(String title, String position) {
    return '\"$title\" · $position';
  }

  @override
  String peersRoomLabel(String room) {
    return 'Salle \"$room\"';
  }

  @override
  String get discoveryThisDevice => 'Cet appareil';

  @override
  String get discoveryCopyAddress => 'Copier l\'adresse';

  @override
  String discoveryCopiedAddress(String address) {
    return 'Copié $address';
  }

  @override
  String get discoveryLocalNetworkRequired => 'Réseau local requis';

  @override
  String get discoveryNotListeningTitle => 'Pas en écoute';

  @override
  String get discoveryNotListeningBody =>
      'Cet appareil n\'écoute pas encore les pairs. Attendez quelques secondes après avoir rejoint le Wi‑Fi, ou appuyez sur Réessayer sur une bannière d\'erreur réseau.';

  @override
  String get discoveryModeTitle => 'Mode de découverte';

  @override
  String get discoveryUnavailableTitle => 'Découverte de pairs indisponible';

  @override
  String get discoveryRetryTooltip => 'Réessayer la découverte';

  @override
  String get peersSecuredSessions => 'Sessions sécurisées';

  @override
  String peersSecurityBannerIdle(String code) {
    return 'Cet appareil annonce via WSS/TLS · code $code';
  }

  @override
  String peersSecurityBannerActive(int connectedCount, int pinnedCount) {
    return '$connectedCount sessions chiffrées · $pinnedCount certificats épinglés';
  }

  @override
  String peersSecurityCompactIdle(String code) {
    return 'WSS/TLS · code $code';
  }

  @override
  String peersSecurityCompactActive(int connectedCount, int pinnedCount) {
    return '$connectedCount chiffrées · $pinnedCount épinglés';
  }

  @override
  String peersSecurityTooltipPinned(String code) {
    return 'Chiffré (WSS/TLS) · épinglé $code';
  }

  @override
  String get peersSecurityTooltipActive => 'Chiffré (WSS/TLS) · session active';

  @override
  String get pairingConnectionRequest => 'Demande de connexion';

  @override
  String pairingAllowPeer(String peer) {
    return 'Autoriser $peer à se connecter et à partager cette note ?';
  }

  @override
  String get pairingVerificationCode => 'Code de vérification';

  @override
  String get pairingConfirmCode =>
      'Confirmez que ce code correspond sur les deux appareils avant d\'accepter.';

  @override
  String get pairingThisDeviceSecurityCode =>
      'Code de sécurité de cet appareil';

  @override
  String get pairingOtherDevicePins =>
      'L\'autre appareil épingle ceci à la première connexion.';

  @override
  String get pairingTrustForAutoSync => 'Faire confiance pour la synchro auto';

  @override
  String get pairingTrustForAutoSyncHint =>
      'Ignorer Accepter aux reconnexions suivantes. Optionnel — laisser décoché pour exiger Accepter à chaque fois.';

  @override
  String get pairingTrustOfferTitle => 'Demande de confiance';

  @override
  String pairingTrustOfferBody(String peer) {
    return '$peer souhaite faire confiance à cet appareil pour la synchro auto. Les reconnexions futures ignoreront Accepter.';
  }

  @override
  String pairingTrustAcceptedSnack(String peer) {
    return 'Confiance accordée à $peer pour la synchro auto';
  }

  @override
  String pairingTrustDeclinedSnack(String peer) {
    return '$peer a refusé la confiance';
  }

  @override
  String get manualConnectTitle => 'Connecter par adresse';

  @override
  String get manualConnectBody =>
      'À utiliser lorsque la découverte ne trouve pas de pairs sur le même sous-réseau. Seules les adresses de votre segment de réseau local actif sont autorisées.';

  @override
  String get manualConnectHostLabel => 'Hôte ou IP';

  @override
  String get manualConnectHostHint => '192.168.1.42';

  @override
  String get manualConnectPortLabel => 'Port';

  @override
  String get manualConnectPortHint => '54321';

  @override
  String get manualConnectLabelOptional => 'Étiquette (optionnel)';

  @override
  String get manualConnectLabelHint => 'PC du salon';

  @override
  String get manualConnectInvalidHostPort =>
      'Entrez un hôte et un port valides (1–65535)';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsDeviceSection => 'Appareil';

  @override
  String settingsDeviceHint(String mod) {
    return 'Le nom de l\'appareil et la salle nécessitent Enregistrer ($mod+S). Les préférences d\'apparence et d\'éditeur s\'enregistrent immédiatement.';
  }

  @override
  String get settingsDeviceName => 'Nom de l\'appareil';

  @override
  String get settingsDeviceNameHint => 'Nom affiché aux autres appareils';

  @override
  String get settingsSessionRoom => 'Session / salle';

  @override
  String get settingsSessionRoomHint =>
      'Seuls les pairs dans la même salle sont découverts';

  @override
  String get settingsListeningPort => 'Port d\'écoute';

  @override
  String get settingsStartingServer => 'Démarrage du serveur…';

  @override
  String settingsAddressShare(String address) {
    return '$address (partagez ceci pour la connexion manuelle)';
  }

  @override
  String get settingsCopyAddress => 'Copier l\'adresse';

  @override
  String get settingsAddressCopied => 'Adresse copiée dans le presse-papiers';

  @override
  String settingsSavedSnack(String name, String room) {
    return 'Paramètres enregistrés · \"$name\" · salle \"$room\"';
  }

  @override
  String get settingsAppearanceSection => 'Apparence';

  @override
  String get settingsMode => 'Mode';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsSkin => 'Thème visuel';

  @override
  String get settingsSkinDefault => 'Par défaut';

  @override
  String get settingsSkinOcean => 'Océan';

  @override
  String get settingsSkinForest => 'Forêt';

  @override
  String get settingsSkinSunset => 'Coucher de soleil';

  @override
  String get settingsSkinSlate => 'Ardoise';

  @override
  String settingsSkinStandardLabel(String skin) {
    return '$skin · Standard';
  }

  @override
  String get settingsStandardSection => 'Netpad Standard';

  @override
  String get settingsStandardUnlocked => 'Standard débloqué';

  @override
  String get settingsFree => 'Gratuit';

  @override
  String get settingsStandardUnlockedSubtitle =>
      'Notes synchronisées et pairs illimités, thèmes, historique, synchronisation automatique et voix';

  @override
  String get settingsStandardBuySubtitle =>
      'Déblocage unique via votre boutique d\'applications';

  @override
  String get settingsPurchasesUnavailable =>
      'Achats indisponibles sur cette plateforme';

  @override
  String get settingsStandardStoreSubtitle =>
      'Obtenez Standard sur l’App Store, Google Play ou Microsoft Store';

  @override
  String get settingsRestorePurchases => 'Restaurer les achats';

  @override
  String get settingsStandardRestored => 'Standard restauré';

  @override
  String get settingsNoPreviousStandard =>
      'Aucun achat Standard précédent trouvé';

  @override
  String get settingsEditorSection => 'Éditeur';

  @override
  String get settingsWordWrap => 'Retour à la ligne';

  @override
  String get settingsWordWrapSubtitle =>
      'Couper les longues lignes plutôt que de défiler horizontalement';

  @override
  String settingsFontSize(int size) {
    return 'Taille de police ($size pt)';
  }

  @override
  String get settingsLegalSection => 'Mentions légales';

  @override
  String get settingsEulaSubtitleStandard =>
      'Standard · Ouvre l\'EULA sur GitHub Pages';

  @override
  String get settingsEulaSubtitleFree =>
      'Gratuit · Ouvre l\'EULA sur GitHub Pages';

  @override
  String get settingsPrivacySubtitle =>
      'Ouvre la page de confidentialité sur GitHub Pages';

  @override
  String get settingsDisclaimerTitle => 'Avertissement et responsabilité';

  @override
  String get settingsDisclaimerSubtitle =>
      'Utilisation à vos risques et périls';

  @override
  String get settingsDisclaimerP1 =>
      'Ce logiciel est fourni \"tel quel\", sans garantie d\'aucune sorte, expresse ou implicite, notamment de commercialisation, d\'adéquation à un usage particulier et de non-contrefaçon.';

  @override
  String get settingsDisclaimerP2 =>
      'Vous êtes seul responsable de la façon dont vous utilisez cette application et du respect de toutes les lois, réglementations, politiques et accords applicables.';

  @override
  String get settingsDisclaimerP3 =>
      'Le titulaire du copyright n\'est pas responsable des réclamations, dommages, pertes, perte de données, interruption d\'activité ou autre responsabilité découlant de l\'utilisation ou de l\'abus de ce logiciel.';

  @override
  String get settingsNoLegalAdviceTitle => 'Pas de conseil juridique';

  @override
  String get settingsNoLegalAdviceSubtitle => 'Logiciel informatif uniquement';

  @override
  String get settingsNoLegalAdviceP1 =>
      'Cette application et sa documentation ne fournissent pas de conseil juridique, réglementaire ou professionnel.';

  @override
  String get settingsNoLegalAdviceP2 =>
      'Si vous avez besoin de conseils juridiques pour votre cas d\'utilisation, consultez un professionnel qualifié.';

  @override
  String get settingsCopyright => '© 2026 Spencer Beaumier';

  @override
  String get paywallTitle => 'Débloquer Netpad Standard';

  @override
  String get paywallSubtitle =>
      'Achat unique. L\'édition principale et la synchronisation LAN restent gratuites.';

  @override
  String get paywallBenefitUnlimitedNotes => 'Notes synchronisées illimitées';

  @override
  String get paywallBenefitUnlimitedPeers => 'Pairs connectés illimités';

  @override
  String get paywallBenefitUnlimitedLength => 'Longueur de note illimitée';

  @override
  String get paywallBenefitSkins => 'Thèmes de couleurs supplémentaires';

  @override
  String get paywallBenefitHistory => 'Historique des versions';

  @override
  String get paywallBenefitAutoSync =>
      'Synchronisation automatique des pairs de confiance';

  @override
  String get paywallBenefitVoice => 'Dictée vocale';

  @override
  String get paywallPurchasesUnsupported =>
      'Les achats intégrés ne sont pas disponibles sur cette plateforme. Ouvrez une fiche boutique pour débloquer Standard.';

  @override
  String get paywallBuyStandard => 'Acheter Standard';

  @override
  String paywallBuyStandardPrice(String price) {
    return 'Acheter Standard · $price';
  }

  @override
  String get paywallGetFromStore => 'Obtenir Standard dans la boutique';

  @override
  String get paywallOpenAppStore => 'Ouvrir l’App Store';

  @override
  String get paywallOpenPlayStore => 'Ouvrir Google Play';

  @override
  String get paywallOpenMicrosoftStore => 'Ouvrir le Microsoft Store';

  @override
  String get paywallCouldNotOpenStore =>
      'Impossible d’ouvrir la fiche boutique';

  @override
  String get paywallRestorePurchases => 'Restaurer les achats';

  @override
  String get paywallPurchaseNotCompleted => 'L\'achat n\'a pas été finalisé.';

  @override
  String get paywallPurchaseFailed => 'L\'achat a échoué.';

  @override
  String get paywallStandardRestored => 'Standard restauré';

  @override
  String get paywallNoPreviousStandard =>
      'Aucun achat Standard précédent trouvé';

  @override
  String get freeTierUsageTitle => 'Utilisation du forfait gratuit';

  @override
  String freeTierUsageLine(
    int synced,
    int syncedLimit,
    int peers,
    int peerLimit,
    int chars,
    int charLimit,
  ) {
    return 'Notes synchronisées $synced/$syncedLimit · Pairs $peers/$peerLimit · Cette note $chars/$charLimit';
  }

  @override
  String standardHighlightNoteLimit(int limit) {
    return 'La version gratuite peut synchroniser jusqu\'à $limit notes à la fois. Débloquez Standard pour des notes synchronisées illimitées.';
  }

  @override
  String standardHighlightPeerLimit(int limit) {
    return 'La version gratuite inclut jusqu\'à $limit pairs connectés. Débloquez Standard pour des pairs illimités.';
  }

  @override
  String standardHighlightCharLimit(int limit) {
    return 'Les notes gratuites sont limitées à $limit caractères. Débloquez Standard pour une longueur illimitée.';
  }

  @override
  String get standardHighlightVersionHistory =>
      'L\'historique des versions est une fonctionnalité Standard.';

  @override
  String get standardHighlightVoice =>
      'La dictée vocale est une fonctionnalité Standard.';

  @override
  String get standardHighlightAutoSync =>
      'La synchronisation automatique des pairs de confiance est une fonctionnalité Standard.';

  @override
  String get standardHighlightSkins =>
      'Les thèmes supplémentaires sont inclus avec Standard.';

  @override
  String get helpTitle => 'Aide';

  @override
  String get helpIntro =>
      'Un bloc-notes LAN pour les notes en texte brut. Les appareils sur le même Wi‑Fi se découvrent mutuellement, s\'associent une fois, puis synchronisent les notes en temps réel.';

  @override
  String get helpAboutTile => 'À propos de SB Simple Netpad';

  @override
  String get helpEulaSubtitle => 'Ouvre l\'EULA sur GitHub Pages';

  @override
  String get helpPrivacySubtitle =>
      'Ouvre la page de confidentialité sur GitHub Pages';

  @override
  String get helpGettingStartedTitle => 'Prise en main';

  @override
  String get helpGettingStarted1 =>
      'Rejoignez le même réseau Wi‑Fi que les appareils avec lesquels vous souhaitez synchroniser.';

  @override
  String get helpGettingStarted2 =>
      'Ouvrez le panneau des pairs (icône de cadenas ou tiroir Pairs) et attendez que les appareils à proximité apparaissent.';

  @override
  String get helpGettingStarted3 =>
      'Copiez votre adresse depuis Cet appareil et partagez-la si la découverte est lente.';

  @override
  String get helpGettingStarted4 =>
      'Utilisez Connecter par IP lorsque la découverte mDNS ne trouve pas de pairs.';

  @override
  String get helpNotesTitle => 'Notes';

  @override
  String get helpNotes1 =>
      'Appuyez sur l\'icône de menu (☰) ou sur le panneau de notes pour basculer entre les notes.';

  @override
  String get helpNotes2 =>
      'Créez, renommez, réorganisez et supprimez des notes depuis la liste des notes.';

  @override
  String get helpNotes3 =>
      'Chaque note se synchronise indépendamment — les nouvelles notes démarrent en local uniquement ; activez la sync pour partager avec les pairs.';

  @override
  String get helpNotes4 =>
      'Recherchez dans une note (Rechercher) ou dans toutes les notes depuis l\'éditeur.';

  @override
  String get helpNotes5 =>
      'L\'historique des versions enregistre des instantanés locaux que vous pouvez restaurer ultérieurement.';

  @override
  String get helpPeersTitle => 'Pairs et association';

  @override
  String get helpPeers1 =>
      'À proximité liste les appareils découverts dans la même salle (voir Paramètres).';

  @override
  String get helpPeers2 =>
      'Appuyez sur Connecter sur un pair — l\'autre appareil doit appuyer sur Accepter.';

  @override
  String get helpPeers3 =>
      'Comparez le code de vérification d\'association avant d\'accepter.';

  @override
  String get helpPeers4 =>
      'Cochez Faire confiance pour la synchro auto à l\'acceptation si vous voulez que les reconnexions ignorent Accepter.';

  @override
  String get helpPeers5 =>
      'Appareils de confiance : activez/désactivez la synchronisation automatique ou Révoquer pour exiger à nouveau Accepter.';

  @override
  String get helpPeers6 =>
      'Bloquer déconnecte un appareil et refuse les futures associations jusqu\'à ce qu\'il soit débloqué.';

  @override
  String get helpPeers7 =>
      'Connecté affiche les sessions actives avec l\'adresse et la présence du curseur.';

  @override
  String get helpFileSharingTitle => 'Fichiers et partage';

  @override
  String get helpFileSharing1Desktop =>
      'Menu Fichier : Enregistrer dans un fichier, Ouvrir un fichier comme nouvelle note, Partager la note, Historique des versions, Paramètres, Quitter.';

  @override
  String get helpFileSharing1Macos =>
      'File menu: Save to File, Open File as New Note, Share Note, Version History. Settings are under the app menu (Cmd+,); Quit ends the app.';

  @override
  String get helpFileSharing1Mobile =>
      'Menu (⋮) : enregistrer dans un fichier, ouvrir un fichier comme nouvelle note, partager, historique des versions, paramètres et ce guide d\'aide.';

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
      'Partager utilise la feuille de partage du système lorsqu\'elle est disponible ; sinon la note est copiée dans le presse-papiers.';

  @override
  String get helpSettingsTitle => 'Paramètres';

  @override
  String get helpSettings1 =>
      'Le nom de l\'appareil et la salle nécessitent Enregistrer — les autres options s\'appliquent immédiatement.';

  @override
  String get helpSettings2 =>
      'L\'ID de salle regroupe les pairs : seuls les appareils dans la même salle sont découverts.';

  @override
  String get helpSettings3 =>
      'Les préférences d\'apparence et d\'éditeur (thème, skin, retour à la ligne, police) s\'enregistrent au fur et à mesure.';

  @override
  String get helpDesktopShortcutsTitle => 'Raccourcis bureau';

  @override
  String get helpDesktopShortcuts1 =>
      'Ctrl/Cmd+S — Enregistrer dans un fichier';

  @override
  String get helpDesktopShortcuts2 =>
      'Ctrl/Cmd+O — Ouvrir un fichier comme nouvelle note';

  @override
  String get helpDesktopShortcuts3 => 'Ctrl/Cmd+F — Rechercher dans la note';

  @override
  String get helpDesktopShortcuts4 =>
      'Ctrl+H (Windows) or Option+Cmd+F (macOS) — Find and replace';

  @override
  String get helpDesktopShortcuts5 =>
      'Ctrl/Cmd+N — Basculer le panneau de notes';

  @override
  String get helpDesktopShortcuts6 =>
      'Ctrl/Cmd+P — Basculer le panneau des pairs';

  @override
  String get helpDesktopShortcuts7 =>
      'Ctrl/Cmd+Q — Exit (Windows); macOS uses Quit from the app menu';

  @override
  String get helpTroubleshootingTitle => 'Dépannage';

  @override
  String get helpTroubleshooting1 =>
      'Pas de pairs ? Confirmez le même sous-réseau Wi‑Fi et l\'ID de salle ; essayez Connecter par IP.';

  @override
  String get helpTroubleshooting2 =>
      'La bannière réseau local requis signifie que la synchronisation est suspendue jusqu\'à ce que le Wi‑Fi soit actif.';

  @override
  String get helpTroubleshooting3 =>
      'Autorisez l\'application via votre pare-feu au premier lancement (bureau).';

  @override
  String get helpTroubleshooting4 =>
      'Assurez-vous que tous les appareils sont sur le même sous-réseau Wi‑Fi et que le réseau local / le pare-feu autorisent la découverte.';

  @override
  String get helpTroubleshooting5 =>
      'Android : accordez la permission Wi‑Fi à proximité lorsqu\'elle est demandée.';

  @override
  String get helpTroubleshooting6 =>
      'iOS/macOS: allow Local Network access for SB Simple Netpad in System Settings if peers never appear.';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutTagline =>
      'Bloc-notes LAN avec découverte de pairs et édition partagée.';

  @override
  String get aboutDescription =>
      'Rédigez des notes en texte brut sur votre téléphone ou ordinateur et maintenez-les synchronisées avec d\'autres appareils sur le même Wi‑Fi. Les pairs se découvrent sur le réseau local, s\'associent une fois avec approbation mutuelle, puis partagent plusieurs notes nommées avec des sessions de pairs chiffrées.';

  @override
  String get aboutPlatforms => 'Android · iOS · Windows · macOS';

  @override
  String get aboutStatus => 'Adapté à un usage LAN quotidien.';

  @override
  String get aboutEulaHeading => 'Contrat de licence utilisateur final';

  @override
  String aboutEulaBody(int noteLimit, int peerLimit) {
    return 'SB Simple Netpad est sous licence EULA, pas une licence open source. L\'édition principale et la synchronisation LAN sont gratuites (notes locales illimitées, jusqu\'à $noteLimit notes synchronisées et $peerLimit pairs connectés). Netpad Standard est un déblocage unique via l\'App Store, Google Play ou Microsoft Store.';
  }

  @override
  String get aboutViewEula => 'Voir l\'EULA';

  @override
  String get aboutPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get aboutHowToUse => 'Comment utiliser SB Simple Netpad';

  @override
  String get aboutCouldNotOpenPrivacy =>
      'Impossible d\'ouvrir la politique de confidentialité';

  @override
  String get aboutCouldNotOpenEula => 'Impossible d\'ouvrir l\'EULA';

  @override
  String get aboutCopyright => '© 2026 Spencer Beaumier';

  @override
  String conflictLiveTitle(String title) {
    return 'Conflit de modification dans \"$title\"';
  }

  @override
  String conflictLiveBody(
    String peer,
    String revision,
    String localPreview,
    String remotePreview,
  ) {
    return '$peer a modifié la même note en même temps (révision $revision).\n\nLa vôtre :\n$localPreview\n\n$peer :\n$remotePreview\n\nQuelle version les deux appareils doivent-ils conserver ?';
  }

  @override
  String conflictDivergedTitle(String title) {
    return '\"$title\" a divergé';
  }

  @override
  String conflictDivergedBody(
    String peer,
    String title,
    int localChars,
    int remoteChars,
  ) {
    return 'Votre copie et la copie de $peer de \"$title\" ont changé différemment pendant la déconnexion.\n\nLa vôtre : $localChars caractères\n$peer : $remoteChars caractères\n\nQuelle version les deux appareils doivent-ils conserver ?';
  }

  @override
  String conflictUsePeers(String peer) {
    return 'Utiliser celle de $peer';
  }

  @override
  String get conflictKeepMine => 'Garder la mienne';

  @override
  String fileSavedTo(String path) {
    return 'Enregistré dans $path';
  }

  @override
  String fileCouldNotSave(String error) {
    return 'Impossible d\'enregistrer : $error';
  }

  @override
  String fileOpenedAsNewNote(String name) {
    return '$name ouvert comme nouvelle note';
  }

  @override
  String fileCouldNotOpen(String error) {
    return 'Impossible d\'ouvrir : $error';
  }

  @override
  String get fileNothingToShare => 'Rien à partager — la note est vide';

  @override
  String get fileShareFallbackClipboard =>
      'Partage non disponible ici — copié dans le presse-papiers';

  @override
  String get fileDefaultNoteName => 'netpad-note';
}
