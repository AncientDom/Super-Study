# StudyGatherer: The Ultimate Student Assistant

An Android application designed for the Realme Narzo 30 5G (and all Android devices) to gather study materials, summarize content, and generate quizzes.

## 🚀 Features
1.  **Goal Selector:** Define your target (e.g., "Learn Quantum Physics").
2.  **Material Gatherer:**
    * **Videos:** Scrapes YouTube for educational content (No Ads/Interruption).
    * **Books:** Searches Open Library for free resources.
    * **AI Summaries:** Uses Gemini AI to summarize content into "Notes."
3.  **Quiz Generator:** Creates quizzes from gathered data and exports to PDF.

## 🛠️ Tech Stack & Free Services
* **Framework:** Flutter (Dart)
* **Video Engine:** `youtube_explode_dart` (Free, No API Key required)
* **AI Engine:** Google Gemini API (Free Tier available)
* **Database:** `sqflite` (Local storage)
* **Export:** `pdf` & `printing` packages.

## ⚙️ Setup & Build APK
1.  **Install Flutter:** [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2.  **Get a Free Gemini API Key:** [aistudio.google.com](https://aistudio.google.com/)
3.  **Clone this repo:**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/StudyGatherer.git](https://github.com/YOUR_USERNAME/StudyGatherer.git)
    cd StudyGatherer
    ```
4.  **Add your API Key:**
    Open `lib/main.dart` and replace `YOUR_GEMINI_API_KEY` with your actual key.
5.  **Build APK:**
    ```bash
    flutter build apk --release
    ```
    The file will be in `build/app/outputs/flutter-apk/app-release.apk`.
    
