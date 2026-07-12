import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('zh'),
  ];

  /// No description provided for @commonAppName.
  ///
  /// In en, this message translates to:
  /// **'SB Simple Netpad'**
  String get commonAppName;

  /// No description provided for @commonStandardName.
  ///
  /// In en, this message translates to:
  /// **'Netpad Standard'**
  String get commonStandardName;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get commonConnect;

  /// No description provided for @commonHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get commonHelp;

  /// No description provided for @commonSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get commonSettings;

  /// No description provided for @commonMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get commonMore;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get commonAccept;

  /// No description provided for @commonReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get commonReject;

  /// No description provided for @commonBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get commonBlock;

  /// No description provided for @commonUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get commonUnblock;

  /// No description provided for @commonRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get commonRevoke;

  /// No description provided for @commonRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get commonRestore;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCouldNotOpenLabel.
  ///
  /// In en, this message translates to:
  /// **'Could not open {label}'**
  String commonCouldNotOpenLabel(String label);

  /// No description provided for @commonEulaLabel.
  ///
  /// In en, this message translates to:
  /// **'EULA'**
  String get commonEulaLabel;

  /// No description provided for @commonPrivacyPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get commonPrivacyPolicyLabel;

  /// No description provided for @commonEndUserLicenseAgreement.
  ///
  /// In en, this message translates to:
  /// **'End User License Agreement'**
  String get commonEndUserLicenseAgreement;

  /// No description provided for @commonPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get commonPrivacyPolicy;

  /// No description provided for @commonVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String commonVersionLabel(String version);

  /// No description provided for @shellMenuFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get shellMenuFile;

  /// No description provided for @shellMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get shellMenuEdit;

  /// No description provided for @shellMenuView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get shellMenuView;

  /// No description provided for @shellMenuHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get shellMenuHelp;

  /// No description provided for @shellSaveToFile.
  ///
  /// In en, this message translates to:
  /// **'Save to File…'**
  String get shellSaveToFile;

  /// No description provided for @shellOpenFileAsNewNote.
  ///
  /// In en, this message translates to:
  /// **'Open File as New Note…'**
  String get shellOpenFileAsNewNote;

  /// No description provided for @shellShareNote.
  ///
  /// In en, this message translates to:
  /// **'Share Note'**
  String get shellShareNote;

  /// No description provided for @shellVersionHistory.
  ///
  /// In en, this message translates to:
  /// **'Version History…'**
  String get shellVersionHistory;

  /// No description provided for @shellSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings…'**
  String get shellSettings;

  /// No description provided for @shellExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get shellExit;

  /// No description provided for @shellCut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get shellCut;

  /// No description provided for @shellCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get shellCopy;

  /// No description provided for @shellPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get shellPaste;

  /// No description provided for @shellFind.
  ///
  /// In en, this message translates to:
  /// **'Find…'**
  String get shellFind;

  /// No description provided for @shellFindAndReplace.
  ///
  /// In en, this message translates to:
  /// **'Find and Replace…'**
  String get shellFindAndReplace;

  /// No description provided for @shellWordWrap.
  ///
  /// In en, this message translates to:
  /// **'Word Wrap'**
  String get shellWordWrap;

  /// No description provided for @shellWordWrapChecked.
  ///
  /// In en, this message translates to:
  /// **'Word Wrap ✓'**
  String get shellWordWrapChecked;

  /// No description provided for @shellNotesPanel.
  ///
  /// In en, this message translates to:
  /// **'Notes Panel'**
  String get shellNotesPanel;

  /// No description provided for @shellNotesPanelChecked.
  ///
  /// In en, this message translates to:
  /// **'Notes Panel ✓'**
  String get shellNotesPanelChecked;

  /// No description provided for @shellPeersPanel.
  ///
  /// In en, this message translates to:
  /// **'Peers Panel'**
  String get shellPeersPanel;

  /// No description provided for @shellPeersPanelChecked.
  ///
  /// In en, this message translates to:
  /// **'Peers Panel ✓'**
  String get shellPeersPanelChecked;

  /// No description provided for @shellHelpItem.
  ///
  /// In en, this message translates to:
  /// **'SB Simple Netpad Help'**
  String get shellHelpItem;

  /// No description provided for @shellAboutItem.
  ///
  /// In en, this message translates to:
  /// **'About SB Simple Netpad'**
  String get shellAboutItem;

  /// No description provided for @shellHideNotesPanel.
  ///
  /// In en, this message translates to:
  /// **'Hide notes panel'**
  String get shellHideNotesPanel;

  /// No description provided for @shellShowNotesPanel.
  ///
  /// In en, this message translates to:
  /// **'Show notes panel (Ctrl+N)'**
  String get shellShowNotesPanel;

  /// No description provided for @shellHidePeersPanel.
  ///
  /// In en, this message translates to:
  /// **'Hide peers panel'**
  String get shellHidePeersPanel;

  /// No description provided for @shellShowPeersPanel.
  ///
  /// In en, this message translates to:
  /// **'Show peers panel (Ctrl+P)'**
  String get shellShowPeersPanel;

  /// No description provided for @shellPeersTooltipConnected.
  ///
  /// In en, this message translates to:
  /// **'{count} encrypted peer sessions · {action} peers panel (Ctrl+P)'**
  String shellPeersTooltipConnected(int count, String action);

  /// No description provided for @shellPeersTooltipActionHide.
  ///
  /// In en, this message translates to:
  /// **'hide'**
  String get shellPeersTooltipActionHide;

  /// No description provided for @shellPeersTooltipActionShow.
  ///
  /// In en, this message translates to:
  /// **'show'**
  String get shellPeersTooltipActionShow;

  /// No description provided for @shellFindInNote.
  ///
  /// In en, this message translates to:
  /// **'Find in note (Ctrl+F)'**
  String get shellFindInNote;

  /// No description provided for @shellSecurityChipConnected.
  ///
  /// In en, this message translates to:
  /// **'{count} peer sessions encrypted with WSS/TLS · tap for peers'**
  String shellSecurityChipConnected(int count);

  /// No description provided for @shellSecurityChipNone.
  ///
  /// In en, this message translates to:
  /// **'No active peer sessions · tap for peers'**
  String get shellSecurityChipNone;

  /// No description provided for @shellMobileWordWrap.
  ///
  /// In en, this message translates to:
  /// **'Word wrap'**
  String get shellMobileWordWrap;

  /// No description provided for @shellMobileSaveToFile.
  ///
  /// In en, this message translates to:
  /// **'Save to file…'**
  String get shellMobileSaveToFile;

  /// No description provided for @shellMobileOpenFileAsNewNote.
  ///
  /// In en, this message translates to:
  /// **'Open file as new note…'**
  String get shellMobileOpenFileAsNewNote;

  /// No description provided for @shellMobileShareNote.
  ///
  /// In en, this message translates to:
  /// **'Share note'**
  String get shellMobileShareNote;

  /// No description provided for @shellMobileVersionHistory.
  ///
  /// In en, this message translates to:
  /// **'Version history…'**
  String get shellMobileVersionHistory;

  /// No description provided for @shellMobileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get shellMobileSettings;

  /// No description provided for @shellMobileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get shellMobileHelp;

  /// No description provided for @shellMobileAbout.
  ///
  /// In en, this message translates to:
  /// **'About SB Simple Netpad'**
  String get shellMobileAbout;

  /// No description provided for @shellListeningSnack.
  ///
  /// In en, this message translates to:
  /// **'Listening… tap the mic again to stop'**
  String get shellListeningSnack;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// No description provided for @notesNewNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get notesNewNote;

  /// No description provided for @notesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search all notes'**
  String get notesSearchHint;

  /// No description provided for @notesRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename note'**
  String get notesRenameTitle;

  /// No description provided for @notesTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get notesTitleLabel;

  /// No description provided for @notesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String notesDeleteTitle(String title);

  /// No description provided for @notesDeleteSyncedBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the note for you and every connected peer.'**
  String get notesDeleteSyncedBody;

  /// No description provided for @notesDeleteLocalBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the note from this device only.'**
  String get notesDeleteLocalBody;

  /// No description provided for @notesNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get notesNoMatches;

  /// No description provided for @notesNoNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes'**
  String get notesNoNotes;

  /// No description provided for @notesRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get notesRename;

  /// No description provided for @notesVersionHistory.
  ///
  /// In en, this message translates to:
  /// **'Version history'**
  String get notesVersionHistory;

  /// No description provided for @notesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get notesDelete;

  /// No description provided for @notesSyncWithPeers.
  ///
  /// In en, this message translates to:
  /// **'Sync with peers'**
  String get notesSyncWithPeers;

  /// No description provided for @notesLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Local only'**
  String get notesLocalOnly;

  /// No description provided for @notesEmptyNote.
  ///
  /// In en, this message translates to:
  /// **'Empty note'**
  String get notesEmptyNote;

  /// No description provided for @notesMatchCount.
  ///
  /// In en, this message translates to:
  /// **'{count} matches'**
  String notesMatchCount(int count);

  /// No description provided for @notesLocalOnlyWithMatches.
  ///
  /// In en, this message translates to:
  /// **'Local only · {matchLine}'**
  String notesLocalOnlyWithMatches(String matchLine);

  /// No description provided for @notesSearchSnippetMatches.
  ///
  /// In en, this message translates to:
  /// **'{snippet}  ·  {count} matches'**
  String notesSearchSnippetMatches(String snippet, int count);

  /// No description provided for @notesNoNoteSelected.
  ///
  /// In en, this message translates to:
  /// **'No note selected'**
  String get notesNoNoteSelected;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Version history · \"{title}\"'**
  String historyTitle(String title);

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved versions yet. Snapshots are kept automatically before remote edits replace your text.'**
  String get historyEmpty;

  /// No description provided for @historyEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{label} · {time} · {chars} chars'**
  String historyEntrySubtitle(String label, String time, int chars);

  /// No description provided for @historyRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get historyRestore;

  /// No description provided for @historyRestoredSnack.
  ///
  /// In en, this message translates to:
  /// **'Version restored'**
  String get historyRestoredSnack;

  /// No description provided for @historyBeforeRemoteUpdate.
  ///
  /// In en, this message translates to:
  /// **'Before remote update'**
  String get historyBeforeRemoteUpdate;

  /// No description provided for @historySnapshot.
  ///
  /// In en, this message translates to:
  /// **'Snapshot'**
  String get historySnapshot;

  /// No description provided for @historyImportedFile.
  ///
  /// In en, this message translates to:
  /// **'Imported file'**
  String get historyImportedFile;

  /// No description provided for @editorFindHint.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get editorFindHint;

  /// No description provided for @editorReplaceHint.
  ///
  /// In en, this message translates to:
  /// **'Replace with'**
  String get editorReplaceHint;

  /// No description provided for @editorMatchCounter.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total}'**
  String editorMatchCounter(int current, int total);

  /// No description provided for @editorMatchNone.
  ///
  /// In en, this message translates to:
  /// **'0/0'**
  String get editorMatchNone;

  /// No description provided for @editorPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get editorPrevious;

  /// No description provided for @editorNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get editorNext;

  /// No description provided for @editorShowReplace.
  ///
  /// In en, this message translates to:
  /// **'Show replace (Ctrl+H)'**
  String get editorShowReplace;

  /// No description provided for @editorHideReplace.
  ///
  /// In en, this message translates to:
  /// **'Hide replace (Ctrl+H)'**
  String get editorHideReplace;

  /// No description provided for @editorClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get editorClose;

  /// No description provided for @editorReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get editorReplace;

  /// No description provided for @editorReplaceAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get editorReplaceAll;

  /// No description provided for @editorListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get editorListening;

  /// No description provided for @editorDictate.
  ///
  /// In en, this message translates to:
  /// **'Dictate'**
  String get editorDictate;

  /// No description provided for @editorStopDictation.
  ///
  /// In en, this message translates to:
  /// **'Stop dictation'**
  String get editorStopDictation;

  /// No description provided for @peersConnectByIp.
  ///
  /// In en, this message translates to:
  /// **'Connect by IP'**
  String get peersConnectByIp;

  /// No description provided for @peersConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get peersConnected;

  /// No description provided for @peersNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get peersNearby;

  /// No description provided for @peersTrustedDevices.
  ///
  /// In en, this message translates to:
  /// **'Trusted devices'**
  String get peersTrustedDevices;

  /// No description provided for @peersBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get peersBlocked;

  /// No description provided for @peersConnectionLog.
  ///
  /// In en, this message translates to:
  /// **'Connection log'**
  String get peersConnectionLog;

  /// No description provided for @peersNoActiveConnections.
  ///
  /// In en, this message translates to:
  /// **'No active connections'**
  String get peersNoActiveConnections;

  /// No description provided for @peersNoTrustedDevices.
  ///
  /// In en, this message translates to:
  /// **'No trusted devices — pair once to enable auto-sync'**
  String get peersNoTrustedDevices;

  /// No description provided for @peersNoBlockedDevices.
  ///
  /// In en, this message translates to:
  /// **'No blocked devices'**
  String get peersNoBlockedDevices;

  /// No description provided for @peersNoConnectionEvents.
  ///
  /// In en, this message translates to:
  /// **'No connection events yet'**
  String get peersNoConnectionEvents;

  /// No description provided for @peersNoDiscoveredPeers.
  ///
  /// In en, this message translates to:
  /// **'No discovered peers — Linux must be on the same Wi‑Fi subnet as This device (check the address above), or use Connect by IP'**
  String get peersNoDiscoveredPeers;

  /// No description provided for @peersDiscoveryPaused.
  ///
  /// In en, this message translates to:
  /// **'Peer discovery is paused until you join a local network'**
  String get peersDiscoveryPaused;

  /// No description provided for @peersDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get peersDisconnect;

  /// No description provided for @peersConnectNow.
  ///
  /// In en, this message translates to:
  /// **'Connect now'**
  String get peersConnectNow;

  /// No description provided for @peersConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get peersConnect;

  /// No description provided for @peersResolving.
  ///
  /// In en, this message translates to:
  /// **'Resolving…'**
  String get peersResolving;

  /// No description provided for @peersBlockTooltip.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get peersBlockTooltip;

  /// No description provided for @peersBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {peer}?'**
  String peersBlockTitle(String peer);

  /// No description provided for @peersBlockBody.
  ///
  /// In en, this message translates to:
  /// **'This disconnects the device, forgets its pinned certificate, and refuses future connection requests until you unblock it.'**
  String get peersBlockBody;

  /// No description provided for @peersRevokeTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke {peer}?'**
  String peersRevokeTitle(String peer);

  /// No description provided for @peersRevokeBody.
  ///
  /// In en, this message translates to:
  /// **'The next connection will require tapping Accept again. The security pin is kept so certificate checks still apply.'**
  String get peersRevokeBody;

  /// No description provided for @peersAutoSync.
  ///
  /// In en, this message translates to:
  /// **'Auto-sync'**
  String get peersAutoSync;

  /// No description provided for @peersCopiedOneLogEntry.
  ///
  /// In en, this message translates to:
  /// **'Copied 1 log entry'**
  String get peersCopiedOneLogEntry;

  /// No description provided for @peersCopiedLogEntries.
  ///
  /// In en, this message translates to:
  /// **'Copied {count} log entries'**
  String peersCopiedLogEntries(int count);

  /// No description provided for @peersLogRevision.
  ///
  /// In en, this message translates to:
  /// **'{time} • revision {revision}'**
  String peersLogRevision(String time, String revision);

  /// No description provided for @peersStillResolving.
  ///
  /// In en, this message translates to:
  /// **'Still resolving {peer}…'**
  String peersStillResolving(String peer);

  /// No description provided for @peersResolveFailedSnack.
  ///
  /// In en, this message translates to:
  /// **'Could not resolve {peer}. Check Avahi and same subnet, or use Connect by IP.'**
  String peersResolveFailedSnack(String peer);

  /// No description provided for @peersPairingRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Pairing request sent to {peer}'**
  String peersPairingRequestSent(String peer);

  /// No description provided for @peersCouldNotConnect.
  ///
  /// In en, this message translates to:
  /// **'Could not connect: {message}'**
  String peersCouldNotConnect(String message);

  /// No description provided for @peersManualHostPort.
  ///
  /// In en, this message translates to:
  /// **'{host}:{port} (manual)'**
  String peersManualHostPort(String host, int port);

  /// No description provided for @peersManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get peersManual;

  /// No description provided for @peersResolveFailedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Resolve failed — try Connect by IP'**
  String get peersResolveFailedSubtitle;

  /// No description provided for @peersResolvingAddress.
  ///
  /// In en, this message translates to:
  /// **'Resolving address…'**
  String get peersResolvingAddress;

  /// No description provided for @peersHostPort.
  ///
  /// In en, this message translates to:
  /// **'{host}:{port}'**
  String peersHostPort(String host, int port);

  /// No description provided for @peersNoAddressYet.
  ///
  /// In en, this message translates to:
  /// **'No address yet'**
  String get peersNoAddressYet;

  /// No description provided for @peersEncryptedPinned.
  ///
  /// In en, this message translates to:
  /// **'Encrypted · pinned {code}'**
  String peersEncryptedPinned(String code);

  /// No description provided for @peersEncryptedWss.
  ///
  /// In en, this message translates to:
  /// **'Encrypted (WSS/TLS)'**
  String get peersEncryptedWss;

  /// No description provided for @peersSubtitleWithPresence.
  ///
  /// In en, this message translates to:
  /// **'{subtitle} • {presence}'**
  String peersSubtitleWithPresence(String subtitle, String presence);

  /// No description provided for @peersSubtitleWithSecurity.
  ///
  /// In en, this message translates to:
  /// **'{subtitle} • {security}'**
  String peersSubtitleWithSecurity(String subtitle, String security);

  /// No description provided for @peersPairedStatus.
  ///
  /// In en, this message translates to:
  /// **'Paired {date} · {status}'**
  String peersPairedStatus(String date, String status);

  /// No description provided for @peersStatusConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get peersStatusConnected;

  /// No description provided for @peersStatusManualOnly.
  ///
  /// In en, this message translates to:
  /// **'Manual only'**
  String get peersStatusManualOnly;

  /// No description provided for @peersStatusReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get peersStatusReconnecting;

  /// No description provided for @peersStatusRetryIn.
  ///
  /// In en, this message translates to:
  /// **'Retry in {seconds}s'**
  String peersStatusRetryIn(int seconds);

  /// No description provided for @peersStatusNotOnNetwork.
  ///
  /// In en, this message translates to:
  /// **'Not on network'**
  String get peersStatusNotOnNetwork;

  /// No description provided for @peersStatusConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get peersStatusConnecting;

  /// No description provided for @peersStatusAutoReconnect.
  ///
  /// In en, this message translates to:
  /// **'Auto-reconnect'**
  String get peersStatusAutoReconnect;

  /// No description provided for @peersPresenceLineCol.
  ///
  /// In en, this message translates to:
  /// **'line {line}, col {column}'**
  String peersPresenceLineCol(int line, int column);

  /// No description provided for @peersPresenceInNote.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" · {position}'**
  String peersPresenceInNote(String title, String position);

  /// No description provided for @peersRoomLabel.
  ///
  /// In en, this message translates to:
  /// **'Room \"{room}\"'**
  String peersRoomLabel(String room);

  /// No description provided for @discoveryThisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get discoveryThisDevice;

  /// No description provided for @discoveryCopyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get discoveryCopyAddress;

  /// No description provided for @discoveryCopiedAddress.
  ///
  /// In en, this message translates to:
  /// **'Copied {address}'**
  String discoveryCopiedAddress(String address);

  /// No description provided for @discoveryLocalNetworkRequired.
  ///
  /// In en, this message translates to:
  /// **'Local network required'**
  String get discoveryLocalNetworkRequired;

  /// No description provided for @discoveryNotListeningTitle.
  ///
  /// In en, this message translates to:
  /// **'Not listening'**
  String get discoveryNotListeningTitle;

  /// No description provided for @discoveryNotListeningBody.
  ///
  /// In en, this message translates to:
  /// **'This device is not listening for peers yet. Wait a few seconds after joining Wi‑Fi, or tap Retry on a networking error banner.'**
  String get discoveryNotListeningBody;

  /// No description provided for @discoveryModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Discovery mode'**
  String get discoveryModeTitle;

  /// No description provided for @discoveryUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Peer discovery unavailable'**
  String get discoveryUnavailableTitle;

  /// No description provided for @discoveryRetryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Retry discovery'**
  String get discoveryRetryTooltip;

  /// No description provided for @peersSecuredSessions.
  ///
  /// In en, this message translates to:
  /// **'Secured sessions'**
  String get peersSecuredSessions;

  /// No description provided for @peersSecurityBannerIdle.
  ///
  /// In en, this message translates to:
  /// **'This device advertises over WSS/TLS · code {code}'**
  String peersSecurityBannerIdle(String code);

  /// No description provided for @peersSecurityBannerActive.
  ///
  /// In en, this message translates to:
  /// **'{connectedCount} encrypted sessions · {pinnedCount} certificates pinned'**
  String peersSecurityBannerActive(int connectedCount, int pinnedCount);

  /// No description provided for @peersSecurityCompactIdle.
  ///
  /// In en, this message translates to:
  /// **'WSS/TLS · code {code}'**
  String peersSecurityCompactIdle(String code);

  /// No description provided for @peersSecurityCompactActive.
  ///
  /// In en, this message translates to:
  /// **'{connectedCount} encrypted · {pinnedCount} pinned'**
  String peersSecurityCompactActive(int connectedCount, int pinnedCount);

  /// No description provided for @peersSecurityTooltipPinned.
  ///
  /// In en, this message translates to:
  /// **'Encrypted (WSS/TLS) · pinned {code}'**
  String peersSecurityTooltipPinned(String code);

  /// No description provided for @peersSecurityTooltipActive.
  ///
  /// In en, this message translates to:
  /// **'Encrypted (WSS/TLS) · active session'**
  String get peersSecurityTooltipActive;

  /// No description provided for @pairingConnectionRequest.
  ///
  /// In en, this message translates to:
  /// **'Connection request'**
  String get pairingConnectionRequest;

  /// No description provided for @pairingAllowPeer.
  ///
  /// In en, this message translates to:
  /// **'Allow {peer} to connect and share this note?'**
  String pairingAllowPeer(String peer);

  /// No description provided for @pairingVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get pairingVerificationCode;

  /// No description provided for @pairingConfirmCode.
  ///
  /// In en, this message translates to:
  /// **'Confirm this code matches on both devices before accepting.'**
  String get pairingConfirmCode;

  /// No description provided for @pairingThisDeviceSecurityCode.
  ///
  /// In en, this message translates to:
  /// **'This device security code'**
  String get pairingThisDeviceSecurityCode;

  /// No description provided for @pairingOtherDevicePins.
  ///
  /// In en, this message translates to:
  /// **'The other device pins this on first connect.'**
  String get pairingOtherDevicePins;

  /// No description provided for @manualConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect by address'**
  String get manualConnectTitle;

  /// No description provided for @manualConnectBody.
  ///
  /// In en, this message translates to:
  /// **'Use when discovery cannot find peers on the same subnet. Only addresses on your active local network segment are allowed.'**
  String get manualConnectBody;

  /// No description provided for @manualConnectHostLabel.
  ///
  /// In en, this message translates to:
  /// **'Host or IP'**
  String get manualConnectHostLabel;

  /// No description provided for @manualConnectHostHint.
  ///
  /// In en, this message translates to:
  /// **'192.168.1.42'**
  String get manualConnectHostHint;

  /// No description provided for @manualConnectPortLabel.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get manualConnectPortLabel;

  /// No description provided for @manualConnectPortHint.
  ///
  /// In en, this message translates to:
  /// **'54321'**
  String get manualConnectPortHint;

  /// No description provided for @manualConnectLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Label (optional)'**
  String get manualConnectLabelOptional;

  /// No description provided for @manualConnectLabelHint.
  ///
  /// In en, this message translates to:
  /// **'Living room PC'**
  String get manualConnectLabelHint;

  /// No description provided for @manualConnectInvalidHostPort.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid host and port (1–65535)'**
  String get manualConnectInvalidHostPort;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsDeviceSection.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get settingsDeviceSection;

  /// No description provided for @settingsDeviceHint.
  ///
  /// In en, this message translates to:
  /// **'Device name and room require Save (Ctrl+S). Appearance and editor preferences save immediately.'**
  String get settingsDeviceHint;

  /// No description provided for @settingsDeviceName.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get settingsDeviceName;

  /// No description provided for @settingsDeviceNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name shown to other devices'**
  String get settingsDeviceNameHint;

  /// No description provided for @settingsSessionRoom.
  ///
  /// In en, this message translates to:
  /// **'Session / room'**
  String get settingsSessionRoom;

  /// No description provided for @settingsSessionRoomHint.
  ///
  /// In en, this message translates to:
  /// **'Only peers in the same room are discovered'**
  String get settingsSessionRoomHint;

  /// No description provided for @settingsListeningPort.
  ///
  /// In en, this message translates to:
  /// **'Listening port'**
  String get settingsListeningPort;

  /// No description provided for @settingsStartingServer.
  ///
  /// In en, this message translates to:
  /// **'Starting server…'**
  String get settingsStartingServer;

  /// No description provided for @settingsAddressShare.
  ///
  /// In en, this message translates to:
  /// **'{address} (share this with manual connect)'**
  String settingsAddressShare(String address);

  /// No description provided for @settingsCopyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get settingsCopyAddress;

  /// No description provided for @settingsAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard'**
  String get settingsAddressCopied;

  /// No description provided for @settingsSavedSnack.
  ///
  /// In en, this message translates to:
  /// **'Settings saved · \"{name}\" · room \"{room}\"'**
  String settingsSavedSnack(String name, String room);

  /// No description provided for @settingsAppearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceSection;

  /// No description provided for @settingsMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get settingsMode;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsSkin.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get settingsSkin;

  /// No description provided for @settingsSkinDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settingsSkinDefault;

  /// No description provided for @settingsSkinOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get settingsSkinOcean;

  /// No description provided for @settingsSkinForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get settingsSkinForest;

  /// No description provided for @settingsSkinSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get settingsSkinSunset;

  /// No description provided for @settingsSkinSlate.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get settingsSkinSlate;

  /// No description provided for @settingsSkinStandardLabel.
  ///
  /// In en, this message translates to:
  /// **'{skin} · Standard'**
  String settingsSkinStandardLabel(String skin);

  /// No description provided for @settingsStandardSection.
  ///
  /// In en, this message translates to:
  /// **'Netpad Standard'**
  String get settingsStandardSection;

  /// No description provided for @settingsStandardUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Standard unlocked'**
  String get settingsStandardUnlocked;

  /// No description provided for @settingsFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get settingsFree;

  /// No description provided for @settingsStandardUnlockedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited notes and peers, skins, history, auto-sync, and voice'**
  String get settingsStandardUnlockedSubtitle;

  /// No description provided for @settingsStandardBuySubtitle.
  ///
  /// In en, this message translates to:
  /// **'One-time unlock via your app store'**
  String get settingsStandardBuySubtitle;

  /// No description provided for @settingsPurchasesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Purchases unavailable on this platform'**
  String get settingsPurchasesUnavailable;

  /// No description provided for @settingsRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get settingsRestorePurchases;

  /// No description provided for @settingsStandardRestored.
  ///
  /// In en, this message translates to:
  /// **'Standard restored'**
  String get settingsStandardRestored;

  /// No description provided for @settingsNoPreviousStandard.
  ///
  /// In en, this message translates to:
  /// **'No previous Standard purchase found'**
  String get settingsNoPreviousStandard;

  /// No description provided for @settingsEditorSection.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get settingsEditorSection;

  /// No description provided for @settingsWordWrap.
  ///
  /// In en, this message translates to:
  /// **'Word wrap'**
  String get settingsWordWrap;

  /// No description provided for @settingsWordWrapSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Wrap long lines instead of horizontal scroll'**
  String get settingsWordWrapSubtitle;

  /// No description provided for @settingsFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size ({size} pt)'**
  String settingsFontSize(int size);

  /// No description provided for @settingsLegalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsLegalSection;

  /// No description provided for @settingsEulaSubtitleStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard · Opens EULA on GitHub Pages'**
  String get settingsEulaSubtitleStandard;

  /// No description provided for @settingsEulaSubtitleFree.
  ///
  /// In en, this message translates to:
  /// **'Free · Opens EULA on GitHub Pages'**
  String get settingsEulaSubtitleFree;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Opens privacy page on GitHub Pages'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer and liability'**
  String get settingsDisclaimerTitle;

  /// No description provided for @settingsDisclaimerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use at your own risk'**
  String get settingsDisclaimerSubtitle;

  /// No description provided for @settingsDisclaimerP1.
  ///
  /// In en, this message translates to:
  /// **'This software is provided \"as is\", without warranties of any kind, express or implied, including merchantability, fitness for a particular purpose, and non-infringement.'**
  String get settingsDisclaimerP1;

  /// No description provided for @settingsDisclaimerP2.
  ///
  /// In en, this message translates to:
  /// **'You are solely responsible for how you use this app and for compliance with all applicable laws, regulations, policies, and agreements.'**
  String get settingsDisclaimerP2;

  /// No description provided for @settingsDisclaimerP3.
  ///
  /// In en, this message translates to:
  /// **'The copyright holder is not liable for any claims, damages, losses, data loss, business interruption, or other liability arising from use or misuse of this software.'**
  String get settingsDisclaimerP3;

  /// No description provided for @settingsNoLegalAdviceTitle.
  ///
  /// In en, this message translates to:
  /// **'No legal advice'**
  String get settingsNoLegalAdviceTitle;

  /// No description provided for @settingsNoLegalAdviceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Informational software only'**
  String get settingsNoLegalAdviceSubtitle;

  /// No description provided for @settingsNoLegalAdviceP1.
  ///
  /// In en, this message translates to:
  /// **'This app and its documentation do not provide legal, regulatory, or professional advice.'**
  String get settingsNoLegalAdviceP1;

  /// No description provided for @settingsNoLegalAdviceP2.
  ///
  /// In en, this message translates to:
  /// **'If you need legal guidance for your use case, consult a qualified professional.'**
  String get settingsNoLegalAdviceP2;

  /// No description provided for @settingsCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Spencer Beaumier'**
  String get settingsCopyright;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock Netpad Standard'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase. Core editing and LAN sync stay free.'**
  String get paywallSubtitle;

  /// No description provided for @paywallBenefitUnlimitedNotes.
  ///
  /// In en, this message translates to:
  /// **'Unlimited notes'**
  String get paywallBenefitUnlimitedNotes;

  /// No description provided for @paywallBenefitUnlimitedPeers.
  ///
  /// In en, this message translates to:
  /// **'Unlimited connected peers'**
  String get paywallBenefitUnlimitedPeers;

  /// No description provided for @paywallBenefitSkins.
  ///
  /// In en, this message translates to:
  /// **'Extra color skins'**
  String get paywallBenefitSkins;

  /// No description provided for @paywallBenefitHistory.
  ///
  /// In en, this message translates to:
  /// **'Version history'**
  String get paywallBenefitHistory;

  /// No description provided for @paywallBenefitAutoSync.
  ///
  /// In en, this message translates to:
  /// **'Trusted peer auto-sync'**
  String get paywallBenefitAutoSync;

  /// No description provided for @paywallBenefitVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice dictation'**
  String get paywallBenefitVoice;

  /// No description provided for @paywallPurchasesUnsupported.
  ///
  /// In en, this message translates to:
  /// **'In-app purchases are not available on this platform. Install from the App Store, Google Play, or Microsoft Store to unlock Standard.'**
  String get paywallPurchasesUnsupported;

  /// No description provided for @paywallBuyStandard.
  ///
  /// In en, this message translates to:
  /// **'Buy Standard'**
  String get paywallBuyStandard;

  /// No description provided for @paywallBuyStandardPrice.
  ///
  /// In en, this message translates to:
  /// **'Buy Standard · {price}'**
  String paywallBuyStandardPrice(String price);

  /// No description provided for @paywallRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestorePurchases;

  /// No description provided for @paywallPurchaseNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Purchase was not completed.'**
  String get paywallPurchaseNotCompleted;

  /// No description provided for @paywallPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed.'**
  String get paywallPurchaseFailed;

  /// No description provided for @paywallStandardRestored.
  ///
  /// In en, this message translates to:
  /// **'Standard restored'**
  String get paywallStandardRestored;

  /// No description provided for @paywallNoPreviousStandard.
  ///
  /// In en, this message translates to:
  /// **'No previous Standard purchase found'**
  String get paywallNoPreviousStandard;

  /// No description provided for @standardHighlightNoteLimit.
  ///
  /// In en, this message translates to:
  /// **'Free includes up to {limit} notes. Unlock Standard for unlimited notes.'**
  String standardHighlightNoteLimit(int limit);

  /// No description provided for @standardHighlightPeerLimit.
  ///
  /// In en, this message translates to:
  /// **'Free includes up to {limit} connected peers. Unlock Standard for unlimited peers.'**
  String standardHighlightPeerLimit(int limit);

  /// No description provided for @standardHighlightVersionHistory.
  ///
  /// In en, this message translates to:
  /// **'Version history is a Standard feature.'**
  String get standardHighlightVersionHistory;

  /// No description provided for @standardHighlightVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice dictation is a Standard feature.'**
  String get standardHighlightVoice;

  /// No description provided for @standardHighlightAutoSync.
  ///
  /// In en, this message translates to:
  /// **'Trusted peer auto-sync is a Standard feature.'**
  String get standardHighlightAutoSync;

  /// No description provided for @standardHighlightSkins.
  ///
  /// In en, this message translates to:
  /// **'Extra skins are included with Standard.'**
  String get standardHighlightSkins;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @helpIntro.
  ///
  /// In en, this message translates to:
  /// **'A LAN notepad for plain-text notes. Devices on the same Wi‑Fi discover each other, pair once, then sync notes in real time.'**
  String get helpIntro;

  /// No description provided for @helpAboutTile.
  ///
  /// In en, this message translates to:
  /// **'About SB Simple Netpad'**
  String get helpAboutTile;

  /// No description provided for @helpEulaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Opens EULA on GitHub Pages'**
  String get helpEulaSubtitle;

  /// No description provided for @helpPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Opens privacy page on GitHub Pages'**
  String get helpPrivacySubtitle;

  /// No description provided for @helpGettingStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Getting started'**
  String get helpGettingStartedTitle;

  /// No description provided for @helpGettingStarted1.
  ///
  /// In en, this message translates to:
  /// **'Join the same Wi‑Fi network as the devices you want to sync with.'**
  String get helpGettingStarted1;

  /// No description provided for @helpGettingStarted2.
  ///
  /// In en, this message translates to:
  /// **'Open the Peers panel (lock icon or Peers drawer) and wait for nearby devices to appear.'**
  String get helpGettingStarted2;

  /// No description provided for @helpGettingStarted3.
  ///
  /// In en, this message translates to:
  /// **'Copy your address from This device and share it if discovery is slow.'**
  String get helpGettingStarted3;

  /// No description provided for @helpGettingStarted4.
  ///
  /// In en, this message translates to:
  /// **'Use Connect by IP when mDNS discovery does not find peers.'**
  String get helpGettingStarted4;

  /// No description provided for @helpNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get helpNotesTitle;

  /// No description provided for @helpNotes1.
  ///
  /// In en, this message translates to:
  /// **'Tap the menu icon (☰) or Notes panel to switch between notes.'**
  String get helpNotes1;

  /// No description provided for @helpNotes2.
  ///
  /// In en, this message translates to:
  /// **'Create, rename, reorder, and delete notes from the notes list.'**
  String get helpNotes2;

  /// No description provided for @helpNotes3.
  ///
  /// In en, this message translates to:
  /// **'Each note syncs independently — toggle sync per note when needed.'**
  String get helpNotes3;

  /// No description provided for @helpNotes4.
  ///
  /// In en, this message translates to:
  /// **'Search within a note (Find) or across all notes from the editor.'**
  String get helpNotes4;

  /// No description provided for @helpNotes5.
  ///
  /// In en, this message translates to:
  /// **'Version history saves local snapshots you can restore later.'**
  String get helpNotes5;

  /// No description provided for @helpPeersTitle.
  ///
  /// In en, this message translates to:
  /// **'Peers & pairing'**
  String get helpPeersTitle;

  /// No description provided for @helpPeers1.
  ///
  /// In en, this message translates to:
  /// **'Nearby lists discovered devices in the same room (see Settings).'**
  String get helpPeers1;

  /// No description provided for @helpPeers2.
  ///
  /// In en, this message translates to:
  /// **'Tap Connect on a peer — the other device must tap Accept.'**
  String get helpPeers2;

  /// No description provided for @helpPeers3.
  ///
  /// In en, this message translates to:
  /// **'Compare the pairing verification code before accepting.'**
  String get helpPeers3;

  /// No description provided for @helpPeers4.
  ///
  /// In en, this message translates to:
  /// **'After the first Accept, trusted devices can auto-reconnect.'**
  String get helpPeers4;

  /// No description provided for @helpPeers5.
  ///
  /// In en, this message translates to:
  /// **'Trusted devices: toggle auto-sync or Revoke to require Accept again.'**
  String get helpPeers5;

  /// No description provided for @helpPeers6.
  ///
  /// In en, this message translates to:
  /// **'Block disconnects a device and refuses future pairing until unblocked.'**
  String get helpPeers6;

  /// No description provided for @helpPeers7.
  ///
  /// In en, this message translates to:
  /// **'Connected shows active sessions with address and cursor presence.'**
  String get helpPeers7;

  /// No description provided for @helpFileSharingTitle.
  ///
  /// In en, this message translates to:
  /// **'File & sharing'**
  String get helpFileSharingTitle;

  /// No description provided for @helpFileSharing1Desktop.
  ///
  /// In en, this message translates to:
  /// **'File menu: Save to File, Open File as New Note, Share Note, Version History, Settings, Exit.'**
  String get helpFileSharing1Desktop;

  /// No description provided for @helpFileSharing1Mobile.
  ///
  /// In en, this message translates to:
  /// **'Overflow menu (⋮): save to file, open file as new note, share, version history, settings, and this help guide.'**
  String get helpFileSharing1Mobile;

  /// No description provided for @helpFileSharing2.
  ///
  /// In en, this message translates to:
  /// **'Save to file exports the active note as .txt or .md.'**
  String get helpFileSharing2;

  /// No description provided for @helpFileSharing3.
  ///
  /// In en, this message translates to:
  /// **'Open file imports text into a new note that syncs like any other.'**
  String get helpFileSharing3;

  /// No description provided for @helpFileSharing4.
  ///
  /// In en, this message translates to:
  /// **'Share uses the OS share sheet; Linux falls back to clipboard.'**
  String get helpFileSharing4;

  /// No description provided for @helpSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get helpSettingsTitle;

  /// No description provided for @helpSettings1.
  ///
  /// In en, this message translates to:
  /// **'Device name and room require Save — other options apply immediately.'**
  String get helpSettings1;

  /// No description provided for @helpSettings2.
  ///
  /// In en, this message translates to:
  /// **'Room ID groups peers: only devices in the same room are discovered.'**
  String get helpSettings2;

  /// No description provided for @helpSettings3.
  ///
  /// In en, this message translates to:
  /// **'Appearance and editor preferences (theme, skin, wrap, font) save as you change them.'**
  String get helpSettings3;

  /// No description provided for @helpDesktopShortcutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Desktop shortcuts'**
  String get helpDesktopShortcutsTitle;

  /// No description provided for @helpDesktopShortcuts1.
  ///
  /// In en, this message translates to:
  /// **'Ctrl/Cmd+S — Save to file'**
  String get helpDesktopShortcuts1;

  /// No description provided for @helpDesktopShortcuts2.
  ///
  /// In en, this message translates to:
  /// **'Ctrl/Cmd+O — Open file as new note'**
  String get helpDesktopShortcuts2;

  /// No description provided for @helpDesktopShortcuts3.
  ///
  /// In en, this message translates to:
  /// **'Ctrl/Cmd+F — Find in note'**
  String get helpDesktopShortcuts3;

  /// No description provided for @helpDesktopShortcuts4.
  ///
  /// In en, this message translates to:
  /// **'Ctrl/Cmd+H — Find and replace'**
  String get helpDesktopShortcuts4;

  /// No description provided for @helpDesktopShortcuts5.
  ///
  /// In en, this message translates to:
  /// **'Ctrl/Cmd+N — Toggle notes panel'**
  String get helpDesktopShortcuts5;

  /// No description provided for @helpDesktopShortcuts6.
  ///
  /// In en, this message translates to:
  /// **'Ctrl/Cmd+P — Toggle peers panel'**
  String get helpDesktopShortcuts6;

  /// No description provided for @helpDesktopShortcuts7.
  ///
  /// In en, this message translates to:
  /// **'Ctrl/Cmd+Q — Exit (Windows/Linux)'**
  String get helpDesktopShortcuts7;

  /// No description provided for @helpTroubleshootingTitle.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting'**
  String get helpTroubleshootingTitle;

  /// No description provided for @helpTroubleshooting1.
  ///
  /// In en, this message translates to:
  /// **'No peers? Confirm same Wi‑Fi subnet and room ID; try Connect by IP.'**
  String get helpTroubleshooting1;

  /// No description provided for @helpTroubleshooting2.
  ///
  /// In en, this message translates to:
  /// **'Local network required banner means sync is paused until Wi‑Fi is up.'**
  String get helpTroubleshooting2;

  /// No description provided for @helpTroubleshooting3.
  ///
  /// In en, this message translates to:
  /// **'Allow the app through your firewall on first launch (desktop).'**
  String get helpTroubleshooting3;

  /// No description provided for @helpTroubleshooting4.
  ///
  /// In en, this message translates to:
  /// **'Linux: install dbus and avahi-daemon if discovery never starts.'**
  String get helpTroubleshooting4;

  /// No description provided for @helpTroubleshooting5.
  ///
  /// In en, this message translates to:
  /// **'Android: grant nearby Wi‑Fi permission when prompted.'**
  String get helpTroubleshooting5;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'LAN notepad with peer discovery and shared editing.'**
  String get aboutTagline;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Write plain-text notes on your phone or computer and keep them in sync with other devices on the same Wi‑Fi. Peers discover each other on the local network, pair once with mutual approval, then share multiple named notes with encrypted peer sessions.'**
  String get aboutDescription;

  /// No description provided for @aboutPlatforms.
  ///
  /// In en, this message translates to:
  /// **'Android · iOS · Windows · macOS · Linux'**
  String get aboutPlatforms;

  /// No description provided for @aboutStatus.
  ///
  /// In en, this message translates to:
  /// **'Beta — suitable for daily LAN use.'**
  String get aboutStatus;

  /// No description provided for @aboutEulaHeading.
  ///
  /// In en, this message translates to:
  /// **'End User License Agreement'**
  String get aboutEulaHeading;

  /// No description provided for @aboutEulaBody.
  ///
  /// In en, this message translates to:
  /// **'SB Simple Netpad is licensed under an EULA, not an open-source license. Core editing and LAN sync are free (up to {noteLimit} notes and {peerLimit} connected peers). Netpad Standard is a one-time unlock via the App Store, Google Play, or Microsoft Store.'**
  String aboutEulaBody(int noteLimit, int peerLimit);

  /// No description provided for @aboutViewEula.
  ///
  /// In en, this message translates to:
  /// **'View EULA'**
  String get aboutViewEula;

  /// No description provided for @aboutPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aboutPrivacyPolicy;

  /// No description provided for @aboutHowToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use SB Simple Netpad'**
  String get aboutHowToUse;

  /// No description provided for @aboutCouldNotOpenPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Could not open privacy policy'**
  String get aboutCouldNotOpenPrivacy;

  /// No description provided for @aboutCouldNotOpenEula.
  ///
  /// In en, this message translates to:
  /// **'Could not open EULA'**
  String get aboutCouldNotOpenEula;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Spencer Beaumier'**
  String get aboutCopyright;

  /// No description provided for @conflictLiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit conflict in \"{title}\"'**
  String conflictLiveTitle(String title);

  /// No description provided for @conflictLiveBody.
  ///
  /// In en, this message translates to:
  /// **'{peer} edited the same note at the same time (revision {revision}).\n\nYours:\n{localPreview}\n\n{peer}:\n{remotePreview}\n\nWhich version should both devices keep?'**
  String conflictLiveBody(
    String peer,
    String revision,
    String localPreview,
    String remotePreview,
  );

  /// No description provided for @conflictDivergedTitle.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" has diverged'**
  String conflictDivergedTitle(String title);

  /// No description provided for @conflictDivergedBody.
  ///
  /// In en, this message translates to:
  /// **'Your copy and {peer}\'s copy of \"{title}\" changed differently while disconnected.\n\nYours: {localChars} characters\n{peer}: {remoteChars} characters\n\nWhich version should both devices keep?'**
  String conflictDivergedBody(
    String peer,
    String title,
    int localChars,
    int remoteChars,
  );

  /// No description provided for @conflictUsePeers.
  ///
  /// In en, this message translates to:
  /// **'Use {peer}\'s'**
  String conflictUsePeers(String peer);

  /// No description provided for @conflictKeepMine.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get conflictKeepMine;

  /// No description provided for @fileSavedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String fileSavedTo(String path);

  /// No description provided for @fileCouldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {error}'**
  String fileCouldNotSave(String error);

  /// No description provided for @fileOpenedAsNewNote.
  ///
  /// In en, this message translates to:
  /// **'Opened {name} as a new note'**
  String fileOpenedAsNewNote(String name);

  /// No description provided for @fileCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open: {error}'**
  String fileCouldNotOpen(String error);

  /// No description provided for @fileNothingToShare.
  ///
  /// In en, this message translates to:
  /// **'Nothing to share — the note is empty'**
  String get fileNothingToShare;

  /// No description provided for @fileShareFallbackClipboard.
  ///
  /// In en, this message translates to:
  /// **'Sharing not available here — copied to clipboard'**
  String get fileShareFallbackClipboard;

  /// No description provided for @fileDefaultNoteName.
  ///
  /// In en, this message translates to:
  /// **'netpad-note'**
  String get fileDefaultNoteName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'nl',
    'pt',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
