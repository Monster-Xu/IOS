# CLAUDE.md - AI Assistant Guide for IOS Repository

**Last Updated:** 2025-11-14
**Repository:** Monster-Xu/IOS
**Status:** Empty/Skeleton Project

## Table of Contents
1. [Repository Overview](#repository-overview)
2. [Current State](#current-state)
3. [iOS Project Structure](#ios-project-structure)
4. [Development Workflows](#development-workflows)
5. [Coding Conventions](#coding-conventions)
6. [Dependencies & Package Management](#dependencies--package-management)
7. [Testing Guidelines](#testing-guidelines)
8. [Build & Deployment](#build--deployment)
9. [AI Assistant Guidelines](#ai-assistant-guidelines)
10. [Common Tasks](#common-tasks)

---

## Repository Overview

### Project Information
- **Type:** iOS Application (Currently Uninitialized)
- **Primary Language:** TBD (Swift/Objective-C)
- **Platform:** iOS
- **Created:** February 8, 2017
- **Repository Size:** Minimal (skeleton project)

### Key Facts
- This is an **empty repository** awaiting iOS project initialization
- No Xcode project files currently exist
- No dependencies or build configurations are present
- Ready for fresh iOS project setup

---

## Current State

### What Exists
```
IOS/
├── .git/                    # Git repository metadata
└── README.md               # Minimal project description
```

### What's Missing (Typical iOS Project)
- ❌ Xcode project files (`.xcodeproj`, `.xcworkspace`)
- ❌ Source code directories (`Sources/`, App name folder)
- ❌ Dependency management (`Podfile`, `Package.swift`, `Cartfile`)
- ❌ Build configurations
- ❌ Test files and test targets
- ❌ Assets catalog
- ❌ Info.plist and configuration files
- ❌ `.gitignore` for iOS
- ❌ CI/CD configuration

---

## iOS Project Structure

### Standard iOS App Structure (When Initialized)

```
IOS/
├── ProjectName/                      # Main application target
│   ├── AppDelegate.swift            # App lifecycle delegate
│   ├── SceneDelegate.swift          # Scene lifecycle (iOS 13+)
│   ├── ContentView.swift            # SwiftUI main view (or)
│   ├── ViewController.swift         # UIKit main controller
│   ├── Models/                      # Data models
│   ├── Views/                       # UI components
│   ├── ViewModels/                  # MVVM view models
│   ├── Controllers/                 # View controllers (UIKit)
│   ├── Services/                    # Business logic & API services
│   ├── Utilities/                   # Helper functions
│   ├── Resources/                   # Non-code resources
│   │   ├── Assets.xcassets/        # Images, colors, data assets
│   │   └── Localizable.strings     # Localization files
│   ├── Info.plist                  # App configuration
│   └── ProjectName.entitlements    # App capabilities
│
├── ProjectNameTests/                # Unit tests
│   └── ProjectNameTests.swift
│
├── ProjectNameUITests/              # UI tests
│   └── ProjectNameUITests.swift
│
├── Podfile                          # CocoaPods dependencies (if used)
├── Podfile.lock                     # Locked dependency versions
├── Package.swift                    # Swift Package Manager (if used)
├── .gitignore                       # Git ignore rules
├── README.md                        # Project documentation
└── ProjectName.xcodeproj/          # Xcode project file
    └── project.pbxproj             # Project configuration
```

### Architecture Patterns

Common iOS architectures to consider:
- **MVC** (Model-View-Controller) - Apple's default
- **MVVM** (Model-View-ViewModel) - Popular for SwiftUI
- **VIPER** (View-Interactor-Presenter-Entity-Router) - Complex apps
- **Clean Architecture** - Scalable, testable structure
- **Composable Architecture** (TCA) - Modern SwiftUI approach

---

## Development Workflows

### Initial Project Setup

#### Option 1: SwiftUI App (Recommended for New Projects)
```bash
# Create new Xcode project via command line (if xcodebuild available)
# OR manually create in Xcode:
# File → New → Project → iOS → App
# - Product Name: ProjectName
# - Interface: SwiftUI
# - Language: Swift
# - Storage: SwiftData/Core Data (optional)
```

#### Option 2: UIKit App (Legacy/Enterprise)
```bash
# File → New → Project → iOS → App
# - Interface: Storyboard
# - Language: Swift or Objective-C
```

#### Option 3: Framework/Library
```bash
# File → New → Project → iOS → Framework
# For reusable components and SDKs
```

### Git Workflow

#### Branch Strategy
```bash
# Current branch for development
git checkout claude/claude-md-mhz3aq78mp1n6oy7-013XbQ2NgzL2fUeCz3hsRpdp

# Standard branch naming conventions:
# - feature/feature-name
# - bugfix/issue-description
# - hotfix/critical-fix
# - release/version-number
```

#### Commit Conventions
```bash
# Format: type(scope): description
#
# Types:
# - feat: New feature
# - fix: Bug fix
# - docs: Documentation changes
# - style: Code style/formatting
# - refactor: Code restructuring
# - test: Test additions/changes
# - chore: Build process, dependencies

# Examples:
git commit -m "feat(auth): add biometric authentication"
git commit -m "fix(network): resolve API timeout issues"
git commit -m "docs: update README with setup instructions"
```

### Build Workflow

```bash
# Clean build
xcodebuild clean -project ProjectName.xcodeproj -scheme ProjectName

# Build for iOS Simulator
xcodebuild build -project ProjectName.xcodeproj \
    -scheme ProjectName \
    -destination 'platform=iOS Simulator,name=iPhone 15'

# Build for iOS Device
xcodebuild build -project ProjectName.xcodeproj \
    -scheme ProjectName \
    -destination 'generic/platform=iOS'

# Archive for distribution
xcodebuild archive -project ProjectName.xcodeproj \
    -scheme ProjectName \
    -archivePath ProjectName.xcarchive
```

---

## Coding Conventions

### Swift Style Guide

#### Naming Conventions
```swift
// Types: UpperCamelCase
class UserProfileViewController { }
struct NetworkManager { }
enum AppTheme { }
protocol DataSourceDelegate { }

// Functions/Variables: lowerCamelCase
func fetchUserData() { }
var isUserLoggedIn: Bool
let maximumRetryCount = 3

// Constants: lowerCamelCase (avoid SCREAMING_CASE)
let apiBaseURL = "https://api.example.com"
private let defaultTimeout: TimeInterval = 30

// Protocols: noun or adjective
protocol UserDataSource { }
protocol Searchable { }
```

#### Code Organization
```swift
// MARK: - GroupName pattern
class ViewController: UIViewController {

    // MARK: - Properties
    private var viewModel: ViewModel

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        // UI configuration
    }

    // MARK: - Actions
    @IBAction func buttonTapped(_ sender: UIButton) {
        // Handle action
    }

    // MARK: - Helper Methods
    private func updateData() {
        // Update logic
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    // Delegate methods
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    // DataSource methods
}
```

#### SwiftUI Conventions
```swift
struct ContentView: View {
    // MARK: - Properties
    @State private var isLoading = false
    @StateObject private var viewModel = ViewModel()
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Body
    var body: some View {
        content
    }

    // MARK: - Views
    private var content: some View {
        VStack {
            // View content
        }
    }
}
```

#### Error Handling
```swift
// Use Swift's error handling
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
}

func fetchData() async throws -> Data {
    guard let url = URL(string: apiURL) else {
        throw NetworkError.invalidURL
    }

    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}

// Usage
Task {
    do {
        let data = try await fetchData()
        // Process data
    } catch NetworkError.invalidURL {
        // Handle invalid URL
    } catch {
        // Handle other errors
    }
}
```

### Objective-C Conventions (If Used)

```objc
// Properties: use descriptive names
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) BOOL isLoading;

// Methods: descriptive with parameters
- (void)fetchUserDataWithCompletion:(void (^)(User *user, NSError *error))completion;

// Constants: k prefix
static NSString *const kAPIBaseURL = @"https://api.example.com";
static const NSTimeInterval kDefaultTimeout = 30.0;
```

---

## Dependencies & Package Management

### Swift Package Manager (Recommended for New Projects)

```swift
// File: Package.swift
// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ProjectName",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ProjectName",
            targets: ["ProjectName"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.40.0"),
    ],
    targets: [
        .target(
            name: "ProjectName",
            dependencies: ["Alamofire", "RealmSwift"]),
        .testTarget(
            name: "ProjectNameTests",
            dependencies: ["ProjectName"]),
    ]
)
```

### CocoaPods (If Preferred)

```ruby
# File: Podfile

platform :ios, '15.0'
use_frameworks!

target 'ProjectName' do
  # Networking
  pod 'Alamofire', '~> 5.8'

  # Database
  pod 'RealmSwift', '~> 10.40'

  # UI
  pod 'SnapKit', '~> 5.6'

  # Analytics
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'

  target 'ProjectNameTests' do
    inherit! :search_paths
    pod 'Quick', '~> 7.0'
    pod 'Nimble', '~> 13.0'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
```

```bash
# Install dependencies
pod install

# Update dependencies
pod update

# IMPORTANT: Always use .xcworkspace after CocoaPods installation
open ProjectName.xcworkspace
```

### Common iOS Libraries

**Networking:**
- Alamofire - HTTP networking
- Moya - Network abstraction layer

**Database/Storage:**
- Realm - Mobile database
- CoreData - Apple's persistence framework
- GRDB - SQLite toolkit

**UI/Layout:**
- SnapKit - Auto Layout DSL
- Kingfisher - Image downloading/caching
- Lottie - Animation library

**Reactive Programming:**
- Combine - Apple's native framework
- RxSwift - Reactive extensions

**Testing:**
- Quick/Nimble - BDD testing
- OHHTTPStubs - Network stubbing

---

## Testing Guidelines

### Unit Tests (XCTest)

```swift
import XCTest
@testable import ProjectName

final class UserViewModelTests: XCTestCase {

    var sut: UserViewModel!
    var mockService: MockUserService!

    override func setUp() {
        super.setUp()
        mockService = MockUserService()
        sut = UserViewModel(service: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    func testFetchUserSuccess() async throws {
        // Given
        let expectedUser = User(id: 1, name: "Test User")
        mockService.userToReturn = expectedUser

        // When
        try await sut.fetchUser()

        // Then
        XCTAssertEqual(sut.user?.name, "Test User")
        XCTAssertTrue(mockService.fetchUserCalled)
    }

    func testFetchUserFailure() async {
        // Given
        mockService.shouldFail = true

        // When
        do {
            try await sut.fetchUser()
            XCTFail("Expected error to be thrown")
        } catch {
            // Then
            XCTAssertNotNil(error)
        }
    }
}
```

### UI Tests

```swift
import XCTest

final class LoginUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testLoginFlow() {
        // Given
        let emailField = app.textFields["emailTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let loginButton = app.buttons["loginButton"]

        // When
        emailField.tap()
        emailField.typeText("test@example.com")

        passwordField.tap()
        passwordField.typeText("password123")

        loginButton.tap()

        // Then
        XCTAssertTrue(app.staticTexts["welcomeLabel"].waitForExistence(timeout: 5))
    }
}
```

### Running Tests

```bash
# Run all tests
xcodebuild test \
    -project ProjectName.xcodeproj \
    -scheme ProjectName \
    -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test suite
xcodebuild test \
    -project ProjectName.xcodeproj \
    -scheme ProjectName \
    -only-testing:ProjectNameTests/UserViewModelTests

# Generate code coverage
xcodebuild test \
    -project ProjectName.xcodeproj \
    -scheme ProjectName \
    -enableCodeCoverage YES
```

---

## Build & Deployment

### Build Configurations

Standard configurations:
- **Debug** - Development builds with debugging symbols
- **Release** - Optimized production builds
- **Staging** (Custom) - Pre-production testing environment

### Build Settings

Key settings to configure:
```
PRODUCT_BUNDLE_IDENTIFIER: com.company.projectname
MARKETING_VERSION: 1.0.0
CURRENT_PROJECT_VERSION: 1
IPHONEOS_DEPLOYMENT_TARGET: 15.0
SWIFT_VERSION: 5.9
ENABLE_BITCODE: NO (deprecated)
```

### Fastlane Integration (Recommended)

```ruby
# File: fastlane/Fastfile

default_platform(:ios)

platform :ios do

  desc "Run tests"
  lane :test do
    run_tests(
      scheme: "ProjectName",
      devices: ["iPhone 15"]
    )
  end

  desc "Build for development"
  lane :dev do
    build_app(
      scheme: "ProjectName",
      configuration: "Debug",
      export_method: "development"
    )
  end

  desc "Deploy to TestFlight"
  lane :beta do
    increment_build_number
    build_app(
      scheme: "ProjectName",
      configuration: "Release"
    )
    upload_to_testflight
  end

  desc "Deploy to App Store"
  lane :release do
    increment_build_number
    build_app(
      scheme: "ProjectName",
      configuration: "Release"
    )
    upload_to_app_store
  end
end
```

### CI/CD with GitHub Actions

```yaml
# File: .github/workflows/ios.yml

name: iOS CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  build-and-test:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v3

    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.0.app

    - name: Install dependencies
      run: |
        if [ -f Podfile ]; then
          pod install
        fi

    - name: Build
      run: |
        xcodebuild build \
          -project ProjectName.xcodeproj \
          -scheme ProjectName \
          -destination 'platform=iOS Simulator,name=iPhone 15'

    - name: Run tests
      run: |
        xcodebuild test \
          -project ProjectName.xcodeproj \
          -scheme ProjectName \
          -destination 'platform=iOS Simulator,name=iPhone 15' \
          -enableCodeCoverage YES

    - name: Upload coverage
      uses: codecov/codecov-action@v3
```

---

## AI Assistant Guidelines

### General Principles

1. **Always Check Project State First**
   - Verify if Xcode project exists before making assumptions
   - Check for existing dependencies and build configurations
   - Read existing code to understand architecture patterns

2. **Respect iOS Conventions**
   - Follow Apple's Human Interface Guidelines
   - Use iOS-specific design patterns (delegates, protocols, closures)
   - Prefer native frameworks over third-party when reasonable

3. **SwiftUI vs UIKit Context**
   - Determine which framework is being used
   - Don't mix paradigms unnecessarily
   - Use appropriate lifecycle methods for each

4. **Security & Privacy**
   - Never commit API keys, certificates, or credentials
   - Use Keychain for sensitive data storage
   - Request minimum necessary permissions
   - Follow App Store privacy requirements

5. **Performance Considerations**
   - Avoid blocking the main thread
   - Use async/await for asynchronous operations
   - Implement proper image caching
   - Profile before optimizing

### Code Review Checklist

When reviewing or modifying code:
- [ ] No force unwrapping (`!`) without proper justification
- [ ] Proper error handling (try/catch, Result type)
- [ ] Memory management (weak/unowned for closures)
- [ ] Accessibility labels for UI elements
- [ ] Localization for user-facing strings
- [ ] Thread safety for shared state
- [ ] Proper use of access control (private, fileprivate, internal, public)
- [ ] Code documentation for public APIs
- [ ] Unit tests for business logic
- [ ] UI tests for critical user flows

### Common Pitfalls to Avoid

```swift
// ❌ BAD: Force unwrapping
let user = userOptional!

// ✅ GOOD: Safe unwrapping
guard let user = userOptional else { return }

// ❌ BAD: Retain cycle
class ViewController: UIViewController {
    var closure: (() -> Void)?

    func setup() {
        closure = {
            self.doSomething()  // Retain cycle!
        }
    }
}

// ✅ GOOD: Weak reference
class ViewController: UIViewController {
    var closure: (() -> Void)?

    func setup() {
        closure = { [weak self] in
            self?.doSomething()
        }
    }
}

// ❌ BAD: Blocking main thread
func fetchData() {
    let data = URLSession.shared.synchronousData(from: url)  // Blocks UI
}

// ✅ GOOD: Async operation
func fetchData() async throws {
    let (data, _) = try await URLSession.shared.data(from: url)
}
```

### File Creation Guidelines

**When creating new files:**
1. Use appropriate file headers with project name and date
2. Place in correct directory based on responsibility
3. Add to appropriate Xcode target
4. Include necessary imports only
5. Follow naming conventions

```swift
//
//  UserViewModel.swift
//  ProjectName
//
//  Created on 2025-11-14.
//

import Foundation
import Combine

final class UserViewModel: ObservableObject {
    // Implementation
}
```

### Documentation Standards

```swift
/// Fetches user data from the remote API.
///
/// This method performs an asynchronous network request to retrieve
/// user information based on the provided user ID.
///
/// - Parameter userID: The unique identifier for the user.
/// - Returns: A `User` object containing the user's information.
/// - Throws: `NetworkError` if the request fails or data is invalid.
///
/// - Example:
/// ```swift
/// let user = try await fetchUser(userID: "123")
/// print(user.name)
/// ```
func fetchUser(userID: String) async throws -> User {
    // Implementation
}
```

### Git Commit Strategy

```bash
# Before committing:
1. Run tests: xcodebuild test -scheme ProjectName
2. Check for warnings: xcodebuild build -scheme ProjectName | grep warning
3. Verify no debug code or print statements
4. Update documentation if public APIs changed

# Commit with descriptive message
git add .
git commit -m "feat(user): add profile picture upload functionality"

# Push to designated branch
git push -u origin claude/claude-md-mhz3aq78mp1n6oy7-013XbQ2NgzL2fUeCz3hsRpdp
```

---

## Common Tasks

### Task: Initialize New iOS Project

```bash
# If creating via Xcode:
# 1. Open Xcode
# 2. File → New → Project
# 3. Select iOS → App
# 4. Configure project settings
# 5. Choose location (this repository root)

# Add .gitignore for iOS
curl https://raw.githubusercontent.com/github/gitignore/main/Swift.gitignore -o .gitignore

# Initialize dependencies (choose one)
# Option A: CocoaPods
pod init
# Edit Podfile, then:
pod install

# Option B: Swift Package Manager
# File → Add Package Dependencies in Xcode
```

### Task: Add New Feature

```bash
# 1. Create feature branch (if not using current)
git checkout -b feature/new-feature

# 2. Create necessary files
# - Add View/ViewController
# - Add ViewModel (if MVVM)
# - Add Models
# - Add Services/Networking

# 3. Implement feature
# - Write code following conventions
# - Add documentation
# - Handle errors properly

# 4. Add tests
# - Unit tests for business logic
# - UI tests for user flows

# 5. Run tests
xcodebuild test -scheme ProjectName

# 6. Commit and push
git add .
git commit -m "feat(feature-name): add new feature description"
git push -u origin feature/new-feature
```

### Task: Fix Bug

```bash
# 1. Reproduce the bug
# 2. Write failing test that exposes the bug
# 3. Fix the bug
# 4. Verify test passes
# 5. Check for regression (run all tests)
# 6. Commit with fix message
git commit -m "fix(component): resolve issue with specific behavior"
```

### Task: Update Dependencies

```bash
# Swift Package Manager
# File → Packages → Update to Latest Package Versions

# CocoaPods
pod update

# Verify everything still works
xcodebuild test -scheme ProjectName

# Commit dependency updates
git add Podfile.lock  # or Package.resolved
git commit -m "chore(deps): update dependencies"
```

### Task: Prepare for Release

```bash
# 1. Update version numbers
# - MARKETING_VERSION (e.g., 1.0.0)
# - CURRENT_PROJECT_VERSION (build number)

# 2. Run full test suite
xcodebuild test -scheme ProjectName

# 3. Check for warnings
xcodebuild build -scheme ProjectName | grep warning

# 4. Update CHANGELOG.md (if exists)

# 5. Create release build
xcodebuild archive \
    -scheme ProjectName \
    -archivePath ProjectName.xcarchive

# 6. Export for distribution
xcodebuild -exportArchive \
    -archivePath ProjectName.xcarchive \
    -exportPath ./build \
    -exportOptionsPlist ExportOptions.plist

# 7. Upload to App Store Connect (manual or via Fastlane)
```

---

## Resources

### Official Apple Documentation
- [iOS Developer Library](https://developer.apple.com/documentation/)
- [Swift Programming Language](https://docs.swift.org/swift-book/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### Recommended Reading
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [raywenderlich.com iOS Tutorials](https://www.raywenderlich.com/ios)
- [Hacking with Swift](https://www.hackingwithswift.com/)

### Tools
- **Xcode** - IDE for iOS development
- **Instruments** - Profiling and debugging
- **CocoaPods** - Dependency manager
- **Fastlane** - Automation tool
- **SwiftLint** - Code linting

---

## Notes for AI Assistants

### Current Repository Status
⚠️ **This repository is currently empty/skeleton.**

When working with this repository:
1. **First step:** Initialize an iOS project before attempting to modify code
2. **Check for changes:** Always verify project state before making assumptions
3. **Ask for clarification:** If unsure about project type or architecture, ask the user
4. **Propose initialization:** Offer to set up the project with proper structure

### Next Steps Recommendation
To make this repository functional, recommend:
1. Initialize Xcode project (SwiftUI or UIKit)
2. Add comprehensive `.gitignore`
3. Set up dependency management
4. Create basic project structure
5. Add CI/CD configuration
6. Update README.md with project-specific information

---

**Document Version:** 1.0
**Maintained by:** AI Assistant (Claude)
**Repository:** https://github.com/Monster-Xu/IOS
