# [KinesteX AI Fitness SDK](https://kinestex.com)

## INTEGRATE AN AI TRAINER INTO YOUR APP IN MINUTES
### Effortlessly enhance your platform with our SDK, providing white-labeled workouts with precise motion tracking and real-time feedback designed for maximum accuracy and engagement.

[Demo Video](https://github.com/V-m1r/KinesteX-B2B-AI-Fitness-and-Physio/assets/62508191/ac4817ca-9257-402d-81db-74e95060b153)

## Integration Options
---

### Integration Overview

| **Option**                   | **Description**                                                                                      | **Features**                                                                                                                                                  | **Details**                                                                                                                |
|------------------------------|------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------|
| **Complete User Experience** | Let us handle the workout recommendations, motion tracking, and overall user interface. Customizable to fit your brand for a seamless experience. | - Long-term lifestyle workout plans<br> - Specific body parts and full-body workouts<br> - Individual exercise challenges (e.g., 20 squat challenge)         | [Explore Complete Experience](https://www.figma.com/proto/XYEoV023iSFdhpw3w65zR1/Complete?page-id=0%3A1&node-id=0-1&viewport=793%2C330%2C0.1&t=d7VfZzKpLBsJAcP9-1&scaling=contain) |
| **Custom User Experience**   | Integrate motion tracking with customizable camera settings. Real-time feedback for all user movements. | - Real-time movement feedback<br> - Instant communication of repetitions and mistakes<br> - Customizable camera position, size, and placement               | [Explore Custom Experience](https://www.figma.com/proto/JyPHuRKKbiQkwgiDTkGJgT/Camera-Component?page-id=0%3A1&node-id=1-4&viewport=925%2C409%2C0.22&t=3UccMcp1o3lKc0cP-1&scaling=contain) |

---

## Configuration

### Info.plist Setup

Add the following keys to enable camera and microphone usage:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for video streaming.</string>
```

### Adding the SDK as a Package Dependency

Add the framework as a package dependency with the following URL:

```xml
https://github.com/KinesteX/KinesteX-SDK-Swift.git
```

## Integration - Main View

Create the main view with personalized AI workout plans, tracking the user's progress and guiding them through their workout schedule.

### Available Workout Plan Categories

| **enum PlanCategory** | 
| --- | 
| **Strength** | 
| **Cardio** |
| **Rehabilitation** | 
| **Weight Management** | 
| **Custom(String)** - For newly released custom plans |

### Initial Setup

1. **Prerequisites**:
    - Ensure the necessary permissions are added in `Info.plist`.
    - Minimum OS version: 13.0

2. **Launching the Main View**:
   - To display the KinesteX Complete User Experience, call `createMainView` from the `KinesteXAIFramework`:

   ```swift
    KinesteXAIFramework.createMainView(
        apiKey: apiKey,
        companyName: company,
        userId: "YOUR USER ID",
        planCategory: planCategory,
        user: nil,
        isLoading: $isLoading,
        onMessageReceived: { message in
            // Handle real-time updates and user activity
            switch message {
            case .kinestex_launched(let data):
                print("KinesteX Launched: \(data)")
            case .finished_workout(let data):
                print("Workout Finished: \(data)")
                // Additional cases as needed
            case .exit_kinestex(let data):
                dismiss() // Dismiss the view
            default:
                break
            }
        }
    )
    // OPTIONAL: Display loading screen during view initialization
    .overlay(
        Group {
            if showAnimation {
                Text("Aifying workouts...")
                    .foregroundColor(.black)
                    .font(.caption)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .scaleEffect(showAnimation ? 1 : 3)
                    .opacity(showAnimation ? 1 : 0)
                    .animation(.easeInOut(duration: 1.5), value: showAnimation)
            }
        }
    )
    .onChange(of: isLoading) { newValue in
        withAnimation(.easeInOut(duration: 2.5)) {
            showAnimation = !newValue
        }
    }
   ```

## Integration - Challenge View

### Launching the Challenge View

Recommended exercises for challenges include:

```swift
"Squats", "Jumping Jack", "Burpee", "Push Ups", "Lunges", 
"Reverse Lunges", "Knee Push Ups", "Hip Thrust", "Squat Thrusts",
"Basic Crunch", "Sprinters Sit Ups", "Low Jacks", "Twisted Mountain Climber"
```

To display the KinesteX Challenge View, use `createChallengeView`:

```swift
KinesteXAIFramework.createChallengeView(
    apiKey: "your key",
    companyName: "your company",
    userId: "your userId",
    exercise: challengeExercise,
    countdown: Int,
    isLoading: $isLoading,
    onMessageReceived: { message in
        switch message {
        case .exit_kinestex(let data):
            dismiss()
        default:
            break
        }
    }
)
```

## Integration - Workout View

### Launching the Workout View

To display the KinesteX Workout View, use `createWorkoutView`:

```swift
KinesteXAIFramework.createWorkoutView(
    apiKey: apiKey,
    companyName: company,
    userId: "YOUR USER ID",
    workoutName: selectedWorkout,
    user: nil,
    isLoading: $isLoading,
    onMessageReceived: { message in
        switch message {
        case .exit_kinestex(_):
            showKinesteX = false
        default:
            break
        }
    }
)
```

## Integration - Plan View

### Launching the Plan View

To display the KinesteX Plan View, use `createPlanView`:

```swift
KinesteXAIFramework.createPlanView(
    apiKey: apiKey,
    companyName: company,
    userId: "YOUR USER ID",
    planName: selectedPlan,
    user: nil,
    isLoading: $isLoading,
    onMessageReceived: { message in
        switch message {
        case .exit_kinestex(_):
            showKinesteX = false
        default:
            break
        }
    }
)
```

## Integration - Camera Component

### Launching the Camera Component

To display the pose analysis view with an embedded camera component, use `createCameraComponent`:

```swift
KinesteXAIFramework.createCameraComponent(
    apiKey: apiKey,
    companyName: company,
    userId: "YOUR USER ID",
    exercises: arrayAllExercises,
    currentExercise: currentExerciseString,
    user: nil,
    isLoading: $isLoading,
    onMessageReceived: { message in
        switch message {
        case .reps(let value):
            reps = value["value"] as? Int ?? 0
        case .mistake(let value):
            mistake = value["value"] as? String ?? "--"
        default:
            break
        }
    }
)
```
### Public Functions

```swift
public struct KinesteXAIFramework {
    
    /**
     Creates the main view with personalized AI workout plans. Keeps track of the person's progress, current day and week to let a person workout according to the schedule.
     
     - Parameters:
       - apiKey: The API key for authentication.
       - companyName: The name of the company using the framework provided by KinesteX.
       - userId: The unique identifier for the user.
       - planCategory: The category of the workout plan (default is Cardio).
       - user: Optional user details including age, height, weight, gender, and lifestyle.
       - isLoading: A binding to a Boolean value indicating if the view is loading.
       - onMessageReceived: A closure that handles messages received from the WebView.
     - Returns: A SwiftUI `AnyView` containing the main view.
    */
    public static func createMainView(apiKey: String, companyName: String, userId: String, planCategory: PlanCategory = .Cardio, user: UserDetails?, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        // Function implementation
    }

    /**
     Creates a view for a specific workout plan. Keeps track of the progress for that particular plan, recommending the workouts according to the person's progression.
     
     - Parameters:
       - apiKey: The API key for authentication.
       - companyName: The name of the company using the framework provided by KinesteX.
       - userId: The unique identifier for the user.
       - planName: The name of the workout plan.
       - user: Optional user details including age, height, weight, gender, and lifestyle.
       - isLoading: A binding to a Boolean value indicating if the view is loading.
       - onMessageReceived: A closure that handles messages received from the WebView.
     - Returns: A SwiftUI `AnyView`

 containing the workout plan view.
    */
    public static func createPlanView(apiKey: String, companyName: String, userId: String, planName: String, user: UserDetails?, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        // Function implementation
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
        // Function implementation
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
        // Function implementation
    }

    /**
     Creates a camera component for real-time feedback on all movements based on the current exercise a person should be doing. You can dynamically change the exercise by calling updateCurrentExercise function.
     
     - Parameters:
       - apiKey: The API key for authentication.
       - companyName: The name of the company using the framework.
       - userId: The unique identifier for the user.
       - exercises: A list of exercises to be tracked.
       - currentExercise: The current exercise being performed.
       - user: Optional user details including age, height, weight, gender, and lifestyle.
       - isLoading: A binding to a Boolean value indicating if the view is loading.
       - onMessageReceived: A closure that handles messages received from the WebView.
     - Returns: A SwiftUI `AnyView` containing the camera component.
    */
    public static func createCameraComponent(apiKey: String, companyName: String, userId: String, exercises: [String], currentExercise: String, user: UserDetails?, isLoading: Binding<Bool>, onMessageReceived: @escaping (WebViewMessage) -> Void) -> AnyView {
        // Function implementation
    }

    /**
     Updates the current exercise in the camera component.
     
     - Parameters:
       - exercise: The name of the current exercise.
    */
    public static func updateCurrentExercise(_ exercise: String) {
        // Function implementation
    }
}
```

## Example Usage

Here's a comprehensive example of how to integrate and use the KinesteX AI Fitness SDK in a SwiftUI app:

```swift
import KinesteXAIFramework
import SwiftUI

struct ContentView: View {
    @State var showKinesteX = false
    @State var isLoading = false
    @State var isExpanded = false
    @State var isExpandedInner = false

    let apiKey = "" // store this key securely
    let company = ""
    @State var selectedWorkout = "Fitness Lite"
    @State var selectedChallenge = "Squats"
    
//    let recommendedChallenges = [
//        "Squats",
//        "Jumping Jack",
//        "Burpee",
//        "Push Ups",
//        "Lunges",
//        "Reverse Lunges",
//        "Knee Push Ups",
//        "Hip Thrust",
//        "Squat Thrusts",
//        "Basic Crunch",
//        "Sprinters Sit Ups",
//        "Low Jacks",
//        "Twisted Mountain Climber"
//    ]

    @State var selectedPlan = "Full Cardio"
    @State var selectedOption = "Complete UX"
    @State var planCategory: PlanCategory = .Cardio
    // for camera component
    @State var reps = 0
    @State var mistake = ""

    @ViewBuilder
    var mainContent: some View {
   
        DisclosureGroup("Select Integration Option", isExpanded: $isExpanded) {
            content
        }
        .accentColor(.white)
        .padding()
        .background(Color.gray.opacity(0.3).cornerRadius(10))
        .foregroundColor(.white)
        .font(.headline)
        .padding(.horizontal)
        
    }
    @ViewBuilder
    var workoutPlanCustomization: some View {
   
        DisclosureGroup("Select Plan", isExpanded: $isExpandedInner) {
            VStack {
                RadioButton(title: "Full Cardio", isSelected: selectedPlan == "Full Cardio", action: {
                    selectedPlan = "Full Cardio"
 
                })
                RadioButton(title: "Elastic Evolution", isSelected: selectedPlan == "Elastic Evolution", action: {
                    selectedPlan = "Elastic Evolution"
                })
                RadioButton(title: "Circuit Training", isSelected: selectedPlan == "Circuit Training", action: {
                    selectedPlan = "Circuit Training"
                })
                RadioButton(title: "Fitness Cardio", isSelected: selectedPlan == "Fitness Cardio", action: {
                    selectedPlan = "Fitness Cardio"
                })
                // all of other available plans. Please contact KinesteX to get access to the list of available plans and workouts
            }
        }
        .accentColor(.white)
        .padding()
        .background(Color.gray.opacity(0.3).cornerRadius(10))
        .foregroundColor(.white)
        .font(.headline)
        .padding(.horizontal)
        
    }
    
    @ViewBuilder
    var mainCustomization: some View {
   
        DisclosureGroup("Select Goal Category", isExpanded: $isExpandedInner) {
            VStack {
                RadioButton(title: "Cardio", isSelected: planCategory == .Cardio, action: {
                    planCategory = .Cardio
 
                })
                RadioButton(title: "Strength", isSelected: planCategory == .Strength, action: {
                    planCategory = .Strength
                })
                RadioButton(title: "Weight Management", isSelected: planCategory == .WeightManagement, action: {
                    planCategory = .WeightManagement
                })
                RadioButton(title: "Rehabilitation", isSelected: planCategory == .Rehabilitation, action: {
                    planCategory = .Rehabilitation
                })
            }
        }
        .accentColor(.white)
        .padding()
        .background(Color.gray.opacity(0.3).cornerRadius(10))
        .foregroundColor(.white)
        .font(.headline)
        .padding(.horizontal)
        
    }
    
    @ViewBuilder
    var workoutCustomization: some View {
   
        DisclosureGroup("Select Workout", isExpanded: $isExpandedInner) {
            VStack {
                RadioButton(title: "Fitness Lite", isSelected: selectedWorkout == "Fitness Lite", action: {
                    selectedWorkout = "Fitness Lite"
 
                })
                RadioButton(title: "Circuit Training", isSelected: selectedWorkout == "Circuit Training", action: {
                    selectedWorkout = "Circuit Training"
                })
                RadioButton(title: "Tabata", isSelected: selectedWorkout == "Tabata", action: {
                   selectedWorkout = "Tabata"
                })
                
            }
        }
        .accentColor(.white)
        .padding()
        .background(Color.gray.opacity(0.3).cornerRadius(10))
        .foregroundColor(.white)
        .font(.headline)
        .padding(.horizontal)
        
    }
    
    @ViewBuilder
    var challengeCustomization: some View {
   
        DisclosureGroup("Select Challenge", isExpanded: $isExpandedInner) {
            VStack {
                RadioButton(title: "Squats", isSelected: selectedChallenge == "Squats", action: {
                    selectedChallenge = "Squats"
 
                })
                RadioButton(title: "Jumping Jack", isSelected: selectedChallenge == "Jumping Jack", action: {
                    selectedChallenge = "Jumping Jack"
                })
           
            }
        }
        .accentColor(.white)
        .padding()
        .background(Color.gray.opacity(0.3).cornerRadius(10))
        .foregroundColor(.white)
        .font(.headline)
        .padding(.horizontal)
        
    }
    
    @ViewBuilder
    var content: some View {
   
        VStack {
            RadioButton(title: "Complete UX", isSelected: selectedOption == "Complete UX", action: {
                selectedOption = "Complete UX"
            })
            RadioButton(title: "Workout Plan", isSelected: selectedOption == "Plan", action: {
                selectedOption = "Plan"
            })
            RadioButton(title: "Workout", isSelected: selectedOption == "Workout", action: {
                selectedOption = "Workout"
            })
            RadioButton(title: "Challenge", isSelected: selectedOption == "Challenge", action: {
                selectedOption = "Challenge"
            })
            RadioButton(title: "Camera", isSelected: selectedOption == "Camera", action: {
                selectedOption = "Camera"
            })
        }
        
    }
    
    @ViewBuilder
    var kinestexView: some View {
   
        if selectedOption == "Complete UX" {
            KinesteXAIFramework.createMainView(apiKey: apiKey, companyName: company, userId: "YOUR USER ID", planCategory: planCategory, user: nil, isLoading: $isLoading, onMessageReceived: {
                    message in
                    switch message {
                    case .exit_kinestex(_):
                       showKinesteX = false
                        break
                   // handle all other cases accordingly
                    default:
                        break
                    }
            })
        } else if selectedOption == "Plan" {
            KinesteXAIFramework.createPlanView(apiKey: apiKey, companyName: company, userId: "YOUR USER ID", planName: selectedPlan, user: nil, isLoading: $isLoading, onMessageReceived: {
                    message in
                    switch message {
                    case .exit_kinestex(_):
                       showKinesteX = false
                        break
                   // handle all other cases accordingly
                    default:
                        break
                    }
            })
        } else if selectedOption == "Workout" {
            KinesteXAIFramework.createWorkoutView(apiKey: apiKey, companyName: company, userId: "YOUR USER ID", workoutName: selectedWorkout, user: nil, isLoading: $isLoading, onMessageReceived: {
                    message in
                    switch message {
                    case .exit_kinestex(_):
                       showKinesteX = false
                        break
                   // handle all other cases accordingly
                    default:
                        break
                    }
            })
        } else if selectedOption == "Challenge" {
            KinesteXAIFramework.createChallengeView(apiKey: apiKey, companyName: company, userId: "YOUR USER ID", exercise: selectedChallenge, countdown: 100, user: nil, isLoading: $isLoading, onMessageReceived: {
                    message in
                    switch message {
                    case .exit_kinestex(_):
                       showKinesteX = false
                        break
                   // handle all other cases accordingly
                    default:
                        break
                    }
            })
        } else {
            ZStack {
                KinesteXAIFramework.createCameraComponent(apiKey: apiKey, companyName: company, userId: "YOUR USER ID", exercises: ["Squats"], currentExercise: "Squats",                        user: nil, isLoading: $isLoading, onMessageReceived: {
                    message in
                    switch message {
                    case .reps(let value):
                        reps = value["value"] as? Int ?? 0
                        break
                    case .mistake(let value):
                        mistake = value["value"] as? String ?? "--"
                        break
                        // handle all other cases accordingly
                    default:
                        break
                    }
                })
                VStack {
                    Text("REPS: \(reps)")
                    Text("MISTAKE: \(mistake)").foregroundColor(.red)
                    Spacer()
                   
                }
            }
        }
        
    }
    var body: some View {
  
            if showKinesteX {
              kinestexView.frame(maxWidth: .infinity, maxHeight: .infinity) // Fullscreen
                   
            } else {
                VStack{
                    Spacer()
                
                    mainContent
                    if selectedOption == "Complete UX" {
                        mainCustomization
                    } else if selectedOption == "Plan" {
                        workoutPlanCustomization
                    } else if selectedOption == "Workout" {
                        workoutCustomization
                    } else if selectedOption == "Challenge" {
                        challengeCustomization
                    } else {
                        
                    }
                    Spacer()
                    
                    Button(action: {
                        showKinesteX = true
                       
                    }, label: {
                        Text("View \(selectedOption)").font(.title3).foregroundColor(.white).bold().padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.cornerRadius(10))
                            .padding(.horizontal)
                            .padding(.bottom)
                        
                    }).padding(.bottom, 30)
                    
                }.ignoresSafeArea().background(.black)
            }
            
            
        
       
    }
}

```
---
## **Handling Data**:

`onMessageReceived` is a callback function that passes `enum WebViewMessage`. Available message types include:

```swift
    kinestex_launched([String: Any]) - Logs when KinesteX View is launched.
    finished_workout([String: Any]) - Logs when a workout is completed.
    error_occurred([String: Any]) - Logs errors, such as missing camera permissions.
    exercise_completed([String: Any]) - Logs when an exercise is finished.
    exit_kinestex([String: Any]) - Logs when the user exits the KinesteX view.
    workout_opened([String: Any]) - Logs when a workout description is viewed.
    workout_started([String: Any]) - Logs when a workout begins.
    plan_unlocked([String: Any]) - Logs when a workout plan is unlocked.
    custom_type([String: Any]) - Handles unrecognized messages.
    reps([String: Any]) - Logs successful repetitions.
    mistake([String: Any]) - Logs detected mistakes.
    left_camera_frame([String: Any]) - Logs when the user leaves the camera frame.
    returned_camera_frame([String: Any]) - Logs when the user returns to the camera frame.
    workout_overview([String: Any]) - Logs a workout summary upon completion.
    exercise_overview([String: Any]) - Logs a summary of completed exercises.
    workout_completed([String: Any]) - Logs when a workout is completed and the overview is exited.
```

## Available data types
 
    
| Type          | Data  |          Description     |
|----------------------|----------------------------|---------------------------------------------------------|
| `kinestex_launched`  | Format: `dd mm yyyy hours:minutes:seconds` | When a user has launched KinesteX 
| `exit_kinestex`     | Format: `date: dd mm yyyy hours:minutes:seconds`, `time_spent: number` | Logs when a user clicks on exit button, requesting dismissal of KinesteX and sending how much time a user has spent totally in seconds since launch   |
| `plan_unlocked`    | Format: `title: String, date: date and time` | Logs when a workout plan is unlocked by a user    |
| `workout_opened`      | Format: `title: String, date: date and time` | Logs when a workout is opened by a user  |
| `workout_started`   |  Format: `title: String, date: date and time`| Logs when a workout is started.  |
| `error_occurred`    | Format:  `data: string`  |  Logs when a significant error has occurred. For example, a user has not granted access to the camera  |
| `exercise_completed`      | Format: `time_spent: number`,  `repeats: number`, `calories: number`,  `exercise: string`, `mistakes: [string: number]`  |  Logs everytime a user finishes an exercise |
| `left_camera_frame` | Format: `number`  |  Indicates that a user has left the camera frame. The data sent is the current number of `total_active_seconds` |
| `returned_camera_frame` | Format: `number`  |  Indicates that a user has returned to the camera frame. The data sent is the current number of `total_active_seconds` |
| `workout_overview`    | Format:  `workout: string`,`total_time_spent: number`,  `total_repeats: number`, `total_calories: number`,  `percentage_completed: number`,  `total_mistakes: number`  |  Logged when a user finishes the workout with a complete short summary of the workout  |
| `exercise_overview`    | Format:  `[exercise_completed]` |  Returns a log of all exercises and their data (exercise_completed data is defined 5 lines above) |
| `workout_completed`    | Format:  `workout: string`, `date: dd mm yyyy hours:minutes:seconds`  |  Logs when a user finishes the workout and exits the workout overview |
| `active_days` (Coming soon)   | Format:  `number`  |  Represents a number of days a user has been opening KinesteX |
| `total_workouts` (Coming soon)  | Format:  `number`  |  Represents a number of workouts a user has done since start of using KinesteX|
| `workout_efficiency` (Coming soon)  | Format:  `number`  |  Represents the level of intensivity a person has done the workout with. An average level of workout efficiency is 0.5, which represents an average time a person should complete the workout for at least 80% within a specific timeframe. For example, if on average people complete workout X in 15 minutes, but a person Y has completed the workout in 12 minutes, they will have a higher `workout_efficiency` number |
------------------

Any questions? Contact us at support@kinestex.com
