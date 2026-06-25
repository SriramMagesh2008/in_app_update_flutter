import UIKit
import Flutter
import StoreKit

public class InAppUpdateFlutterPlugin: NSObject, FlutterPlugin, SKStoreProductViewControllerDelegate {
  var flutterResult: FlutterResult?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "in_app_update_flutter", binaryMessenger: registrar.messenger())
    let instance = InAppUpdateFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /// Resolves the view controller to present from at call time. Capturing the
  /// root view controller at registration is unreliable: on app launch the
  /// window/rootViewController may not be set yet (especially with scene-based
  /// lifecycles), leaving it nil for the lifetime of the plugin.
  private func topViewController() -> UIViewController? {
    let keyWindow = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }

    var top = keyWindow?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "showStoreUpdateIos",
       let args = call.arguments as? [String: Any],
       let appStoreId = args["appStoreId"] as? String {
      flutterResult = result
      showStoreProductView(appStoreId: appStoreId)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func showStoreProductView(appStoreId: String) {
    // StoreKit requires the iTunes item identifier as an NSNumber. Passing a
    // String causes loadProduct(withParameters:) to silently fail (loaded == false,
    // error == nil), which surfaces as STORE_NOT_LOADED.
    guard let appStoreIdNumber = Int(appStoreId) else {
      flutterResult?(FlutterError(code: "INVALID_APP_STORE_ID", message: "appStoreId must be a numeric value", details: appStoreId))
      return
    }

    let productViewController = SKStoreProductViewController()
    productViewController.delegate = self

    let parameters = [SKStoreProductParameterITunesItemIdentifier : NSNumber(value: appStoreIdNumber)]

    productViewController.loadProduct(withParameters: parameters) { loaded, error in
      if let error = error {
        self.flutterResult?(FlutterError(code: "STORE_ERROR", message: "Failed to load product", details: error.localizedDescription))
        return
      }

      guard loaded else {
        self.flutterResult?(FlutterError(code: "STORE_NOT_LOADED", message: "Could not load product", details: nil))
        return
      }

      guard let vc = self.topViewController() else {
        self.flutterResult?(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No view controller available to present the App Store overlay", details: nil))
        return
      }

      vc.present(productViewController, animated: true) {
        self.flutterResult?(nil)
      }
    }
  }

  public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
    viewController.dismiss(animated: true, completion: nil)
  }
}
