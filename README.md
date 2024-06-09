# [KinesteX AI Fitness SDK](https://kinestex.com)

## INTEGRATE AI TRAINER IN YOUR APP IN MINUTES
### Easily transform your platform with our SDK: white-labeled workouts with precise motion tracking and real-time feedback tailored for accuracy and engagement.

https://github.com/V-m1r/KinesteX-B2B-AI-Fitness-and-Physio/assets/62508191/ac4817ca-9257-402d-81db-74e95060b153

## Available Integration Option
---

### Integration Options

| **Integration Option**     | **Description**                                                                                       | **Features**                                                                                                                                                      | **Details**                                                                                                             |
|----------------------------|-------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| **Complete User Experience** | Leave it to us to recommend the best workout routines for your customers, handle motion tracking, and overall user interface. High level of customization based on your brand book for a seamless experience. | - Long-term lifestyle workout plans <br> - Specific body parts and full-body workouts <br> - Individual exercise challenges (e.g., 20 squat challenge)              | [View Integration Options](https://www.figma.com/proto/XYEoV023iSFdhpw3w65zR1/Complete?page-id=0%3A1&node-id=0-1&viewport=793%2C330%2C0.1&t=d7VfZzKpLBsJAcP9-1&scaling=contain) |
| **Custom User Experience**   | Integrate the camera component with motion tracking. Real-time feedback on all customer movements. Control the position, size, and placement of the camera component. | - Real-time feedback on customer movements <br> - Communication of every repeat and mistake <br> - Customizable camera component position, size, and placement     | [View Details](https://www.figma.com/proto/JyPHuRKKbiQkwgiDTkGJgT/Camera-Component?page-id=0%3A1&node-id=1-4&viewport=925%2C409%2C0.22&t=3UccMcp1o3lKc0cP-1&scaling=contain) |

---
## Configuration

#### Info.plist

Add the following keys for camera usage:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for video streaming.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for video streaming.</string>
```

### Add the framework as a package dependency:

```xml
https://github.com/KinesteX/KinesteX-SDK-Swift.git
```
<img width="1451" alt="Screenshot 2024-06-03 at 12 06 46 AM" src="https://github.com/KinesteX/KinesteX-SDK-Swift/assets/62508191/e1c311c2-cd67-4009-bcac-18db7acf0979">


### Available categories to sort workout plans:

| **enum PlanCategory** | 
| --- | 
| **Strength** | 
| **Cardio** |
| **Rehabilitation** | 
| **Weight Management** | 
| **Custom(String) - in case we release new custom plans for your usage** | 

## USAGE WORKOUT PLANS

### Initial Setup

1. **Prerequisites**:
    - Ensure you've added the necessary permissions in `Info.plist`.
    - miniOS version - 13.0
      
2. **Launching the view**:
   - To display KinesteX Complete User Experience, call `createMainView` in KinesteXAIFramework:

   ```Swift
    // isLoading is a State variable that can be used to display a loading screen before the webview loads
    KinesteXAIFramework.createMainView(apiKey: "your key", companyName: "your company", userId: "your userId", planCategory: .Cardio, isLoading: $isLoading, onMessageReceived: { message in
                        // our callback function to let you know of any real-time changes and user activity
                        switch message {
                            
                        case .kinestex_launched(let data):
                            print("KinesteX Launched: \(data)")
                        case .finished_workout(let data):
                            print("Workout Finished: \(data)")
                            // Handle other cases as needed
                        case .exit_kinestex(let data):
                             // user wants to close KinesteX view, so dismiss the view
                            dismiss()
                        default:
                            break
                        }
                        
                    })

                       // OPTIONAL: Display loading screen
                      .overlay(
                        
                        Group {
                            if showAnimation {
                                 Text("Aifying workouts...").foregroundColor(.black).font(.caption)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Fullscreen
                                    .background(Color.white) // White background
                                     .scaleEffect(showAnimation ? 1 : 3) // Scale up
                                    .opacity(showAnimation ? 1 : 0) // Fade out
                                    .animation(.easeInOut(duration: 1.5), value: showAnimation)
                                
                            }
                        }
                        
                        
                    )
                    // Smoothly hide the animation
                   .onChange(of: isLoading) { newValue in
                        if !newValue {
                            withAnimation(.easeInOut(duration: 2.5)) { // Extended duration to 2.5 seconds
                                showAnimation = false
                            }
                            
                        } else {
                            showAnimation = true
                        }
                    }
   
   ```

3. **Handling the data**:
   `onMessageReceived` is a callback function that passes `enum WebViewMessage`
   Available options are:

```swift
    kinestex_launched([String: Any]) - Logs when the KinesteX View is successfully launched.
    finished_workout([String: Any]) - Logs when a workout is finished.
    error_occurred([String: Any]) - Logs when an error has occurred, example (user did not grant access to the camera)
    exercise_completed([String: Any]) - Logs when an exercise is completed.
    exit_kinestex([String: Any]) - Logs when user clicks on exit button and wishes to close the KinesteX view.
    workout_opened([String: Any]) - Logs when the workout description view is opened.
    workout_started([String: Any]) - Logs when a workout is started.
    plan_unlocked([String: Any]) - Logs when a plan is unlocked.
    custom_type([String: Any]) - For handling any unrecognized messages
    reps([String: Any]) - Logs when a successful repeat is performed.
    mistake([String: Any]) - Logs when a mistake is detected.
    left_camera_frame([String: Any]) - Logs when the user leaves the camera frame.
    returned_camera_frame([String: Any]) - Logs when the user returns to the camera frame.
    workout_overview([String: Any]) - Logs a summary when a workout is completed.
    exercise_overview([String: Any]) - Logs a summary of exercises completed.
    workout_completed([String: Any]) - Logs when a workout is finished and the user exits the overview.
```

## USAGE CHALLENGE
      
 **Launching the view**:
   - To display KinesteX Challenge, call `createChallengeView` in KinesteXAIFramework:

   ```Swift
    // isLoading is a State variable that can be used to display a loading screen before the webview loads
    KinesteXAIFramework.createChallengeView(apiKey: "your key", companyName: "your company", userId: "your userId", exercise: String = "Squats", countdown: Int, isLoading: $isLoading, onMessageReceived: { message in
                        // our callback function to let you know of any real-time changes and user activity
                        switch message {
                            
                        case .kinestex_launched(let data):
                            print("KinesteX Launched: \(data)")
                        case .finished_workout(let data):
                            print("Workout Finished: \(data)")
                            // Handle other cases as needed
                        case .exit_kinestex(let data):
                             // user wants to close KinesteX view, so dismiss the view
                            dismiss()
                        default:
                            break
                        }
                        
                    })

                       // OPTIONAL: Display loading screen
                      .overlay(
                        
                        Group {
                            if showAnimation {
                                 Text("Aifying challenges...").foregroundColor(.black).font(.caption)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Fullscreen
                                    .background(Color.white) // White background
                                     .scaleEffect(showAnimation ? 1 : 3) // Scale up
                                    .opacity(showAnimation ? 1 : 0) // Fade out
                                    .animation(.easeInOut(duration: 1.5), value: showAnimation)
                                
                            }
                        }
                        
                        
                    )
                    // Smoothly hide the animation
                   .onChange(of: isLoading) { newValue in
                        if !newValue {
                            withAnimation(.easeInOut(duration: 2.5)) { // Extended duration to 2.5 seconds
                                showAnimation = false
                            }
                            
                        } else {
                            showAnimation = true
                        }
                    }
   
   ```

## API Reference

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
View Demo Project here: https://github.com/KinesteX/KinesteX-Swift-Demo

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
    @State var selectedPlan = "Full Cardio"
    @State var selectedOption = "Complete"
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
            KinesteXAIFramework.createMainView(apiKey:

 apiKey, companyName: company, userId: "user1", planCategory: planCategory, user: nil, isLoading: $isLoading, onMessageReceived: { message in
                switch message {
                case .exit_kinestex(_):
                    showKinesteX = false
                default:
                    break
                }
            })
        } else if selectedOption == "Plan" {
            KinesteXAIFramework.createPlanView(apiKey: apiKey, companyName: company, userId: "user1", planName: selectedPlan, user: nil, isLoading: $isLoading, onMessageReceived: { message in
                switch message {
                case .exit_kinestex(_):
                    showKinesteX = false
                default:
                    break
                }
            })
        } else if selectedOption == "Workout" {
            KinesteXAIFramework.createWorkoutView(apiKey: apiKey, companyName: company, userId: "user1", workoutName: selectedWorkout, user: nil, isLoading: $isLoading, onMessageReceived: { message in
                switch message {
                case .exit_kinestex(_):
                    showKinesteX = false
                default:
                    break
                }
            })
        } else if selectedOption == "Challenge" {
            KinesteXAIFramework.createChallengeView(apiKey: apiKey, companyName: company, userId: "user1", exercise: selectedChallenge, countdown: 100, user: nil, isLoading: $isLoading, onMessageReceived: { message in
                switch message {
                case .exit_kinestex(_):
                    showKinesteX = false
                default:
                    break
                }
            })
        } else {
            ZStack {
                KinesteXAIFramework.createCameraComponent(apiKey: apiKey, companyName: company, userId: "user1", exercises: ["Squats"], currentExercise: "Squats", user: nil, isLoading: $isLoading, onMessageReceived: { message in
                    switch message {
                    case .exit_kinestex(_):
                        showKinesteX = false
                    case .reps(let value):
                        reps = value["value"] as? Int ?? 0
                    case .mistake(let value):
                        mistake = value["value"] as? String ?? "--"
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
            VStack {
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

#Preview {
    ContentView()
}
```
---


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
