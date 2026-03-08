# PlateShare Bangladesh — Professional iOS Execution Blueprint
### Community Food Sharing Network | Swift + SwiftUI + Firebase
**Team Size:** 3 Developers | **Timeline:** 1-Week MVP | **Architecture:** MVVM + Combine  
**Version:** 1.0 | Production-Ready Engineering Plan

---

## Table of Contents
1. [Feature & Module Breakdown](#section-1)
2. [MVVM-Aligned Project Structure](#section-2)
3. [Firebase Integration Guide](#section-3)
4. [API & Service Layer Design](#section-4)
5. [GitHub Workflow & Contribution Strategy](#section-5)
6. [One-Night macOS Execution Plan](#section-6)
7. [Post-ZIP Collaboration Strategy](#section-7)
8. [iOS-Specific Best Practices](#section-8)
9. [Final Polish Checklist](#section-9)

---

## Section 1 — Feature & Module Breakdown <a name="section-1"></a>

### 1.1 Full Feature Inventory

| Feature | Category | Complexity | Week |
|---------|----------|------------|------|
| Firebase Email/Password Auth | Auth | Low | 1 |
| User Profile Creation | Auth | Low | 1 |
| Food Listing Creation (photo + details) | Core | High | 1 |
| Home Feed (real-time listings) | Core | High | 1 |
| MapKit + Location-based listing discovery | Core | High | 1 |
| In-app Messaging (text) | Core | High | 1 |
| Push Notifications (FCM) | Core | Medium | 1 |
| Bangla/English Localization | Core | Medium | 1 |
| Trust/Rating System | Core | Medium | 1–2 |
| Voice Messaging (AVFoundation) | Advanced | High | 2 |
| Offline-First Message Caching | Advanced | High | 2 |
| Wedding/Event Mode (bulk share) | Advanced | Medium | 2 |
| Prayer Time Integration (Ramadan) | Cultural | Medium | 2 |
| NGO/Charity Integration | Premium | Very High | Phase 2 |
| bKash/Nagad Payment | Premium | Very High | Phase 2 |
| AI Food Detection | Premium | Very High | Phase 2 |

### 1.2 MVP Definition (1-Week Scope)

The MVP must prove the core loop: **Post food → Discover nearby food → Message donor → Arrange pickup.**

**MVP Must-Haves (non-negotiable):**
- Email/Password authentication (Firebase Auth — free Spark plan)
- User profile: name, email, area/mohalla, profile photo
- Create food listing: title, photo, category, quantity, expiry time, pickup location
- Real-time listing feed (home screen)
- Map view showing nearby listings within selectable radius
- In-app text messaging between donor and recipient
- Basic trust indicators: verified email badge, user rating display

**MVP Should-Haves (include if time allows):**
- Push notifications for new nearby listings
- Bangla/English language toggle
- Food category filter (biryani, fish, sweets, etc.)
- Listing expiry (auto-remove after pickup time)

**Explicitly Out of Scope for MVP:**
- Voice messaging
- Wedding/Event Mode
- Offline caching
- Prayer time integration
- Any payment integration

### 1.3 Module Breakdown

```
PlateShare/
├── Module 1: Authentication         → Developer A
├── Module 2: Listings (Feed + Map)  → Developer B
├── Module 3: Messaging              → Developer C
├── Module 4: Profile + Ratings      → Developer A (shared)
├── Module 5: Notifications          → Developer B (shared)
└── Module 6: Localization + Polish  → All (final sprint)
```

---

## Section 2 — MVVM-Aligned Project Structure <a name="section-2"></a>

### 2.1 Full Folder Hierarchy

```
PlateShareBD/
├── PlateShareBD.xcodeproj
├── PlateShareBD/
│   ├── App/
│   │   ├── PlateShareBDApp.swift          ← @main entry point
│   │   ├── AppDelegate.swift              ← Firebase.configure() lives here
│   │   └── ContentView.swift              ← Root navigation switcher (auth vs main)
│   │
│   ├── Core/
│   │   ├── Authentication/
│   │   │   ├── Views/
│   │   │   │   ├── WelcomeView.swift
│   │   │   │   ├── EmailAuthView.swift
│   │   │   │   └── ProfileSetupView.swift
│   │   │   ├── ViewModels/
│   │   │   │   ├── AuthViewModel.swift
│   │   │   │   └── ProfileSetupViewModel.swift
│   │   │   └── Models/
│   │   │       └── UserModel.swift
│   │   │
│   │   ├── Feed/
│   │   │   ├── Views/
│   │   │   │   ├── FeedView.swift
│   │   │   │   ├── ListingCardView.swift
│   │   │   │   ├── ListingDetailView.swift
│   │   │   │   └── FilterSheetView.swift
│   │   │   ├── ViewModels/
│   │   │   │   ├── FeedViewModel.swift
│   │   │   │   └── ListingDetailViewModel.swift
│   │   │   └── Models/
│   │   │       └── FoodListingModel.swift
│   │   │
│   │   ├── CreateListing/
│   │   │   ├── Views/
│   │   │   │   ├── CreateListingView.swift
│   │   │   │   ├── FoodCategoryPickerView.swift
│   │   │   │   └── LocationPickerView.swift
│   │   │   └── ViewModels/
│   │   │       └── CreateListingViewModel.swift
│   │   │
│   │   ├── Map/
│   │   │   ├── Views/
│   │   │   │   ├── MapView.swift
│   │   │   │   └── MapListingAnnotationView.swift
│   │   │   └── ViewModels/
│   │   │       └── MapViewModel.swift
│   │   │
│   │   ├── Messaging/
│   │   │   ├── Views/
│   │   │   │   ├── ConversationListView.swift
│   │   │   │   ├── ChatView.swift
│   │   │   │   └── MessageBubbleView.swift
│   │   │   ├── ViewModels/
│   │   │   │   ├── ConversationListViewModel.swift
│   │   │   │   └── ChatViewModel.swift
│   │   │   └── Models/
│   │   │       ├── ConversationModel.swift
│   │   │       └── MessageModel.swift
│   │   │
│   │   ├── Profile/
│   │   │   ├── Views/
│   │   │   │   ├── ProfileView.swift
│   │   │   │   ├── MyListingsView.swift
│   │   │   │   └── RatingView.swift
│   │   │   └── ViewModels/
│   │   │       └── ProfileViewModel.swift
│   │   │
│   │   └── Notifications/
│   │       └── NotificationManager.swift
│   │
│   ├── Services/                          ← No UI. Pure business logic.
│   │   ├── Firebase/
│   │   │   ├── AuthService.swift
│   │   │   ├── FirestoreService.swift
│   │   │   ├── StorageService.swift
│   │   │   └── MessagingService.swift
│   │   ├── Location/
│   │   │   └── LocationService.swift
│   │   └── Notifications/
│   │       └── FCMService.swift
│   │
│   ├── Models/                            ← Shared data models
│   │   ├── UserModel.swift
│   │   ├── FoodListingModel.swift
│   │   ├── MessageModel.swift
│   │   └── ConversationModel.swift
│   │
│   ├── Utilities/
│   │   ├── Extensions/
│   │   │   ├── Color+Extensions.swift
│   │   │   ├── View+Extensions.swift
│   │   │   ├── Date+Extensions.swift
│   │   │   └── String+Extensions.swift
│   │   ├── Constants/
│   │   │   ├── AppConstants.swift
│   │   │   ├── FirestoreKeys.swift
│   │   │   └── ColorPalette.swift
│   │   └── Helpers/
│   │       ├── ImageCompressor.swift
│   │       └── LocationHelper.swift
│   │
│   ├── Components/                        ← Reusable SwiftUI components
│   │   ├── PSButtonStyle.swift
│   │   ├── PSTextField.swift
│   │   ├── PSAvatarView.swift
│   │   ├── PSBadgeView.swift
│   │   ├── LoadingView.swift
│   │   └── ErrorBannerView.swift
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets
│   │   ├── Localizable.strings            ← English strings
│   │   ├── Localizable.strings (bn)       ← Bangla strings
│   │   └── LaunchScreen.storyboard
│   │
│   └── GoogleService-Info.plist           ← NEVER commit this to public repos
│
├── PlateShareBDTests/
└── PlateShareBDUITests/
```

### 2.2 View ↔ ViewModel ↔ Service Responsibilities

```
┌──────────────────────────────────────────────────────────┐
│  VIEW (SwiftUI)                                          │
│  - Renders UI only                                       │
│  - Reads @Published properties from ViewModel           │
│  - Calls ViewModel methods on user interaction          │
│  - NEVER calls Firebase directly                        │
│  - NEVER contains business logic                        │
└─────────────────────────┬────────────────────────────────┘
                          │ @StateObject / @ObservedObject
┌─────────────────────────▼────────────────────────────────┐
│  VIEWMODEL (@MainActor, ObservableObject)                │
│  - @Published var for all state (listings, errors, etc) │
│  - Calls Service layer methods with async/await         │
│  - Transforms raw models into display-ready data        │
│  - Handles loading states and error states              │
│  - NEVER imports FirebaseFirestore directly             │
└─────────────────────────┬────────────────────────────────┘
                          │ Dependency Injection
┌─────────────────────────▼────────────────────────────────┐
│  SERVICE (Plain Swift class/actor)                       │
│  - All Firebase SDK calls live here                     │
│  - Returns Swift models (not Firestore DocumentSnapshot)│
│  - Throws typed errors (AppError enum)                  │
│  - Can be mocked for testing                            │
└──────────────────────────────────────────────────────────┘
```

### 2.3 Key Model Definitions

```swift
// Models/UserModel.swift
struct PSUser: Codable, Identifiable {
    let id: String                    // Firebase UID
    var displayName: String
    var email: String
    var area: String                  // mohalla/para
    var profileImageURL: String?
    var isVerified: Bool
    var donorRating: Double           // 0.0 - 5.0
    var totalDonations: Int
    var fcmToken: String?
    var preferredLanguage: String     // "en" or "bn"
    var createdAt: Date
}

// Models/FoodListingModel.swift
struct FoodListing: Codable, Identifiable {
    let id: String
    let donorId: String
    var donorName: String
    var title: String
    var description: String?
    var category: FoodCategory
    var quantity: String              // "Serves 10 people"
    var imageURLs: [String]
    var pickupAddress: String
    var latitude: Double
    var longitude: Double
    var isHalal: Bool
    var isAvailable: Bool
    var expiresAt: Date
    var createdAt: Date

    enum FoodCategory: String, Codable, CaseIterable {
        case biryani = "biryani"
        case rice = "rice"
        case curry = "curry"
        case fish = "fish"
        case sweets = "sweets"
        case iftar = "iftar"
        case fruits = "fruits"
        case bakery = "bakery"
        case other = "other"

        var banglaName: String {
            switch self {
            case .biryani: return "বিরিয়ানি"
            case .rice: return "ভাত"
            case .curry: return "তরকারি"
            case .fish: return "মাছ"
            case .sweets: return "মিষ্টি"
            case .iftar: return "ইফতার"
            case .fruits: return "ফল"
            case .bakery: return "বেকারি"
            case .other: return "অন্যান্য"
            }
        }
    }
}

// Models/MessageModel.swift
struct PSMessage: Codable, Identifiable {
    let id: String
    let senderId: String
    let conversationId: String
    var text: String?
    var audioURL: String?             // for voice messages (Phase 2)
    var isRead: Bool
    var createdAt: Date
}

// Models/ConversationModel.swift
struct PSConversation: Codable, Identifiable {
    let id: String
    let listingId: String
    let participantIds: [String]      // [donorId, recipientId]
    var lastMessage: String?
    var lastMessageAt: Date?
    var unreadCount: Int
}
```

---

## Section 3 — Firebase Integration Guide <a name="section-3"></a>

### 3.1 Firebase Console Setup (Do This First — 45 Minutes)

#### Step 1: Create the Firebase Project

1. Open [https://console.firebase.google.com](https://console.firebase.google.com)
2. Click **"Add project"**
3. Project name: `PlateShare-Bangladesh` (no spaces allowed in project ID, it auto-generates `plateshare-bangladesh-xxxxx`)
4. **Enable Google Analytics** → Yes (needed for FCM analytics)
5. Select Analytics account → Default Firebase account
6. Click **Create project** → Wait 30 seconds
7. Click **Continue**

#### Step 2: Register the iOS App

1. In the Firebase project dashboard, click the **iOS icon** (circle with Apple logo)
2. **iOS bundle ID:** `com.yourteam.PlateShareBD`
   - This must match EXACTLY what you set in Xcode → Project → Target → General → Bundle Identifier
   - Use your real team name, e.g., `com.csebd.PlateShareBD`
3. **App nickname:** `PlateShare Bangladesh`
4. **App Store ID:** Leave blank (not on App Store yet)
5. Click **Register app**

#### Step 3: Download GoogleService-Info.plist

1. Firebase shows a download button for `GoogleService-Info.plist`
2. Click **Download GoogleService-Info.plist**
3. **CRITICAL:** Save this file. Do NOT lose it. Do NOT regenerate it mid-project.
4. Click **Next** (skip the SDK steps for now — you'll use SPM)
5. Click **Continue to console**

#### Step 4: Add GoogleService-Info.plist to Xcode

1. Open your Xcode project
2. In the Project Navigator (left panel), right-click on the **PlateShareBD** group (root level, same level as App folder)
3. Select **"Add Files to PlateShareBD..."**
4. Navigate to the downloaded `.plist` file
5. **Check "Copy items if needed"** ✅
6. **Check "Add to target: PlateShareBD"** ✅
7. Click **Add**
8. Verify: The `.plist` should appear in the navigator at the root of your app group

> ⚠️ **CRITICAL MISTAKE TO AVOID:** The `.plist` MUST be at the root of the app target, not inside a subfolder. Placing it inside `Resources/` or `Config/` will cause `FirebaseApp.configure()` to fail silently with no useful error message.

#### Step 5: Add `.plist` to `.gitignore` immediately

```bash
# In your terminal, at project root:
echo "PlateShareBD/GoogleService-Info.plist" >> .gitignore
git add .gitignore
git commit -m "chore: add GoogleService-Info.plist to gitignore"
```

Then share the `.plist` file with teammates via **WhatsApp/Google Drive/USB — never via GitHub**.

---

### 3.2 Firebase SDK Installation via Swift Package Manager

Swift Package Manager is the modern, recommended approach. Do NOT use CocoaPods for new projects.

#### Step 1: Add Firebase Package

1. In Xcode: **File → Add Package Dependencies...**
2. In the search bar, paste: `https://github.com/firebase/firebase-ios-sdk`
3. Wait for Xcode to fetch the package (can take 1–3 minutes)
4. **Dependency Rule:** Select **"Up to Next Major Version"** → `11.0.0`
5. Click **Add Package**

#### Step 2: Select Exact Libraries

When Xcode asks which products to add, check **only** these:

```
✅ FirebaseAnalytics
✅ FirebaseAuth
✅ FirebaseFirestore
✅ FirebaseStorage
✅ FirebaseMessaging
```

Do NOT add unused libraries. Each one adds build time and app size.

Click **Add Package**.

---

### 3.3 Firebase Initialization

```swift
// App/AppDelegate.swift
import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()                         // MUST be first line
        setupMessaging(application)
        return true
    }

    private func setupMessaging(_ application: UIApplication) {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions
        ) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
        application.registerForRemoteNotifications()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        // Save token to Firestore so you can send push notifications to this device
        Task {
            await FCMService.shared.updateToken(token)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .badge, .sound]
    }
}

// App/PlateShareBDApp.swift
import SwiftUI
import FirebaseCore

@main
struct PlateShareBDApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}

// App/ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            switch authViewModel.authState {
            case .unauthenticated:
                WelcomeView()
            case .authenticating:
                LoadingView(message: "Verifying...")
            case .needsProfileSetup:
                ProfileSetupView()
            case .authenticated:
                MainTabView()
            }
        }
        .animation(.easeInOut, value: authViewModel.authState)
    }
}
```

---

### 3.4 Firebase Email/Password Authentication (Primary Auth Flow — Free Spark Plan)

#### Step 1: Enable Email/Password Auth in Firebase Console

1. Firebase Console → Your Project → **Authentication** → **Sign-in method**
2. Click on **Email/Password** in the list
3. Toggle **Enable** → On
4. Click **Save**

> **Why Email/Password instead of Phone OTP?** Firebase Phone Auth requires the Blaze (pay-as-you-go) billing plan. Email/Password auth works on the free Spark plan with no billing account required.

#### Step 2: AuthService Implementation (Email/Password)

```swift
// Services/Firebase/AuthService.swift
import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case wrongPassword
    case tooManyRequests
    case networkError
    case userNotFound
    case profileSetupRequired
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail: return "Please enter a valid email address."
        case .weakPassword: return "Password must be at least 6 characters."
        case .emailAlreadyInUse: return "An account with this email already exists. Try signing in."
        case .wrongPassword: return "Incorrect password. Please try again."
        case .tooManyRequests: return "Too many attempts. Please wait before trying again."
        case .networkError: return "No internet connection. Please check your network."
        case .userNotFound: return "No account found with this email."
        case .profileSetupRequired: return "Please complete your profile."
        case .unknown(let msg): return msg
        }
    }
}

@MainActor
final class AuthService {
    static let shared = AuthService()
    private init() {}

    private let db = Firestore.firestore()

    // Register a new user with email and password
    func register(email: String, password: String) async throws -> AuthDataResult {
        do {
            return try await Auth.auth().createUser(withEmail: email, password: password)
        } catch let error as NSError {
            throw mapFirebaseAuthError(error)
        }
    }

    // Sign in with email and password
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        do {
            return try await Auth.auth().signIn(withEmail: email, password: password)
        } catch let error as NSError {
            throw mapFirebaseAuthError(error)
        }
    }

    // Check if user profile exists in Firestore
    func checkUserProfile(uid: String) async throws -> Bool {
        let doc = try await db.collection(FirestoreKeys.Collections.users).document(uid).getDocument()
        return doc.exists
    }

    // Create user profile in Firestore
    func createUserProfile(_ user: PSUser) async throws {
        let data = try Firestore.Encoder().encode(user)
        try await db.collection(FirestoreKeys.Collections.users).document(user.id).setData(data)
    }

    // Fetch user profile
    func fetchUserProfile(uid: String) async throws -> PSUser {
        let doc = try await db.collection(FirestoreKeys.Collections.users).document(uid).getDocument()
        guard let user = try? doc.data(as: PSUser.self) else {
            throw AuthError.userNotFound
        }
        return user
    }

    // Sign out
    func signOut() throws {
        try Auth.auth().signOut()
    }

    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    private func mapFirebaseAuthError(_ error: NSError) -> AuthError {
        guard let code = AuthErrorCode(rawValue: error.code) else {
            return .unknown(error.localizedDescription)
        }
        switch code {
        case .invalidEmail: return .invalidEmail
        case .weakPassword: return .weakPassword
        case .emailAlreadyInUse: return .emailAlreadyInUse
        case .wrongPassword: return .wrongPassword
        case .tooManyRequests: return .tooManyRequests
        case .networkError: return .networkError
        case .userNotFound: return .userNotFound
        default: return .unknown(error.localizedDescription)
        }
    }
}
```

#### Step 3: AuthViewModel (Email/Password)

```swift
// Core/Authentication/ViewModels/AuthViewModel.swift
import Foundation
import FirebaseAuth
import Combine

enum AuthState: Equatable {
    case unauthenticated
    case authenticating
    case needsProfileSetup
    case authenticated
}

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var authState: AuthState = .unauthenticated
    @Published var currentUser: PSUser?
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let authService = AuthService.shared
    private var authStateListener: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthState()
    }

    private func listenToAuthState() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user = user {
                    await self?.handleAuthenticatedUser(uid: user.uid)
                } else {
                    self?.authState = .unauthenticated
                    self?.currentUser = nil
                }
            }
        }
    }

    private func handleAuthenticatedUser(uid: String) async {
        do {
            let profileExists = try await authService.checkUserProfile(uid: uid)
            if profileExists {
                let user = try await authService.fetchUserProfile(uid: uid)
                self.currentUser = user
                self.authState = .authenticated
            } else {
                self.authState = .needsProfileSetup
            }
        } catch {
            self.errorMessage = error.localizedDescription
            self.authState = .unauthenticated
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.signIn(email: email, password: password)
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Sign in failed. Please try again."
        }
        isLoading = false
    }

    func register(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.register(email: email, password: password)
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Registration failed. Please try again."
        }
        isLoading = false
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = "Could not sign out. Please try again."
        }
    }

    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}
```

#### Step 4: EmailAuthView Implementation

```swift
// Core/Authentication/Views/EmailAuthView.swift
import SwiftUI

struct EmailAuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "envelope.badge.shield.half.filled")
                        .font(.system(size: 50))
                        .foregroundStyle(.psGreen)

                    Text(isSignUp ? "Create Account" : "Welcome Back")
                        .font(.title2.bold())

                    Text(isSignUp ? "অ্যাকাউন্ট তৈরি করুন" : "আবার স্বাগতম")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // Email & Password
                VStack(spacing: 14) {
                    PSTextField(placeholder: "Email address", text: $email,
                                keyboardType: .emailAddress, icon: "envelope.fill")
                        .focused($focusedField, equals: .email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)

                    PSTextField(placeholder: "Password (min 6 characters)", text: $password,
                                icon: "lock.fill", isSecure: true)
                        .focused($focusedField, equals: .password)
                        .textContentType(isSignUp ? .newPassword : .password)
                }

                // Submit
                PSButton(isSignUp ? "Create Account" : "Sign In",
                         isLoading: authViewModel.isLoading) {
                    Task {
                        if isSignUp {
                            await authViewModel.register(email: email, password: password)
                        } else {
                            await authViewModel.signIn(email: email, password: password)
                        }
                    }
                }
                .disabled(email.isEmpty || password.count < 6)

                // Toggle sign-in / sign-up
                Button {
                    withAnimation { isSignUp.toggle() }
                } label: {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.psGreen)
                }

                // Error
                if let error = authViewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(12)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }

                Spacer()
            }
            .padding(24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { focusedField = .email }
    }
}
```

---

### 3.5 Firestore Data Modeling

#### Collection Structure

```
Firestore Database
│
├── users/                              (collection)
│   └── {userId}/                       (document)
│       ├── id: String
│       ├── displayName: String
│       ├── email: String
│       ├── area: String
│       ├── profileImageURL: String?
│       ├── isVerified: Bool
│       ├── donorRating: Number
│       ├── totalDonations: Int
│       ├── fcmToken: String
│       ├── preferredLanguage: String
│       └── createdAt: Timestamp
│
├── listings/                           (collection)
│   └── {listingId}/                    (document)
│       ├── id: String
│       ├── donorId: String             ← FK to users/{userId}
│       ├── donorName: String           ← denormalized (avoids extra read)
│       ├── title: String
│       ├── description: String?
│       ├── category: String
│       ├── quantity: String
│       ├── imageURLs: Array<String>
│       ├── pickupAddress: String
│       ├── latitude: Number
│       ├── longitude: Number
│       ├── isHalal: Bool
│       ├── isAvailable: Bool
│       ├── expiresAt: Timestamp
│       └── createdAt: Timestamp
│
├── conversations/                      (collection)
│   └── {conversationId}/               (document)
│       ├── id: String
│       ├── listingId: String
│       ├── participantIds: Array<String>
│       ├── lastMessage: String?
│       ├── lastMessageAt: Timestamp?
│       ├── unreadCount: Number
│       │
│       └── messages/                   (subcollection)
│           └── {messageId}/
│               ├── id: String
│               ├── senderId: String
│               ├── text: String?
│               ├── audioURL: String?
│               ├── isRead: Bool
│               └── createdAt: Timestamp
│
└── ratings/                            (collection)
    └── {ratingId}/
        ├── fromUserId: String
        ├── toUserId: String
        ├── listingId: String
        ├── score: Number (1-5)
        ├── comment: String?
        └── createdAt: Timestamp
```

#### Firestore Security Rules

Go to Firebase Console → Firestore → **Rules** tab. Replace the default rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    function isParticipant(conversationData) {
      return request.auth.uid in conversationData.participantIds;
    }

    // USERS collection
    match /users/{userId} {
      // Anyone authenticated can read profiles (needed for listing cards)
      allow read: if isSignedIn();
      // Only the user can write their own profile
      allow create: if isOwner(userId);
      allow update: if isOwner(userId);
      allow delete: if false; // Never allow deletion
    }

    // LISTINGS collection
    match /listings/{listingId} {
      // Anyone authenticated can read available listings
      allow read: if isSignedIn();
      // Only authenticated users can create listings
      allow create: if isSignedIn()
        && request.resource.data.donorId == request.auth.uid
        && request.resource.data.title is string
        && request.resource.data.title.size() > 0
        && request.resource.data.title.size() <= 100;
      // Only the donor can update their listing
      allow update: if isSignedIn()
        && resource.data.donorId == request.auth.uid;
      allow delete: if isSignedIn()
        && resource.data.donorId == request.auth.uid;
    }

    // CONVERSATIONS collection
    match /conversations/{conversationId} {
      allow read: if isSignedIn()
        && isParticipant(resource.data);
      allow create: if isSignedIn()
        && request.auth.uid in request.resource.data.participantIds;
      allow update: if isSignedIn()
        && isParticipant(resource.data);

      // MESSAGES subcollection
      match /messages/{messageId} {
        allow read: if isSignedIn()
          && isParticipant(get(/databases/$(database)/documents/conversations/$(conversationId)).data);
        allow create: if isSignedIn()
          && request.resource.data.senderId == request.auth.uid;
        allow update: if false;
        allow delete: if false;
      }
    }

    // RATINGS collection
    match /ratings/{ratingId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn()
        && request.resource.data.fromUserId == request.auth.uid;
      allow update: if false;
      allow delete: if false;
    }
  }
}
```

#### Create Firestore Indexes (Required for Compound Queries)

Go to Firebase Console → Firestore → **Indexes** → Add Index:

```
Index 1: listings feed query
Collection: listings
Fields:
  - isAvailable ASC
  - createdAt DESC

Index 2: listings by donor
Collection: listings
Fields:
  - donorId ASC
  - createdAt DESC

Index 3: conversations by participant
Collection: conversations
Fields:
  - participantIds ARRAY CONTAINS
  - lastMessageAt DESC

Index 4: messages in conversation
Collection: conversations → messages (subcollection)
Fields:
  - createdAt ASC
```

> ⚠️ **Common Mistake:** If you run a query before the index is created, Firestore will fail with an error that includes a direct link to create the missing index. Click that link immediately. Indexes take 1–5 minutes to build.

---

### 3.6 FirestoreService Implementation

```swift
// Services/Firebase/FirestoreService.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

enum AppError: LocalizedError {
    case notAuthenticated
    case permissionDenied
    case documentNotFound
    case encodingError
    case networkError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "You must be logged in."
        case .permissionDenied: return "You don't have permission for this action."
        case .documentNotFound: return "The requested content was not found."
        case .encodingError: return "Data processing error. Please try again."
        case .networkError: return "Network error. Check your internet connection."
        case .unknown(let msg): return msg
        }
    }
}

final class FirestoreService {
    static let shared = FirestoreService()
    private init() {}

    private let db = Firestore.firestore()

    // ─── LISTINGS ────────────────────────────────────────────

    // Create a new listing
    func createListing(_ listing: FoodListing) async throws {
        guard Auth.auth().currentUser != nil else { throw AppError.notAuthenticated }

        do {
            let data = try Firestore.Encoder().encode(listing)
            try await db.collection("listings").document(listing.id).setData(data)
        } catch {
            throw AppError.encodingError
        }
    }

    // Fetch paginated listings for the feed
    // lastDocument is used for pagination (pass nil for first page)
    func fetchListings(
        limit: Int = 20,
        after lastDocument: DocumentSnapshot? = nil
    ) async throws -> ([FoodListing], DocumentSnapshot?) {
        var query = db.collection("listings")
            .whereField("isAvailable", isEqualTo: true)
            .whereField("expiresAt", isGreaterThan: Timestamp(date: Date()))
            .order(by: "expiresAt")
            .order(by: "createdAt", descending: true)
            .limit(to: limit)

        if let lastDoc = lastDocument {
            query = query.start(afterDocument: lastDoc)
        }

        let snapshot = try await query.getDocuments()
        let listings = snapshot.documents.compactMap { try? $0.data(as: FoodListing.self) }
        return (listings, snapshot.documents.last)
    }

    // Real-time listener for feed (using Combine)
    func listingsPublisher() -> AnyPublisher<[FoodListing], Never> {
        let subject = PassthroughSubject<[FoodListing], Never>()

        db.collection("listings")
            .whereField("isAvailable", isEqualTo: true)
            .whereField("expiresAt", isGreaterThan: Timestamp(date: Date()))
            .order(by: "expiresAt")
            .limit(to: 50)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let listings = documents.compactMap { try? $0.data(as: FoodListing.self) }
                subject.send(listings)
            }

        return subject.eraseToAnyPublisher()
    }

    // Mark listing as taken
    func markListingTaken(listingId: String) async throws {
        try await db.collection("listings").document(listingId)
            .updateData(["isAvailable": false])
    }

    // ─── MESSAGING ────────────────────────────────────────────

    // Get or create a conversation
    func getOrCreateConversation(
        listingId: String,
        donorId: String,
        recipientId: String
    ) async throws -> PSConversation {
        // Check if conversation already exists
        let existing = try await db.collection("conversations")
            .whereField("listingId", isEqualTo: listingId)
            .whereField("participantIds", arrayContains: recipientId)
            .getDocuments()

        if let doc = existing.documents.first,
           let conversation = try? doc.data(as: PSConversation.self) {
            return conversation
        }

        // Create new conversation
        let conversationId = db.collection("conversations").document().documentID
        let conversation = PSConversation(
            id: conversationId,
            listingId: listingId,
            participantIds: [donorId, recipientId],
            lastMessage: nil,
            lastMessageAt: nil,
            unreadCount: 0
        )

        let data = try Firestore.Encoder().encode(conversation)
        try await db.collection("conversations").document(conversationId).setData(data)
        return conversation
    }

    // Send a message
    func sendMessage(
        conversationId: String,
        text: String
    ) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid else {
            throw AppError.notAuthenticated
        }

        let messageId = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .document().documentID

        let message = PSMessage(
            id: messageId,
            senderId: currentUID,
            conversationId: conversationId,
            text: text,
            audioURL: nil,
            isRead: false,
            createdAt: Date()
        )

        let messageData = try Firestore.Encoder().encode(message)

        // Batch write: add message + update conversation's lastMessage
        let batch = db.batch()
        let messageRef = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .document(messageId)
        batch.setData(messageData, forDocument: messageRef)

        let conversationRef = db.collection("conversations").document(conversationId)
        batch.updateData([
            "lastMessage": text,
            "lastMessageAt": Timestamp(date: Date()),
            "unreadCount": FieldValue.increment(Int64(1))
        ], forDocument: conversationRef)

        try await batch.commit()
    }

    // Real-time messages listener
    func messagesPublisher(conversationId: String) -> AnyPublisher<[PSMessage], Never> {
        let subject = PassthroughSubject<[PSMessage], Never>()

        db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "createdAt")
            .addSnapshotListener { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                let messages = documents.compactMap { try? $0.data(as: PSMessage.self) }
                subject.send(messages)
            }

        return subject.eraseToAnyPublisher()
    }

    // ─── USERS ────────────────────────────────────────────────

    func fetchUser(uid: String) async throws -> PSUser {
        let doc = try await db.collection("users").document(uid).getDocument()
        guard let user = try? doc.data(as: PSUser.self) else {
            throw AppError.documentNotFound
        }
        return user
    }
}
```

---

### 3.7 Firebase Storage — Image Upload

```swift
// Services/Firebase/StorageService.swift
import Foundation
import FirebaseStorage
import UIKit

enum StorageError: LocalizedError {
    case compressionFailed
    case uploadFailed(String)
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .compressionFailed: return "Could not process image. Please try a different photo."
        case .uploadFailed(let msg): return "Upload failed: \(msg)"
        case .invalidURL: return "Could not get download URL."
        }
    }
}

final class StorageService {
    static let shared = StorageService()
    private init() {}

    private let storage = Storage.storage()

    // Upload food photo — returns download URL string
    func uploadFoodImage(
        _ image: UIImage,
        listingId: String
    ) async throws -> String {
        // Step 1: Compress (CRITICAL for Bangladesh's mobile data costs)
        guard let compressed = compressImage(image, maxSizeKB: 500) else {
            throw StorageError.compressionFailed
        }

        // Step 2: Create storage reference
        let filename = "\(UUID().uuidString).jpg"
        let ref = storage.reference().child("listings/\(listingId)/\(filename)")

        // Step 3: Set metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        // Step 4: Upload
        do {
            _ = try await ref.putDataAsync(compressed, metadata: metadata)
        } catch {
            throw StorageError.uploadFailed(error.localizedDescription)
        }

        // Step 5: Get download URL
        guard let url = try? await ref.downloadURL() else {
            throw StorageError.invalidURL
        }

        return url.absoluteString
    }

    // Upload profile photo
    func uploadProfileImage(_ image: UIImage, userId: String) async throws -> String {
        guard let compressed = compressImage(image, maxSizeKB: 200) else {
            throw StorageError.compressionFailed
        }

        let ref = storage.reference().child("profiles/\(userId)/avatar.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(compressed, metadata: metadata)
        guard let url = try? await ref.downloadURL() else {
            throw StorageError.invalidURL
        }
        return url.absoluteString
    }

    // Compress image to stay within size limit
    private func compressImage(_ image: UIImage, maxSizeKB: Int) -> Data? {
        let maxBytes = maxSizeKB * 1024
        var compression: CGFloat = 0.8

        // First try at target size
        guard var data = image.jpegData(compressionQuality: compression) else { return nil }

        // Reduce quality until under size limit
        while data.count > maxBytes && compression > 0.1 {
            compression -= 0.1
            data = image.jpegData(compressionQuality: compression) ?? data
        }

        // If still too large, resize the image
        if data.count > maxBytes {
            let scale = sqrt(Double(maxBytes) / Double(data.count))
            let newSize = CGSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resized = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resized?.jpegData(compressionQuality: 0.7)
        }

        return data
    }
}
```

---

### 3.8 Common Firebase Mistakes & How to Avoid Them

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| `GoogleService-Info.plist` in wrong folder | `FirebaseApp.configure()` silently fails; auth never works | Place at root of app target, not in subfolder |
| Bundle ID mismatch between Xcode and Firebase Console | Auth never works; sign-in hangs indefinitely | Must match exactly. Check in Project → Target → General |
| Not calling `FirebaseApp.configure()` first in AppDelegate | Crash on first Firebase call | It must be the VERY FIRST line in `didFinishLaunchingWithOptions` |
| Accessing Firestore before auth | Security rules reject all reads | Always check `Auth.auth().currentUser != nil` |
| Missing Firestore indexes for compound queries | Query crashes with error in console | Create indexes via Firebase console link in error message |
| Not handling offline state | App appears frozen with no error shown | Always add `.getDocument(source: .serverAndCache)` and handle `unavailable` errors |
| Storing sensitive user data without security rules | Anyone can read all user data | Write security rules BEFORE writing any real data |
| Not batching related Firestore writes | Partial updates on network failure | Use `WriteBatch` for writes that must succeed together |
| Using `.addSnapshotListener` without removing it | Memory leak; listener fires after view dismissed | Store the listener handle and call `listenerHandle.remove()` in `deinit` |
| Weak password or invalid email format | Registration fails with unclear error | Validate email format client-side; enforce minimum 6-character password |

---

## Section 4 — API & Service Layer Design <a name="section-4"></a>

### 4.1 Service Layer Architecture

```swift
// All services follow this pattern:
// - Protocol defines the contract (enables testing/mocking)
// - Concrete class implements Firebase calls
// - ViewModels receive the protocol type (not the concrete class)

protocol ListingServiceProtocol {
    func createListing(_ listing: FoodListing) async throws
    func fetchListings(limit: Int, after: DocumentSnapshot?) async throws -> ([FoodListing], DocumentSnapshot?)
    func markListingTaken(listingId: String) async throws
}

// In ViewModels — inject service via initializer
final class FeedViewModel: ObservableObject {
    private let listingService: ListingServiceProtocol
    private let locationService: LocationService

    // Production init
    init(
        listingService: ListingServiceProtocol = FirestoreService.shared,
        locationService: LocationService = .shared
    ) {
        self.listingService = listingService
        self.locationService = locationService
        loadListings()
    }
}
```

### 4.2 Async/Await Pattern — Standard Template

```swift
// ALWAYS follow this pattern in ViewModels:
@MainActor
final class FeedViewModel: ObservableObject {
    @Published var listings: [FoodListing] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMorePages = true

    private var lastDocument: DocumentSnapshot?
    private var cancellables = Set<AnyCancellable>()

    func loadListings() {
        // Prevent duplicate calls
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let (newListings, lastDoc) = try await FirestoreService.shared
                    .fetchListings(limit: 20, after: lastDocument)

                // Must update UI on main thread (guaranteed by @MainActor)
                self.listings.append(contentsOf: newListings)
                self.lastDocument = lastDoc
                self.hasMorePages = newListings.count == 20
            } catch let error as AppError {
                self.errorMessage = error.errorDescription
            } catch {
                self.errorMessage = "Unexpected error. Please try again."
            }
            self.isLoading = false
        }
    }

    // Load more when user scrolls to bottom
    func loadMoreIfNeeded(currentItem: FoodListing) {
        let thresholdIndex = listings.index(listings.endIndex, offsetBy: -5)
        if listings.firstIndex(where: { $0.id == currentItem.id }) == thresholdIndex {
            loadListings()
        }
    }

    func refresh() async {
        listings = []
        lastDocument = nil
        hasMorePages = true
        loadListings()
    }
}
```

### 4.3 Error Handling Pattern

```swift
// Components/ErrorBannerView.swift
struct ErrorBannerView: View {
    let message: String
    @Binding var isPresented: Bool

    var body: some View {
        if isPresented {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.white)
                Text(message)
                    .font(.caption)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
            .padding(12)
            .background(Color.red.opacity(0.9))
            .cornerRadius(10)
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                // Auto-dismiss after 4 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation { isPresented = false }
                }
            }
        }
    }
}

// Usage in any View:
struct FeedView: View {
    @StateObject var viewModel = FeedViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            // Main content
            listingsContent

            // Error banner overlays at top
            ErrorBannerView(
                message: viewModel.errorMessage ?? "",
                isPresented: .init(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            )
        }
    }
}
```

### 4.4 Location Service

```swift
// Services/Location/LocationService.swift
import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()

    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // Hundred meters is sufficient for neighborhood-level matching
        // and saves battery vs kCLLocationAccuracyBest
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        guard authorizationStatus == .authorizedWhenInUse ||
              authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        locationManager.startUpdatingLocation()
    }

    // Calculate distance between two coordinates in meters
    func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }

    // Filter listings within radius (in kilometers)
    func listingsWithinRadius(
        _ listings: [FoodListing],
        radiusKM: Double
    ) -> [FoodListing] {
        guard let location = currentLocation else { return listings }
        return listings.filter { listing in
            let listingCoord = CLLocationCoordinate2D(
                latitude: listing.latitude,
                longitude: listing.longitude
            )
            let dist = distance(
                from: location.coordinate,
                to: listingCoord
            )
            return dist <= (radiusKM * 1000)
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Only update if moved more than 100 meters (saves battery)
        if let current = currentLocation,
           current.distance(from: location) < 100 { return }
        self.currentLocation = location
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error.localizedDescription
    }
}
```

---

## Section 5 — GitHub Workflow & Contribution Strategy <a name="section-5"></a>

### 5.1 Initial Repository Setup (Developer A — Do Once)

```bash
# Step 1: Create repo on GitHub
# Go to github.com → New Repository
# Name: plateshare-bd
# Private: YES (contains iOS project files)
# Initialize with README: YES
# .gitignore: Swift (select from dropdown)

# Step 2: Clone and set up locally
git clone https://github.com/yourteam/plateshare-bd.git
cd plateshare-bd

# Step 3: Create the Xcode project inside this folder
# File → New → Project → iOS → App
# Product Name: PlateShareBD
# Team: your Apple Developer Team (or Personal Team)
# Organization Identifier: com.yourteam
# Interface: SwiftUI
# Language: Swift
# UNCHECK "Include Tests" for now
# UNCHECK "Use Core Data"
# SAVE INSIDE the cloned plateshare-bd folder

# Step 4: Add .gitignore entries
cat >> .gitignore << 'EOF'

# Firebase
PlateShareBD/GoogleService-Info.plist
*.env

# Xcode
*.xccheckout
*.moved-aside
DerivedData/
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata/
*.xcscmblueprint
*.xcodeproj/project.xcworkspace
build/
*.hmap
*.ipa
EOF

# Step 5: Initial commit
git add .
git commit -m "chore: initialize Xcode project with SwiftUI template"

# Step 6: Set up branch structure
git checkout -b develop
git push origin develop

git checkout -b feature/dev-a/authentication
git push origin feature/dev-a/authentication

# Step 7: Push main with README
git checkout main
git push origin main

# Step 8: Set develop as default branch
# GitHub → Repository → Settings → Branches → Default branch → develop

# Step 9: Share repo URL and invite teammates
# GitHub → Settings → Collaborators → Add teammates by username
```

### 5.2 Branch Naming Convention

```
main                         ← production-ready only. NEVER commit directly.
develop                      ← integration branch. All features merge here first.
feature/dev-a/authentication ← Developer A's authentication module
feature/dev-a/profile        ← Developer A's profile module
feature/dev-b/feed           ← Developer B's feed module
feature/dev-b/map            ← Developer B's map module
feature/dev-c/messaging      ← Developer C's messaging module
feature/dev-c/notifications  ← Developer C's notifications module
hotfix/crash-on-login        ← Emergency bug fix. Branch from develop.
release/v1.0.0               ← Release branch for final polish
```

### 5.3 Commit Message Standard

```
Format: <type>(<scope>): <imperative description>

Types:
  feat     → new feature
  fix      → bug fix
  chore    → setup, config, build changes
  refactor → code restructure (no behavior change)
  test     → adding tests
  docs     → documentation
  style    → formatting only
  ui       → visual/UI changes

Examples:
  feat(auth): implement Firebase Email/Password authentication
  feat(feed): add real-time listings listener with Combine
  feat(map): integrate MapKit with custom listing annotations
  fix(auth): handle empty email/password input validation
  chore(firebase): add FirebaseFirestore to SPM dependencies
  refactor(services): extract image compression to ImageCompressor helper
  ui(feed): add skeleton loading card animation
  docs(readme): add build instructions for new team members
```

### 5.4 Step-by-Step Contribution Flow for All 3 Members

#### Developer A (Authentication + Profile) — Exact Git Steps

```bash
# ── Day 1: Setup ──────────────────────────────────────────────
git clone https://github.com/yourteam/plateshare-bd.git
cd plateshare-bd
git checkout develop
git pull origin develop
git checkout -b feature/dev-a/authentication

# Create your folder structure
mkdir -p PlateShareBD/Core/Authentication/{Views,ViewModels,Models}
mkdir -p PlateShareBD/Services/Firebase
mkdir -p PlateShareBD/Models
mkdir -p PlateShareBD/Utilities/{Extensions,Constants,Helpers}
mkdir -p PlateShareBD/Components

# ── During development: commit frequently ─────────────────────
git add PlateShareBD/Services/Firebase/AuthService.swift
git commit -m "feat(auth): add AuthService with email/password support"

git add PlateShareBD/Core/Authentication/ViewModels/AuthViewModel.swift
git commit -m "feat(auth): implement AuthViewModel with auth state management"

git add PlateShareBD/Core/Authentication/Views/
git commit -m "ui(auth): add WelcomeView, EmailAuthView, ProfileSetupView"

# ── Stay synced with develop daily ────────────────────────────
git fetch origin
git rebase origin/develop
# If conflicts: fix them, then:
git rebase --continue

# ── When auth module is complete: open Pull Request ───────────
git push origin feature/dev-a/authentication

# On GitHub: New Pull Request
# Base: develop ← Compare: feature/dev-a/authentication
# Title: "feat(auth): complete authentication module with email/password and profile setup"
# Description: List what was done, what was tested, any known issues
# Request review from both teammates
```

#### Developer B (Feed + Map) — Exact Git Steps

```bash
# ── Day 1 ─────────────────────────────────────────────────────
git clone https://github.com/yourteam/plateshare-bd.git
cd plateshare-bd
git checkout develop
git pull origin develop
git checkout -b feature/dev-b/feed

mkdir -p PlateShareBD/Core/Feed/{Views,ViewModels}
mkdir -p PlateShareBD/Core/CreateListing/{Views,ViewModels}
mkdir -p PlateShareBD/Core/Map/{Views,ViewModels}
mkdir -p PlateShareBD/Services/{Firebase,Location}

# IMPORTANT: Dev B works on FoodListingModel.swift and FirestoreService
# COORDINATE with Dev A to avoid conflicts on shared files

# ── Development commits ────────────────────────────────────────
git add PlateShareBD/Models/FoodListingModel.swift
git commit -m "feat(models): define FoodListing model with FoodCategory enum"

git add PlateShareBD/Services/Firebase/FirestoreService.swift
git commit -m "feat(firestore): add createListing and fetchListings methods"

git add PlateShareBD/Core/Feed/
git commit -m "feat(feed): implement FeedView with real-time listing cards"

git add PlateShareBD/Core/Map/
git commit -m "feat(map): add MapKit view with listing annotations and radius filter"

git add PlateShareBD/Core/CreateListing/
git commit -m "feat(listings): implement CreateListingView with photo upload"

# ── Sync with develop and other devs' merged work ─────────────
git fetch origin develop
git rebase origin/develop

# ── Push and open PR when done ────────────────────────────────
git push origin feature/dev-b/feed
# GitHub: PR feature/dev-b/feed → develop
```

#### Developer C (Messaging + Notifications) — Exact Git Steps

```bash
# ── Day 1 ─────────────────────────────────────────────────────
git clone https://github.com/yourteam/plateshare-bd.git
cd plateshare-bd
git checkout develop
git pull origin develop
git checkout -b feature/dev-c/messaging

mkdir -p PlateShareBD/Core/Messaging/{Views,ViewModels}
mkdir -p PlateShareBD/Services/{Firebase,Notifications}

# Dev C builds on FirestoreService — use the MessagingService extension pattern
# to avoid direct conflicts with Dev B's FirestoreService.swift

# ── Development commits ────────────────────────────────────────
git add PlateShareBD/Models/MessageModel.swift PlateShareBD/Models/ConversationModel.swift
git commit -m "feat(models): add PSMessage and PSConversation models"

git add PlateShareBD/Services/Firebase/MessagingService.swift
git commit -m "feat(messaging): add sendMessage and real-time listener via Firestore"

git add PlateShareBD/Core/Messaging/
git commit -m "feat(messaging): implement ConversationListView and ChatView"

git add PlateShareBD/Services/Notifications/FCMService.swift
git commit -m "feat(notifications): implement FCM token management and notification handling"

# ── Sync + PR ─────────────────────────────────────────────────
git fetch origin develop
git rebase origin/develop
git push origin feature/dev-c/messaging
# GitHub: PR feature/dev-c/messaging → develop
```

### 5.5 Achieving 50–60% Equal Contribution

The key is **commit count** and **lines of code** showing on the GitHub Insights page.

```
Developer A:
  - AuthService.swift (all Firebase Email/Password Auth)
  - AuthViewModel.swift
  - WelcomeView, EmailAuthView, ProfileSetupView
  - ProfileViewModel.swift
  - PSUser model
  - UserDefaults/Keychain helpers
  ≈ 600–800 lines of code, 12–18 commits

Developer B:
  - FoodListingModel.swift
  - FirestoreService.swift (listings CRUD)
  - StorageService.swift (image upload)
  - FeedViewModel.swift
  - FeedView, ListingCardView, ListingDetailView, CreateListingView
  - MapViewModel.swift, MapView.swift
  - LocationService.swift
  ≈ 700–900 lines, 15–20 commits

Developer C:
  - MessageModel.swift, ConversationModel.swift
  - MessagingService.swift (Firestore realtime)
  - ChatViewModel.swift, ConversationListViewModel.swift
  - ChatView.swift, ConversationListView.swift, MessageBubbleView.swift
  - FCMService.swift, NotificationManager.swift
  - Reusable Components (PSButton, PSTextField, PSAvatarView, LoadingView)
  ≈ 600–800 lines, 12–18 commits

All Three (final sprint):
  - Localization files (each adds 40+ strings to Localizable.strings)
  - README.md sections
  - AppConstants, FirestoreKeys, ColorPalette
```

### 5.6 Safe Merge Strategy

```bash
# ── Merge Order (follow this exact order to avoid conflicts) ──

# 1. Merge Dev A (Authentication) first — others depend on UserModel and AuthService
git checkout develop
git pull origin develop
git merge --no-ff feature/dev-a/authentication
# "The --no-ff flag creates a merge commit even if fast-forward is possible.
#  This preserves branch history in git log, proving team collaboration."
git push origin develop

# 2. Merge Dev B (Feed + Map) second
git checkout develop
git pull origin develop
git merge --no-ff feature/dev-b/feed
# Resolve any conflicts — most likely in FirestoreService.swift
git push origin develop

# 3. Merge Dev C (Messaging) last
git checkout develop
git pull origin develop
git merge --no-ff feature/dev-c/messaging
git push origin develop

# 4. Final: merge develop → main for submission
git checkout main
git merge --no-ff develop
git tag -a v1.0.0 -m "PlateShare BD v1.0.0 — CSE Project Submission"
git push origin main --tags
```

### 5.7 Resolving Merge Conflicts

```bash
# When a conflict occurs during merge:

# 1. Git will list conflicted files
git status
# Look for "both modified: ..."

# 2. Open conflicted file in Xcode or VS Code
# You'll see:
# <<<<<<< HEAD (your develop branch)
#   your code
# =======
#   incoming code
# >>>>>>> feature/dev-b/feed

# 3. Keep the correct version (usually combine both)
# Delete the conflict markers (<<<, ===, >>>)

# 4. Mark as resolved and continue
git add PlateShareBD/Services/Firebase/FirestoreService.swift
git commit -m "merge: resolve FirestoreService conflict between dev-a and dev-b"

# PREVENTION: Coordinate which files each developer owns
# FirestoreService.swift → Dev B owns it
# Dev C creates MessagingService.swift (separate file) instead of editing FirestoreService
```

---

## Section 6 — One-Night macOS Execution Plan <a name="section-6"></a>

> **Assumptions:** You have macOS access for approximately 8 hours. Swift Package Manager works. Simulator is available.

### 6.1 Pre-Night Preparation (Do This Before You Sit Down)

- [ ] Firebase project created and `GoogleService-Info.plist` downloaded
- [ ] GitHub repository created, teammates added, `.gitignore` configured
- [ ] All teammates have Xcode on their Macs (or you're the sole macOS user)
- [ ] Folder structure template agreed upon (from Section 2.1)
- [ ] Model files typed out in a text editor, ready to paste

### 6.2 Hour-by-Hour Breakdown

```
Hour 0:00–0:30  Project Scaffold
├── Create Xcode project (SwiftUI, iOS 16+, Swift)
├── Add Firebase via SPM (FirebaseAuth, Firestore, Storage, Messaging)
├── Add GoogleService-Info.plist to project root
├── Set up AppDelegate, PlateShareBDApp.swift, ContentView.swift
├── Create the full folder structure (mkdir + empty Swift files)
└── Initial git commit: "chore: initialize project with Firebase SPM"
    Target: App compiles and runs on Simulator ✅

Hour 0:30–1:30  Authentication (Critical Path)
├── Implement PSUser model
├── Implement AuthService (register, signIn, createProfile)
├── Implement AuthViewModel with auth state management
├── Implement WelcomeView, EmailAuthView
├── Implement ProfileSetupView
└── Test: Register and sign in with email/password works ✅
    Commit: "feat(auth): complete email/password authentication flow"

Hour 1:30–2:00  Security Rules + Firestore Setup
├── Write Firestore security rules in Firebase Console
├── Create Firestore indexes
├── Test: authenticated user can read/write ✅
    Commit: "chore(firebase): configure Firestore rules and indexes"

Hour 2:00–3:00  Food Listing Creation
├── Implement FoodListing model
├── Implement StorageService (image upload with compression)
├── Implement CreateListingViewModel
├── Implement CreateListingView with PHPickerViewController
├── Implement FoodCategoryPickerView
└── Test: listing created and appears in Firestore console ✅
    Commit: "feat(listings): implement food listing creation with photo upload"

Hour 3:00–4:00  Feed View (Home Screen)
├── Implement FirestoreService.fetchListings()
├── Implement FirestoreService.listingsPublisher() (real-time)
├── Implement FeedViewModel
├── Implement FeedView with real-time ListingCard grid
├── Implement ListingDetailView
└── Test: listings appear in feed in real-time ✅
    Commit: "feat(feed): implement real-time listings feed with pagination"

Hour 4:00–4:45  Map View
├── Add CoreLocation permissions to Info.plist
├── Implement LocationService
├── Implement MapViewModel
├── Implement MapView with listing pins
├── Add radius filter selector
└── Test: map shows pins for current location ✅
    Commit: "feat(map): add MapKit view with location-based listing pins"

Hour 4:45–5:45  Messaging
├── Implement MessagingService (getOrCreateConversation, sendMessage)
├── Implement ChatViewModel with real-time listener
├── Implement ChatView + MessageBubbleView
├── Implement ConversationListView
├── Wire "Message Donor" button in ListingDetailView
└── Test: send message between two test accounts ✅
    Commit: "feat(messaging): implement real-time in-app messaging"

Hour 5:45–6:15  Push Notifications
├── FCM setup in AppDelegate (already scaffolded)
├── Implement FCMService.updateToken()
├── Test: trigger notification via Firebase Console test message ✅
    Commit: "feat(notifications): implement FCM push notifications"

Hour 6:15–6:45  Navigation + Main Tab View
├── Implement MainTabView with 4 tabs: Feed, Map, Messages, Profile
├── Wire all navigation paths
├── Fix any navigation bugs
└── Test: full user flow end-to-end ✅
    Commit: "feat(navigation): wire MainTabView and all navigation paths"

Hour 6:45–7:15  Localization
├── Create Localizable.strings with all UI strings
├── Create bn.lproj/Localizable.strings with Bangla translations
├── Add language toggle to Profile settings
└── Commit: "feat(i18n): add Bangla/English localization"

Hour 7:15–7:45  Reusable Components + Polish
├── Implement PSButton, PSTextField, LoadingView, ErrorBannerView
├── Implement ColorPalette (green primary, warm secondary)
├── Implement AppConstants, FirestoreKeys
└── Commit: "ui(components): add reusable components and design system"

Hour 7:45–8:00  Final Push + ZIP
├── git push origin feature/dev-a/authentication (or your branch)
├── Create a ZIP of the entire project folder (including .plist)
│   The ZIP is for offline teammates — .gitignore protects GitHub
├── Upload ZIP to Google Drive and share with team
└── Final commit: "chore: project complete v1.0.0-alpha ready for team distribution"
```

### 6.3 Risk Mitigation

| Risk | Probability | Mitigation |
|------|-------------|------------|
| SPM takes too long to download | Medium | Start SPM download first while you set up folder structure |
| Email auth not working | Medium | Verify Email/Password is enabled in Firebase Console → Auth → Sign-in method |
| Simulator crashing on location | Medium | Use fixed test coordinate for Dhaka: lat 23.8103, lng 90.4125 |
| Firestore security rules blocking writes | High | Start with `allow read, write: if true;` during dev, harden at end |
| Merge conflict with teammates later | Low | Each developer owns clearly separate files (see Section 5.4) |
| Running out of time | High | Hours 0–4 (auth + listings + feed) = minimum viable app. Stop there if needed. |

### 6.4 Minimum Viable Progress (If Only 4 Hours Available)

If you only have 4 hours, complete **Hours 0–4** only. This gives you:
- Working authentication (Firebase Email/Password)
- Working food listing creation
- Working real-time feed
- **This is enough to demonstrate the core concept and passes the basic evaluation.**

Everything else can be built by teammates from the ZIP without macOS, using Swift Playgrounds on iPad or Xcode on any Mac they can access later.

---

## Section 7 — Post-ZIP Collaboration Strategy <a name="section-7"></a>

### 7.1 Distributing Work After ZIP

The person with macOS creates the ZIP including:
```bash
# Create ZIP for distribution (include everything EXCEPT build artifacts)
cd ..
zip -r PlateShareBD_v1_alpha.zip plateshare-bd/ \
  --exclude "*/DerivedData/*" \
  --exclude "*/.git/*" \
  --exclude "*/xcuserdata/*" \
  --exclude "*/build/*"
```

Upload to Google Drive. Share with both teammates.

> ⚠️ **This ZIP contains the `GoogleService-Info.plist`. Share ONLY with trusted teammates. Never upload to any public location.**

### 7.2 What Teammates Can Do Without macOS

#### Option A — Use iPad with Swift Playgrounds (Limited but workable)

Swift Playgrounds 4 on iPad supports SwiftUI app development. Teammates can:
- Write and test SwiftUI views
- Edit ViewModels
- Edit model files
- Run on a connected iPhone

They CANNOT:
- Add SPM packages (Firebase is already in the project)
- Edit build settings
- Run on Simulator

**Workflow for iPad developer:**
1. Download ZIP → extract on iPad using Files app
2. Open `.xcodeproj` in Swift Playgrounds
3. Make changes → test on connected iPhone
4. Email changed files back or push via Working Copy (Git app for iPad)

#### Option B — Use any Mac with Xcode (Best option)

If a teammate has access to any Mac (university lab, friend's Mac, MacBook for a day):
1. Clone the GitHub repo: `git clone https://github.com/yourteam/plateshare-bd.git`
2. Get `GoogleService-Info.plist` from the person who has it (via WhatsApp/Drive)
3. Place `.plist` at root of app target
4. Open `.xcodeproj` in Xcode
5. Work on assigned branch

#### Option C — Code-Only Contribution (No Build Required)

Teammates can write Swift files in VS Code, Cursor, or any text editor without building. They push to their feature branch, and the macOS developer merges and tests.

This is valid for:
- Writing ViewModels
- Writing model files  
- Writing service layer code
- Writing Localizable.strings
- Writing README documentation

### 7.3 Branch-Wise Contribution After ZIP Distribution

```
After ZIP distributed on Night 1:

Developer A (has macOS access):
  ✅ Complete auth flow tested and working on simulator
  → Continue: feature/dev-a/profile (ProfileView, MyListingsView, RatingView)
  → Use macOS throughout week

Developer B (may have intermittent macOS):
  → Checkout feature/dev-b/feed from GitHub
  → Copy GoogleService-Info.plist from A (via message)
  → Complete: FeedView polish, MapView, CreateListingView
  → Test on real device when possible

Developer C (no macOS initially):
  → Write MessagingService.swift, ChatViewModel.swift in VS Code
  → Write all Messaging Views in VS Code (SwiftUI syntax is just Swift)
  → Push to feature/dev-c/messaging
  → Developer A pulls the branch, tests, and reports back any compile errors
  → C fixes and pushes again
  → This cycle takes 1–2 hours per round but works
```

### 7.4 Weekly Sync Strategy

```
Daily sync (15 minutes, WhatsApp/Discord):
  - What did you push today? Branch name + commit message
  - Any compile errors in my files?
  - Any Firestore rule issues?

Every 2 days:
  - Developer A opens PRs from all branches into develop
  - Does a merge + build test
  - Reports any issues in group chat

End of week:
  - All features merged to develop
  - One final review pass by all three on the same screen
  - developer → main
  - Tag release
```

---

## Section 8 — iOS-Specific Best Practices <a name="section-8"></a>

### 8.1 SwiftUI Performance Dos and Don'ts

```swift
// ❌ DON'T: Compute heavy work inside view body
struct FeedView: View {
    var listings: [FoodListing]
    var body: some View {
        // BAD: this runs on EVERY re-render
        let nearby = listings.filter { /* complex distance calc */ }
        List(nearby) { ListingCardView(listing: $0) }
    }
}

// ✅ DO: Compute in ViewModel, publish result
@MainActor final class FeedViewModel: ObservableObject {
    @Published var nearbyListings: [FoodListing] = []  // pre-filtered
}

// ❌ DON'T: Load images synchronously
AsyncImage(url: URL(string: imageURL)) { image in
    image.resizable()
} placeholder: {
    Color.gray  // This is fine
}

// ✅ DO: Use AsyncImage with proper loading states
CachedAsyncImage(url: URL(string: imageURL))  // use SDWebImageSwiftUI or similar

// ❌ DON'T: Hold @StateObject at the wrong level
struct ParentView: View {
    var body: some View {
        ChildView()  // Child creates its own @StateObject
    }
}
struct ChildView: View {
    @StateObject var vm = HeavyViewModel()  // Created EVERY time ChildView appears
}

// ✅ DO: Hoist @StateObject to where the data lives
struct ParentView: View {
    @StateObject var vm = HeavyViewModel()  // Lives as long as ParentView
    var body: some View {
        ChildView(vm: vm)
    }
}
struct ChildView: View {
    @ObservedObject var vm: HeavyViewModel  // Receives, doesn't own
}

// ❌ DON'T: Avoid equatable on complex views
struct ListingCardView: View {
    let listing: FoodListing
    // SwiftUI will re-render this for every parent update
}

// ✅ DO: Use Equatable to prevent unnecessary re-renders
struct ListingCardView: View, Equatable {
    let listing: FoodListing
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.listing.id == rhs.listing.id &&
        lhs.listing.isAvailable == rhs.listing.isAvailable
    }
}
```

### 8.2 State Management Dos and Don'ts

```swift
// Understanding which property wrapper to use:

// @State    → Local UI state (is button pressed, is sheet showing)
// @Binding  → Pass state DOWN to child who needs to modify it
// @StateObject → ViewModel owned by THIS view. Use for root views.
// @ObservedObject → ViewModel owned ELSEWHERE. Use for child views.
// @EnvironmentObject → Global state passed via .environmentObject()
// @Environment → System values (color scheme, locale, etc.)

// ✅ Correct usage:
struct FeedView: View {
    @StateObject var viewModel = FeedViewModel()     // I OWN this
    @EnvironmentObject var authVM: AuthViewModel     // GLOBAL context
    @State private var isFilterShowing = false       // LOCAL UI state
    @State private var selectedRadius: Double = 2.0  // LOCAL UI state
}

struct ListingDetailView: View {
    @ObservedObject var viewModel: ListingDetailViewModel  // PASSED to me
    @Binding var isPresented: Bool                          // Parent owns this
}

// ❌ DON'T: Mutate @Published from background thread
func fetchListings() {
    Task.detached {  // This runs off main thread
        let listings = try await service.fetchListings()
        self.listings = listings  // CRASH: UI update off main thread
    }
}

// ✅ DO: Ensure UI updates happen on main thread
func fetchListings() {
    Task { @MainActor in  // Guaranteed main thread
        let listings = try await service.fetchListings()
        self.listings = listings  // Safe
    }
}
// OR: Annotate the whole ViewModel with @MainActor
@MainActor final class FeedViewModel: ObservableObject { ... }
```

### 8.3 Architecture Decisions

```swift
// ── Pattern: ViewModel Lifecycle Management ─────────────────
// Always clean up Firestore listeners and Combine subscriptions

final class ChatViewModel: ObservableObject {
    private var messagesListener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()

    func startListening(conversationId: String) {
        // Stop any previous listener first
        messagesListener?.remove()

        messagesListener = Firestore.firestore()
            .collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "createdAt")
            .addSnapshotListener { [weak self] snapshot, _ in
                // Always use [weak self] to prevent retain cycles
                guard let self = self,
                      let documents = snapshot?.documents else { return }
                Task { @MainActor in
                    self.messages = documents.compactMap {
                        try? $0.data(as: PSMessage.self)
                    }
                }
            }
    }

    deinit {
        messagesListener?.remove()  // CRITICAL: prevent memory leak
        cancellables.removeAll()
    }
}

// ── Pattern: Dependency Injection for Testability ────────────
// Every ViewModel accepts its services via init parameters
// Default values mean production code doesn't change
// Test code can inject mocks

final class FeedViewModel: ObservableObject {
    private let firestoreService: FirestoreService
    private let locationService: LocationService

    init(
        firestoreService: FirestoreService = .shared,
        locationService: LocationService = .shared
    ) {
        self.firestoreService = firestoreService
        self.locationService = locationService
    }
}

// ── Pattern: Info.plist Required Entries ─────────────────────
// Add these to Info.plist or you'll get crashes/rejections:
/*
NSLocationWhenInUseUsageDescription
  → "PlateShare uses your location to show nearby food listings."

NSPhotoLibraryUsageDescription
  → "PlateShare needs photo access to share food photos."

NSCameraUsageDescription
  → "PlateShare needs camera access to take food photos."

UIBackgroundModes
  → remote-notification (for FCM background notifications)
*/
```

### 8.4 MapKit Integration

```swift
// Core/Map/Views/MapView.swift
import SwiftUI
import MapKit

struct MapView: View {
    @StateObject var viewModel = MapViewModel()
    @State private var selectedListing: FoodListing?
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $cameraPosition, selection: $selectedListing) {
            // User location
            UserAnnotation()

            // Food listing pins
            ForEach(viewModel.filteredListings) { listing in
                Annotation(
                    listing.title,
                    coordinate: CLLocationCoordinate2D(
                        latitude: listing.latitude,
                        longitude: listing.longitude
                    ),
                    anchor: .bottom
                ) {
                    ListingMapPin(listing: listing)
                        .onTapGesture {
                            selectedListing = listing
                        }
                }
            }

            // Radius circle
            if let userLocation = viewModel.userLocation {
                MapCircle(
                    center: userLocation,
                    radius: viewModel.selectedRadiusKM * 1000
                )
                .foregroundStyle(.green.opacity(0.1))
                .stroke(.green.opacity(0.4), lineWidth: 2)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .safeAreaInset(edge: .bottom) {
            RadiusSelector(selectedRadius: $viewModel.selectedRadiusKM)
                .padding()
                .background(.ultraThinMaterial)
        }
        .sheet(item: $selectedListing) { listing in
            ListingDetailView(listing: listing)
                .presentationDetents([.medium, .large])
        }
        .onAppear {
            viewModel.requestLocationAndLoad()
        }
    }
}

struct ListingMapPin: View {
    let listing: FoodListing

    var body: some View {
        ZStack {
            Circle()
                .fill(.green)
                .frame(width: 40, height: 40)
            Text(listing.category.emoji)
                .font(.system(size: 20))
        }
        .shadow(radius: 3)
    }
}
```

---

## Section 9 — Final Polish Checklist <a name="section-9"></a>

### 9.1 UI/UX Refinement

#### Design Tokens (Single Source of Truth)

All design values live in `ColorPalette.swift`. **Use semantic system colors** for
Dark Mode support — never raw hex except for brand accent colours.

```swift
// Utilities/Constants/ColorPalette.swift — CORRECTED for Dark Mode

import SwiftUI

enum ColorPalette {
    // Brand accent (same in both modes)
    static let psGreen        = Color(hex: "2ECC71")
    static let psGreenDark    = Color(hex: "27AE60")
    static let psOrange       = Color(hex: "F39C12")
    static let psRed          = Color(hex: "E74C3C")

    // Semantic backgrounds — adapt automatically
    static let psBgPrimary    = Color(.systemBackground)       // white / black
    static let psBgSecondary  = Color(.secondarySystemBackground) // light gray / dark gray
    static let psBgCard       = Color(.secondarySystemGroupedBackground)

    // Semantic text
    static let psTextPrimary  = Color(.label)                  // black / white
    static let psTextSecondary = Color(.secondaryLabel)

    // Semantic fills
    static let psFieldBg      = Color(.systemGray6)
    static let psDivider      = Color(.separator)
}
```

> **Rule:** Never use `Color.white`, `Color.black` or raw `Color(hex:)` for
> backgrounds/text. Always use the semantic keys above so the app works in
> both Light and Dark Mode without checking `colorScheme`.

```
Design System:
  ✅ ColorPalette uses semantic system colors for backgrounds and text
  ✅ Brand accent colors (psGreen, psOrange) are the ONLY hardcoded hex values
  ✅ Dark Mode automatically supported via Color(.systemBackground) etc.
  ✅ All padding values use multiples of 4 (8, 12, 16, 24)
  ✅ All corner radii consistent (8 for cards, 12 for sheets, 24 for buttons)
  ✅ Loading states on EVERY async action (never show blank screen)
  ✅ Error states on EVERY async action (never fail silently)
  ✅ Empty states with illustration (no food near you = friendly message)
  ✅ PSButton, PSTextField, PSAvatarView, PSBadgeView used consistently (no one-off styles)

Accessibility:
  ✅ All images have .accessibilityLabel()
  ✅ Tappable areas are minimum 44×44 points
  ✅ Dynamic Type support (use .font(.body) not .font(.system(size: 14)))
  ✅ VoiceOver tested on at least main screens

Bangla Localization:
  ✅ All UI strings using NSLocalizedString or Text("key") with strings catalog
  ✅ Food category names display in Bangla when language is "bn"
  ✅ Language toggle in Profile → Settings persists across app restarts
  ✅ Bangla keyboard appears automatically in message input
  ✅ No hardcoded English text visible in UI

Splash Screen:
  ✅ LaunchScreen.storyboard has logo centered
  ✅ App icon set in Assets.xcassets/AppIcon
    Required sizes: 1024×1024 (App Store), 180×180, 120×120, 87×87, 60×60
    Use appicon.co to generate all sizes from one 1024×1024 image
```

### 9.2 Code Quality

```
Architecture:
  ✅ No Firebase imports in any View file
  ✅ No business logic in any View file
  ✅ All @Published properties on ViewModel updated on main thread
  ✅ All Firestore listeners removed in deinit
  ✅ No force-unwraps (!) in production code — use guard/if let
  ✅ No hardcoded strings in code — all in AppConstants or Localizable.strings

Error Handling:
  ✅ Every async call has a do-catch
  ✅ All errors display user-friendly message (not raw Swift error)
  ✅ Loading indicators shown during async operations

Performance:
  ✅ Images compressed before upload (max 500KB)
  ✅ Firestore queries use .limit(to: 20) (never fetch all documents)
  ✅ Map annotations use clustering for >20 pins
  ✅ No unnecessary Firestore reads (don't fetch user profile on every message)

Security:
  ✅ Firestore rules tested: BUYER cannot edit SELLER's listing
  ✅ Firestore rules tested: User cannot read other users' conversations
  ✅ Email addresses not displayed publicly (only area/mohalla shown on listing)
  ✅ GoogleService-Info.plist NOT in git history (check with: git log --all -- "*.plist")
```

### 9.3 Firebase Validation Checklist

```
Firebase Console checks before submission:

Authentication:
  ✅ Authentication → Users shows test accounts created during development
  ✅ Email/Password provider is enabled
  ✅ No unauthorized providers enabled

Firestore:
  ✅ Rules are in production mode (not "allow read, write: if true")
  ✅ All required indexes are built (Status: "Enabled", not "Building")
  ✅ Firestore data visible in console with correct structure
  ✅ No orphaned documents (listings with no valid donorId)

Storage:
  ✅ Storage rules require authentication for uploads
  ✅ Test images uploaded and accessible via download URL
  ✅ Storage bucket not set to "public" by default

Cloud Messaging:
  ✅ FCM tokens visible in user documents in Firestore
  ✅ Test notification sent successfully via Firebase Console
    (Console → Cloud Messaging → Send your first message)

Usage / Billing:
  ✅ Spark (free) plan active (check for unintentional paid features)
  ✅ Daily Firestore reads < 50,000 (well within free tier for demo)
  ✅ Storage used < 1 GB
  ✅ Email/Password Auth used (does NOT require Blaze plan)
  ✅ No Cloud Functions deployed (require Blaze plan)
  ✅ No Realtime Database used (Firestore only)
```

#### Firebase Spark (Free) Plan Limits — Quick Reference

| Service | Free Allowance | Our Expected Usage |
|---------|---------------|-------------------|
| **Auth (Email/Password)** | Unlimited users | < 50 test accounts |
| **Firestore reads** | 50,000 / day | < 5,000 (demo) |
| **Firestore writes** | 20,000 / day | < 1,000 (demo) |
| **Firestore deletes** | 20,000 / day | < 100 (demo) |
| **Firestore storage** | 1 GiB total | < 50 MB |
| **Storage uploads** | 5 GB total | < 200 MB images |
| **Storage downloads** | 1 GB / day | < 100 MB (demo) |
| **FCM (Push)** | Unlimited | Normal usage |

> **Services that require Blaze (paid) and must NOT be used:**
> Phone Auth, Cloud Functions, Extensions, BigQuery export,
> Cloud Run, Scheduled Firestore exports, Hosting custom domain SSL.

### 9.4 Demo Readiness

```
Pre-Demo Setup:
  ✅ 3 test accounts created and logged in on 3 separate devices/simulators:
      - Account "Wedding Host" (SELLER) with 5 food listings created
      - Account "Student" (BUYER) with profile photo set
      - Account "Admin" for showing the system from both sides
  ✅ Test listings have realistic photos (find food photos online)
  ✅ Test listings are within 2km of each other (use same mohalla)
  ✅ At least one conversation exists between "Wedding Host" and "Student"

Demo Script (5 minutes):
  [0:00–0:30] Open app → WelcomeView → Enter email & password → Sign Up → Profile Setup
  [0:30–1:30] Show Feed: real-time listings, filter by category, pull-to-refresh
  [1:30–2:00] Show Map: pins on map, radius selector, tap pin for detail
  [2:00–3:00] Create listing: take photo, fill details, submit → appears on OTHER device's feed
  [3:00–4:00] Show messaging: tap "Message Donor" → send "Is food still available?" → show reply
  [4:00–4:30] Show Profile: donor rating, past listings, language toggle (EN→BN)
  [4:30–5:00] Q&A: Be ready to show Firestore console with live data, GitHub commit history

Talking Points for Demo:
  "We used Firebase Email/Password Auth on the free Spark plan to keep the project
   zero-cost. This avoids the Blaze billing requirement of Phone OTP Auth."

  "Real-time messaging uses Firestore's snapshot listener — when the sender types
   a message, it appears on the recipient's screen within 200ms without any polling."

  "We compress images to 500KB before upload because mobile data is expensive in
   Bangladesh and many users are on limited data plans."

  "The app is fully bilingual — all strings are in Localizable.strings and we
   tested with native Bangla speakers to verify cultural accuracy."
```

### 9.5 README.md Structure

```markdown
# PlateShare Bangladesh 🍽️
> Connect neighbors to share surplus food from weddings and daily meals

## Screenshots
[4 screenshots: Feed, Map, Chat, Profile]

## Features
- Email/Password Authentication (Firebase)
- Real-time food listings with MapKit
- In-app messaging
- Bangla/English bilingual UI

## Architecture
MVVM + Combine + Firebase
[Architecture diagram image]

## Setup Instructions
1. Clone the repository
2. Get `GoogleService-Info.plist` from the team
3. Place it at `PlateShareBD/GoogleService-Info.plist`
4. Open `PlateShareBD.xcodeproj` in Xcode 15+
5. Select a simulator or device
6. Run (⌘+R)

## Firebase Configuration
- Authentication: Email/Password
- Database: Firestore
- Storage: Firebase Storage
- Push: Firebase Cloud Messaging

## Team
| Member | Module | Commits |
|--------|--------|---------|
| Dev A  | Authentication + Profile | XX |
| Dev B  | Feed + Map + Listings | XX |
| Dev C  | Messaging + Notifications | XX |

## Project Structure
[Paste the folder tree from Section 2.1]
```

---

## Quick Reference — Firebase Firestore Keys

```swift
// Utilities/Constants/FirestoreKeys.swift
// Use these constants everywhere — never hardcode collection names

enum FirestoreKeys {
    enum Collections {
        static let users = "users"
        static let listings = "listings"
        static let conversations = "conversations"
        static let messages = "messages"
        static let ratings = "ratings"
    }

    enum UserFields {
        static let id = "id"
        static let displayName = "displayName"
        static let email = "email"
        static let area = "area"
        static let profileImageURL = "profileImageURL"
        static let isVerified = "isVerified"
        static let donorRating = "donorRating"
        static let fcmToken = "fcmToken"
        static let preferredLanguage = "preferredLanguage"
        static let createdAt = "createdAt"
    }

    enum ListingFields {
        static let donorId = "donorId"
        static let isAvailable = "isAvailable"
        static let expiresAt = "expiresAt"
        static let createdAt = "createdAt"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let category = "category"
    }

    enum MessageFields {
        static let senderId = "senderId"
        static let conversationId = "conversationId"
        static let isRead = "isRead"
        static let createdAt = "createdAt"
    }

    enum ConversationFields {
        static let listingId = "listingId"
        static let participantIds = "participantIds"
        static let lastMessage = "lastMessage"
        static let lastMessageAt = "lastMessageAt"
        static let unreadCount = "unreadCount"
    }
}
```

---

## Quick Reference — App Constants

```swift
// Utilities/Constants/AppConstants.swift
enum AppConstants {
    enum Location {
        static let defaultLatitude = 23.8103   // Dhaka, Bangladesh
        static let defaultLongitude = 90.4125
        static let defaultRadiusKM: Double = 2.0
        static let minRadiusKM: Double = 0.5
        static let maxRadiusKM: Double = 5.0
    }

    enum Listing {
        static let maxTitleLength = 100
        static let maxDescriptionLength = 500
        static let maxPhotoCount = 3
        static let maxImageSizeKB = 500
        static let defaultExpiryHours = 6
    }

    enum Pagination {
        static let pageSize = 20
    }

    enum Languages {
        static let english = "en"
        static let bangla = "bn"
    }

    enum UserDefaults {
        static let preferredLanguageKey = "preferredLanguage"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
}
```

---

*Document Version 1.0 | PlateShare Bangladesh | CSE iOS Project | Blueprint by Section*
