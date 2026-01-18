import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel?
  private var initialUrl: URL?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller = window?.rootViewController as! FlutterViewController
    methodChannel = FlutterMethodChannel(name: "com.example.mywallet/intent",
                                        binaryMessenger: controller.binaryMessenger)
    
    methodChannel?.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "getInitialIntent" {
        if let url = self?.initialUrl {
          result(url.path)
          self?.initialUrl = nil
        } else {
          result(nil)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if url.pathExtension == "pkpass" {
      handlePkpassFile(url)
      return true
    }
    return super.application(app, open: url, options: options)
  }
  
  private func handlePkpassFile(_ url: URL) {
    // Copy file to temp directory
    let tempDir = FileManager.default.temporaryDirectory
    let tempFile = tempDir.appendingPathComponent("temp.pkpass")
    
    do {
      if FileManager.default.fileExists(atPath: tempFile.path) {
        try FileManager.default.removeItem(at: tempFile)
      }
      try FileManager.default.copyItem(at: url, to: tempFile)
      
      if let channel = methodChannel {
        channel.invokeMethod("onNewIntent", arguments: tempFile.path)
      } else {
        initialUrl = tempFile
      }
    } catch {
      print("Error handling pkpass file: \(error)")
    }
  }
}
