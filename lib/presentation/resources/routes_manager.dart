import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/presentation/auth/login/view/login_view.dart';
import 'package:ai_movie_suggestion/presentation/auth/register/view/register_view.dart';
import 'package:ai_movie_suggestion/presentation/auth/reset_password/reset_password_view.dart';
import 'package:ai_movie_suggestion/presentation/auth/verify_email/view/verify_email_view.dart';
import 'package:ai_movie_suggestion/presentation/main/main_view.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/discover/discover_view.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/movie_detail/view/movie_detail_view.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/profile/view/pages/watchlist/view/watchlist_view.dart';
import 'package:ai_movie_suggestion/presentation/onboarding/view/onboarding_view.dart';
import 'package:ai_movie_suggestion/presentation/splash/splashscreen_view.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String splashRoute = "/";
  static const String onboardingRoute = "/onboarding";
  static const String loginRoute = "/login";
  static const String registerRoute = "/register";
  static const String verifyEmailRoute = "/verifyEmailRoute";
  static const String forgetPasswordRoute = "/forgetPassword";
  static const String resetPasswordRoute = "/resetPasswordRoute";
  static const String mainRoute = "/main";
  static const String testRoute = "/testRoute";
  static const String movieDetailsRoute = "/movieDetailsRoute";
  static const String discoverRoute = "/discoverRoute";
  static const String watchListRoute = "/watchListRoute";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashscreenView());
      case Routes.onboardingRoute:
        return MaterialPageRoute(builder: (_) => const OnboardingView());

      case Routes.loginRoute:
        initLoginModule();
        return MaterialPageRoute(
          builder: (_) => const LoginView(),
        );
      case Routes.registerRoute:
        initRegisterModule();
        return MaterialPageRoute(
          builder: (_) => const RegisterView(),
        );
      case Routes.resetPasswordRoute:
        return MaterialPageRoute(builder: (_) => const ResetPasswordView());
      case Routes.forgetPasswordRoute:
        return MaterialPageRoute(builder: (_) => const Scaffold());
      case Routes.mainRoute:
        return MaterialPageRoute(builder: (_) => const MainView());
      case Routes.verifyEmailRoute:
        initVerifyEmailModule();
        return MaterialPageRoute(builder: (_) => const VerifyEmailView());

      case Routes.movieDetailsRoute:
        return _getMovieDetailsRoute(settings);
      case Routes.watchListRoute:
        return _getWatchListRoute(settings);
      case Routes.discoverRoute:
        return MaterialPageRoute(builder: (_) => const DiscoverView());
      default:
        return _getUndefinedRoute();
    }
  }

  static Future<void> navigateAndRemoveUntil(
      BuildContext context, String routeName) {
    return Navigator.of(context).pushAndRemoveUntil(
      getRoute(RouteSettings(name: routeName)),
      (route) => false,
    );
  }

  static Route<dynamic> _getMovieDetailsRoute(RouteSettings settings) {
    final arguments = settings.arguments;

    int? movieId;
    String? routeName;

    if (arguments is MovieDetailsArguments) {
      movieId = arguments.movieId;
      routeName = arguments.routeName; // Extract routeName here
    } else if (arguments is int) {
      movieId = arguments;
      // For backward compatibility, you might want to set a default or null routeName
      // or handle this case where routeName isn't available.
      routeName = null; // Or some default value if appropriate
    }

    if (movieId != null) {
      // Ensure routeName is not null before using it, or provide a fallback
      return MaterialPageRoute(
        builder: (_) => MovieDetailsView(
          movieId: movieId!,
          routeName: routeName ??
              'unknownRoute', // Provide a fallback if routeName can be null
        ),
        settings: settings,
      );
    }

    return _getUndefinedRoute();
  }

  static Route<dynamic> _getWatchListRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => const WatchlistView(),
      settings: settings,
    );
  }

  static Route<dynamic> _getUndefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('Route not found!'),
        ),
      ),
    );
  }

  static Future<void> navigateToMovieDetails(
      BuildContext context, int movieId, String routeName) {
    return Navigator.pushNamed(
      context,
      Routes.movieDetailsRoute,
      arguments: MovieDetailsArguments(
        movieId: movieId,
        routeName: routeName,
      ),
    );
  }
}

class MovieDetailsArguments {
  final int movieId;
  final String routeName;

  MovieDetailsArguments({required this.movieId, required this.routeName});
}
