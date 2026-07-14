import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Prevent AppKit from injecting "Show Tab Bar" into Flutter's View menu,
    // which fights PlatformMenuDelegate.setMenus and makes the bar feel shaky.
    NSWindow.allowsAutomaticWindowTabbing = false
    super.applicationDidFinishLaunching(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
