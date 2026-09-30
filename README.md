# Expense Tracker Mobile App
**apk** : https://drive.google.com/drive/project/18E1wF2H2edR5Ywx_XDw2QaQ5jCYd1LdU?usp=sharing

A Flutter-based mobile expense tracking application that allows users to securely manage and monitor their personal expenses.

## Project Setup Instructions

### Prerequisites

Make sure the following are installed:

* Flutter SDK
* Dart SDK
* Android Studio or Visual Studio Code
* Android Emulator or physical Android device
* A Firebase account

### 1. Clone the Repository

```bash
git clone <your-github-repository-url>
cd expense_tracker
```

### 2. Install Dependencies

Run:

```bash
flutter pub get
```

### 3. Firebase Configuration

The application uses Firebase for authentication and cloud data storage.

Firebase services used:

* Firebase Authentication
* Cloud Firestore

Make sure the Firebase project is configured with the Flutter application.

The project uses the generated:

```text
lib/firebase_options.dart
```

### 4. Enable Email/Password Authentication

In the Firebase Console:

**Authentication → Sign-in method → Email/Password → Enable**

### 5. Configure Firestore

Create a Cloud Firestore database in the Firebase project.

The application stores expenses using a user-specific structure:

```text
users
 └── {userId}
      └── expenses
           └── {expenseId}
```

### 6. Run the Application

Connect an Android device or start an emulator and run:

```bash
flutter run
```

---

## Features Implemented

### Authentication

* User registration using email and password.
* User login using email and password.
* Persistent Firebase authentication session.
* Automatic navigation between Login and Home screens based on authentication state.
* Logout functionality.
* Authentication error handling.

### Expense Management

* Add new expenses.
* Edit existing expenses.
* Delete expenses.
* Expense title.
* Expense amount.
* Expense category.
* Expense date.
* Optional expense note.

### Expense Dashboard

* Display current-month expense total.
* Display all recorded expenses.
* Display expenses in a user-friendly card/list format.
* Loading, empty and error states.

### Search

* Search expenses by title.
* Clear search functionality.
* Search results update dynamically.

### Filtering

Expenses can be filtered by:

* Category.
* Start date.
* End date.
* Combined category and date filters.

The application also validates the date range and prevents an end date from being earlier than the start date.

### Expense Chart

* Visual representation of expenses by category.
* Implemented using the `fl_chart` package.

### User Data Security

Each authenticated user has a separate Firestore expense collection.

Firestore security rules ensure that users can only access their own expense data.

---

## Technologies / Packages Used

### Flutter

Used to build the cross-platform mobile application and user interface.

### Dart

Used as the primary programming language for the Flutter application.

### Firebase Core

Used to initialize and connect the Flutter application with Firebase.

```yaml
firebase_core
```

### Firebase Authentication

Used for secure email/password registration, login and logout.

```yaml
firebase_auth
```

### Cloud Firestore

Used as the cloud database for storing user expense information.

```yaml
cloud_firestore
```

### fl_chart

Used to create the expense visualization/chart.

```yaml
fl_chart
```

### Material Design

Flutter Material widgets were used to create the application's user interface, including:

* AppBar
* Cards
* Buttons
* Text fields
* Dialogs
* Bottom sheets
* Date pickers
* Navigation components

---

## AI Tools Used

### ChatGPT

**AI Tool:** ChatGPT by OpenAI

ChatGPT was used as a development assistance tool during the development of this Expense Tracker application.

It helped with:

* Understanding Flutter and Firebase concepts.
* Generating and explaining Flutter/Dart code.
* Implementing Firebase Authentication.
* Implementing Firebase Firestore integration.
* Troubleshooting Flutter compilation and runtime errors.
* Debugging Firebase Authentication and Firestore permission issues.
* Implementing search and filtering functionality.
* Implementing the expense chart using `fl_chart`.
* Improving code structure and readability.
* Explaining errors and suggesting solutions during development.

ChatGPT was used as a development assistance and learning tool. The implemented features were manually integrated and tested during development.

---

## Project Structure

```text
lib/
├── models/
│   └── expense.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   └── expense_form_screen.dart
│
├── services/
│   ├── auth_service.dart
│   └── expense_service.dart
│
├── widgets/
│   ├── expense_card.dart
│   ├── expense_summary.dart
│   └── expense_chart.dart
│
├── firebase_options.dart
└── main.dart
```

## How the Application Works

```text
User
  │
  ├── Register
  │      │
  │      └── Firebase Authentication
  │
  ├── Login
  │      │
  │      └── Firebase Authentication
  │
  └── Home Screen
         │
         ├── View Expenses
         ├── Add Expense
         ├── Edit Expense
         ├── Delete Expense
         ├── Search
         ├── Filter
         └── Expense Chart
                  │
                  └── Cloud Firestore
```



**AI Tools used:ChatGPT**

ChatGPT was used as a development assistance tool during the development of this Expense Tracker application.

It helped with:

* Understanding Flutter and Firebase concepts.
* Generating and explaining Flutter/Dart code for UI components and application features.
* Implementing Firebase Firestore integration for storing and retrieving expenses.
* Troubleshooting Flutter compilation and runtime errors.
* Debugging Firebase Authentication and Firestore permission issues.
* Implementing search and filtering functionality.
* Implementing the expense chart using the `fl_chart` package.
* Improving the structure and readability of the application code.
* Explaining errors and suggesting solutions during development.

ChatGPT was used as a *development assistance and learning tool*. The application was tested and integrated manually during development to ensure that the implemented features worked as expected.
