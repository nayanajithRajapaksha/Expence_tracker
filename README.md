# Expense Tracker
**apk** : https://drive.google.com/file/d/10wniyOuHglNdZfIENvttGDA2sfJScnqK/view?usp=sharing

A Flutter-based mobile Expense Tracker application that allows users to securely manage their personal expenses using Firebase Authentication and Cloud Firestore.

## Features

### 🔐 Authentication

* User registration with email and password
* User login and logout
* Firebase Authentication
* Authentication state persistence
* Each user's expenses are isolated from other users

### 💰 Expense Management

* Add new expenses
* Edit existing expenses
* Delete expenses
* Expense title
* Amount
* Category
* Date
* Optional note
* Input validation

### 🔎 Search & Filtering

* Search expenses by title
* Filter by category
* Filter by date range
* Combine search and filters
* Clear filters

### 📊 Expense Summary

* Current-month total spending
* Filtered expense information
* Expense count

### 📈 Expense Chart

* Visual spending breakdown by category
* Implemented using `fl_chart`

### ☁️ Firebase

* Firebase Authentication for user accounts
* Cloud Firestore for expense storage
* User-specific Firestore collections
* Real-time expense updates

### ⚠️ Application States

* Loading state
* Empty state
* Error state
* Retry functionality
* Authentication state handling

---

## Technologies Used

* **Flutter**
* **Dart**
* **Firebase Authentication**
* **Cloud Firestore**
* **fl_chart**

---

## Project Structure

```text
lib/
│
├── constants/
│   └── constants.dart
│
├── models/
│   └── expense.dart
│
├── services/
│   ├── auth_service.dart
│   └── expense_service.dart
│
├── utils/
│   ├── constants.dart
│   └── expense_filter.dart
│
├── widgets/
│   ├── category_selector.dart
│   ├── expense_card.dart
│   ├── expense_summary.dart
│   ├── expense_chart.dart
│   └── error_state.dart
│
└── screens/
    ├── home_screen.dart
    ├── login_screen.dart
    ├── register_screen.dart
    └── expense_form_screen.dart
```

> Keep only the folders/files that actually exist in your final project. If `constants.dart` is inside `utils/`, don't also keep a duplicate inside `constants/`.

---

## Firestore Structure

Each authenticated user has their own expense collection.

```text
users
└── {userId}
    └── expenses
        ├── {expenseId}
        │   ├── title
        │   ├── amount
        │   ├── category
        │   ├── date
        │   └── note
        │
        └── {expenseId}
```

This structure ensures that users can only access their own expenses.

---

## Firestore Security Rules

The application uses Firebase Authentication together with Firestore security rules.

```text
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId}/expenses/{expenseId} {
      allow read, write: if request.auth != null
                            && request.auth.uid == userId;
    }
  }
}
```

These rules prevent an authenticated user from reading or modifying another user's expenses.

---

## Firebase Setup

### 1. Create a Firebase Project

Create a Firebase project and register the Flutter application.

### 2. Enable Authentication

In Firebase Console:

```text
Authentication
→ Sign-in method
→ Email/Password
→ Enable
```

### 3. Create Firestore Database

Create a Cloud Firestore database for the project.

### 4. Configure Firebase in Flutter

The project uses FlutterFire configuration.

The generated Firebase configuration file is:

```text
lib/firebase_options.dart
```

Do not manually expose sensitive configuration or Firebase credentials in the README.

### 5. Configure Firestore Rules

Replace the default Firestore rules with the user-specific rules shown above and publish them.

---

## Installation

### Prerequisites

Make sure the following are installed:

* Flutter SDK
* Dart SDK
* Android Studio
* Android SDK
* A physical Android device or Android Emulator

Check Flutter installation:

```bash
flutter doctor
```

### Clone the Project

```bash
git clone <your-github-repository-url>
```

Navigate into the project:

```bash
cd Expence_tracker
```

### Install Dependencies

```bash
flutter pub get
```

### Run the Application

```bash
flutter run
```

---

## Required Packages

The project uses packages for Firebase services and chart visualization.

Example:

```yaml
dependencies:
  flutter:
    sdk: flutter

  firebase_core:
  firebase_auth:
  cloud_firestore:
  fl_chart:
```

Run:

```bash
flutter pub get
```

after adding or changing dependencies.

---

## Application Flow

```text
Start Application
       │
       ▼
Firebase Initialization
       │
       ▼
Check Authentication
       │
   ┌───┴────┐
   │        │
Logged In  Logged Out
   │        │
   ▼        ▼
Home      Login
   │        │
   │        ▼
   │      Register
   │        │
   └────────┘
       │
       ▼
Expense Management
       │
 ┌─────┼──────────┐
 ▼     ▼          ▼
Add   Edit       Delete
       │
       ▼
Cloud Firestore
```

---

## User Data Security

Expenses are stored under the authenticated user's UID:

```text
users/{uid}/expenses
```

The application uses the authenticated user's UID to access the correct expense collection.

Firestore security rules additionally verify:

```text
request.auth.uid == userId
```

Therefore, users cannot access another user's expense documents through the application's Firestore requests.

---

## Building the APK

To create a release APK:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

The generated APK will be located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

For smaller APKs optimized for different Android CPU architectures:

```bash
flutter build apk --release --split-per-abi
```

---

## Internet Requirement

The application requires an internet connection for Firebase services such as:

* User authentication
* Firestore synchronization
* Adding expenses
* Updating expenses
* Deleting expenses
* Loading expense data

The application does not require a separate Node.js, PHP, or Python backend because Firebase provides the backend services used by the application.

---

## Validation & Error Handling

The application handles common user and network scenarios including:

* Empty expense title
* Invalid amount
* Missing category
* Invalid date range
* Firebase authentication errors
* Firestore errors
* Empty expense list
* Loading states
* Retry after errors

---

## AI Tools Used

### ChatGPT — OpenAI

ChatGPT was used as a development assistance and learning tool during the project.

It helped with:

* Flutter and Dart development guidance
* Firebase Authentication implementation
* Cloud Firestore integration
* Debugging and resolving implementation issues
* Search and filtering functionality
* Expense chart implementation
* Code organization and separation of concerns
* Understanding Firebase security rules
* README and project documentation

The generated suggestions were reviewed, integrated, modified where necessary, and tested as part of the development process.

---

## Testing

The following application workflows were tested:

* User registration
* User login
* User logout
* Authentication state persistence
* Adding an expense
* Editing an expense
* Deleting an expense
* Searching expenses
* Category filtering
* Date-range filtering
* Expense chart display
* Monthly expense calculation
* Firestore data synchronization
* User-specific expense access
* Error and empty states

---

## Future Improvements

Possible future improvements include:

* Dark mode
* Advanced expense analytics
* Monthly and yearly reports
* Export expenses to CSV/PDF
* Budget limits
* Notifications
* Recurring expenses
* Cloud backup enhancements
* More advanced charts

---

## Author

Developed as a Flutter application project demonstrating mobile application development, Firebase integration, authentication, cloud data management, and user-focused UI functionality.
