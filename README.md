# Expense Tracker

A simple and clean Expense Tracker mobile application built with Flutter and Firebase. This project was developed as a practical task for the Flutter Developer Internship selection process at CyphLab.

## Features Implemented

*   **Add, Edit, and Delete Expenses:** Full CRUD operations for managing expenses.
*   **Categories:** Select from various categories (Food, Transport, Shopping, Bills, etc.) when adding an expense.
*   **Firebase Integration:** Expenses are stored and retrieved in real-time using Cloud Firestore.
*   **Monthly Summary:** Displays the total expenses for the current month at a glance.
*   **Expense History:** Shows a list of all tracked expenses, sorted by date.
*   **Filtering:** Filter the expense list by category or date range using a convenient bottom sheet.
*   **Form Validation:** Proper validation ensures that titles, amounts, and categories are correctly entered.
*   **State Management:** Properly handles loading states, empty lists, and error states gracefully.
*   **Dark Mode Support:** The app seamlessly adapts to the system's dark or light theme.

## Technologies and Packages Used

*   **Flutter & Dart:** Core framework and language for building the UI and logic.
*   **Firebase Core & Cloud Firestore:** Used as the backend for persistent and real-time data storage.
*   **Intl:** Used for date formatting.

## AI Tools Used

*   **Gemini:** Used as an AI assistant (Antigravity IDE) during development to help write boilerplate code, structure the UI components rapidly, and refine the filter logic. It also assisted in validating the code structure and writing this README.

## Project Setup Instructions

1.  **Clone the repository:**
    ```bash
    git clone <your_repository_url>
    cd Expence_tracker
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup (If necessary):**
    The project uses Firebase. Ensure you have the `firebase_options.dart` file correctly set up or initialized for your own Firebase project if you plan to run a separate instance.

4.  **Run the app:**
    ```bash
    flutter run
    ```

## Submission Details

Please refer to the repository and the accompanying screen recording link for a full demonstration of the app's capabilities.
