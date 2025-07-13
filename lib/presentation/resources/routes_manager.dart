import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/presentation/auth/login/view/login_view.dart';
import 'package:ai_movie_suggestion/presentation/auth/register/view/register_view.dart';
import 'package:ai_movie_suggestion/presentation/auth/reset_password/reset_password_view.dart';
import 'package:ai_movie_suggestion/presentation/auth/verify_email/view/verify_email_view.dart';
import 'package:ai_movie_suggestion/presentation/main/main_view.dart';
import 'package:ai_movie_suggestion/presentation/main/pages/movie_detail/view/movie_detail_view.dart';
import 'package:ai_movie_suggestion/presentation/onboarding/view/onboarding_view.dart';
import 'package:ai_movie_suggestion/presentation/splash/splashscreen_view.dart';
import 'package:ai_movie_suggestion/presentation/test/success_test_page.dart';
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
      case Routes.testRoute:
        return MaterialPageRoute(builder: (_) => const SuccessTestPage());
      case Routes.movieDetailsRoute:
        final movieId = settings.arguments as int;
        initMovieDetailsModule();
        return MaterialPageRoute(
          builder: (_) => MovieDetailsView(movieId: movieId),
        );
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold());
    }
  }

  static Future<void> navigateAndRemoveUntil(
      BuildContext context, String routeName) {
    return Navigator.of(context).pushAndRemoveUntil(
      getRoute(RouteSettings(name: routeName)),
      (route) => false,
    );
  }

  static Future<void> navigateToMovieDetails(
      BuildContext context, int movieId) {
    return Navigator.pushNamed(
      context,
      Routes.movieDetailsRoute,
      arguments: movieId,
    );
  }
}
