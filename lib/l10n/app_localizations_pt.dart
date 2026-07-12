// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get commonAppName => 'SB Simple Netpad';

  @override
  String get commonStandardName => 'Netpad Standard';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonConnect => 'Conectar';

  @override
  String get commonHelp => 'Ajuda';

  @override
  String get commonSettings => 'ConfiguraÃ§Ãµes';

  @override
  String get commonMore => 'Mais';

  @override
  String get commonCopy => 'Copiar';

  @override
  String get commonClear => 'Limpar';

  @override
  String get commonAccept => 'Aceitar';

  @override
  String get commonReject => 'Rejeitar';

  @override
  String get commonBlock => 'Bloquear';

  @override
  String get commonUnblock => 'Desbloquear';

  @override
  String get commonRevoke => 'Revogar';

  @override
  String get commonRestore => 'Restaurar';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String commonCouldNotOpenLabel(String label) {
    return 'NÃ£o foi possÃ­vel abrir $label';
  }

  @override
  String get commonEulaLabel => 'EULA';

  @override
  String get commonPrivacyPolicyLabel => 'polÃ­tica de privacidade';

  @override
  String get commonEndUserLicenseAgreement =>
      'Contrato de LicenÃ§a do UsuÃ¡rio Final';

  @override
  String get commonPrivacyPolicy => 'PolÃ­tica de Privacidade';

  @override
  String commonVersionLabel(String version) {
    return 'VersÃ£o $version';
  }

  @override
  String get shellMenuFile => 'Arquivo';

  @override
  String get shellMenuEdit => 'Editar';

  @override
  String get shellMenuView => 'Exibir';

  @override
  String get shellMenuHelp => 'Ajuda';

  @override
  String get shellSaveToFile => 'Salvar em arquivoâ€¦';

  @override
  String get shellOpenFileAsNewNote => 'Abrir arquivo como nova notaâ€¦';

  @override
  String get shellShareNote => 'Compartilhar nota';

  @override
  String get shellVersionHistory => 'HistÃ³rico de versÃµesâ€¦';

  @override
  String get shellSettings => 'ConfiguraÃ§Ãµesâ€¦';

  @override
  String get shellExit => 'Sair';

  @override
  String get shellCut => 'Recortar';

  @override
  String get shellCopy => 'Copiar';

  @override
  String get shellPaste => 'Colar';

  @override
  String get shellFind => 'Localizarâ€¦';

  @override
  String get shellFindAndReplace => 'Localizar e substituirâ€¦';

  @override
  String get shellWordWrap => 'Quebra de linha';

  @override
  String get shellWordWrapChecked => 'Quebra de linha âœ“';

  @override
  String get shellNotesPanel => 'Painel de notas';

  @override
  String get shellNotesPanelChecked => 'Painel de notas âœ“';

  @override
  String get shellPeersPanel => 'Painel de pares';

  @override
  String get shellPeersPanelChecked => 'Painel de pares âœ“';

  @override
  String get shellHelpItem => 'Ajuda do SB Simple Netpad';

  @override
  String get shellAboutItem => 'Sobre o SB Simple Netpad';

  @override
  String get shellHideNotesPanel => 'Ocultar painel de notas';

  @override
  String get shellShowNotesPanel => 'Mostrar painel de notas (Ctrl+N)';

  @override
  String get shellHidePeersPanel => 'Ocultar painel de pares';

  @override
  String get shellShowPeersPanel => 'Mostrar painel de pares (Ctrl+P)';

  @override
  String shellPeersTooltipConnected(int count, String action) {
    return '$count sessÃµes de pares criptografadas Â· $action painel de pares (Ctrl+P)';
  }

  @override
  String get shellPeersTooltipActionHide => 'ocultar';

  @override
  String get shellPeersTooltipActionShow => 'mostrar';

  @override
  String get shellFindInNote => 'Localizar na nota (Ctrl+F)';

  @override
  String shellSecurityChipConnected(int count) {
    return '$count sessÃµes de pares criptografadas com WSS/TLS Â· toque para ver pares';
  }

  @override
  String get shellSecurityChipNone =>
      'Sem sessÃµes de pares ativas Â· toque para ver pares';

  @override
  String get shellMobileWordWrap => 'Quebra de linha';

  @override
  String get shellMobileSaveToFile => 'Salvar em arquivoâ€¦';

  @override
  String get shellMobileOpenFileAsNewNote => 'Abrir arquivo como nova notaâ€¦';

  @override
  String get shellMobileShareNote => 'Compartilhar nota';

  @override
  String get shellMobileVersionHistory => 'HistÃ³rico de versÃµesâ€¦';

  @override
  String get shellMobileSettings => 'ConfiguraÃ§Ãµes';

  @override
  String get shellMobileHelp => 'Ajuda';

  @override
  String get shellMobileAbout => 'Sobre o SB Simple Netpad';

  @override
  String get shellListeningSnack =>
      'Ouvindoâ€¦ toque no microfone novamente para parar';

  @override
  String get notesTitle => 'Notas';

  @override
  String get notesNewNote => 'Nova nota';

  @override
  String get notesSearchHint => 'Pesquisar em todas as notas';

  @override
  String get notesRenameTitle => 'Renomear nota';

  @override
  String get notesTitleLabel => 'TÃ­tulo';

  @override
  String notesDeleteTitle(String title) {
    return 'Excluir \"$title\"?';
  }

  @override
  String get notesDeleteSyncedBody =>
      'Isso remove a nota para vocÃª e todos os pares conectados.';

  @override
  String get notesDeleteLocalBody =>
      'Isso remove a nota somente deste dispositivo.';

  @override
  String get notesNoMatches => 'Nenhuma correspondÃªncia';

  @override
  String get notesNoNotes => 'Nenhuma nota';

  @override
  String get notesRename => 'Renomear';

  @override
  String get notesVersionHistory => 'HistÃ³rico de versÃµes';

  @override
  String get notesDelete => 'Excluir';

  @override
  String get notesSyncWithPeers => 'Sincronizar com pares';

  @override
  String get notesLocalOnly => 'Somente local';

  @override
  String get notesEmptyNote => 'Nota vazia';

  @override
  String notesMatchCount(int count) {
    return '$count correspondÃªncias';
  }

  @override
  String notesLocalOnlyWithMatches(String matchLine) {
    return 'Somente local Â· $matchLine';
  }

  @override
  String notesSearchSnippetMatches(String snippet, int count) {
    return '$snippet  Â·  $count correspondÃªncias';
  }

  @override
  String get notesNoNoteSelected => 'Nenhuma nota selecionada';

  @override
  String historyTitle(String title) {
    return 'HistÃ³rico de versÃµes Â· \"$title\"';
  }

  @override
  String get historyEmpty =>
      'Nenhuma versÃ£o salva ainda. InstantÃ¢neos sÃ£o mantidos automaticamente antes que ediÃ§Ãµes remotas substituam seu texto.';

  @override
  String historyEntrySubtitle(String label, String time, int chars) {
    return '$label Â· $time Â· $chars caracteres';
  }

  @override
  String get historyRestore => 'Restaurar';

  @override
  String get historyRestoredSnack => 'VersÃ£o restaurada';

  @override
  String get historyBeforeRemoteUpdate => 'Antes da atualizaÃ§Ã£o remota';

  @override
  String get historySnapshot => 'InstantÃ¢neo';

  @override
  String get historyImportedFile => 'Arquivo importado';

  @override
  String get editorFindHint => 'Localizar';

  @override
  String get editorReplaceHint => 'Substituir por';

  @override
  String editorMatchCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get editorMatchNone => '0/0';

  @override
  String get editorPrevious => 'Anterior';

  @override
  String get editorNext => 'PrÃ³ximo';

  @override
  String get editorShowReplace => 'Mostrar substituiÃ§Ã£o (Ctrl+H)';

  @override
  String get editorHideReplace => 'Ocultar substituiÃ§Ã£o (Ctrl+H)';

  @override
  String get editorClose => 'Fechar';

  @override
  String get editorReplace => 'Substituir';

  @override
  String get editorReplaceAll => 'Todos';

  @override
  String get editorListening => 'Ouvindoâ€¦';

  @override
  String get editorDictate => 'Ditar';

  @override
  String get editorStopDictation => 'Parar ditado';

  @override
  String get peersConnectByIp => 'Conectar por IP';

  @override
  String get peersConnected => 'Conectado';

  @override
  String get peersNearby => 'PrÃ³ximos';

  @override
  String get peersTrustedDevices => 'Dispositivos confiÃ¡veis';

  @override
  String get peersBlocked => 'Bloqueados';

  @override
  String get peersConnectionLog => 'Registro de conexÃµes';

  @override
  String get peersNoActiveConnections => 'Nenhuma conexÃ£o ativa';

  @override
  String get peersNoTrustedDevices =>
      'Nenhum dispositivo confiÃ¡vel â€” emparelhe uma vez para habilitar sincronizaÃ§Ã£o automÃ¡tica';

  @override
  String get peersNoBlockedDevices => 'Nenhum dispositivo bloqueado';

  @override
  String get peersNoConnectionEvents => 'Nenhum evento de conexÃ£o ainda';

  @override
  String get peersNoDiscoveredPeers =>
      'Nenhum par descoberto â€” o Linux deve estar na mesma sub-rede Wiâ€‘Fi que Este dispositivo (verifique o endereÃ§o acima), ou use Conectar por IP';

  @override
  String get peersDiscoveryPaused =>
      'A descoberta de pares estÃ¡ pausada atÃ© que vocÃª entre em uma rede local';

  @override
  String get peersDisconnect => 'Desconectar';

  @override
  String get peersConnectNow => 'Conectar agora';

  @override
  String get peersConnect => 'Conectar';

  @override
  String get peersResolving => 'Resolvendoâ€¦';

  @override
  String get peersBlockTooltip => 'Bloquear';

  @override
  String peersBlockTitle(String peer) {
    return 'Bloquear $peer?';
  }

  @override
  String get peersBlockBody =>
      'Isso desconecta o dispositivo, esquece seu certificado fixado e recusa futuras solicitaÃ§Ãµes de conexÃ£o atÃ© que vocÃª o desbloqueie.';

  @override
  String peersRevokeTitle(String peer) {
    return 'Revogar $peer?';
  }

  @override
  String get peersRevokeBody =>
      'A prÃ³xima conexÃ£o exigirÃ¡ tocar em Aceitar novamente. O PIN de seguranÃ§a Ã© mantido para que as verificaÃ§Ãµes de certificado ainda se apliquem.';

  @override
  String get peersAutoSync => 'SincronizaÃ§Ã£o automÃ¡tica';

  @override
  String get peersCopiedOneLogEntry => '1 entrada de registro copiada';

  @override
  String peersCopiedLogEntries(int count) {
    return '$count entradas de registro copiadas';
  }

  @override
  String peersLogRevision(String time, String revision) {
    return '$time â€¢ revisÃ£o $revision';
  }

  @override
  String peersStillResolving(String peer) {
    return 'Ainda resolvendo $peerâ€¦';
  }

  @override
  String peersResolveFailedSnack(String peer) {
    return 'NÃ£o foi possÃ­vel resolver $peer. Verifique o Avahi e a mesma sub-rede, ou use Conectar por IP.';
  }

  @override
  String peersPairingRequestSent(String peer) {
    return 'SolicitaÃ§Ã£o de emparelhamento enviada para $peer';
  }

  @override
  String peersCouldNotConnect(String message) {
    return 'NÃ£o foi possÃ­vel conectar: $message';
  }

  @override
  String peersManualHostPort(String host, int port) {
    return '$host:$port (manual)';
  }

  @override
  String get peersManual => 'Manual';

  @override
  String get peersResolveFailedSubtitle =>
      'ResoluÃ§Ã£o falhou â€” tente Conectar por IP';

  @override
  String get peersResolvingAddress => 'Resolvendo endereÃ§oâ€¦';

  @override
  String peersHostPort(String host, int port) {
    return '$host:$port';
  }

  @override
  String get peersNoAddressYet => 'Nenhum endereÃ§o ainda';

  @override
  String peersEncryptedPinned(String code) {
    return 'Criptografado Â· fixado $code';
  }

  @override
  String get peersEncryptedWss => 'Criptografado (WSS/TLS)';

  @override
  String peersSubtitleWithPresence(String subtitle, String presence) {
    return '$subtitle â€¢ $presence';
  }

  @override
  String peersSubtitleWithSecurity(String subtitle, String security) {
    return '$subtitle â€¢ $security';
  }

  @override
  String peersPairedStatus(String date, String status) {
    return 'Emparelhado em $date Â· $status';
  }

  @override
  String get peersStatusConnected => 'Conectado';

  @override
  String get peersStatusManualOnly => 'Somente manual';

  @override
  String get peersStatusReconnecting => 'Reconectandoâ€¦';

  @override
  String peersStatusRetryIn(int seconds) {
    return 'Tentar novamente em ${seconds}s';
  }

  @override
  String get peersStatusNotOnNetwork => 'Fora da rede';

  @override
  String get peersStatusConnecting => 'Conectandoâ€¦';

  @override
  String get peersStatusAutoReconnect => 'ReconexÃ£o automÃ¡tica';

  @override
  String peersPresenceLineCol(int line, int column) {
    return 'linha $line, col $column';
  }

  @override
  String peersPresenceInNote(String title, String position) {
    return '\"$title\" Â· $position';
  }

  @override
  String peersRoomLabel(String room) {
    return 'Sala \"$room\"';
  }

  @override
  String get discoveryThisDevice => 'Este dispositivo';

  @override
  String get discoveryCopyAddress => 'Copiar endereÃ§o';

  @override
  String discoveryCopiedAddress(String address) {
    return 'Copiado $address';
  }

  @override
  String get discoveryLocalNetworkRequired => 'Rede local necessÃ¡ria';

  @override
  String get discoveryNotListeningTitle => 'NÃ£o estÃ¡ ouvindo';

  @override
  String get discoveryNotListeningBody =>
      'Este dispositivo ainda nÃ£o estÃ¡ ouvindo por pares. Aguarde alguns segundos apÃ³s entrar no Wiâ€‘Fi, ou toque em Tentar novamente em um banner de erro de rede.';

  @override
  String get discoveryModeTitle => 'Modo de descoberta';

  @override
  String get discoveryUnavailableTitle => 'Descoberta de pares indisponÃ­vel';

  @override
  String get discoveryRetryTooltip => 'Tentar descoberta novamente';

  @override
  String get peersSecuredSessions => 'SessÃµes seguras';

  @override
  String peersSecurityBannerIdle(String code) {
    return 'Este dispositivo anuncia via WSS/TLS Â· cÃ³digo $code';
  }

  @override
  String peersSecurityBannerActive(int connectedCount, int pinnedCount) {
    return '$connectedCount sessÃµes criptografadas Â· $pinnedCount certificados fixados';
  }

  @override
  String peersSecurityCompactIdle(String code) {
    return 'WSS/TLS Â· cÃ³digo $code';
  }

  @override
  String peersSecurityCompactActive(int connectedCount, int pinnedCount) {
    return '$connectedCount criptografadas Â· $pinnedCount fixados';
  }

  @override
  String peersSecurityTooltipPinned(String code) {
    return 'Criptografado (WSS/TLS) Â· fixado $code';
  }

  @override
  String get peersSecurityTooltipActive =>
      'Criptografado (WSS/TLS) Â· sessÃ£o ativa';

  @override
  String get pairingConnectionRequest => 'SolicitaÃ§Ã£o de conexÃ£o';

  @override
  String pairingAllowPeer(String peer) {
    return 'Permitir que $peer se conecte e compartilhe esta nota?';
  }

  @override
  String get pairingVerificationCode => 'CÃ³digo de verificaÃ§Ã£o';

  @override
  String get pairingConfirmCode =>
      'Confirme que este cÃ³digo corresponde em ambos os dispositivos antes de aceitar.';

  @override
  String get pairingThisDeviceSecurityCode =>
      'CÃ³digo de seguranÃ§a deste dispositivo';

  @override
  String get pairingOtherDevicePins =>
      'O outro dispositivo fixa isso na primeira conexÃ£o.';

  @override
  String get manualConnectTitle => 'Conectar por endereÃ§o';

  @override
  String get manualConnectBody =>
      'Use quando a descoberta nÃ£o encontrar pares na mesma sub-rede. Somente endereÃ§os no seu segmento de rede local ativo sÃ£o permitidos.';

  @override
  String get manualConnectHostLabel => 'Host ou IP';

  @override
  String get manualConnectHostHint => '192.168.1.42';

  @override
  String get manualConnectPortLabel => 'Porta';

  @override
  String get manualConnectPortHint => '54321';

  @override
  String get manualConnectLabelOptional => 'RÃ³tulo (opcional)';

  @override
  String get manualConnectLabelHint => 'PC da sala';

  @override
  String get manualConnectInvalidHostPort =>
      'Digite um host e porta vÃ¡lidos (1â€“65535)';

  @override
  String get settingsTitle => 'ConfiguraÃ§Ãµes';

  @override
  String get settingsDeviceSection => 'Dispositivo';

  @override
  String get settingsDeviceHint =>
      'O nome do dispositivo e a sala requerem Salvar (Ctrl+S). As preferÃªncias de aparÃªncia e editor sÃ£o salvas imediatamente.';

  @override
  String get settingsDeviceName => 'Nome do dispositivo';

  @override
  String get settingsDeviceNameHint => 'Nome exibido para outros dispositivos';

  @override
  String get settingsSessionRoom => 'SessÃ£o / sala';

  @override
  String get settingsSessionRoomHint =>
      'Somente pares na mesma sala sÃ£o descobertos';

  @override
  String get settingsListeningPort => 'Porta de escuta';

  @override
  String get settingsStartingServer => 'Iniciando servidorâ€¦';

  @override
  String settingsAddressShare(String address) {
    return '$address (compartilhe para conexÃ£o manual)';
  }

  @override
  String get settingsCopyAddress => 'Copiar endereÃ§o';

  @override
  String get settingsAddressCopied =>
      'EndereÃ§o copiado para a Ã¡rea de transferÃªncia';

  @override
  String settingsSavedSnack(String name, String room) {
    return 'ConfiguraÃ§Ãµes salvas Â· \"$name\" Â· sala \"$room\"';
  }

  @override
  String get settingsAppearanceSection => 'AparÃªncia';

  @override
  String get settingsMode => 'Modo';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsSkin => 'Visual';

  @override
  String get settingsSkinDefault => 'PadrÃ£o';

  @override
  String get settingsSkinOcean => 'Oceano';

  @override
  String get settingsSkinForest => 'Floresta';

  @override
  String get settingsSkinSunset => 'PÃ´r do sol';

  @override
  String get settingsSkinSlate => 'ArdÃ³sia';

  @override
  String settingsSkinStandardLabel(String skin) {
    return '$skin Â· Standard';
  }

  @override
  String get settingsStandardSection => 'Netpad Standard';

  @override
  String get settingsStandardUnlocked => 'Standard desbloqueado';

  @override
  String get settingsFree => 'GrÃ¡tis';

  @override
  String get settingsStandardUnlockedSubtitle =>
      'Notas e pares ilimitados, visuais, histÃ³rico, sincronizaÃ§Ã£o automÃ¡tica e voz';

  @override
  String get settingsStandardBuySubtitle =>
      'Desbloqueio Ãºnico pela sua loja de aplicativos';

  @override
  String get settingsPurchasesUnavailable =>
      'Compras indisponÃ­veis nesta plataforma';

  @override
  String get settingsRestorePurchases => 'Restaurar compras';

  @override
  String get settingsStandardRestored => 'Standard restaurado';

  @override
  String get settingsNoPreviousStandard =>
      'Nenhuma compra anterior de Standard encontrada';

  @override
  String get settingsEditorSection => 'Editor';

  @override
  String get settingsWordWrap => 'Quebra de linha';

  @override
  String get settingsWordWrapSubtitle =>
      'Quebrar linhas longas em vez de rolar horizontalmente';

  @override
  String settingsFontSize(int size) {
    return 'Tamanho da fonte ($size pt)';
  }

  @override
  String get settingsLegalSection => 'Legal';

  @override
  String get settingsEulaSubtitleStandard =>
      'Standard Â· Abre EULA no GitHub Pages';

  @override
  String get settingsEulaSubtitleFree => 'GrÃ¡tis Â· Abre EULA no GitHub Pages';

  @override
  String get settingsPrivacySubtitle =>
      'Abre pÃ¡gina de privacidade no GitHub Pages';

  @override
  String get settingsDisclaimerTitle =>
      'IsenÃ§Ã£o de responsabilidade e responsabilidade civil';

  @override
  String get settingsDisclaimerSubtitle => 'Use por sua prÃ³pria conta e risco';

  @override
  String get settingsDisclaimerP1 =>
      'Este software Ã© fornecido \"como estÃ¡\", sem garantias de qualquer tipo, expressas ou implÃ­citas, incluindo comercializaÃ§Ã£o, adequaÃ§Ã£o a uma finalidade especÃ­fica e nÃ£o violaÃ§Ã£o.';

  @override
  String get settingsDisclaimerP2 =>
      'VocÃª Ã© o Ãºnico responsÃ¡vel pela forma como usa este aplicativo e pelo cumprimento de todas as leis, regulamentos, polÃ­ticas e acordos aplicÃ¡veis.';

  @override
  String get settingsDisclaimerP3 =>
      'O titular do direito autoral nÃ£o Ã© responsÃ¡vel por quaisquer reclamaÃ§Ãµes, danos, perdas, perda de dados, interrupÃ§Ã£o de negÃ³cios ou outra responsabilidade decorrente do uso ou mau uso deste software.';

  @override
  String get settingsNoLegalAdviceTitle => 'Sem aconselhamento jurÃ­dico';

  @override
  String get settingsNoLegalAdviceSubtitle => 'Apenas software informativo';

  @override
  String get settingsNoLegalAdviceP1 =>
      'Este aplicativo e sua documentaÃ§Ã£o nÃ£o fornecem aconselhamento jurÃ­dico, regulatÃ³rio ou profissional.';

  @override
  String get settingsNoLegalAdviceP2 =>
      'Se vocÃª precisar de orientaÃ§Ã£o jurÃ­dica para seu caso de uso, consulte um profissional qualificado.';

  @override
  String get settingsCopyright => 'Â© 2026 Spencer Beaumier';

  @override
  String get paywallTitle => 'Desbloquear Netpad Standard';

  @override
  String get paywallSubtitle =>
      'Compra Ãºnica. EdiÃ§Ã£o bÃ¡sica e sincronizaÃ§Ã£o LAN permanecem gratuitas.';

  @override
  String get paywallBenefitUnlimitedNotes => 'Notas ilimitadas';

  @override
  String get paywallBenefitUnlimitedPeers => 'Pares conectados ilimitados';

  @override
  String get paywallBenefitSkins => 'Visuais de cores extras';

  @override
  String get paywallBenefitHistory => 'HistÃ³rico de versÃµes';

  @override
  String get paywallBenefitAutoSync =>
      'SincronizaÃ§Ã£o automÃ¡tica com pares confiÃ¡veis';

  @override
  String get paywallBenefitVoice => 'Ditado por voz';

  @override
  String get paywallPurchasesUnsupported =>
      'Compras no aplicativo nÃ£o estÃ£o disponÃ­veis nesta plataforma. Instale da App Store, Google Play ou Microsoft Store para desbloquear o Standard.';

  @override
  String get paywallBuyStandard => 'Comprar Standard';

  @override
  String paywallBuyStandardPrice(String price) {
    return 'Comprar Standard Â· $price';
  }

  @override
  String get paywallRestorePurchases => 'Restaurar compras';

  @override
  String get paywallPurchaseNotCompleted => 'A compra nÃ£o foi concluÃ­da.';

  @override
  String get paywallPurchaseFailed => 'A compra falhou.';

  @override
  String get paywallStandardRestored => 'Standard restaurado';

  @override
  String get paywallNoPreviousStandard =>
      'Nenhuma compra anterior de Standard encontrada';

  @override
  String standardHighlightNoteLimit(int limit) {
    return 'A versÃ£o gratuita inclui atÃ© $limit notas. Desbloqueie o Standard para notas ilimitadas.';
  }

  @override
  String standardHighlightPeerLimit(int limit) {
    return 'A versÃ£o gratuita inclui atÃ© $limit pares conectados. Desbloqueie o Standard para pares ilimitados.';
  }

  @override
  String get standardHighlightVersionHistory =>
      'O histÃ³rico de versÃµes Ã© um recurso Standard.';

  @override
  String get standardHighlightVoice =>
      'O ditado por voz Ã© um recurso Standard.';

  @override
  String get standardHighlightAutoSync =>
      'A sincronizaÃ§Ã£o automÃ¡tica com pares confiÃ¡veis Ã© um recurso Standard.';

  @override
  String get standardHighlightSkins =>
      'Visuais extras estÃ£o incluÃ­dos no Standard.';

  @override
  String get helpTitle => 'Ajuda';

  @override
  String get helpIntro =>
      'Um bloco de notas LAN para notas em texto simples. Dispositivos na mesma rede Wiâ€‘Fi se descobrem, emparelham uma vez e sincronizam notas em tempo real.';

  @override
  String get helpAboutTile => 'Sobre o SB Simple Netpad';

  @override
  String get helpEulaSubtitle => 'Abre EULA no GitHub Pages';

  @override
  String get helpPrivacySubtitle =>
      'Abre pÃ¡gina de privacidade no GitHub Pages';

  @override
  String get helpGettingStartedTitle => 'Primeiros passos';

  @override
  String get helpGettingStarted1 =>
      'Entre na mesma rede Wiâ€‘Fi que os dispositivos com os quais deseja sincronizar.';

  @override
  String get helpGettingStarted2 =>
      'Abra o painel de pares (Ã­cone de cadeado ou gaveta de Pares) e aguarde os dispositivos prÃ³ximos aparecerem.';

  @override
  String get helpGettingStarted3 =>
      'Copie seu endereÃ§o de Este dispositivo e compartilhe se a descoberta estiver lenta.';

  @override
  String get helpGettingStarted4 =>
      'Use Conectar por IP quando a descoberta mDNS nÃ£o encontrar pares.';

  @override
  String get helpNotesTitle => 'Notas';

  @override
  String get helpNotes1 =>
      'Toque no Ã­cone de menu (â˜°) ou no painel de notas para alternar entre notas.';

  @override
  String get helpNotes2 =>
      'Crie, renomeie, reordene e exclua notas na lista de notas.';

  @override
  String get helpNotes3 =>
      'Cada nota sincroniza de forma independente â€” alterne a sincronizaÃ§Ã£o por nota quando necessÃ¡rio.';

  @override
  String get helpNotes4 =>
      'Pesquise dentro de uma nota (Localizar) ou em todas as notas pelo editor.';

  @override
  String get helpNotes5 =>
      'O histÃ³rico de versÃµes salva instantÃ¢neos locais que vocÃª pode restaurar posteriormente.';

  @override
  String get helpPeersTitle => 'Pares e emparelhamento';

  @override
  String get helpPeers1 =>
      'PrÃ³ximos lista os dispositivos descobertos na mesma sala (veja ConfiguraÃ§Ãµes).';

  @override
  String get helpPeers2 =>
      'Toque em Conectar em um par â€” o outro dispositivo deve tocar em Aceitar.';

  @override
  String get helpPeers3 =>
      'Compare o cÃ³digo de verificaÃ§Ã£o de emparelhamento antes de aceitar.';

  @override
  String get helpPeers4 =>
      'ApÃ³s o primeiro Aceitar, dispositivos confiÃ¡veis podem se reconectar automaticamente.';

  @override
  String get helpPeers5 =>
      'Dispositivos confiÃ¡veis: alterne sincronizaÃ§Ã£o automÃ¡tica ou Revogar para exigir Aceitar novamente.';

  @override
  String get helpPeers6 =>
      'Bloquear desconecta um dispositivo e recusa emparelhamentos futuros atÃ© ser desbloqueado.';

  @override
  String get helpPeers7 =>
      'Conectado mostra sessÃµes ativas com endereÃ§o e presenÃ§a do cursor.';

  @override
  String get helpFileSharingTitle => 'Arquivos e compartilhamento';

  @override
  String get helpFileSharing1Desktop =>
      'Menu Arquivo: Salvar em arquivo, Abrir arquivo como nova nota, Compartilhar nota, HistÃ³rico de versÃµes, ConfiguraÃ§Ãµes, Sair.';

  @override
  String get helpFileSharing1Mobile =>
      'Menu (â‹®): salvar em arquivo, abrir arquivo como nova nota, compartilhar, histÃ³rico de versÃµes, configuraÃ§Ãµes e este guia de ajuda.';

  @override
  String get helpFileSharing2 =>
      'Salvar em arquivo exporta a nota ativa como .txt ou .md.';

  @override
  String get helpFileSharing3 =>
      'Abrir arquivo importa texto para uma nova nota que sincroniza como qualquer outra.';

  @override
  String get helpFileSharing4 =>
      'Compartilhar usa a planilha de compartilhamento do SO; Linux recorre Ã  Ã¡rea de transferÃªncia.';

  @override
  String get helpSettingsTitle => 'ConfiguraÃ§Ãµes';

  @override
  String get helpSettings1 =>
      'O nome do dispositivo e a sala requerem Salvar â€” outras opÃ§Ãµes se aplicam imediatamente.';

  @override
  String get helpSettings2 =>
      'O ID da sala agrupa pares: somente dispositivos na mesma sala sÃ£o descobertos.';

  @override
  String get helpSettings3 =>
      'As preferÃªncias de aparÃªncia e editor (tema, visual, quebra, fonte) sÃ£o salvas ao alterÃ¡-las.';

  @override
  String get helpDesktopShortcutsTitle => 'Atalhos de teclado';

  @override
  String get helpDesktopShortcuts1 => 'Ctrl/Cmd+S â€” Salvar em arquivo';

  @override
  String get helpDesktopShortcuts2 =>
      'Ctrl/Cmd+O â€” Abrir arquivo como nova nota';

  @override
  String get helpDesktopShortcuts3 => 'Ctrl/Cmd+F â€” Localizar na nota';

  @override
  String get helpDesktopShortcuts4 => 'Ctrl/Cmd+H â€” Localizar e substituir';

  @override
  String get helpDesktopShortcuts5 => 'Ctrl/Cmd+N â€” Alternar painel de notas';

  @override
  String get helpDesktopShortcuts6 => 'Ctrl/Cmd+P â€” Alternar painel de pares';

  @override
  String get helpDesktopShortcuts7 => 'Ctrl/Cmd+Q â€” Sair (Windows/Linux)';

  @override
  String get helpTroubleshootingTitle => 'SoluÃ§Ã£o de problemas';

  @override
  String get helpTroubleshooting1 =>
      'Sem pares? Confirme a mesma sub-rede Wiâ€‘Fi e ID de sala; tente Conectar por IP.';

  @override
  String get helpTroubleshooting2 =>
      'O banner rede local necessÃ¡ria significa que a sincronizaÃ§Ã£o estÃ¡ pausada atÃ© o Wiâ€‘Fi estar ativo.';

  @override
  String get helpTroubleshooting3 =>
      'Permita o aplicativo pelo seu firewall no primeiro lanÃ§amento (desktop).';

  @override
  String get helpTroubleshooting4 =>
      'Linux: instale dbus e avahi-daemon se a descoberta nunca iniciar.';

  @override
  String get helpTroubleshooting5 =>
      'Android: conceda permissÃ£o de Wiâ€‘Fi prÃ³ximo quando solicitado.';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String get aboutTagline =>
      'Bloco de notas LAN com descoberta de pares e ediÃ§Ã£o compartilhada.';

  @override
  String get aboutDescription =>
      'Escreva notas em texto simples no seu celular ou computador e mantenha-as sincronizadas com outros dispositivos na mesma rede Wiâ€‘Fi. Os pares se descobrem na rede local, emparelham uma vez com aprovaÃ§Ã£o mÃºtua e compartilham vÃ¡rias notas nomeadas com sessÃµes de pares criptografadas.';

  @override
  String get aboutPlatforms => 'Android Â· iOS Â· Windows Â· macOS Â· Linux';

  @override
  String get aboutStatus => 'Beta â€” adequado para uso LAN diÃ¡rio.';

  @override
  String get aboutEulaHeading => 'Contrato de LicenÃ§a do UsuÃ¡rio Final';

  @override
  String aboutEulaBody(int noteLimit, int peerLimit) {
    return 'SB Simple Netpad Ã© licenciado sob um EULA, nÃ£o uma licenÃ§a de cÃ³digo aberto. A ediÃ§Ã£o bÃ¡sica e a sincronizaÃ§Ã£o LAN sÃ£o gratuitas (atÃ© $noteLimit notas e $peerLimit pares conectados). Netpad Standard Ã© um desbloqueio Ãºnico via App Store, Google Play ou Microsoft Store.';
  }

  @override
  String get aboutViewEula => 'Ver EULA';

  @override
  String get aboutPrivacyPolicy => 'PolÃ­tica de Privacidade';

  @override
  String get aboutHowToUse => 'Como usar o SB Simple Netpad';

  @override
  String get aboutCouldNotOpenPrivacy =>
      'NÃ£o foi possÃ­vel abrir a polÃ­tica de privacidade';

  @override
  String get aboutCouldNotOpenEula => 'NÃ£o foi possÃ­vel abrir o EULA';

  @override
  String get aboutCopyright => 'Â© 2026 Spencer Beaumier';

  @override
  String conflictLiveTitle(String title) {
    return 'Conflito de ediÃ§Ã£o em \"$title\"';
  }

  @override
  String conflictLiveBody(
    String peer,
    String revision,
    String localPreview,
    String remotePreview,
  ) {
    return '$peer editou a mesma nota ao mesmo tempo (revisÃ£o $revision).\n\nA sua:\n$localPreview\n\n$peer:\n$remotePreview\n\nQual versÃ£o ambos os dispositivos devem manter?';
  }

  @override
  String conflictDivergedTitle(String title) {
    return '\"$title\" divergiu';
  }

  @override
  String conflictDivergedBody(
    String peer,
    String title,
    int localChars,
    int remoteChars,
  ) {
    return 'Sua cÃ³pia e a cÃ³pia de $peer de \"$title\" foram alteradas de forma diferente enquanto desconectadas.\n\nA sua: $localChars caracteres\n$peer: $remoteChars caracteres\n\nQual versÃ£o ambos os dispositivos devem manter?';
  }

  @override
  String conflictUsePeers(String peer) {
    return 'Usar a de $peer';
  }

  @override
  String get conflictKeepMine => 'Manter a minha';

  @override
  String fileSavedTo(String path) {
    return 'Salvo em $path';
  }

  @override
  String fileCouldNotSave(String error) {
    return 'NÃ£o foi possÃ­vel salvar: $error';
  }

  @override
  String fileOpenedAsNewNote(String name) {
    return '$name aberto como nova nota';
  }

  @override
  String fileCouldNotOpen(String error) {
    return 'NÃ£o foi possÃ­vel abrir: $error';
  }

  @override
  String get fileNothingToShare =>
      'Nada para compartilhar â€” a nota estÃ¡ vazia';

  @override
  String get fileShareFallbackClipboard =>
      'Compartilhamento nÃ£o disponÃ­vel aqui â€” copiado para a Ã¡rea de transferÃªncia';

  @override
  String get fileDefaultNoteName => 'netpad-note';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get commonAppName => 'SB Simple Netpad';

  @override
  String get commonStandardName => 'Netpad Standard';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonConnect => 'Conectar';

  @override
  String get commonHelp => 'Ajuda';

  @override
  String get commonSettings => 'Configurações';

  @override
  String get commonMore => 'Mais';

  @override
  String get commonCopy => 'Copiar';

  @override
  String get commonClear => 'Limpar';

  @override
  String get commonAccept => 'Aceitar';

  @override
  String get commonReject => 'Rejeitar';

  @override
  String get commonBlock => 'Bloquear';

  @override
  String get commonUnblock => 'Desbloquear';

  @override
  String get commonRevoke => 'Revogar';

  @override
  String get commonRestore => 'Restaurar';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String commonCouldNotOpenLabel(String label) {
    return 'Não foi possível abrir $label';
  }

  @override
  String get commonEulaLabel => 'EULA';

  @override
  String get commonPrivacyPolicyLabel => 'política de privacidade';

  @override
  String get commonEndUserLicenseAgreement =>
      'Contrato de Licença do Usuário Final';

  @override
  String get commonPrivacyPolicy => 'Política de Privacidade';

  @override
  String commonVersionLabel(String version) {
    return 'Versão $version';
  }

  @override
  String get shellMenuFile => 'Arquivo';

  @override
  String get shellMenuEdit => 'Editar';

  @override
  String get shellMenuView => 'Exibir';

  @override
  String get shellMenuHelp => 'Ajuda';

  @override
  String get shellSaveToFile => 'Salvar em arquivo…';

  @override
  String get shellOpenFileAsNewNote => 'Abrir arquivo como nova nota…';

  @override
  String get shellShareNote => 'Compartilhar nota';

  @override
  String get shellVersionHistory => 'Histórico de versões…';

  @override
  String get shellSettings => 'Configurações…';

  @override
  String get shellExit => 'Sair';

  @override
  String get shellCut => 'Recortar';

  @override
  String get shellCopy => 'Copiar';

  @override
  String get shellPaste => 'Colar';

  @override
  String get shellFind => 'Localizar…';

  @override
  String get shellFindAndReplace => 'Localizar e substituir…';

  @override
  String get shellWordWrap => 'Quebra de linha';

  @override
  String get shellWordWrapChecked => 'Quebra de linha ✓';

  @override
  String get shellNotesPanel => 'Painel de notas';

  @override
  String get shellNotesPanelChecked => 'Painel de notas ✓';

  @override
  String get shellPeersPanel => 'Painel de pares';

  @override
  String get shellPeersPanelChecked => 'Painel de pares ✓';

  @override
  String get shellHelpItem => 'Ajuda do SB Simple Netpad';

  @override
  String get shellAboutItem => 'Sobre o SB Simple Netpad';

  @override
  String get shellHideNotesPanel => 'Ocultar painel de notas';

  @override
  String get shellShowNotesPanel => 'Mostrar painel de notas (Ctrl+N)';

  @override
  String get shellHidePeersPanel => 'Ocultar painel de pares';

  @override
  String get shellShowPeersPanel => 'Mostrar painel de pares (Ctrl+P)';

  @override
  String shellPeersTooltipConnected(int count, String action) {
    return '$count sessões de pares criptografadas · $action painel de pares (Ctrl+P)';
  }

  @override
  String get shellPeersTooltipActionHide => 'ocultar';

  @override
  String get shellPeersTooltipActionShow => 'mostrar';

  @override
  String get shellFindInNote => 'Localizar na nota (Ctrl+F)';

  @override
  String shellSecurityChipConnected(int count) {
    return '$count sessões de pares criptografadas com WSS/TLS · toque para ver pares';
  }

  @override
  String get shellSecurityChipNone =>
      'Sem sessões de pares ativas · toque para ver pares';

  @override
  String get shellMobileWordWrap => 'Quebra de linha';

  @override
  String get shellMobileSaveToFile => 'Salvar em arquivo…';

  @override
  String get shellMobileOpenFileAsNewNote => 'Abrir arquivo como nova nota…';

  @override
  String get shellMobileShareNote => 'Compartilhar nota';

  @override
  String get shellMobileVersionHistory => 'Histórico de versões…';

  @override
  String get shellMobileSettings => 'Configurações';

  @override
  String get shellMobileHelp => 'Ajuda';

  @override
  String get shellMobileAbout => 'Sobre o SB Simple Netpad';

  @override
  String get shellListeningSnack =>
      'Ouvindo… toque no microfone novamente para parar';

  @override
  String get notesTitle => 'Notas';

  @override
  String get notesNewNote => 'Nova nota';

  @override
  String get notesSearchHint => 'Pesquisar em todas as notas';

  @override
  String get notesRenameTitle => 'Renomear nota';

  @override
  String get notesTitleLabel => 'Título';

  @override
  String notesDeleteTitle(String title) {
    return 'Excluir \"$title\"?';
  }

  @override
  String get notesDeleteSyncedBody =>
      'Isso remove a nota para você e todos os pares conectados.';

  @override
  String get notesDeleteLocalBody =>
      'Isso remove a nota somente deste dispositivo.';

  @override
  String get notesNoMatches => 'Nenhuma correspondência';

  @override
  String get notesNoNotes => 'Nenhuma nota';

  @override
  String get notesRename => 'Renomear';

  @override
  String get notesVersionHistory => 'Histórico de versões';

  @override
  String get notesDelete => 'Excluir';

  @override
  String get notesSyncWithPeers => 'Sincronizar com pares';

  @override
  String get notesLocalOnly => 'Somente local';

  @override
  String get notesEmptyNote => 'Nota vazia';

  @override
  String notesMatchCount(int count) {
    return '$count correspondências';
  }

  @override
  String notesLocalOnlyWithMatches(String matchLine) {
    return 'Somente local · $matchLine';
  }

  @override
  String notesSearchSnippetMatches(String snippet, int count) {
    return '$snippet  ·  $count correspondências';
  }

  @override
  String get notesNoNoteSelected => 'Nenhuma nota selecionada';

  @override
  String historyTitle(String title) {
    return 'Histórico de versões · \"$title\"';
  }

  @override
  String get historyEmpty =>
      'Nenhuma versão salva ainda. Instantâneos são mantidos automaticamente antes que edições remotas substituam seu texto.';

  @override
  String historyEntrySubtitle(String label, String time, int chars) {
    return '$label · $time · $chars caracteres';
  }

  @override
  String get historyRestore => 'Restaurar';

  @override
  String get historyRestoredSnack => 'Versão restaurada';

  @override
  String get historyBeforeRemoteUpdate => 'Antes da atualização remota';

  @override
  String get historySnapshot => 'Instantâneo';

  @override
  String get historyImportedFile => 'Arquivo importado';

  @override
  String get editorFindHint => 'Localizar';

  @override
  String get editorReplaceHint => 'Substituir por';

  @override
  String editorMatchCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get editorMatchNone => '0/0';

  @override
  String get editorPrevious => 'Anterior';

  @override
  String get editorNext => 'Próximo';

  @override
  String get editorShowReplace => 'Mostrar substituição (Ctrl+H)';

  @override
  String get editorHideReplace => 'Ocultar substituição (Ctrl+H)';

  @override
  String get editorClose => 'Fechar';

  @override
  String get editorReplace => 'Substituir';

  @override
  String get editorReplaceAll => 'Todos';

  @override
  String get editorListening => 'Ouvindo…';

  @override
  String get editorDictate => 'Ditar';

  @override
  String get editorStopDictation => 'Parar ditado';

  @override
  String get peersConnectByIp => 'Conectar por IP';

  @override
  String get peersConnected => 'Conectado';

  @override
  String get peersNearby => 'Próximos';

  @override
  String get peersTrustedDevices => 'Dispositivos confiáveis';

  @override
  String get peersBlocked => 'Bloqueados';

  @override
  String get peersConnectionLog => 'Registro de conexões';

  @override
  String get peersNoActiveConnections => 'Nenhuma conexão ativa';

  @override
  String get peersNoTrustedDevices =>
      'Nenhum dispositivo confiável — emparelhe uma vez para habilitar sincronização automática';

  @override
  String get peersNoBlockedDevices => 'Nenhum dispositivo bloqueado';

  @override
  String get peersNoConnectionEvents => 'Nenhum evento de conexão ainda';

  @override
  String get peersNoDiscoveredPeers =>
      'Nenhum par descoberto — o Linux deve estar na mesma sub-rede Wi‑Fi que Este dispositivo (verifique o endereço acima), ou use Conectar por IP';

  @override
  String get peersDiscoveryPaused =>
      'A descoberta de pares está pausada até que você entre em uma rede local';

  @override
  String get peersDisconnect => 'Desconectar';

  @override
  String get peersConnectNow => 'Conectar agora';

  @override
  String get peersConnect => 'Conectar';

  @override
  String get peersResolving => 'Resolvendo…';

  @override
  String get peersBlockTooltip => 'Bloquear';

  @override
  String peersBlockTitle(String peer) {
    return 'Bloquear $peer?';
  }

  @override
  String get peersBlockBody =>
      'Isso desconecta o dispositivo, esquece seu certificado fixado e recusa futuras solicitações de conexão até que você o desbloqueie.';

  @override
  String peersRevokeTitle(String peer) {
    return 'Revogar $peer?';
  }

  @override
  String get peersRevokeBody =>
      'A próxima conexão exigirá tocar em Aceitar novamente. O PIN de segurança é mantido para que as verificações de certificado ainda se apliquem.';

  @override
  String get peersAutoSync => 'Sincronização automática';

  @override
  String get peersCopiedOneLogEntry => '1 entrada de registro copiada';

  @override
  String peersCopiedLogEntries(int count) {
    return '$count entradas de registro copiadas';
  }

  @override
  String peersLogRevision(String time, String revision) {
    return '$time • revisão $revision';
  }

  @override
  String peersStillResolving(String peer) {
    return 'Ainda resolvendo $peer…';
  }

  @override
  String peersResolveFailedSnack(String peer) {
    return 'Não foi possível resolver $peer. Verifique o Avahi e a mesma sub-rede, ou use Conectar por IP.';
  }

  @override
  String peersPairingRequestSent(String peer) {
    return 'Solicitação de emparelhamento enviada para $peer';
  }

  @override
  String peersCouldNotConnect(String message) {
    return 'Não foi possível conectar: $message';
  }

  @override
  String peersManualHostPort(String host, int port) {
    return '$host:$port (manual)';
  }

  @override
  String get peersManual => 'Manual';

  @override
  String get peersResolveFailedSubtitle =>
      'Resolução falhou — tente Conectar por IP';

  @override
  String get peersResolvingAddress => 'Resolvendo endereço…';

  @override
  String peersHostPort(String host, int port) {
    return '$host:$port';
  }

  @override
  String get peersNoAddressYet => 'Nenhum endereço ainda';

  @override
  String peersEncryptedPinned(String code) {
    return 'Criptografado · fixado $code';
  }

  @override
  String get peersEncryptedWss => 'Criptografado (WSS/TLS)';

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
    return 'Emparelhado em $date · $status';
  }

  @override
  String get peersStatusConnected => 'Conectado';

  @override
  String get peersStatusManualOnly => 'Somente manual';

  @override
  String get peersStatusReconnecting => 'Reconectando…';

  @override
  String peersStatusRetryIn(int seconds) {
    return 'Tentar novamente em ${seconds}s';
  }

  @override
  String get peersStatusNotOnNetwork => 'Fora da rede';

  @override
  String get peersStatusConnecting => 'Conectando…';

  @override
  String get peersStatusAutoReconnect => 'Reconexão automática';

  @override
  String peersPresenceLineCol(int line, int column) {
    return 'linha $line, col $column';
  }

  @override
  String peersPresenceInNote(String title, String position) {
    return '\"$title\" · $position';
  }

  @override
  String peersRoomLabel(String room) {
    return 'Sala \"$room\"';
  }

  @override
  String get discoveryThisDevice => 'Este dispositivo';

  @override
  String get discoveryCopyAddress => 'Copiar endereço';

  @override
  String discoveryCopiedAddress(String address) {
    return 'Copiado $address';
  }

  @override
  String get discoveryLocalNetworkRequired => 'Rede local necessária';

  @override
  String get discoveryNotListeningTitle => 'Não está ouvindo';

  @override
  String get discoveryNotListeningBody =>
      'Este dispositivo ainda não está ouvindo por pares. Aguarde alguns segundos após entrar no Wi‑Fi, ou toque em Tentar novamente em um banner de erro de rede.';

  @override
  String get discoveryModeTitle => 'Modo de descoberta';

  @override
  String get discoveryUnavailableTitle => 'Descoberta de pares indisponível';

  @override
  String get discoveryRetryTooltip => 'Tentar descoberta novamente';

  @override
  String get peersSecuredSessions => 'Sessões seguras';

  @override
  String peersSecurityBannerIdle(String code) {
    return 'Este dispositivo anuncia via WSS/TLS · código $code';
  }

  @override
  String peersSecurityBannerActive(int connectedCount, int pinnedCount) {
    return '$connectedCount sessões criptografadas · $pinnedCount certificados fixados';
  }

  @override
  String peersSecurityCompactIdle(String code) {
    return 'WSS/TLS · código $code';
  }

  @override
  String peersSecurityCompactActive(int connectedCount, int pinnedCount) {
    return '$connectedCount criptografadas · $pinnedCount fixados';
  }

  @override
  String peersSecurityTooltipPinned(String code) {
    return 'Criptografado (WSS/TLS) · fixado $code';
  }

  @override
  String get peersSecurityTooltipActive =>
      'Criptografado (WSS/TLS) · sessão ativa';

  @override
  String get pairingConnectionRequest => 'Solicitação de conexão';

  @override
  String pairingAllowPeer(String peer) {
    return 'Permitir que $peer se conecte e compartilhe esta nota?';
  }

  @override
  String get pairingVerificationCode => 'Código de verificação';

  @override
  String get pairingConfirmCode =>
      'Confirme que este código corresponde em ambos os dispositivos antes de aceitar.';

  @override
  String get pairingThisDeviceSecurityCode =>
      'Código de segurança deste dispositivo';

  @override
  String get pairingOtherDevicePins =>
      'O outro dispositivo fixa isso na primeira conexão.';

  @override
  String get manualConnectTitle => 'Conectar por endereço';

  @override
  String get manualConnectBody =>
      'Use quando a descoberta não encontrar pares na mesma sub-rede. Somente endereços no seu segmento de rede local ativo são permitidos.';

  @override
  String get manualConnectHostLabel => 'Host ou IP';

  @override
  String get manualConnectHostHint => '192.168.1.42';

  @override
  String get manualConnectPortLabel => 'Porta';

  @override
  String get manualConnectPortHint => '54321';

  @override
  String get manualConnectLabelOptional => 'Rótulo (opcional)';

  @override
  String get manualConnectLabelHint => 'PC da sala';

  @override
  String get manualConnectInvalidHostPort =>
      'Digite um host e porta válidos (1–65535)';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsDeviceSection => 'Dispositivo';

  @override
  String get settingsDeviceHint =>
      'O nome do dispositivo e a sala requerem Salvar (Ctrl+S). As preferências de aparência e editor são salvas imediatamente.';

  @override
  String get settingsDeviceName => 'Nome do dispositivo';

  @override
  String get settingsDeviceNameHint => 'Nome exibido para outros dispositivos';

  @override
  String get settingsSessionRoom => 'Sessão / sala';

  @override
  String get settingsSessionRoomHint =>
      'Somente pares na mesma sala são descobertos';

  @override
  String get settingsListeningPort => 'Porta de escuta';

  @override
  String get settingsStartingServer => 'Iniciando servidor…';

  @override
  String settingsAddressShare(String address) {
    return '$address (compartilhe para conexão manual)';
  }

  @override
  String get settingsCopyAddress => 'Copiar endereço';

  @override
  String get settingsAddressCopied =>
      'Endereço copiado para a área de transferência';

  @override
  String settingsSavedSnack(String name, String room) {
    return 'Configurações salvas · \"$name\" · sala \"$room\"';
  }

  @override
  String get settingsAppearanceSection => 'Aparência';

  @override
  String get settingsMode => 'Modo';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsSkin => 'Visual';

  @override
  String get settingsSkinDefault => 'Padrão';

  @override
  String get settingsSkinOcean => 'Oceano';

  @override
  String get settingsSkinForest => 'Floresta';

  @override
  String get settingsSkinSunset => 'Pôr do sol';

  @override
  String get settingsSkinSlate => 'Ardósia';

  @override
  String settingsSkinStandardLabel(String skin) {
    return '$skin · Standard';
  }

  @override
  String get settingsStandardSection => 'Netpad Standard';

  @override
  String get settingsStandardUnlocked => 'Standard desbloqueado';

  @override
  String get settingsFree => 'Grátis';

  @override
  String get settingsStandardUnlockedSubtitle =>
      'Notas e pares ilimitados, visuais, histórico, sincronização automática e voz';

  @override
  String get settingsStandardBuySubtitle =>
      'Desbloqueio único pela sua loja de aplicativos';

  @override
  String get settingsPurchasesUnavailable =>
      'Compras indisponíveis nesta plataforma';

  @override
  String get settingsRestorePurchases => 'Restaurar compras';

  @override
  String get settingsStandardRestored => 'Standard restaurado';

  @override
  String get settingsNoPreviousStandard =>
      'Nenhuma compra anterior de Standard encontrada';

  @override
  String get settingsEditorSection => 'Editor';

  @override
  String get settingsWordWrap => 'Quebra de linha';

  @override
  String get settingsWordWrapSubtitle =>
      'Quebrar linhas longas em vez de rolar horizontalmente';

  @override
  String settingsFontSize(int size) {
    return 'Tamanho da fonte ($size pt)';
  }

  @override
  String get settingsLegalSection => 'Legal';

  @override
  String get settingsEulaSubtitleStandard =>
      'Standard · Abre EULA no GitHub Pages';

  @override
  String get settingsEulaSubtitleFree => 'Grátis · Abre EULA no GitHub Pages';

  @override
  String get settingsPrivacySubtitle =>
      'Abre página de privacidade no GitHub Pages';

  @override
  String get settingsDisclaimerTitle =>
      'Isenção de responsabilidade e responsabilidade civil';

  @override
  String get settingsDisclaimerSubtitle => 'Use por sua própria conta e risco';

  @override
  String get settingsDisclaimerP1 =>
      'Este software é fornecido \"como está\", sem garantias de qualquer tipo, expressas ou implícitas, incluindo comercialização, adequação a uma finalidade específica e não violação.';

  @override
  String get settingsDisclaimerP2 =>
      'Você é o único responsável pela forma como usa este aplicativo e pelo cumprimento de todas as leis, regulamentos, políticas e acordos aplicáveis.';

  @override
  String get settingsDisclaimerP3 =>
      'O titular do direito autoral não é responsável por quaisquer reclamações, danos, perdas, perda de dados, interrupção de negócios ou outra responsabilidade decorrente do uso ou mau uso deste software.';

  @override
  String get settingsNoLegalAdviceTitle => 'Sem aconselhamento jurídico';

  @override
  String get settingsNoLegalAdviceSubtitle => 'Apenas software informativo';

  @override
  String get settingsNoLegalAdviceP1 =>
      'Este aplicativo e sua documentação não fornecem aconselhamento jurídico, regulatório ou profissional.';

  @override
  String get settingsNoLegalAdviceP2 =>
      'Se você precisar de orientação jurídica para seu caso de uso, consulte um profissional qualificado.';

  @override
  String get settingsCopyright => '© 2026 Spencer Beaumier';

  @override
  String get paywallTitle => 'Desbloquear Netpad Standard';

  @override
  String get paywallSubtitle =>
      'Compra única. Edição básica e sincronização LAN permanecem gratuitas.';

  @override
  String get paywallBenefitUnlimitedNotes => 'Notas ilimitadas';

  @override
  String get paywallBenefitUnlimitedPeers => 'Pares conectados ilimitados';

  @override
  String get paywallBenefitSkins => 'Visuais de cores extras';

  @override
  String get paywallBenefitHistory => 'Histórico de versões';

  @override
  String get paywallBenefitAutoSync =>
      'Sincronização automática com pares confiáveis';

  @override
  String get paywallBenefitVoice => 'Ditado por voz';

  @override
  String get paywallPurchasesUnsupported =>
      'Compras no aplicativo não estão disponíveis nesta plataforma. Instale da App Store, Google Play ou Microsoft Store para desbloquear o Standard.';

  @override
  String get paywallBuyStandard => 'Comprar Standard';

  @override
  String paywallBuyStandardPrice(String price) {
    return 'Comprar Standard · $price';
  }

  @override
  String get paywallRestorePurchases => 'Restaurar compras';

  @override
  String get paywallPurchaseNotCompleted => 'A compra não foi concluída.';

  @override
  String get paywallPurchaseFailed => 'A compra falhou.';

  @override
  String get paywallStandardRestored => 'Standard restaurado';

  @override
  String get paywallNoPreviousStandard =>
      'Nenhuma compra anterior de Standard encontrada';

  @override
  String standardHighlightNoteLimit(int limit) {
    return 'A versão gratuita inclui até $limit notas. Desbloqueie o Standard para notas ilimitadas.';
  }

  @override
  String standardHighlightPeerLimit(int limit) {
    return 'A versão gratuita inclui até $limit pares conectados. Desbloqueie o Standard para pares ilimitados.';
  }

  @override
  String get standardHighlightVersionHistory =>
      'O histórico de versões é um recurso Standard.';

  @override
  String get standardHighlightVoice =>
      'O ditado por voz é um recurso Standard.';

  @override
  String get standardHighlightAutoSync =>
      'A sincronização automática com pares confiáveis é um recurso Standard.';

  @override
  String get standardHighlightSkins =>
      'Visuais extras estão incluídos no Standard.';

  @override
  String get helpTitle => 'Ajuda';

  @override
  String get helpIntro =>
      'Um bloco de notas LAN para notas em texto simples. Dispositivos na mesma rede Wi‑Fi se descobrem, emparelham uma vez e sincronizam notas em tempo real.';

  @override
  String get helpAboutTile => 'Sobre o SB Simple Netpad';

  @override
  String get helpEulaSubtitle => 'Abre EULA no GitHub Pages';

  @override
  String get helpPrivacySubtitle =>
      'Abre página de privacidade no GitHub Pages';

  @override
  String get helpGettingStartedTitle => 'Primeiros passos';

  @override
  String get helpGettingStarted1 =>
      'Entre na mesma rede Wi‑Fi que os dispositivos com os quais deseja sincronizar.';

  @override
  String get helpGettingStarted2 =>
      'Abra o painel de pares (ícone de cadeado ou gaveta de Pares) e aguarde os dispositivos próximos aparecerem.';

  @override
  String get helpGettingStarted3 =>
      'Copie seu endereço de Este dispositivo e compartilhe se a descoberta estiver lenta.';

  @override
  String get helpGettingStarted4 =>
      'Use Conectar por IP quando a descoberta mDNS não encontrar pares.';

  @override
  String get helpNotesTitle => 'Notas';

  @override
  String get helpNotes1 =>
      'Toque no ícone de menu (☰) ou no painel de notas para alternar entre notas.';

  @override
  String get helpNotes2 =>
      'Crie, renomeie, reordene e exclua notas na lista de notas.';

  @override
  String get helpNotes3 =>
      'Cada nota sincroniza de forma independente — alterne a sincronização por nota quando necessário.';

  @override
  String get helpNotes4 =>
      'Pesquise dentro de uma nota (Localizar) ou em todas as notas pelo editor.';

  @override
  String get helpNotes5 =>
      'O histórico de versões salva instantâneos locais que você pode restaurar posteriormente.';

  @override
  String get helpPeersTitle => 'Pares e emparelhamento';

  @override
  String get helpPeers1 =>
      'Próximos lista os dispositivos descobertos na mesma sala (veja Configurações).';

  @override
  String get helpPeers2 =>
      'Toque em Conectar em um par — o outro dispositivo deve tocar em Aceitar.';

  @override
  String get helpPeers3 =>
      'Compare o código de verificação de emparelhamento antes de aceitar.';

  @override
  String get helpPeers4 =>
      'Após o primeiro Aceitar, dispositivos confiáveis podem se reconectar automaticamente.';

  @override
  String get helpPeers5 =>
      'Dispositivos confiáveis: alterne sincronização automática ou Revogar para exigir Aceitar novamente.';

  @override
  String get helpPeers6 =>
      'Bloquear desconecta um dispositivo e recusa emparelhamentos futuros até ser desbloqueado.';

  @override
  String get helpPeers7 =>
      'Conectado mostra sessões ativas com endereço e presença do cursor.';

  @override
  String get helpFileSharingTitle => 'Arquivos e compartilhamento';

  @override
  String get helpFileSharing1Desktop =>
      'Menu Arquivo: Salvar em arquivo, Abrir arquivo como nova nota, Compartilhar nota, Histórico de versões, Configurações, Sair.';

  @override
  String get helpFileSharing1Mobile =>
      'Menu (⋮): salvar em arquivo, abrir arquivo como nova nota, compartilhar, histórico de versões, configurações e este guia de ajuda.';

  @override
  String get helpFileSharing2 =>
      'Salvar em arquivo exporta a nota ativa como .txt ou .md.';

  @override
  String get helpFileSharing3 =>
      'Abrir arquivo importa texto para uma nova nota que sincroniza como qualquer outra.';

  @override
  String get helpFileSharing4 =>
      'Compartilhar usa a planilha de compartilhamento do SO; Linux recorre à área de transferência.';

  @override
  String get helpSettingsTitle => 'Configurações';

  @override
  String get helpSettings1 =>
      'O nome do dispositivo e a sala requerem Salvar — outras opções se aplicam imediatamente.';

  @override
  String get helpSettings2 =>
      'O ID da sala agrupa pares: somente dispositivos na mesma sala são descobertos.';

  @override
  String get helpSettings3 =>
      'As preferências de aparência e editor (tema, visual, quebra, fonte) são salvas ao alterá-las.';

  @override
  String get helpDesktopShortcutsTitle => 'Atalhos de teclado';

  @override
  String get helpDesktopShortcuts1 => 'Ctrl/Cmd+S — Salvar em arquivo';

  @override
  String get helpDesktopShortcuts2 =>
      'Ctrl/Cmd+O — Abrir arquivo como nova nota';

  @override
  String get helpDesktopShortcuts3 => 'Ctrl/Cmd+F — Localizar na nota';

  @override
  String get helpDesktopShortcuts4 => 'Ctrl/Cmd+H — Localizar e substituir';

  @override
  String get helpDesktopShortcuts5 => 'Ctrl/Cmd+N — Alternar painel de notas';

  @override
  String get helpDesktopShortcuts6 => 'Ctrl/Cmd+P — Alternar painel de pares';

  @override
  String get helpDesktopShortcuts7 => 'Ctrl/Cmd+Q — Sair (Windows/Linux)';

  @override
  String get helpTroubleshootingTitle => 'Solução de problemas';

  @override
  String get helpTroubleshooting1 =>
      'Sem pares? Confirme a mesma sub-rede Wi‑Fi e ID de sala; tente Conectar por IP.';

  @override
  String get helpTroubleshooting2 =>
      'O banner rede local necessária significa que a sincronização está pausada até o Wi‑Fi estar ativo.';

  @override
  String get helpTroubleshooting3 =>
      'Permita o aplicativo pelo seu firewall no primeiro lançamento (desktop).';

  @override
  String get helpTroubleshooting4 =>
      'Linux: instale dbus e avahi-daemon se a descoberta nunca iniciar.';

  @override
  String get helpTroubleshooting5 =>
      'Android: conceda permissão de Wi‑Fi próximo quando solicitado.';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String get aboutTagline =>
      'Bloco de notas LAN com descoberta de pares e edição compartilhada.';

  @override
  String get aboutDescription =>
      'Escreva notas em texto simples no seu celular ou computador e mantenha-as sincronizadas com outros dispositivos na mesma rede Wi‑Fi. Os pares se descobrem na rede local, emparelham uma vez com aprovação mútua e compartilham várias notas nomeadas com sessões de pares criptografadas.';

  @override
  String get aboutPlatforms => 'Android · iOS · Windows · macOS · Linux';

  @override
  String get aboutStatus => 'Beta — adequado para uso LAN diário.';

  @override
  String get aboutEulaHeading => 'Contrato de Licença do Usuário Final';

  @override
  String aboutEulaBody(int noteLimit, int peerLimit) {
    return 'SB Simple Netpad é licenciado sob um EULA, não uma licença de código aberto. A edição básica e a sincronização LAN são gratuitas (até $noteLimit notas e $peerLimit pares conectados). Netpad Standard é um desbloqueio único via App Store, Google Play ou Microsoft Store.';
  }

  @override
  String get aboutViewEula => 'Ver EULA';

  @override
  String get aboutPrivacyPolicy => 'Política de Privacidade';

  @override
  String get aboutHowToUse => 'Como usar o SB Simple Netpad';

  @override
  String get aboutCouldNotOpenPrivacy =>
      'Não foi possível abrir a política de privacidade';

  @override
  String get aboutCouldNotOpenEula => 'Não foi possível abrir o EULA';

  @override
  String get aboutCopyright => '© 2026 Spencer Beaumier';

  @override
  String conflictLiveTitle(String title) {
    return 'Conflito de edição em \"$title\"';
  }

  @override
  String conflictLiveBody(
    String peer,
    String revision,
    String localPreview,
    String remotePreview,
  ) {
    return '$peer editou a mesma nota ao mesmo tempo (revisão $revision).\n\nA sua:\n$localPreview\n\n$peer:\n$remotePreview\n\nQual versão ambos os dispositivos devem manter?';
  }

  @override
  String conflictDivergedTitle(String title) {
    return '\"$title\" divergiu';
  }

  @override
  String conflictDivergedBody(
    String peer,
    String title,
    int localChars,
    int remoteChars,
  ) {
    return 'Sua cópia e a cópia de $peer de \"$title\" foram alteradas de forma diferente enquanto desconectadas.\n\nA sua: $localChars caracteres\n$peer: $remoteChars caracteres\n\nQual versão ambos os dispositivos devem manter?';
  }

  @override
  String conflictUsePeers(String peer) {
    return 'Usar a de $peer';
  }

  @override
  String get conflictKeepMine => 'Manter a minha';

  @override
  String fileSavedTo(String path) {
    return 'Salvo em $path';
  }

  @override
  String fileCouldNotSave(String error) {
    return 'Não foi possível salvar: $error';
  }

  @override
  String fileOpenedAsNewNote(String name) {
    return '$name aberto como nova nota';
  }

  @override
  String fileCouldNotOpen(String error) {
    return 'Não foi possível abrir: $error';
  }

  @override
  String get fileNothingToShare => 'Nada para compartilhar — a nota está vazia';

  @override
  String get fileShareFallbackClipboard =>
      'Compartilhamento não disponível aqui — copiado para a área de transferência';

  @override
  String get fileDefaultNoteName => 'netpad-note';
}
