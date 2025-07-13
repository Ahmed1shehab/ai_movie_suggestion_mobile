
# 🎬 AI Movie Suggestion - Flutter App

A modern Flutter application for discovering movies, powered by an AI movie suggestion microservice. This app provides a seamless user experience for Browse trending, popular, and upcoming movies, along with detailed information for each.

-----

## ✨ Features

  * **Discover Movies**: Explore a vast collection of movies, including Now Playing, Trending (Popular), Top Rated, and Upcoming releases.
  * **Detailed Movie Information**: Get comprehensive details for any movie, including overview, cast, ratings, and more.
  * **Intuitive UI**: A clean and responsive user interface designed for an enjoyable Browse experience.
  * **Robust Architecture**: Built with a layered architecture, leveraging **GetIt** for dependency injection and **Dio** for network requests.
  * **AI Integration**: Connects with an AI movie suggestion microservice to enhance discovery (requires the backend microservice to be running).

-----

## 🛠️ Tech Stack

This application is built using the following key technologies and libraries:

  * **Flutter**: Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
  * **Dio**: A powerful HTTP client for Dart, used for making network requests to the movie APIs.
  * **Retrofit**: A type-safe HTTP client for Dart, generating API service code from annotations.
  * **GetIt**: A simple and fast service locator for Dart and Flutter, used for dependency injection.
  * **Freezed**: Code generation for data classes and unions, ensuring immutability and reducing boilerplate.
  * **flutter\_dotenv**: To load environment variables from a `.env` file securely.
  * **Lottie**: For beautiful animations to enhance the user experience.
  * **Carousel Slider**: To create engaging carousels for movie posters.
  * **Shared Preferences**: For light-weight data storage (e.g., app preferences).
  * **Internet Connection Checker**: To monitor network connectivity.
  * **rxdart**: Reactive Extensions for Dart, enhancing stream capabilities.

-----

## 📂 Project Structure

The project follows a clean architecture pattern, separating concerns into distinct layers:

```
├── lib/
│   ├── app/                 # Application setup, DI, and main app widget
│   │   ├── app.dart
│   │   ├── app_prefs.dart
│   │   ├── constants.dart
│   │   └── di.dart          # Dependency Injection setup
│   ├── data/                # Data layer (repositories, data sources, network)
│   ├── domain/              # Domain layer (use cases, entities, repositories interfaces)
│   ├── presentation/        # Presentation layer (UI, viewmodels, resources, routes)
│   └── main.dart            # Entry point of the application
├── .env                     # Environment variables
├── pubspec.yaml             # Project dependencies and metadata
└── README.md
```

-----

## 🚀 Getting Started

Follow these steps to get the AI Movie Suggestion Flutter app running on your local machine.

### 1\. Clone the Repository

```bash
git clone https://github.com/your-username/ai-movie-suggestion-flutter.git
cd ai-movie-suggestion-flutter
```

### 2\. Install Dependencies

Fetch all the necessary Flutter and Dart packages:

```bash
flutter pub get
```

### 3\. Generate Code

This project uses code generation for `freezed`, `json_serializable`, and `retrofit`. Run the build runner:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4\. Configure Environment Variables

Create a `.env` file in the root directory of your project and add your TMDb API key. This key is crucial for fetching movie data.

```
TMDB_API_KEY=your_tmdb_api_key_here
```

You can obtain a TMDb API key by registering on [TMDb's website](https://www.themoviedb.org/documentation/api).

### 5\. Run the Application

Connect a device or start an emulator/simulator, then run the app:

```bash
flutter run
```

-----

## 🤝 Contributing

Contributions are welcome\! If you have suggestions for improvements or find any issues, please feel free to open a pull request or an issue on GitHub.

-----

## 📞 Contact

  * **Ahmed Shehab**
  * **Email**: ahmed.shehab.7355@gmail.com
  * **GitHub**: [Ahmed1shehab](https://github.com/Ahmed1shehab)
  * **LinkedIn**: [Ahmed Shehab](https://www.linkedin.com/in/ahmed-shehab-6767652b3/)

-----

Last updated: July 13, 2025