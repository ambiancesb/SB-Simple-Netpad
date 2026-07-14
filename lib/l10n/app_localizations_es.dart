// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get commonAppName => 'SB Simple Netpad';

  @override
  String get commonStandardName => 'Netpad Standard';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonConnect => 'Conectar';

  @override
  String get commonHelp => 'Ayuda';

  @override
  String get commonSettings => 'Configuración';

  @override
  String get commonMore => 'Más';

  @override
  String get commonCopy => 'Copiar';

  @override
  String get commonClear => 'Limpiar';

  @override
  String get commonAccept => 'Aceptar';

  @override
  String get commonReject => 'Rechazar';

  @override
  String get commonBlock => 'Bloquear';

  @override
  String get commonUnblock => 'Desbloquear';

  @override
  String get commonRevoke => 'Revocar';

  @override
  String get commonRestore => 'Restaurar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String commonCouldNotOpenLabel(String label) {
    return 'No se pudo abrir $label';
  }

  @override
  String get commonEulaLabel => 'EULA';

  @override
  String get commonPrivacyPolicyLabel => 'política de privacidad';

  @override
  String get commonEndUserLicenseAgreement =>
      'Acuerdo de licencia de usuario final';

  @override
  String get commonPrivacyPolicy => 'Política de privacidad';

  @override
  String commonVersionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get shellMenuFile => 'Archivo';

  @override
  String get shellMenuEdit => 'Editar';

  @override
  String get shellMenuView => 'Ver';

  @override
  String get shellMenuHelp => 'Ayuda';

  @override
  String get shellSaveToFile => 'Guardar en archivo…';

  @override
  String get shellOpenFileAsNewNote => 'Abrir archivo como nota nueva…';

  @override
  String get shellShareNote => 'Compartir nota';

  @override
  String get shellVersionHistory => 'Historial de versiones…';

  @override
  String get shellSettings => 'Configuración…';

  @override
  String get shellExit => 'Salir';

  @override
  String get shellCut => 'Cortar';

  @override
  String get shellCopy => 'Copiar';

  @override
  String get shellPaste => 'Pegar';

  @override
  String get shellFind => 'Buscar…';

  @override
  String get shellFindAndReplace => 'Buscar y reemplazar…';

  @override
  String get shellWordWrap => 'Ajuste de línea';

  @override
  String get shellWordWrapChecked => 'Ajuste de línea ✓';

  @override
  String get shellNotesPanel => 'Panel de notas';

  @override
  String get shellNotesPanelChecked => 'Panel de notas ✓';

  @override
  String get shellPeersPanel => 'Panel de pares';

  @override
  String get shellPeersPanelChecked => 'Panel de pares ✓';

  @override
  String get shellHelpItem => 'Ayuda de SB Simple Netpad';

  @override
  String get shellAboutItem => 'Acerca de SB Simple Netpad';

  @override
  String get shellHideNotesPanel => 'Ocultar panel de notas';

  @override
  String shellShowNotesPanel(String mod) {
    return 'Mostrar panel de notas ($mod+N)';
  }

  @override
  String get shellHidePeersPanel => 'Ocultar panel de pares';

  @override
  String shellShowPeersPanel(String mod) {
    return 'Mostrar panel de pares ($mod+P)';
  }

  @override
  String shellPeersTooltipConnected(int count, String action, String mod) {
    return '$count sesiones de pares cifradas · $action panel de pares ($mod+P)';
  }

  @override
  String get shellPeersTooltipActionHide => 'ocultar';

  @override
  String get shellPeersTooltipActionShow => 'mostrar';

  @override
  String shellFindInNote(String mod) {
    return 'Buscar en nota ($mod+F)';
  }

  @override
  String shellSecurityChipConnected(int count) {
    return '$count sesiones de pares cifradas con WSS/TLS · toca para ver pares';
  }

  @override
  String get shellSecurityChipNone =>
      'Sin sesiones de pares activas · toca para ver pares';

  @override
  String get shellMobileWordWrap => 'Ajuste de línea';

  @override
  String get shellMobileSaveToFile => 'Guardar en archivo…';

  @override
  String get shellMobileOpenFileAsNewNote => 'Abrir archivo como nota nueva…';

  @override
  String get shellMobileShareNote => 'Compartir nota';

  @override
  String get shellMobileVersionHistory => 'Historial de versiones…';

  @override
  String get shellMobileSettings => 'Configuración';

  @override
  String get shellMobileHelp => 'Ayuda';

  @override
  String get shellMobileAbout => 'Acerca de SB Simple Netpad';

  @override
  String get shellListeningSnack =>
      'Escuchando… toca el micrófono de nuevo para detener';

  @override
  String get notesTitle => 'Notas';

  @override
  String get notesNewNote => 'Nueva nota';

  @override
  String get notesSearchHint => 'Buscar en todas las notas';

  @override
  String get notesRenameTitle => 'Renombrar nota';

  @override
  String get notesTitleLabel => 'Título';

  @override
  String notesDeleteTitle(String title) {
    return '¿Eliminar \"$title\"?';
  }

  @override
  String get notesDeleteSyncedBody =>
      'Esto elimina la nota para ti y para todos los pares conectados.';

  @override
  String get notesDeleteLocalBody =>
      'Esto elimina la nota solo de este dispositivo.';

  @override
  String get notesNoMatches => 'Sin coincidencias';

  @override
  String get notesNoNotes => 'Sin notas';

  @override
  String get notesRename => 'Renombrar';

  @override
  String get notesVersionHistory => 'Historial de versiones';

  @override
  String get notesDelete => 'Eliminar';

  @override
  String get notesSyncWithPeers => 'Sincronizar con pares';

  @override
  String get notesLocalOnly => 'Solo local';

  @override
  String get notesEmptyNote => 'Nota vacía';

  @override
  String notesMatchCount(int count) {
    return '$count coincidencias';
  }

  @override
  String notesLocalOnlyWithMatches(String matchLine) {
    return 'Solo local · $matchLine';
  }

  @override
  String notesSearchSnippetMatches(String snippet, int count) {
    return '$snippet  ·  $count coincidencias';
  }

  @override
  String get notesNoNoteSelected => 'Ninguna nota seleccionada';

  @override
  String historyTitle(String title) {
    return 'Historial de versiones · \"$title\"';
  }

  @override
  String get historyEmpty =>
      'Aún no hay versiones guardadas. Las instantáneas se guardan automáticamente antes de que las ediciones remotas reemplacen tu texto.';

  @override
  String historyEntrySubtitle(String label, String time, int chars) {
    return '$label · $time · $chars caracteres';
  }

  @override
  String get historyRestore => 'Restaurar';

  @override
  String get historyRestoredSnack => 'Versión restaurada';

  @override
  String get historyBeforeRemoteUpdate => 'Antes de la actualización remota';

  @override
  String get historySnapshot => 'Instantánea';

  @override
  String get historyImportedFile => 'Archivo importado';

  @override
  String get editorFindHint => 'Buscar';

  @override
  String get editorReplaceHint => 'Reemplazar con';

  @override
  String editorMatchCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get editorMatchNone => '0/0';

  @override
  String get editorPrevious => 'Anterior';

  @override
  String get editorNext => 'Siguiente';

  @override
  String editorShowReplace(String shortcut) {
    return 'Mostrar reemplazo ($shortcut)';
  }

  @override
  String editorHideReplace(String shortcut) {
    return 'Ocultar reemplazo ($shortcut)';
  }

  @override
  String get editorClose => 'Cerrar';

  @override
  String get editorReplace => 'Reemplazar';

  @override
  String get editorReplaceAll => 'Todo';

  @override
  String get editorListening => 'Escuchando…';

  @override
  String get editorDictate => 'Dictar';

  @override
  String get editorStopDictation => 'Detener dictado';

  @override
  String get peersConnectByIp => 'Conectar por IP';

  @override
  String get peersConnected => 'Conectado';

  @override
  String get peersNearby => 'Cercanos';

  @override
  String get peersTrustedDevices => 'Dispositivos de confianza';

  @override
  String get peersBlocked => 'Bloqueados';

  @override
  String get peersConnectionLog => 'Registro de conexiones';

  @override
  String get peersNoActiveConnections => 'Sin conexiones activas';

  @override
  String get peersNoTrustedDevices =>
      'Sin dispositivos de confianza — marca Confiar para auto-sincronización al aceptar';

  @override
  String get peersNoBlockedDevices => 'Sin dispositivos bloqueados';

  @override
  String get peersNoConnectionEvents => 'Aún no hay eventos de conexión';

  @override
  String get peersNoDiscoveredPeers =>
      'Sin pares descubiertos — Linux debe estar en la misma subred Wi‑Fi que Este dispositivo (verifica la dirección arriba), o usa Conectar por IP';

  @override
  String get peersDiscoveryPaused =>
      'El descubrimiento de pares está pausado hasta que te unas a una red local';

  @override
  String get peersDisconnect => 'Desconectar';

  @override
  String get peersTrustTooltip => 'Confiar para auto-sincronización';

  @override
  String get peersTrustWaiting => 'Esperando…';

  @override
  String get peersTrustOfferFailed =>
      'No se pudo enviar la solicitud de confianza';

  @override
  String get peersConnectNow => 'Conectar ahora';

  @override
  String get peersConnect => 'Conectar';

  @override
  String get peersResolving => 'Resolviendo…';

  @override
  String get peersBlockTooltip => 'Bloquear';

  @override
  String peersBlockTitle(String peer) {
    return '¿Bloquear a $peer?';
  }

  @override
  String get peersBlockBody =>
      'Esto desconecta el dispositivo, olvida su certificado fijado y rechaza futuras solicitudes de conexión hasta que lo desbloquees.';

  @override
  String peersRevokeTitle(String peer) {
    return '¿Revocar a $peer?';
  }

  @override
  String get peersRevokeBody =>
      'La próxima conexión requerirá tocar Aceptar de nuevo. El PIN de seguridad se conserva para que las verificaciones de certificado sigan aplicándose.';

  @override
  String get peersAutoSync => 'Sincronización automática';

  @override
  String get peersCopiedOneLogEntry => '1 entrada de registro copiada';

  @override
  String peersCopiedLogEntries(int count) {
    return '$count entradas de registro copiadas';
  }

  @override
  String peersLogRevision(String time, String revision) {
    return '$time • revisión $revision';
  }

  @override
  String peersStillResolving(String peer) {
    return 'Aún resolviendo $peer…';
  }

  @override
  String peersResolveFailedSnack(String peer) {
    return 'No se pudo resolver $peer. Verifica Avahi y la misma subred, o usa Conectar por IP.';
  }

  @override
  String peersPairingRequestSent(String peer) {
    return 'Solicitud de emparejamiento enviada a $peer';
  }

  @override
  String peersCouldNotConnect(String message) {
    return 'No se pudo conectar: $message';
  }

  @override
  String peersManualHostPort(String host, int port) {
    return '$host:$port (manual)';
  }

  @override
  String get peersManual => 'Manual';

  @override
  String get peersResolveFailedSubtitle =>
      'Resolución fallida — intenta Conectar por IP';

  @override
  String get peersResolvingAddress => 'Resolviendo dirección…';

  @override
  String peersHostPort(String host, int port) {
    return '$host:$port';
  }

  @override
  String get peersNoAddressYet => 'Aún sin dirección';

  @override
  String peersEncryptedPinned(String code) {
    return 'Cifrado · fijado $code';
  }

  @override
  String get peersEncryptedWss => 'Cifrado (WSS/TLS)';

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
    return 'Emparejado $date · $status';
  }

  @override
  String get peersStatusConnected => 'Conectado';

  @override
  String get peersStatusManualOnly => 'Solo manual';

  @override
  String get peersStatusReconnecting => 'Reconectando…';

  @override
  String peersStatusRetryIn(int seconds) {
    return 'Reintentar en ${seconds}s';
  }

  @override
  String get peersStatusNotOnNetwork => 'No en la red';

  @override
  String get peersStatusConnecting => 'Conectando…';

  @override
  String get peersStatusAutoReconnect => 'Reconexión automática';

  @override
  String peersPresenceLineCol(int line, int column) {
    return 'línea $line, col $column';
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
  String get discoveryCopyAddress => 'Copiar dirección';

  @override
  String discoveryCopiedAddress(String address) {
    return 'Copiado $address';
  }

  @override
  String get discoveryLocalNetworkRequired => 'Se requiere red local';

  @override
  String get discoveryNotListeningTitle => 'No está escuchando';

  @override
  String get discoveryNotListeningBody =>
      'Este dispositivo aún no está escuchando pares. Espera unos segundos después de unirte a Wi‑Fi, o toca Reintentar en el banner de error de red.';

  @override
  String get discoveryModeTitle => 'Modo de descubrimiento';

  @override
  String get discoveryUnavailableTitle =>
      'Descubrimiento de pares no disponible';

  @override
  String get discoveryRetryTooltip => 'Reintentar descubrimiento';

  @override
  String get peersSecuredSessions => 'Sesiones seguras';

  @override
  String peersSecurityBannerIdle(String code) {
    return 'Este dispositivo anuncia sobre WSS/TLS · código $code';
  }

  @override
  String peersSecurityBannerActive(int connectedCount, int pinnedCount) {
    return '$connectedCount sesiones cifradas · $pinnedCount certificados fijados';
  }

  @override
  String peersSecurityCompactIdle(String code) {
    return 'WSS/TLS · código $code';
  }

  @override
  String peersSecurityCompactActive(int connectedCount, int pinnedCount) {
    return '$connectedCount cifradas · $pinnedCount fijadas';
  }

  @override
  String peersSecurityTooltipPinned(String code) {
    return 'Cifrado (WSS/TLS) · fijado $code';
  }

  @override
  String get peersSecurityTooltipActive => 'Cifrado (WSS/TLS) · sesión activa';

  @override
  String get pairingConnectionRequest => 'Solicitud de conexión';

  @override
  String pairingAllowPeer(String peer) {
    return '¿Permitir que $peer se conecte y comparta esta nota?';
  }

  @override
  String get pairingVerificationCode => 'Código de verificación';

  @override
  String get pairingConfirmCode =>
      'Confirma que este código coincide en ambos dispositivos antes de aceptar.';

  @override
  String get pairingThisDeviceSecurityCode =>
      'Código de seguridad de este dispositivo';

  @override
  String get pairingOtherDevicePins =>
      'El otro dispositivo fija esto en la primera conexión.';

  @override
  String get pairingTrustForAutoSync => 'Confiar para auto-sincronización';

  @override
  String get pairingTrustForAutoSyncHint =>
      'Omitir Aceptar en reconexiones posteriores. Opcional: déjalo desmarcado para exigir Aceptar cada vez.';

  @override
  String get pairingTrustOfferTitle => 'Solicitud de confianza';

  @override
  String pairingTrustOfferBody(String peer) {
    return '$peer quiere confiar en este dispositivo para auto-sincronización. Las reconexiones futuras omitirán Aceptar.';
  }

  @override
  String pairingTrustAcceptedSnack(String peer) {
    return 'Se confió en $peer para auto-sincronización';
  }

  @override
  String pairingTrustDeclinedSnack(String peer) {
    return '$peer rechazó la confianza';
  }

  @override
  String get manualConnectTitle => 'Conectar por dirección';

  @override
  String get manualConnectBody =>
      'Úsalo cuando el descubrimiento no pueda encontrar pares en la misma subred. Solo se permiten direcciones en tu segmento de red local activo.';

  @override
  String get manualConnectHostLabel => 'Host o IP';

  @override
  String get manualConnectHostHint => '192.168.1.42';

  @override
  String get manualConnectPortLabel => 'Puerto';

  @override
  String get manualConnectPortHint => '54321';

  @override
  String get manualConnectLabelOptional => 'Etiqueta (opcional)';

  @override
  String get manualConnectLabelHint => 'PC de la sala';

  @override
  String get manualConnectInvalidHostPort =>
      'Ingresa un host y puerto válidos (1–65535)';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsDeviceSection => 'Dispositivo';

  @override
  String settingsDeviceHint(String mod) {
    return 'El nombre del dispositivo y la sala requieren Guardar ($mod+S). Las preferencias de apariencia y editor se guardan inmediatamente.';
  }

  @override
  String get settingsDeviceName => 'Nombre del dispositivo';

  @override
  String get settingsDeviceNameHint => 'Nombre visible para otros dispositivos';

  @override
  String get settingsSessionRoom => 'Sesión / sala';

  @override
  String get settingsSessionRoomHint =>
      'Solo los pares en la misma sala son descubiertos';

  @override
  String get settingsListeningPort => 'Puerto de escucha';

  @override
  String get settingsStartingServer => 'Iniciando servidor…';

  @override
  String settingsAddressShare(String address) {
    return '$address (comparte esto para conectar manualmente)';
  }

  @override
  String get settingsCopyAddress => 'Copiar dirección';

  @override
  String get settingsAddressCopied => 'Dirección copiada al portapapeles';

  @override
  String settingsSavedSnack(String name, String room) {
    return 'Configuración guardada · \"$name\" · sala \"$room\"';
  }

  @override
  String get settingsAppearanceSection => 'Apariencia';

  @override
  String get settingsMode => 'Modo';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsSkin => 'Apariencia';

  @override
  String get settingsSkinDefault => 'Predeterminado';

  @override
  String get settingsSkinOcean => 'Océano';

  @override
  String get settingsSkinForest => 'Bosque';

  @override
  String get settingsSkinSunset => 'Atardecer';

  @override
  String get settingsSkinSlate => 'Pizarra';

  @override
  String settingsSkinStandardLabel(String skin) {
    return '$skin · Standard';
  }

  @override
  String get settingsStandardSection => 'Netpad Standard';

  @override
  String get settingsStandardUnlocked => 'Standard desbloqueado';

  @override
  String get settingsFree => 'Gratis';

  @override
  String get settingsStandardUnlockedSubtitle =>
      'Notas sincronizadas y pares ilimitados, apariencias, historial, sincronización automática y voz';

  @override
  String get settingsStandardBuySubtitle =>
      'Desbloqueo único a través de tu tienda de aplicaciones';

  @override
  String get settingsPurchasesUnavailable =>
      'Compras no disponibles en esta plataforma';

  @override
  String get settingsRestorePurchases => 'Restaurar compras';

  @override
  String get settingsStandardRestored => 'Standard restaurado';

  @override
  String get settingsNoPreviousStandard =>
      'No se encontró ninguna compra anterior de Standard';

  @override
  String get settingsEditorSection => 'Editor';

  @override
  String get settingsWordWrap => 'Ajuste de línea';

  @override
  String get settingsWordWrapSubtitle =>
      'Ajustar líneas largas en lugar de desplazamiento horizontal';

  @override
  String settingsFontSize(int size) {
    return 'Tamaño de fuente ($size pt)';
  }

  @override
  String get settingsLegalSection => 'Legal';

  @override
  String get settingsEulaSubtitleStandard =>
      'Standard · Abre EULA en GitHub Pages';

  @override
  String get settingsEulaSubtitleFree => 'Gratis · Abre EULA en GitHub Pages';

  @override
  String get settingsPrivacySubtitle =>
      'Abre la página de privacidad en GitHub Pages';

  @override
  String get settingsDisclaimerTitle =>
      'Descargo de responsabilidad y responsabilidad';

  @override
  String get settingsDisclaimerSubtitle => 'Úsalo bajo tu propio riesgo';

  @override
  String get settingsDisclaimerP1 =>
      'Este software se proporciona \"tal cual\", sin garantías de ningún tipo, expresas o implícitas, incluidas la comerciabilidad, la idoneidad para un propósito particular y la no infracción.';

  @override
  String get settingsDisclaimerP2 =>
      'Eres el único responsable de cómo usas esta aplicación y del cumplimiento de todas las leyes, reglamentos, políticas y acuerdos aplicables.';

  @override
  String get settingsDisclaimerP3 =>
      'El titular del copyright no es responsable de ninguna reclamación, daño, pérdida, pérdida de datos, interrupción del negocio u otra responsabilidad derivada del uso o mal uso de este software.';

  @override
  String get settingsNoLegalAdviceTitle => 'Sin asesoramiento legal';

  @override
  String get settingsNoLegalAdviceSubtitle => 'Solo software informativo';

  @override
  String get settingsNoLegalAdviceP1 =>
      'Esta aplicación y su documentación no proporcionan asesoramiento legal, regulatorio ni profesional.';

  @override
  String get settingsNoLegalAdviceP2 =>
      'Si necesitas orientación legal para tu caso de uso, consulta a un profesional calificado.';

  @override
  String get settingsCopyright => '© 2026 Spencer Beaumier';

  @override
  String get paywallTitle => 'Desbloquear Netpad Standard';

  @override
  String get paywallSubtitle =>
      'Compra única. La edición básica y la sincronización LAN permanecen gratuitas.';

  @override
  String get paywallBenefitUnlimitedNotes => 'Notas sincronizadas ilimitadas';

  @override
  String get paywallBenefitUnlimitedPeers => 'Pares conectados ilimitados';

  @override
  String get paywallBenefitSkins => 'Apariencias de colores extra';

  @override
  String get paywallBenefitHistory => 'Historial de versiones';

  @override
  String get paywallBenefitAutoSync =>
      'Sincronización automática con pares de confianza';

  @override
  String get paywallBenefitVoice => 'Dictado por voz';

  @override
  String get paywallPurchasesUnsupported =>
      'Las compras integradas no están disponibles en esta plataforma. Instala desde App Store, Google Play o Microsoft Store para desbloquear Standard.';

  @override
  String get paywallBuyStandard => 'Comprar Standard';

  @override
  String paywallBuyStandardPrice(String price) {
    return 'Comprar Standard · $price';
  }

  @override
  String get paywallRestorePurchases => 'Restaurar compras';

  @override
  String get paywallPurchaseNotCompleted => 'La compra no se completó.';

  @override
  String get paywallPurchaseFailed => 'La compra falló.';

  @override
  String get paywallStandardRestored => 'Standard restaurado';

  @override
  String get paywallNoPreviousStandard =>
      'No se encontró ninguna compra anterior de Standard';

  @override
  String standardHighlightNoteLimit(int limit) {
    return 'La versión gratuita puede sincronizar hasta $limit notas a la vez. Desbloquea Standard para notas sincronizadas ilimitadas.';
  }

  @override
  String standardHighlightPeerLimit(int limit) {
    return 'La versión gratuita incluye hasta $limit pares conectados. Desbloquea Standard para pares ilimitados.';
  }

  @override
  String get standardHighlightVersionHistory =>
      'El historial de versiones es una función de Standard.';

  @override
  String get standardHighlightVoice =>
      'El dictado por voz es una función de Standard.';

  @override
  String get standardHighlightAutoSync =>
      'La sincronización automática con pares de confianza es una función de Standard.';

  @override
  String get standardHighlightSkins =>
      'Las apariencias extra están incluidas con Standard.';

  @override
  String get helpTitle => 'Ayuda';

  @override
  String get helpIntro =>
      'Un bloc de notas LAN para notas de texto simple. Los dispositivos en el mismo Wi‑Fi se descubren mutuamente, se emparejan una vez y luego sincronizan notas en tiempo real.';

  @override
  String get helpAboutTile => 'Acerca de SB Simple Netpad';

  @override
  String get helpEulaSubtitle => 'Abre EULA en GitHub Pages';

  @override
  String get helpPrivacySubtitle =>
      'Abre la página de privacidad en GitHub Pages';

  @override
  String get helpGettingStartedTitle => 'Primeros pasos';

  @override
  String get helpGettingStarted1 =>
      'Únete a la misma red Wi‑Fi que los dispositivos con los que deseas sincronizar.';

  @override
  String get helpGettingStarted2 =>
      'Abre el panel de pares (icono de candado o cajón de Pares) y espera a que aparezcan los dispositivos cercanos.';

  @override
  String get helpGettingStarted3 =>
      'Copia tu dirección desde Este dispositivo y compártela si el descubrimiento es lento.';

  @override
  String get helpGettingStarted4 =>
      'Usa Conectar por IP cuando el descubrimiento mDNS no encuentre pares.';

  @override
  String get helpNotesTitle => 'Notas';

  @override
  String get helpNotes1 =>
      'Toca el icono de menú (☰) o el panel de notas para cambiar entre notas.';

  @override
  String get helpNotes2 =>
      'Crea, renombra, reordena y elimina notas desde la lista de notas.';

  @override
  String get helpNotes3 =>
      'Cada nota se sincroniza de forma independiente — las notas nuevas empiezan solo en local; activa la sincronización para compartir con pares.';

  @override
  String get helpNotes4 =>
      'Busca dentro de una nota (Buscar) o en todas las notas desde el editor.';

  @override
  String get helpNotes5 =>
      'El historial de versiones guarda instantáneas locales que puedes restaurar más tarde.';

  @override
  String get helpPeersTitle => 'Pares y emparejamiento';

  @override
  String get helpPeers1 =>
      'Cercanos muestra los dispositivos descubiertos en la misma sala (ver Configuración).';

  @override
  String get helpPeers2 =>
      'Toca Conectar en un par — el otro dispositivo debe tocar Aceptar.';

  @override
  String get helpPeers3 =>
      'Compara el código de verificación de emparejamiento antes de aceptar.';

  @override
  String get helpPeers4 =>
      'Marca Confiar para auto-sincronización al aceptar si quieres que las reconexiones omitan Aceptar.';

  @override
  String get helpPeers5 =>
      'Dispositivos de confianza: alterna la sincronización automática o Revocar para requerir Aceptar de nuevo.';

  @override
  String get helpPeers6 =>
      'Bloquear desconecta un dispositivo y rechaza futuros emparejamientos hasta que sea desbloqueado.';

  @override
  String get helpPeers7 =>
      'Conectado muestra sesiones activas con dirección y presencia del cursor.';

  @override
  String get helpFileSharingTitle => 'Archivos y compartir';

  @override
  String get helpFileSharing1Desktop =>
      'Menú Archivo: Guardar en archivo, Abrir archivo como nota nueva, Compartir nota, Historial de versiones, Configuración, Salir.';

  @override
  String get helpFileSharing1Macos =>
      'File menu: Save to File, Open File as New Note, Share Note, Version History. Settings are under the app menu (Cmd+,); Quit ends the app.';

  @override
  String get helpFileSharing1Mobile =>
      'Menú (⋮): guardar en archivo, abrir archivo como nota nueva, compartir, historial de versiones, configuración y esta guía de ayuda.';

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
      'Compartir usa la hoja de compartir del SO; Linux recurre al portapapeles.';

  @override
  String get helpSettingsTitle => 'Configuración';

  @override
  String get helpSettings1 =>
      'El nombre del dispositivo y la sala requieren Guardar; las otras opciones se aplican inmediatamente.';

  @override
  String get helpSettings2 =>
      'El ID de sala agrupa pares: solo los dispositivos en la misma sala son descubiertos.';

  @override
  String get helpSettings3 =>
      'Las preferencias de apariencia y editor (tema, apariencia, ajuste, fuente) se guardan al cambiarlas.';

  @override
  String get helpDesktopShortcutsTitle => 'Atajos de escritorio';

  @override
  String get helpDesktopShortcuts1 => 'Ctrl/Cmd+S — Guardar en archivo';

  @override
  String get helpDesktopShortcuts2 =>
      'Ctrl/Cmd+O — Abrir archivo como nota nueva';

  @override
  String get helpDesktopShortcuts3 => 'Ctrl/Cmd+F — Buscar en nota';

  @override
  String get helpDesktopShortcuts4 =>
      'Ctrl+H (Windows/Linux) or Option+Cmd+F (macOS) — Find and replace';

  @override
  String get helpDesktopShortcuts5 => 'Ctrl/Cmd+N — Alternar panel de notas';

  @override
  String get helpDesktopShortcuts6 => 'Ctrl/Cmd+P — Alternar panel de pares';

  @override
  String get helpDesktopShortcuts7 =>
      'Ctrl/Cmd+Q — Exit (Windows/Linux); macOS uses Quit from the app menu';

  @override
  String get helpTroubleshootingTitle => 'Solución de problemas';

  @override
  String get helpTroubleshooting1 =>
      '¿Sin pares? Confirma la misma subred Wi‑Fi e ID de sala; intenta Conectar por IP.';

  @override
  String get helpTroubleshooting2 =>
      'El banner de red local requerida significa que la sincronización está pausada hasta que el Wi‑Fi esté activo.';

  @override
  String get helpTroubleshooting3 =>
      'Permite la aplicación a través de tu firewall en el primer inicio (escritorio).';

  @override
  String get helpTroubleshooting4 =>
      'Linux: instala dbus y avahi-daemon si el descubrimiento nunca comienza.';

  @override
  String get helpTroubleshooting5 =>
      'Android: otorga el permiso de Wi‑Fi cercano cuando se solicite.';

  @override
  String get helpTroubleshooting6 =>
      'iOS/macOS: allow Local Network access for SB Simple Netpad in System Settings if peers never appear.';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String get aboutTagline =>
      'Bloc de notas LAN con descubrimiento de pares y edición compartida.';

  @override
  String get aboutDescription =>
      'Escribe notas de texto simple en tu teléfono o computadora y mantenlas sincronizadas con otros dispositivos en el mismo Wi‑Fi. Los pares se descubren en la red local, se emparejan una vez con aprobación mutua y luego comparten múltiples notas con nombres con sesiones de pares cifradas.';

  @override
  String get aboutPlatforms => 'Android · iOS · Windows · macOS · Linux';

  @override
  String get aboutStatus => 'Beta — apto para uso LAN diario.';

  @override
  String get aboutEulaHeading => 'Acuerdo de licencia de usuario final';

  @override
  String aboutEulaBody(int noteLimit, int peerLimit) {
    return 'SB Simple Netpad está licenciado bajo un EULA, no una licencia de código abierto. La edición básica y la sincronización LAN son gratuitas (notas locales ilimitadas, hasta $noteLimit notas sincronizadas y $peerLimit pares conectados). Netpad Standard es un desbloqueo único a través de App Store, Google Play o Microsoft Store.';
  }

  @override
  String get aboutViewEula => 'Ver EULA';

  @override
  String get aboutPrivacyPolicy => 'Política de privacidad';

  @override
  String get aboutHowToUse => 'Cómo usar SB Simple Netpad';

  @override
  String get aboutCouldNotOpenPrivacy =>
      'No se pudo abrir la política de privacidad';

  @override
  String get aboutCouldNotOpenEula => 'No se pudo abrir el EULA';

  @override
  String get aboutCopyright => '© 2026 Spencer Beaumier';

  @override
  String conflictLiveTitle(String title) {
    return 'Conflicto de edición en \"$title\"';
  }

  @override
  String conflictLiveBody(
    String peer,
    String revision,
    String localPreview,
    String remotePreview,
  ) {
    return '$peer editó la misma nota al mismo tiempo (revisión $revision).\n\nTuya:\n$localPreview\n\n$peer:\n$remotePreview\n\n¿Qué versión deben conservar ambos dispositivos?';
  }

  @override
  String conflictDivergedTitle(String title) {
    return '\"$title\" ha divergido';
  }

  @override
  String conflictDivergedBody(
    String peer,
    String title,
    int localChars,
    int remoteChars,
  ) {
    return 'Tu copia y la copia de $peer de \"$title\" cambiaron de forma diferente mientras estaban desconectadas.\n\nTuya: $localChars caracteres\n$peer: $remoteChars caracteres\n\n¿Qué versión deben conservar ambos dispositivos?';
  }

  @override
  String conflictUsePeers(String peer) {
    return 'Usar la de $peer';
  }

  @override
  String get conflictKeepMine => 'Conservar la mía';

  @override
  String fileSavedTo(String path) {
    return 'Guardado en $path';
  }

  @override
  String fileCouldNotSave(String error) {
    return 'No se pudo guardar: $error';
  }

  @override
  String fileOpenedAsNewNote(String name) {
    return 'Se abrió $name como nota nueva';
  }

  @override
  String fileCouldNotOpen(String error) {
    return 'No se pudo abrir: $error';
  }

  @override
  String get fileNothingToShare => 'Nada que compartir — la nota está vacía';

  @override
  String get fileShareFallbackClipboard =>
      'Compartir no está disponible aquí — copiado al portapapeles';

  @override
  String get fileDefaultNoteName => 'netpad-note';
}
