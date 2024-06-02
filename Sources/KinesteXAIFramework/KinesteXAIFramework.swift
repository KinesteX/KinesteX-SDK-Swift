import SwiftUI
import WebKit
import Combine

class WebViewState: ObservableObject {
    @Published var webView: WKWebView?
}

public enum WebViewMessage {
    case kinestex_launched([String: Any])
    case finished_workout([String: Any])
    case error_occurred([String: Any])
    case exercise_completed([String: Any])
    case exit_kinestex([String: Any])
    case workout_opened([String: Any])
    case workout_started([String: Any])
    case plan_unlocked([String: Any])
    case custom_type([String: Any])
    case reps([String: Any])
    case mistake([String: Any])
    case left_camera_frame([String: Any])
    case returned_camera_frame([String: Any])
    case workout_overview([String: Any])
    case exercise_overview([String: Any])
    case workout_completed([String: Any])
}


public enum Gender {
    case Male
    case Female
    case Unknown
}

public enum Lifestyle {
    case Sedentary
    case SlightlyActive
    case Active
    case VeryActive
}

public struct UserDetails {
    var age: Int
    var height: Int
    var weight: Int
    var gender: Gender
    var lifestyle: Lifestyle
}

public enum PlanCategory {
    case Cardio
    case WeightManagement
    case Strength
    case Rehabilitation
    case Custom(String)
}

public struct KinesteXAIFramework {

    private static var cameraWebView: GenericWebView?

    /**
     Creates the main view with personalized AI workout plans. Keeps track of the person's progress, current day and week to let a person workout according to the schedule

     - Parameters:
       - apiKey: The API key for authentication.
       - companyName: The name of the company using the framework provided by KinesteX
       - userId: The unique identifier for the user.
       - planCategory: The category of the workout plan (default is Cardio).
       - user: Optional user details including age, height, weight, gender, and lifestyle.
       - isLoading: A binding to a Boolean value indicating if the view is loading.
       - onMessageReceived: A closure that handles messages received from the WebView.
     - Returns: A SwiftUI `AnyView` containing the main view.
    */
    public static func createMainView(apiKey: String, companyName: String, userId: String, planCategory: PlanCategory = .Cardio, user: UserDetails?, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        let validationError = validateInput(apiKey: apiKey, companyName: companyName, userId: userId, planCategory: planCategory)
        
        if let error = validationError {
            print("⚠️ Validation Error: \(error)")
            return AnyView(EmptyView())
        } else {
            var data: [String: Any] = [
                "planC": planCategoryString(planCategory)
            ]
            if let user = user {
                data["age"] = user.age
                data["height"] = user.height
                data["weight"] = user.weight
                data["gender"] = genderString(user.gender)
                data["lifestyle"] = lifestyleString(user.lifestyle)
            }
            return AnyView(GenericWebView(apiKey: apiKey, companyName: companyName, userId: userId, url: URL(string: "https://kinestex.vercel.app")!, data: data, isLoading: isLoading, onMessageReceived: onMessageReceived))
        }
    }

    /**
     Creates a view for a specific workout plan. Keeps track of the progress for that particular plan, recommending the workouts according to the person's progression

     - Parameters:
       - apiKey: The API key for authentication.
       - companyName: The name of the company using the framework provided by KinesteX
       - userId: The unique identifier for the user.
       - planName: The name of the workout plan.
       - user: Optional user details including age, height, weight, gender, and lifestyle.
       - isLoading: A binding to a Boolean value indicating if the view is loading.
       - onMessageReceived: A closure that handles messages received from the WebView.
     - Returns: A SwiftUI `AnyView` containing the workout plan view.
     */
    public static func createPlanView(apiKey: String, companyName: String, userId: String, planName: String, user: UserDetails?, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        if containsDisallowedCharacters(apiKey) || containsDisallowedCharacters(companyName) || containsDisallowedCharacters(userId) || containsDisallowedCharacters(planName) {
            print("⚠️ Validation Error: apiKey, companyName, userId, or planName contains disallowed characters")
            return AnyView(EmptyView())
        } else {
            let adjustedPlanName = planName.replacingOccurrences(of: " ", with: "%20")
            let url = URL(string: "https://kinestex.vercel.app/plan/\(adjustedPlanName)")!
            var data: [String: Any] = [:]
            if let user = user {
                data["age"] = user.age
                data["height"] = user.height
                data["weight"] = user.weight
                data["gender"] = genderString(user.gender)
                data["lifestyle"] = lifestyleString(user.lifestyle)
            }
            return AnyView(GenericWebView(apiKey: apiKey, companyName: companyName, userId: userId, url: url, data: data, isLoading: isLoading, onMessageReceived: onMessageReceived))
        }
    }
    /**
        Creates a view for a specific workout.

        - Parameters:
          - apiKey: The API key for authentication.
          - companyName: The name of the company using the framework.
          - userId: The unique identifier for the user.
          - workoutName: The name of the workout.
          - user: Optional user details including age, height, weight, gender, and lifestyle.
          - isLoading: A binding to a Boolean value indicating if the view is loading.
          - onMessageReceived: A closure that handles messages received from the WebView.
        - Returns: A SwiftUI `AnyView` containing the workout view.
    */
    public static func createWorkoutView(apiKey: String, companyName: String, userId: String, workoutName: String, user: UserDetails?, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        if containsDisallowedCharacters(apiKey) || containsDisallowedCharacters(companyName) || containsDisallowedCharacters(userId) || containsDisallowedCharacters(workoutName) {
            print("⚠️ Validation Error: apiKey, companyName, userId, or workoutName contains disallowed characters")
            return AnyView(EmptyView())
        } else {
            let adjustedWorkoutName = workoutName.replacingOccurrences(of: " ", with: "%20")
            let url = URL(string: "https://kinestex.vercel.app/workout/\(adjustedWorkoutName)")!
            var data: [String: Any] = [:]
            if let user = user {
                data["age"] = user.age
                data["height"] = user.height
                data["weight"] = user.weight
                data["gender"] = genderString(user.gender)
                data["lifestyle"] = lifestyleString(user.lifestyle)
            }
            return AnyView(GenericWebView(apiKey: apiKey, companyName: companyName, userId: userId, url: url, data: data, isLoading: isLoading, onMessageReceived: onMessageReceived))
        }
    }
    /**
         Creates a view for a specific exercise challenge.

         - Parameters:
           - apiKey: The API key for authentication.
           - companyName: The name of the company using the framework.
           - userId: The unique identifier for the user.
           - exercise: The name of the exercise (default is "Squats").
           - countdown: The countdown time for the challenge.
           - user: Optional user details including age, height, weight, gender, and lifestyle.
           - isLoading: A binding to a Boolean value indicating if the view is loading.
           - onMessageReceived: A closure that handles messages received from the WebView.
         - Returns: A SwiftUI `AnyView` containing the challenge view.
    */
    public static func createChallengeView(apiKey: String, companyName: String, userId: String, exercise: String = "Squats", countdown: Int, user: UserDetails?, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        if containsDisallowedCharacters(apiKey) || containsDisallowedCharacters(companyName) || containsDisallowedCharacters(userId) || containsDisallowedCharacters(exercise) {
            print("⚠️ Validation Error: apiKey, companyName, userId, or exercise contains disallowed characters")
            return AnyView(EmptyView())
        } else {
            var data: [String: Any] = [
                "exercise": exercise,
                "countdown": countdown
            ]
            if let user = user {
                data["age"] = user.age
                data["height"] = user.height
                data["weight"] = user.weight
                data["gender"] = genderString(user.gender)
                data["lifestyle"] = lifestyleString(user.lifestyle)
            }
            return AnyView(GenericWebView(apiKey: apiKey, companyName: companyName, userId: userId, url: URL(string: "https://kinestex-challenge.vercel.app")!, data: data, isLoading: isLoading, onMessageReceived: onMessageReceived))
        }
    }

    private static func genderString(_ gender: Gender) -> String {
        switch gender {
        case .Male:
            return "Male"
        case .Female:
            return "Female"
        case .Unknown:
            return "Male"
        }
    }

    private static func lifestyleString(_ lifestyle: Lifestyle) -> String {
        switch lifestyle {
        case .Sedentary:
            return "Sedentary"
        case .SlightlyActive:
            return "Slightly Active"
        case .Active:
            return "Active"
        case .VeryActive:
            return "Very Active"
        }
    }
/// Creates a camera component for realtime feedback on all movements based on the current exercise a person should be doing. You can dynamically change the exercise by calling updateCurrentExercise function.
///        - Parameters:
///          - apiKey: The API key for authentication.
///          - companyName: The name of the company using the framework.
///          - userId: The unique identifier for the user.
///          - exercises: A list of exercises to be tracked.
///          - currentExercise: The current exercise being performed.
///          - user: Optional user details including age, height, weight, gender, and lifestyle.
///          - isLoading: A binding to a Boolean value indicating if the view is loading.
///         - onMessageReceived: A closure that handles messages received from the WebView.
///        - Returns: A SwiftUI `AnyView` containing the camera component.

    public static func createCameraComponent(apiKey: String, companyName: String, userId: String, exercises: [String], currentExercise: String, user: UserDetails?, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        for exercise in exercises {
            if containsDisallowedCharacters(exercise) {
                print("⚠️ Validation Error: \(exercise) contains disallowed characters")
                return AnyView(EmptyView())
            }
        }
        if containsDisallowedCharacters(apiKey) || containsDisallowedCharacters(companyName) || containsDisallowedCharacters(userId) || containsDisallowedCharacters(currentExercise) {
            print("⚠️ Validation Error: apiKey, companyName, userId, or currentExercise contains disallowed characters")
            return AnyView(EmptyView())
        } else {
            var data: [String: Any] = [
                "exercises": exercises,
                "currentExercise": currentExercise
            ]
            if let user = user {
                data["age"] = user.age
                data["height"] = user.height
                data["weight"] = user.weight
                data["gender"] = genderString(user.gender)
                data["lifestyle"] = lifestyleString(user.lifestyle)
            }
            if cameraWebView == nil {
                let cameraWebViewInstance = GenericWebView(apiKey: apiKey, companyName: companyName, userId: userId, url: URL(string: "https://kinestex-camera-ai.vercel.app")!, data: data, isLoading: isLoading, onMessageReceived: onMessageReceived)
                self.cameraWebView = cameraWebViewInstance
            }
            return AnyView(cameraWebView!)
        }
    }
    /**
      Updates the current exercise in the camera component.

      - Parameters:
        - exercise: The name of the current exercise.
      */
    public static func updateCurrentExercise(_ exercise: String) {
        DispatchQueue.main.async {
            self.cameraWebView?.updateCurrentExercise(exercise)
        }
    }

    private static func validateInput(apiKey: String, companyName: String, userId: String, planCategory: PlanCategory) -> String? {
        if containsDisallowedCharacters(apiKey) || containsDisallowedCharacters(companyName) || containsDisallowedCharacters(userId) {
            return "apiKey, companyName, or userId contains disallowed characters"
        }
        if case .Custom(let string) = planCategory, string.isEmpty || containsDisallowedCharacters(string) {
            return "planCategory is invalid"
        }
        return nil
    }

    private static func planCategoryString(_ category: PlanCategory) -> String {
        switch category {
        case .Cardio:
            return "Cardio"
        case .WeightManagement:
            return "Weight Management"
        case .Strength:
            return "Strength"
        case .Rehabilitation:
            return "Rehabilitation"
        case .Custom(let string):
            return string
        }
    }

    private static func containsDisallowedCharacters(_ input: String) -> Bool {
        let disallowedPattern = "<script>|</script>|[<>{}()\\[\\];\"'\\$\\.#]"
        let regex = try! NSRegularExpression(pattern: disallowedPattern, options: [])
        let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        return !matches.isEmpty
    }
}

private struct GenericWebView: View {
    let apiKey: String
    let companyName: String
    let userId: String
    let url: URL
    let data: [String: Any]?
    @Binding var isLoading: Bool
    var onMessageReceived: (WebViewMessage) -> Void
    @ObservedObject var webViewState = WebViewState()

    public init(apiKey: String, companyName: String, userId: String, url: URL, data: [String: Any]?, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) {
        self.apiKey = apiKey
        self.companyName = companyName
        self.userId = userId
        self.url = url
        self.data = data
        self._isLoading = isLoading
        self.onMessageReceived = onMessageReceived
    }

    public var body: some View {
        WebViewWrapper(url: url, apiKey: apiKey, companyName: companyName, userId: userId, data: data, isLoading: $isLoading, onMessageReceived: onMessageReceived, webViewState: webViewState)
            .onAppear {
                if webViewState.webView == nil {
                    let webView = WKWebView()
                    self.webViewState.webView = webView
                }
            }
    }


    func updateCurrentExercise(_ exercise: String) {
        guard let webView = webViewState.webView else {
            print("⚠️ WebView is not available")
            return
        }

        let script = """
        window.postMessage({ 'currentExercise': '\(exercise)' }, '*');
        """

        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("⚠️ JavaScript Error: \(error.localizedDescription)")
            } else {
                print("✅ Successfully sent an update")
            }
        }
    }

}

struct WebViewWrapper: UIViewRepresentable {
    let url: URL
    let apiKey: String
    let companyName: String
    let userId: String
    let data: [String: Any]?
    @Binding var isLoading: Bool
    var onMessageReceived: (WebViewMessage) -> Void
    @ObservedObject var webViewState: WebViewState
    func makeUIView(context: Context) -> WKWebView {
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

        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black

        webView.load(URLRequest(url: url))

        if self.webViewState.webView == nil {
            DispatchQueue.main.async {
                self.webViewState.webView = webView
            }
        }

        return webView
    }


    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No-op
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, onMessageReceived: onMessageReceived)
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate {
        let parent: WebViewWrapper
        var onMessageReceived: (WebViewMessage) -> Void

        init(parent: WebViewWrapper, onMessageReceived: @escaping (WebViewMessage) -> Void) {
            self.parent = parent
            self.onMessageReceived = onMessageReceived
        }

        @available(iOS 15.0, *)
        func webView(_ webView: WKWebView, decideMediaCapturePermissionsFor origin: WKSecurityOrigin, initiatedBy frame: WKFrameInfo, type: WKMediaCaptureType) async -> WKPermissionDecision {
            return .grant
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                
                var script = "window.postMessage({ 'key': '\(self.parent.apiKey)', 'company': '\(self.parent.companyName)', 'userId': '\(self.parent.userId)', 'exercises': \(self.jsonString(from: self.parent.data?["exercises"] as? [String] ?? [])), 'currentExercise': '\(self.parent.data?["currentExercise"] as? String ?? "")'"
                if let data = self.parent.data {
                    for (key, value) in data where key != "exercises" && key != "currentExercise" {
                        script += ", '\(key)': '\(value)'"
                    }
                }
                script += "}, '\(self.parent.url)');"
                
                webView.evaluateJavaScript(script) { (result, error) in
                    if let error = error {
                        print("⚠️ JavaScript Error: \(error.localizedDescription)")
                    }
                }
            }
        }

        func jsonString(from array: [String]) -> String {
            if let data = try? JSONSerialization.data(withJSONObject: array, options: []),
               let jsonString = String(data: data, encoding: .utf8) {
                return jsonString
            }
            return "[]"
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

            let webViewMessage: WebViewMessage
            switch type {
            case "kinestex_launched":
                webViewMessage = .kinestex_launched(json)
            case "finished_workout":
                webViewMessage = .finished_workout(json)
            case "error_occurred":
                webViewMessage = .error_occurred(json)
            case "exercise_completed":
                webViewMessage = .exercise_completed(json)
            case "exit_kinestex":
                webViewMessage = .exit_kinestex(json)
            case "workout_opened":
                webViewMessage = .workout_opened(json)
            case "workout_started":
                webViewMessage = .workout_started(json)
            case "plan_unlocked":
                webViewMessage = .plan_unlocked(json)
            case "mistake":
                webViewMessage = .mistake(json)
            case "successful_repeat":
                webViewMessage = .reps(json)
            case "left_camera_frame":
                webViewMessage = .left_camera_frame(json)
            case "returned_camera_frame":
                webViewMessage = .returned_camera_frame(json)
            case "workout_overview":
                webViewMessage = .workout_overview(json)
            case "exercise_overview":
                webViewMessage = .exercise_overview(json)
            case "workout_completed":
                webViewMessage = .exercise_overview(json)
            
            default:
                webViewMessage = .custom_type(json)
            }

            DispatchQueue.main.async {
                self.onMessageReceived(webViewMessage)
            }
        }

    }
}
