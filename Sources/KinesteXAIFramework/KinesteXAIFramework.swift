import SwiftUI
import WebKit
import Combine
import AVKit

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


class WebViewState: ObservableObject {
    @Published var webView: WKWebView?
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
    
    public init(age: Int, height: Int, weight: Int, gender: Gender, lifestyle: Lifestyle) {
        self.age = age
        self.height = height
        self.weight = weight
        self.gender = gender
        self.lifestyle = lifestyle
    }
}

public enum PlanCategory: Equatable {
    case Cardio
    case WeightManagement
    case Strength
    case Rehabilitation
    case Custom(String)

    // Optional: Implement the Equatable conformance manually if needed
    public static func == (lhs: PlanCategory, rhs: PlanCategory) -> Bool {
        switch (lhs, rhs) {
        case (.Cardio, .Cardio),
             (.WeightManagement, .WeightManagement),
             (.Strength, .Strength),
             (.Rehabilitation, .Rehabilitation):
            return true
        case let (.Custom(lhsValue), .Custom(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}


public struct KinesteXAIFramework {

    
    private static let defaultVideoURL = "https://cdn.kinestex.com/SDK%2Fhow-to-video%2Foutput_compressed.mp4?alt=media&token=9a3c0ed8-c86b-4553-86dd-a96f23e55f74"
      
      /**
       Creates a view that plays the 'how to' video.
       
       - Parameters:
         - videoURL: An optional custom video URL to be played (default is provided).
         - onVideoEnd: A closure called when the video playback ends.
       
       - Returns: A SwiftUI `AnyView` containing the video player.
       */
    public static func createHowToView(
        videoURL: String? = nil,  // Optional URL, default to the predefined URL
        onVideoEnd: @escaping () -> Void
    ) -> AnyView {
        let url = URL(string: videoURL ?? defaultVideoURL)!
        let player = AVPlayer(url: url)
        
        // Store the observer so we can remove it later
        var observer: NSObjectProtocol?
        
        let playerView = VideoPlayer(player: player)
            .onAppear {
                player.play()
                
                // Add observer for video end
                observer = NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: player.currentItem,
                    queue: .main
                ) { _ in
                    onVideoEnd()
                }
            }
            .onDisappear {
                player.pause()
                
                // Remove observer safely when the view disappears
                if let observer = observer {
                    NotificationCenter.default.removeObserver(observer)
                }
            }
        
        return AnyView(playerView)
    }

    
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
    public static func createMainView(apiKey: String, companyName: String, userId: String, planCategory: PlanCategory = .Cardio, user: UserDetails?, isLoading: Binding<Bool>, customParams: [String: Any] = [:], onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
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
            
            // Add custom parameters if they are valid
            for (key, value) in customParams {
                if containsDisallowedCharacters(key) || (value as? String).map(containsDisallowedCharacters) == true {
                    print("⚠️ Validation Error: Custom parameter key or value contains disallowed characters")
                    return AnyView(EmptyView())
                } else {
                    data[key] = value
                }
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
    public static func createPlanView(apiKey: String, companyName: String, userId: String, planName: String, user: UserDetails?, isLoading: Binding<Bool>, customParams: [String: Any] = [:], onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
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
            // Add custom parameters if they are valid
            for (key, value) in customParams {
                if containsDisallowedCharacters(key) || (value as? String).map(containsDisallowedCharacters) == true {
                    print("⚠️ Validation Error: Custom parameter key or value contains disallowed characters")
                    return AnyView(EmptyView())
                } else {
                    data[key] = value
                }
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
    public static func createWorkoutView(apiKey: String, companyName: String, userId: String, workoutName: String, user: UserDetails?, isLoading: Binding<Bool>, customParams: [String: Any] = [:], onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
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
            // Add custom parameters if they are valid
            for (key, value) in customParams {
                if containsDisallowedCharacters(key) || (value as? String).map(containsDisallowedCharacters) == true {
                    print("⚠️ Validation Error: Custom parameter key or value contains disallowed characters")
                    return AnyView(EmptyView())
                } else {
                    data[key] = value
                }
            }
            return AnyView(GenericWebView(apiKey: apiKey, companyName: companyName, userId: userId, url: url, data: data, isLoading: isLoading, onMessageReceived: onMessageReceived))
        }
    }
    
    /**
        Creates a view for a specific AI experience.

        - Parameters:
          - apiKey: The API key for authentication.
          - companyName: The name of the company using the framework.
          - userId: The unique identifier for the user.
          - experience: The name of the experience.
          - user: Optional user details including age, height, weight, gender, and lifestyle.
          - isLoading: A binding to a Boolean value indicating if the view is loading.
          - onMessageReceived: A closure that handles messages received from the WebView.
        - Returns: A SwiftUI `AnyView` containing the workout view.
    */
    public static func createExperienceView(apiKey: String, companyName: String, userId: String, experience: String, user: UserDetails?, isLoading: Binding<Bool>, customParams: [String: Any] = [:], onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        if containsDisallowedCharacters(apiKey) || containsDisallowedCharacters(companyName) || containsDisallowedCharacters(userId) || containsDisallowedCharacters(experience) {
            print("⚠️ Validation Error: apiKey, companyName, userId, or workoutName contains disallowed characters")
            return AnyView(EmptyView())
        } else {
            let adjustedExperienceName = experience.replacingOccurrences(of: " ", with: "%20").lowercased()
            let url = URL(string: "https://kinestex.vercel.app/experiences/\(adjustedExperienceName)")!
            var data: [String: Any] = [:]
            if let user = user {
                data["age"] = user.age
                data["height"] = user.height
                data["weight"] = user.weight
                data["gender"] = genderString(user.gender)
                data["lifestyle"] = lifestyleString(user.lifestyle)
            }
            // Add custom parameters if they are valid
            for (key, value) in customParams {
                if containsDisallowedCharacters(key) || (value as? String).map(containsDisallowedCharacters) == true {
                    print("⚠️ Validation Error: Custom parameter key or value contains disallowed characters")
                    return AnyView(EmptyView())
                } else {
                    data[key] = value
                }
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
    public static func createChallengeView(apiKey: String, companyName: String, userId: String, exercise: String = "Squats", countdown: Int, user: UserDetails?, showLeaderboard: Bool = true, isLoading: Binding<Bool>, customParams: [String: Any] = [:], onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        if containsDisallowedCharacters(apiKey) || containsDisallowedCharacters(companyName) || containsDisallowedCharacters(userId) || containsDisallowedCharacters(exercise) {
            print("⚠️ Validation Error: apiKey, companyName, userId, or exercise contains disallowed characters")
            return AnyView(EmptyView())
        } else {
            var data: [String: Any] = [
                "exercise": exercise,
                "countdown": countdown,
                "showLeaderboard": showLeaderboard
            ]
            if let user = user {
                data["age"] = user.age
                data["height"] = user.height
                data["weight"] = user.weight
                data["gender"] = genderString(user.gender)
                data["lifestyle"] = lifestyleString(user.lifestyle)
            }
            // Add custom parameters if they are valid
            for (key, value) in customParams {
                if containsDisallowedCharacters(key) || (value as? String).map(containsDisallowedCharacters) == true {
                    print("⚠️ Validation Error: Custom parameter key or value contains disallowed characters")
                    return AnyView(EmptyView())
                } else {
                    data[key] = value
                }
            }
            return AnyView(GenericWebView(apiKey: apiKey, companyName: companyName, userId: userId, url: URL(string: "https://kinestex.vercel.app/challenge")!, data: data, isLoading: isLoading, onMessageReceived: onMessageReceived))
        }
    }
    
    public static func createLeaderboardView(apiKey: String, companyName: String, userId: String, exercise: String = "Squats", username: String = "", isLoading: Binding<Bool>, customParams: [String: Any] = [:], onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        if containsDisallowedCharacters(apiKey) || containsDisallowedCharacters(companyName) || containsDisallowedCharacters(userId) || containsDisallowedCharacters(exercise) || containsDisallowedCharacters(username) {
            print("⚠️ Validation Error: apiKey, companyName, userId, exercise, or username contains disallowed characters")
            return AnyView(EmptyView())
        } else {
            var data: [String: Any] = [
                "exercise": exercise,
            ]
     
            let adjustedUsername = username.replacingOccurrences(of: " ", with: "%20")
            var url = URL(string: "https://kinestex.vercel.app/leaderboard")!
            if !adjustedUsername.isEmpty {
                url = URL(string: "https://kinestex.vercel.app/leaderboard?username=\(adjustedUsername)")!
            }
            // Add custom parameters if they are valid
            for (key, value) in customParams {
                if containsDisallowedCharacters(key) || (value as? String).map(containsDisallowedCharacters) == true {
                    print("⚠️ Validation Error: Custom parameter key or value contains disallowed characters")
                    return AnyView(EmptyView())
                } else {
                    data[key] = value
                }
            }
            return AnyView(GenericWebView(apiKey: apiKey, companyName: companyName, userId: userId, url: url, data: data, isLoading: isLoading, onMessageReceived: onMessageReceived))
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

    public static func createCameraComponent(apiKey: String, companyName: String, userId: String, exercises: [String], currentExercise: String, user: UserDetails?, isLoading: Binding<Bool>, customParams: [String: Any] = [:], onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
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
            // Add custom parameters if they are valid
            for (key, value) in customParams {
                if containsDisallowedCharacters(key) || (value as? String).map(containsDisallowedCharacters) == true {
                    print("⚠️ Validation Error: Custom parameter key or value contains disallowed characters")
                    return AnyView(EmptyView())
                } else {
                    data[key] = value
                }
            }
            if cameraWebView == nil {
                let cameraWebViewInstance = GenericWebView(apiKey: apiKey, companyName: companyName, userId: userId, url: URL(string: "https://kinestex.vercel.app/camera")!, data: data, isLoading: isLoading, onMessageReceived: onMessageReceived)
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
    
    /// Fetches content data from the API based on the provided parameters such as `apiKey`, `companyName`, `contentType`, and various filtering options like `id`, `title`, `category`, and `bodyParts`.
    ///
    /// This function retrieves data for specific content types (workouts, plans, or exercises) and returns the parsed result using a completion handler.
    ///
    /// - Parameters:
    ///   - apiKey: The API key for authentication to access the content.
    ///   - companyName: The name of the company making the request.
    ///   - contentType: The type of content to fetch (`.workout`, `.plan`, or `.exercise`).
    ///   - id: An optional unique identifier for the content; if provided, it overrides other search parameters.
    ///   - title: An optional title used to search for the content when `id` is not provided.
    ///   - category: An optional category to filter workouts and plans.
    ///   - bodyParts: An optional array of `BodyPart` to filter workouts, plans, and exercises.
    ///   - lang: The language for the content; defaults to English ("en").
    ///   - lastDocId: An optional document ID for pagination; fetches content after this ID.
    ///   - limit: An optional limit on the number of items to fetch.
    ///   - completion: A closure that returns the result of the API request. It can return a success result with the requested content or an error message if any issues occur.
    ///
    /// - Returns: Void. The function performs the request asynchronously and delivers the result via the `completion` closure.
    ///
    /// - Important:
    ///     - Ensures `apiKey`, `companyName`, `lang`, `category`, and `bodyParts` do not contain disallowed characters before making the request.
    ///     - If `id`, `title`, `category`, or any of the `bodyParts` contains disallowed characters, the request will terminate with a validation error.
    ///
    /// - Example Usage:
    ///     ```swift
    ///     // Fetch a workout by ID
    ///     fetchAPIContentData(apiKey: "yourApiKey",
    ///                         companyName: "MyCompany",
    ///                         contentType: .workout,
    ///                         id: "12345") { result in
    ///         switch result {
    ///         case .workout(let workout):
    ///             // Handle workout data
    ///         case .error(let message):
    ///             print("Error: \(message)")
    ///         }
    ///     }
    ///
    ///     // Fetch exercises targeting specific body parts
    ///     fetchAPIContentData(apiKey: "yourApiKey",
    ///                         companyName: "MyCompany",
    ///                         contentType: .exercise,
    ///                         bodyParts: [.abs, .biceps],
    ///                         limit: 10) { result in
    ///         switch result {
    ///         case .exercises(let exercisesResponse):
    ///             let exercises = exercisesResponse.exercises
    ///             // Handle exercises data
    ///         case .error(let message):
    ///             print("Error: \(message)")
    ///         }
    ///     }
    ///
    ///     // Fetch workouts in a specific category
    ///     fetchAPIContentData(apiKey: "yourApiKey",
    ///                         companyName: "MyCompany",
    ///                         contentType: .workout,
    ///                         category: "Cardio",
    ///                         limit: 5) { result in
    ///         switch result {
    ///         case .workouts(let workoutsResponse):
    ///             let workouts = workoutsResponse.workouts
    ///             // Handle workouts data
    ///         case .error(let message):
    ///             print("Error: \(message)")
    ///         }
    ///     }
    ///     ```
    ///
    /// - Throws: An error if there is a network issue or if the data cannot be parsed correctly.
    public static func fetchAPIContentData(apiKey: String, companyName: String, contentType: ContentType,
                                           id: String? = nil, title: String? = nil, lang: String = "en", category: String? = nil,
                                           lastDocId: String? = nil, limit: Int? = nil, bodyParts: [BodyPart]? = nil,
                                           completion: @escaping (APIContentResult) -> Void) async {
       
        if containsDisallowedCharacters(apiKey) || containsDisallowedCharacters(companyName) || containsDisallowedCharacters(lang) {
            completion(.error("⚠️ Validation Error: apiKey, companyName, or lang contains disallowed characters"))
        }
        if (id != nil) {
            if (containsDisallowedCharacters(id!)) {
                completion(.error("⚠️ Error: ID contains disallowed characters"))
            }
        } else if (title != nil) {
            if (containsDisallowedCharacters(title!)) {
                completion(.error("⚠️ Error: Title contains disallowed characters"))
            }
        }
        if (category != nil) {
            if (containsDisallowedCharacters(category!)) {
                completion(.error("⚠️ Error: Category contains disallowed characters"))
            }
        }
        
        if (lastDocId != nil) {
            if (containsDisallowedCharacters(lastDocId!)){
                completion(.error("⚠️ Error: LastDocID contains disallowed characters"))
            }
        }

        
        let baseAPIURL = "https://admin.kinestex.com/api/v1/"
        
        // Determine endpoint
        let endpoint: String
        switch contentType {
        case .workout: endpoint = "workouts"
        case .plan: endpoint = "plans"
        case .exercise: endpoint = "exercises"
        }
 
        guard var components = URLComponents(string: baseAPIURL + endpoint + ((id != nil) ? "/\(id!)" : (title != nil) ? "/\(title!)" : "")) else {
                completion(.error("Failed to construct URL. Invalid ID or title"))
                return
        }
        
        // Set query parameters
        var queryItems: [URLQueryItem] = []

        queryItems.append(URLQueryItem(name: "lang", value: lang))
        if let category { queryItems.append(URLQueryItem(name: "category", value: category)) }
        if let lastDocId { queryItems.append(URLQueryItem(name: "lastDocId", value: lastDocId)) }
        if let bodyParts {
            let bodyPartsStrings = bodyParts.map { $0.rawValue }
            let bodyPartsJoined = bodyPartsStrings.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "body_parts", value: bodyPartsJoined))
        }
        if let limit { queryItems.append(URLQueryItem(name: "limit", value: String(limit))) }
        components.queryItems = queryItems
        
        guard let url = components.url else {
            completion(.error("Failed to send request. Invalid ID, title, or language setting."))
            return
        }
        
        print("complete url: \(url.absoluteString)")
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(companyName, forHTTPHeaderField: "x-company-name")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.error("Invalid response from server"))
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                do {
                    if category != nil || bodyParts != nil {
                        
                                switch contentType {
                                      case .workout:
                                          let workouts = try DataProcessor.processWorkoutsArray(data)
                                          completion(.workouts(workouts))
                                      case .plan:
                                          let plans = try DataProcessor.processPlansArray(data)
                                          completion(.plans(plans))
                                      case .exercise:
                                          let exercises = try DataProcessor.processExercisesArray(data)
                                          completion(.exercises(exercises))
                                      }
                                  } else {
                                      // Handle single item responses as before
                                      switch contentType {
                                      case .workout:
                                          let workout = try DataProcessor.processWorkoutData(data)
                                          completion(.workout(workout))
                                      case .plan:
                                          let plan = try DataProcessor.processPlanData(data)
                                          completion(.plan(plan))
                                      case .exercise:
                                          let exercise = try DataProcessor.processExerciseData(data)
                                          completion(.exercise(exercise))
                                }
                   }
                } catch {
                    completion(.error("Failed to parse data: \(error.localizedDescription). Please contact us at support@kinestex.com if this issue persists"))
                }
            } else {
                do {
                    let errorResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                    completion(.error("Error: \(errorResponse.message ?? errorResponse.error ?? "Unknown error")"))
                } catch {
                    completion(.error("Error \(httpResponse.statusCode): \(error.localizedDescription)"))
                }
            }
        } catch {
            completion(.error("Network error: \(error.localizedDescription)"))
        }
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
        webView.allowsLinkPreview = false
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


// MARK: - Network Request Function

/// APIContentResult is an enum that represents the result of an API request.
/// It returns either a specific content model(s) (workout, plan, or exercise) or an error message if the request fails.
public enum APIContentResult {
       case workouts(WorkoutsResponse)
       case workout(WorkoutModel)
       case plans(PlansResponse)
       case plan(PlanModel)
       case exercises(ExerciseResponse)
       case exercise(ExerciseModel)
       case error(String)
}

// Models for API responses

/// WorkoutModel represents the structure of a workout returned by the API.
/// It includes details about the workout's ID, title, image URL, category, description,
/// duration, calorie burn, body parts targeted, difficulty level, and the sequence of exercises in the workout.
public struct WorkoutModel: Codable {
    public let id: String
    public let title: String
    public let img_URL: String
    public let category: String?
    public let description: String
    public let total_minutes: Int?
    public let total_calories: Int?
    public let body_parts: [String]
    public let dif_level: String?
    public let sequence: [ExerciseModel]
}

/// ExerciseModel represents the details of an exercise included in a workout or independently.
/// It contains the exercise's ID, title, media URLs, repetitions, average reps, countdowns,
/// rest duration, calories burned, body parts targeted, and guidance including tips and common mistakes.
public struct ExerciseModel: Codable {
    public let id: String
    public let title: String
    public let thumbnail_URL: String
    public let video_URL: String
    public let workout_countdown: Int?
    public let workout_reps: Int?
    public let avg_reps: Int?
    public let avg_countdown: Int?
    public let rest_duration: Int?
    public let avg_cal: Double?
    public let body_parts: [String]
    public let description: String
    public let dif_level: String
    public let common_mistakes: String
    public let steps: [String]
    public let tips: String
}

/// PlanModel represents a workout plan containing structured workouts at various levels.
/// It includes the plan's ID, title, image, category, difficulty levels, and creator's information.
public struct PlanModel: Codable {
    public let id: String
    public let img_URL: String
    public let title: String
    public let category: PlanModelCategory
    public let levels: [String: PlanLevel]
    public let created_by: String
}

/// PlanModelCategory defines a category within a workout plan, associating each level type with a difficulty rating.
public struct PlanModelCategory: Codable {
    public let description: String
    public let levels: [String: Int] // e.g., "Cardio": 2, "Strength": 3
}

/// PlanLevel defines a specific level within a workout plan, including a title, description, and assigned workout days.
public struct PlanLevel: Codable {
    public let title: String
    public let description: String
    public let days: [String: PlanDay]
}

public struct WorkoutsResponse: Codable {
    public let workouts: [WorkoutModel]
    public let lastDocId: String
}
public struct ExerciseResponse: Codable {
    public let exercises: [ExerciseModel]
    public let lastDocId: String
}

public struct PlansResponse: Codable {
    public let plans: [PlanModel]
    public let lastDocId: String
}


/// PlanDay represents a day within a plan level, with a title, description, and an optional array of workouts for that day.
public struct PlanDay: Codable {
    public let title: String
    public let description: String
    public let workouts: [WorkoutSummary]?
}

/// WorkoutSummary provides basic information about a workout within a plan day, containing its title and ID.
public struct WorkoutSummary: Codable {
    public let id: String
    public let imgURL: String
    public let title: String
    public let calories: Double?
    public let total_minutes: Int
}

/// ContentType is an enum for the types of content that can be fetched, with each case representing a different content type (workout, plan, exercise).
public enum ContentType: String, CaseIterable, Identifiable {
    case workout = "Workout"
    case plan = "Plan"
    case exercise = "Exercise"
    public var id: String { self.rawValue }
}
/// ContentType is an enum for the types of content that can be fetched, with each case representing a different content type (workout, plan, exercise).
public enum BodyPart: String, CaseIterable, Identifiable {
    case abs = "Abs"
    case biceps = "Biceps"
    case calves = "Calves"
    case chest = "Chest"
    case external_oblique = "External Oblique"
    case forearms = "Forearms"
    case glutes = "Glutes"
    case neck = "Neck"
    case quads = "Quads"
    case shoulders = "Shoulders"
    case triceps = "Triceps"
    case hamstrings = "Hamstrings"
    case lats = "Lats"
    case lower_back = "Lower Back"
    case traps = "Traps"
    case full_body = "Full Body"
    
    public var id: String { self.rawValue }
}


/// APIResponse represents a generic API response structure, containing optional fields for message or error details.
struct APIResponse: Codable {
    let message: String?
    let error: String?
}



// Filter processing to DataProcessor
extension DataProcessor {
    static func processWorkoutsArray(_ data: Data) throws -> WorkoutsResponse {
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw Workout JSON: \(jsonString)")
           }
           
           do {
               let decoder = JSONDecoder()
               let workoutsResponse = try decoder.decode(WorkoutsResponseRaw.self, from: data)
               
               // Map RawWorkoutData to WorkoutModel
               let workoutModels = workoutsResponse.workouts.map { rawWorkout in
                   return WorkoutModel(
                       id: rawWorkout.id,
                       title: rawWorkout.title,
                       img_URL: rawWorkout.workout_desc_img,
                       category: rawWorkout.category,
                       description: rawWorkout.description,
                       total_minutes: rawWorkout.total_minutes,
                       total_calories: rawWorkout.calories,
                       body_parts: rawWorkout.body_parts,
                       dif_level: rawWorkout.dif_level,
                       sequence: processSequence(rawWorkout.sequence)
                   )
               }
               
               let workoutResp = WorkoutsResponse(workouts: workoutModels, lastDocId: workoutsResponse.lastDocId)
               return workoutResp
           } catch let error as DecodingError {
               // Handle decoding errors
               print("Decoding Error in processWorkoutData: \(error)")
               throw error
           } catch {
               // Handle other errors
               print("Unexpected error in processWorkoutData: \(error)")
               throw error
        }
    }
    
    static func processExercisesArray(_ data: Data) throws -> ExerciseResponse {
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw Exercises Array JSON: \(jsonString)")
        }
        
        do {
            let decoder = JSONDecoder()
            let items = try decoder.decode(ExerciseResponseRaw.self, from: data)
            let exercises = items.exercises.map { item in
                ExerciseModel(
                    id: item.id ?? "NA",
                    title: item.title,
                    thumbnail_URL: item.thumbnail_URL ?? "",
                    video_URL: item.video_URL ?? "",
                    workout_countdown: item.workout_countdown,
                    workout_reps: item.workout_repeats,
                    avg_reps: item.repeats,
                    avg_countdown: item.countdown,
                    rest_duration: 10,
                    avg_cal: item.calories,
                    body_parts: item.body_parts ?? [],
                    description: item.description ?? "Missing exercise description",
                    dif_level: item.dif_level ?? "Medium",
                    common_mistakes: item.common_mistakes ?? "",
                    steps: processSteps(item.steps),
                    tips: item.tips ?? ""
                )
            }
            return ExerciseResponse(exercises: exercises, lastDocId: items.lastDocId)
        } catch {
            print("Error processing exercises array: \(error)")
            throw error
        }
    }
    
    static func processPlansArray(_ data: Data) throws -> PlansResponse {
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw Plans Array JSON: \(jsonString)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(PlansResponse.self, from: data)
        } catch {
            print("Error processing plans array: \(error)")
            throw error
        }
    }
}

// Processing JSON from API:
struct DataProcessor {
    
    static func processPlanData(_ data: Data) throws -> PlanModel {
           // Log raw JSON
           if let jsonString = String(data: data, encoding: .utf8) {
               print("Raw Plan JSON: \(jsonString)")
           }
           
           do {
               let decoder = JSONDecoder()
               return try decoder.decode(PlanModel.self, from: data)
           } catch let error as DecodingError {
               switch error {
               case .keyNotFound(let key, let context):
                   print("Missing key '\(key.stringValue)' in PlanModel: \(context.debugDescription)")
               case .typeMismatch(let type, let context):
                   print("Type mismatch for type '\(type)' in PlanModel: \(context.debugDescription)")
               case .valueNotFound(let value, let context):
                   print("Value '\(value)' not found in PlanModel: \(context.debugDescription)")
               case .dataCorrupted(let context):
                   print("Data corrupted in PlanModel: \(context.debugDescription)")
               default:
                   print("Unknown DecodingError in PlanModel: \(error)")
               }
               throw error
           } catch {
               print("Unexpected error in PlanModel decoding: \(error.localizedDescription)")
               throw error
           }
       }
       
    static func processWorkoutData(_ data: Data) throws -> WorkoutModel {
            // Log raw JSON
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw Workout JSON: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let rawWorkout = try decoder.decode(RawWorkoutData.self, from: data)
                
                return WorkoutModel(
                    id: rawWorkout.id,
                    title: rawWorkout.title,
                    img_URL: rawWorkout.workout_desc_img,
                    category: rawWorkout.category,
                    description: rawWorkout.description,
                    total_minutes: rawWorkout.total_minutes,
                    total_calories: rawWorkout.calories,
                    body_parts: rawWorkout.body_parts,
                    dif_level: rawWorkout.dif_level,
                    sequence: processSequence(rawWorkout.sequence)
                )
            } catch let error as DecodingError {
                switch error {
                case .keyNotFound(let key, let context):
                    print("Missing key '\(key.stringValue)' in WorkoutModel: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch for type '\(type)' in WorkoutModel: \(context.debugDescription)")
                case .valueNotFound(let value, let context):
                    print("Value '\(value)' not found in WorkoutModel: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("Data corrupted in WorkoutModel: \(context.debugDescription)")
                default:
                    print("Unknown DecodingError in WorkoutModel: \(error)")
                }
                throw error
            } catch {
                print("Unexpected error in WorkoutModel decoding: \(error.localizedDescription)")
                throw error
            }
        }
       
    static func processExerciseData(_ data: Data) throws -> ExerciseModel {
            // Log raw JSON
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw Exercise JSON: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let item = try decoder.decode(RawSequenceItem.self, from: data)
                
                return ExerciseModel(
                    id: item.id ?? "NA",
                    title: item.title,
                    thumbnail_URL: item.thumbnail_URL ?? "",
                    video_URL: item.video_URL ?? "",
                    workout_countdown: item.workout_countdown, // Convert to milliseconds
                    workout_reps: item.workout_repeats,
                    avg_reps: item.repeats,
                    avg_countdown: item.countdown,
                    rest_duration: 10,
                    avg_cal: item.calories,
                    body_parts: item.body_parts ?? [],
                    description: item.description ?? "Missing exercise description",
                    dif_level: item.dif_level ?? "Medium",
                    common_mistakes: item.common_mistakes ?? "",
                    steps: processSteps(item.steps),
                    tips: item.tips ?? ""
                )
            } catch let error as DecodingError {
                switch error {
                case .keyNotFound(let key, let context):
                    print("Missing key '\(key.stringValue)' in ExerciseModel: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch for type '\(type)' in ExerciseModel: \(context.debugDescription)")
                case .valueNotFound(let value, let context):
                    print("Value '\(value)' not found in ExerciseModel: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("Data corrupted in ExerciseModel: \(context.debugDescription)")
                default:
                    print("Unknown DecodingError in ExerciseModel: \(error)")
                }
                throw error
            } catch {
                print("Unexpected error in ExerciseModel decoding: \(error.localizedDescription)")
                throw error
            }
        }
    
    private static func processSequence(_ sequence: [RawSequenceItem]) -> [ExerciseModel] {
        var exercises: [ExerciseModel] = []
        var currentRestDuration: Int = 0
        
        for (index, item) in sequence.enumerated() {
            if item.title == "Rest" {
                currentRestDuration = item.countdown ?? 10
                continue
            }
            
            // Process exercise
            let exercise = ExerciseModel(
                id: item.id ?? "NA",
                title: item.title,
                thumbnail_URL: item.thumbnail_URL ?? "",
                video_URL: item.video_URL ?? "",
                workout_countdown: item.workout_countdown, // Convert to milliseconds
                workout_reps: item.workout_repeats,
                avg_reps: item.workout_repeats,
                avg_countdown: item.repeats,
                rest_duration: currentRestDuration,
                avg_cal: item.calories,
                body_parts: item.body_parts ?? [],
                description: item.description ?? "Missing exercise description",
                dif_level: item.dif_level ?? "Medium",
                common_mistakes: item.common_mistakes ?? "",
                steps: processSteps(item.steps),
                tips: item.tips ?? ""
            )
            
            exercises.append(exercise)
            currentRestDuration = 0 // Reset rest duration for next exercise
        }
        
        return exercises
    }
    
    private static func processSteps(_ steps: [String?]?) -> [String] {
        guard let steps = steps else { return [] }
        return steps.compactMap { $0 }.filter { !$0.isEmpty }
    }
    
    private static func calculateTotalCalories(_ sequence: [RawSequenceItem]) -> Double {
        return sequence.reduce(0) { sum, item in
            sum + (item.calories ?? 0) * Double(item.repeats ?? 1)
        }
    }
}

// MARK: - Raw Data Models
private struct RawWorkoutData: Codable {
    let id: String
    let body_img: String?
    let workout_desc_img: String
    let calories: Int?
    let category: String?
    let title: String
    let total_minutes: Int?
    let description: String
    let dif_level: String?
    let body_parts: [String]
    let sequence: [RawSequenceItem]
}

private struct RawSequenceItem: Codable {
    let id: String?
    let title: String
    let countdown: Int?
    let repeats: Int?
    let correct_second: Double?
    let video_URL: String?
    let thumbnail_URL: String?
    let calories: Double?
    let body_parts: [String]?
    let dif_level: String?
    let description: String?
    let steps: [String?]?
    let tips: String?
    let common_mistakes: String?
    let workout_repeats: Int?
    let workout_countdown: Int?
}


private struct WorkoutsResponseRaw: Codable {
     let workouts: [RawWorkoutData]
     let lastDocId: String
}

private struct ExerciseResponseRaw: Codable {
    let exercises: [RawSequenceItem]
     let lastDocId: String
}
