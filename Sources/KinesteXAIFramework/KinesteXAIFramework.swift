
import SwiftUI
import WebKit

public enum WebViewMessage {
    case kinestexLaunched(String)
    case finishedWorkout(String)
    case errorOccurred(String)
    case exerciseCompleted(String)
    case exitApp(String)
    case workoutOpened(String)
    case workoutStarted(String)
    case planUnlocked(String)
    case unknown(String)
}

public enum PlanCategory {
    case Cardio
    case WeightManagement
    case Strength
    case Rehabilitation
    case Custom(String)
}

public enum WorkoutCategory {
    case Fitness
    case Rehabilitation
    case Custom(String)
  
}

public struct KinesteXAIFramework {
    private static var planCat = "Cardio"
    private static var workoutCat = ""
    
    public static func createPlanView(apiKey: String, companyName: String, userId: String, planCategory: PlanCategory = .Cardio, workoutCategory: WorkoutCategory = .Fitness, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        let validationError = validateInput(apiKey: apiKey, companyName: companyName, userId: userId, planCategory: planCategory, workoutCategory: workoutCategory)
        
        if let error = validationError {
            // For framework internal use, you might want to log the error or handle it differently.
            print("⚠️ Validation Error: \(error)")
            return AnyView(EmptyView())// Return an empty view or any placeholder to indicate failure
        } else {
            return AnyView(KinesteXAIView(apiKey: apiKey, companyName: companyName, userId: userId, planCategory: planCat, workoutCategory: workoutCat, isLoading: isLoading, onMessageReceived: onMessageReceived))
        }
    }
    
    public static func createChallengeView(apiKey: String, companyName: String, userId: String, exercise: String = "Squats", countdown: Int, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
       var error = ""
        if containsDisallowedCharacters(apiKey) || containsDisallowedCharacters(companyName) || containsDisallowedCharacters(userId) {
            error = "apiKey, companyName, or userId contains disallowed characters: < >, { }, ( ), [ ], ;, \", ', $, ., #, or <script>"
        }
        if error != "" {
            // For framework internal use, you might want to log the error or handle it differently.
            print("⚠️ Validation Error: \(error)")
            return AnyView(EmptyView())// Return an empty view or any placeholder to indicate failure
        } else {
            return AnyView(KinesteXAIViewChallenge(apiKey: apiKey, companyName: companyName, userId: userId, exercise: exercise, countdown: countdown, isLoading: isLoading, onMessageReceived: onMessageReceived))
        }
    }

    private static func validateInput(apiKey: String, companyName: String, userId: String, planCategory: PlanCategory, workoutCategory: WorkoutCategory) -> String? {
        // Perform validation checks here
        // Return nil if validation is successful, or an error message string if not
        if containsDisallowedCharacters(apiKey) || containsDisallowedCharacters(companyName) || containsDisallowedCharacters(userId) {
            return "apiKey, companyName, or userId contains disallowed characters: < >, { }, ( ), [ ], ;, \", ', $, ., #, or <script>"
        }
                switch planCategory {
        
                case .Cardio:
                    self.planCat = "Cardio"
                case .WeightManagement:
                    self.planCat = "Weight Management"
                case .Strength:
                    self.planCat = "Strength"
                case .Rehabilitation:
                    self.planCat = "Rehabilitation"
                case .Custom(let string):
                    if string.isEmpty {
                        return "planCategory cannot be empty"
                    } else if containsDisallowedCharacters(string) {
                        return "planCategory contains disallowed characters: < >, { }, ( ), [ ], ;, \", ', $, ., #, or <script>"
                    }
                    planCat = string
        
                }
        
                switch workoutCategory {
        
                case .Fitness:
                    self.workoutCat = "Fitness"
                case .Rehabilitation:
                    self.workoutCat = "Rehabilitation"
        
                case .Custom(let string):
                    if string.isEmpty {
                        return "workoutCategory cannot be empty"
                    } else if containsDisallowedCharacters(string) {
                        return "workoutCategory contains disallowed characters: < >, { }, ( ), [ ], ;, \", ', $, ., #, or <script>"
                    }
                    workoutCat = string
        
                }
        // Add more validation as needed
        return nil
    }
    
    private static func containsDisallowedCharacters(_ input: String) -> Bool {
        let disallowedPattern = "<script>|</script>|[<>{}()\\[\\];\"'\\$\\.#]"
        let regex = try! NSRegularExpression(pattern: disallowedPattern, options: [])
        let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        return !matches.isEmpty
    }
}


// Define a single SwiftUI view for both iOS and macOS
private struct KinesteXAIView: View {
    let apiKey: String
    let companyName: String
    let userId: String
    var planCategory: String
    var workoutCategory: String
 
    @Binding var isLoading: Bool
    
    var onMessageReceived: (WebViewMessage) -> Void

    public init(apiKey: String, companyName: String, userId: String, planCategory: String, workoutCategory: String, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) {
        self.apiKey = apiKey
        self.companyName = companyName
        self.userId = userId
        self.planCategory = planCategory
        self.workoutCategory = workoutCategory
        self._isLoading = isLoading
        self.onMessageReceived = onMessageReceived
    }
    

    public var body: some View {
  
     
        #if os(macOS)
        WebViewWrappermacOS(url: URL(string: "https://kineste-x-w.vercel.app")!, apiKey: apiKey, companyName: companyName, userId: userId, planCategory: planCategory, workoutCategory: workoutCategory, isLoading: $isLoading, onMessageReceived: onMessageReceived)
      
        #else
        WebViewWrapperiOS(url: URL(string: "https://kineste-x-w.vercel.app")!, apiKey: apiKey, companyName: companyName, userId: userId, planCategory: planCategory, workoutCategory: workoutCategory, isLoading: $isLoading, onMessageReceived: onMessageReceived)
        #endif
    }
}


private struct KinesteXAIViewChallenge: View {
    let apiKey: String
    let companyName: String
    let userId: String
    var exercise: String
    var countdown: Int
    @Binding var isLoading: Bool
    
    var onMessageReceived: (WebViewMessage) -> Void

    public init(apiKey: String, companyName: String, userId: String, exercise: String, countdown: Int, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) {
        self.apiKey = apiKey
        self.companyName = companyName
        self.userId = userId
        self.exercise = exercise
        self.countdown = countdown
        self._isLoading = isLoading
        self.onMessageReceived = onMessageReceived
    }
    

    public var body: some View {
  
     
        #if os(macOS)
        WebViewWrappermacOSChallenge(url: URL(string: "https://kinestex-challenges.vercel.app/")!, apiKey: apiKey, companyName: companyName, userId: userId, exercise: exercise, countdown: countdown, isLoading: $isLoading, onMessageReceived: onMessageReceived)
      
        #else
        WebViewWrapperiOSChallenge(url: URL(string: "https://kinestex-challenges.vercel.app/")!, apiKey: apiKey, companyName: companyName, userId: userId, exercice: exercise, countdown: countdown, isLoading: $isLoading, onMessageReceived: onMessageReceived)
        #endif
    }
}

#if canImport(UIKit)
import UIKit

struct WebViewWrapperiOS: UIViewRepresentable {
    let url: URL
    let apiKey: String
    let companyName: String
    let userId: String
    let planCategory: String
    let workoutCategory: String
    
    @Binding var isLoading: Bool
    var onMessageReceived: (WebViewMessage) -> Void
    
    func makeUIView(context: Context) -> WKWebView  {
        let contentController = WKUserContentController()
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences = preferences
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.requiresUserActionForMediaPlayback = false
       
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        contentController.add(context.coordinator, name: "listener")

      
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, onMessageReceived: onMessageReceived)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
        let parent: WebViewWrapperiOS
        var onMessageReceived: (WebViewMessage) -> Void
        
        init(parent: WebViewWrapperiOS, onMessageReceived: @escaping (WebViewMessage) -> Void) {
            self.parent = parent
            self.onMessageReceived = onMessageReceived
        }
        
  
        @available(iOS 15.0, *)
        func webView(_ webView: WKWebView,
                     decideMediaCapturePermissionsFor origin: WKSecurityOrigin,
                     initiatedBy frame: WKFrameInfo,
                     type: WKMediaCaptureType) async -> WKPermissionDecision {
            return .grant
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
      
            
            let script = """
            window.postMessage({
                'key': '\(parent.apiKey)',
                'company': '\(parent.companyName)',
                'userId': '\(parent.userId)',
                'planC': '\(parent.planCategory)',
                'category': '\(parent.workoutCategory)'
                              
            });
            """
            webView.evaluateJavaScript(script) { (result, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.onMessageReceived(.errorOccurred("Cannot send data"))
                    }
                }
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("Received message: \(message.body)")
            if message.name == "listener", let messageBody = message.body as? String {
                handle(message: messageBody)
            }
        }
            
            func handle(message: String) {
                guard let data = message.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let type = json["type"] as? String else {
                    print("Could not parse JSON message from WebView.")
                    return
                }
                
                let messageData = json["data"] as? String ?? ""
                
                // Using the currentTime function as described, ensure it's defined or adjust as needed
                
                let webViewMessage: WebViewMessage
                switch type {
                case "kinestex_launched":
                    webViewMessage = .kinestexLaunched(messageData)
                case "finished_workout":
                    webViewMessage = .finishedWorkout(messageData)
                case "error_occured":
                    webViewMessage = .errorOccurred(messageData)
                case "exercise_completed":
                    webViewMessage = .exerciseCompleted(messageData)
                case "exitApp":
                    webViewMessage = .exitApp("User closed workout window")
                case "exit_kinestex":
                    webViewMessage = .exitApp("User closed workout window")
                case "workoutOpened":
                    webViewMessage = .workoutOpened(messageData)
                case "workoutStarted":
                    webViewMessage = .workoutStarted(messageData)
                case "plan_unlocked":
                    webViewMessage = .planUnlocked(messageData)
                default:
                    webViewMessage = .unknown("Unknown message type: \(type) with data: \(messageData)")
                }
                
                DispatchQueue.main.async {
                    self.onMessageReceived(webViewMessage)
                }
            }
            
            
        }
    
}


struct WebViewWrapperiOSChallenge: UIViewRepresentable {
    let url: URL
    let apiKey: String
    let companyName: String
    let userId: String
    let exercice: String
    let countdown: Int
    
    @Binding var isLoading: Bool
    var onMessageReceived: (WebViewMessage) -> Void
    
    func makeUIView(context: Context) -> WKWebView  {
        let contentController = WKUserContentController()
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences = preferences
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.requiresUserActionForMediaPlayback = false
       
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        contentController.add(context.coordinator, name: "listener")

      
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        
        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, onMessageReceived: onMessageReceived)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
        let parent: WebViewWrapperiOSChallenge
        var onMessageReceived: (WebViewMessage) -> Void
        
        init(parent: WebViewWrapperiOSChallenge, onMessageReceived: @escaping (WebViewMessage) -> Void) {
            self.parent = parent
            self.onMessageReceived = onMessageReceived
        }
        
  
        @available(iOS 15.0, *)
        func webView(_ webView: WKWebView,
                     decideMediaCapturePermissionsFor origin: WKSecurityOrigin,
                     initiatedBy frame: WKFrameInfo,
                     type: WKMediaCaptureType) async -> WKPermissionDecision {
            return .grant
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
      
            
            let script = """
            window.postMessage({
                'key': '\(parent.apiKey)',
                'company': '\(parent.companyName)',
                'userId': '\(parent.userId)',
                'exercise': '\(parent.exercice)',
                'countdown': \(parent.countdown)
                              
            });
            """
            webView.evaluateJavaScript(script) { (result, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.onMessageReceived(.errorOccurred("Cannot send data"))
                    }
                }
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("Received message: \(message.body)")
            if message.name == "listener", let messageBody = message.body as? String {
                handle(message: messageBody)
            }
        }
            
            func handle(message: String) {
                guard let data = message.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let type = json["type"] as? String else {
                    print("Could not parse JSON message from WebView.")
                    return
                }
                
                let messageData = json["data"] as? String ?? ""
                
                // Using the currentTime function as described, ensure it's defined or adjust as needed
                
                let webViewMessage: WebViewMessage
                switch type {
                case "kinestex_launched":
                    webViewMessage = .kinestexLaunched(messageData)
                case "finished_workout":
                    webViewMessage = .finishedWorkout(messageData)
                case "error_occured":
                    webViewMessage = .errorOccurred(messageData)
                case "exercise_completed":
                    webViewMessage = .exerciseCompleted(messageData)
                case "exitApp":
                    webViewMessage = .exitApp("User closed workout window")
                case "exit_kinestex":
                    webViewMessage = .exitApp("User closed workout window")
                case "workoutOpened":
                    webViewMessage = .workoutOpened(messageData)
                case "workoutStarted":
                    webViewMessage = .workoutStarted(messageData)
                case "plan_unlocked":
                    webViewMessage = .planUnlocked(messageData)
                default:
                    webViewMessage = .unknown("Unknown message type: \(type) with data: \(messageData)")
                }
                
                DispatchQueue.main.async {
                    self.onMessageReceived(webViewMessage)
                }
            }
            
            
        }
    
}
#endif

// iOS specific wrapper

#if canImport(AppKit)
import AppKit

struct WebViewWrappermacOS: NSViewRepresentable {
    let url: URL
    let apiKey: String
    let companyName: String
    let userId: String
    let planCategory: String
    let workoutCategory: String
    
    @Binding var isLoading: Bool
    var onMessageReceived: (WebViewMessage) -> Void
    
    func makeUIView(context: Context) -> WKWebView  {
        let contentController = WKUserContentController()
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences = preferences
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.requiresUserActionForMediaPlayback = false
       
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        contentController.add(context.coordinator, name: "listener")

      
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
         

        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, onMessageReceived: onMessageReceived)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
        let parent: WebViewWrappermacOS
        var onMessageReceived: (WebViewMessage) -> Void
        
        init(parent: WebViewWrappermacOS, onMessageReceived: @escaping (WebViewMessage) -> Void) {
            self.parent = parent
            self.onMessageReceived = onMessageReceived
        }
        
  
        @available(iOS 15.0, *)
        func webView(_ webView: WKWebView,
                     decideMediaCapturePermissionsFor origin: WKSecurityOrigin,
                     initiatedBy frame: WKFrameInfo,
                     type: WKMediaCaptureType) async -> WKPermissionDecision {
            return .grant
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
      
            
            let script = """
            window.postMessage({
                'key': '\(parent.apiKey)',
                'company': '\(parent.companyName)',
                'userId': '\(parent.userId)',
                'planC': '\(parent.planCategory)',
                'category': '\(parent.workoutCategory)'
                              
            });
            """
            webView.evaluateJavaScript(script) { (result, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.onMessageReceived(.errorOccurred("Cannot send data"))
                    }
                }
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("Received message: \(message.body)")
            if message.name == "listener", let messageBody = message.body as? String {
                handle(message: messageBody)
            }
        }
            
            func handle(message: String) {
                guard let data = message.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let type = json["type"] as? String else {
                    print("Could not parse JSON message from WebView.")
                    return
                }
                
                let messageData = json["data"] as? String ?? ""
                
                // Using the currentTime function as described, ensure it's defined or adjust as needed
                
                let webViewMessage: WebViewMessage
                switch type {
                case "kinestex_launched":
                    webViewMessage = .kinestexLaunched(messageData)
                case "finished_workout":
                    webViewMessage = .finishedWorkout(messageData)
                case "error_occured":
                    webViewMessage = .errorOccurred(messageData)
                case "exercise_completed":
                    webViewMessage = .exerciseCompleted(messageData)
                case "exitApp":
                    webViewMessage = .exitApp("User closed workout window")
                case "exit_kinestex":
                    webViewMessage = .exitApp("User closed workout window")
                case "workoutOpened":
                    webViewMessage = .workoutOpened(messageData)
                case "workoutStarted":
                    webViewMessage = .workoutStarted(messageData)
                case "plan_unlocked":
                    webViewMessage = .planUnlocked(messageData)
                default:
                    webViewMessage = .unknown("Unknown message type: \(type) with data: \(messageData)")
                }
                
                DispatchQueue.main.async {
                    self.onMessageReceived(webViewMessage)
                }
            }
            
            
        }
}
struct WebViewWrappermacOSChallenge: NSViewRepresentable {
    let url: URL
    let apiKey: String
    let companyName: String
    let userId: String
    let planCategory: String
    let workoutCategory: String
    
    @Binding var isLoading: Bool
    var onMessageReceived: (WebViewMessage) -> Void
    
    func makeUIView(context: Context) -> WKWebView  {
        let contentController = WKUserContentController()
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences = preferences
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.requiresUserActionForMediaPlayback = false
       
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        contentController.add(context.coordinator, name: "listener")

      
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
         

        webView.load(URLRequest(url: url))
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, onMessageReceived: onMessageReceived)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
        let parent: WebViewWrappermacOSChallenge
        var onMessageReceived: (WebViewMessage) -> Void
        
        init(parent: WebViewWrappermacOSChallenge, onMessageReceived: @escaping (WebViewMessage) -> Void) {
            self.parent = parent
            self.onMessageReceived = onMessageReceived
        }
        
  
        @available(iOS 15.0, *)
        func webView(_ webView: WKWebView,
                     decideMediaCapturePermissionsFor origin: WKSecurityOrigin,
                     initiatedBy frame: WKFrameInfo,
                     type: WKMediaCaptureType) async -> WKPermissionDecision {
            return .grant
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
      
            
            let script = """
            window.postMessage({
                'key': '\(parent.apiKey)',
                'company': '\(parent.companyName)',
                'userId': '\(parent.userId)',
                'exercise': '\(parent.exercice)',
                'countdown': \(parent.countdown)
                              
            });
            """
            webView.evaluateJavaScript(script) { (result, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.onMessageReceived(.errorOccurred("Cannot send data"))
                    }
                }
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("Received message: \(message.body)")
            if message.name == "listener", let messageBody = message.body as? String {
                handle(message: messageBody)
            }
        }
            
            func handle(message: String) {
                guard let data = message.data(using: .utf8),
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let type = json["type"] as? String else {
                    print("Could not parse JSON message from WebView.")
                    return
                }
                
                let messageData = json["data"] as? String ?? ""
                
                // Using the currentTime function as described, ensure it's defined or adjust as needed
                
                let webViewMessage: WebViewMessage
                switch type {
                case "kinestex_launched":
                    webViewMessage = .kinestexLaunched(messageData)
                case "finished_workout":
                    webViewMessage = .finishedWorkout(messageData)
                case "error_occured":
                    webViewMessage = .errorOccurred(messageData)
                case "exercise_completed":
                    webViewMessage = .exerciseCompleted(messageData)
                case "exitApp":
                    webViewMessage = .exitApp("User closed workout window")
                case "exit_kinestex":
                    webViewMessage = .exitApp("User closed workout window")
                case "workoutOpened":
                    webViewMessage = .workoutOpened(messageData)
                case "workoutStarted":
                    webViewMessage = .workoutStarted(messageData)
                case "plan_unlocked":
                    webViewMessage = .planUnlocked(messageData)
                default:
                    webViewMessage = .unknown("Unknown message type: \(type) with data: \(messageData)")
                }
                
                DispatchQueue.main.async {
                    self.onMessageReceived(webViewMessage)
                }
            }
            
            
        }
}
#endif

