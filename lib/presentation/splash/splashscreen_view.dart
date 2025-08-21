import 'dart:async';

import 'package:ai_movie_suggestion/app/app_prefs.dart';
import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/presentation/resources/assets_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/constants_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/font_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/routes_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/string_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';

class SplashscreenView extends StatefulWidget {
  const SplashscreenView({super.key});

  @override
  State<SplashscreenView> createState() => _SplashscreenView();
}

class _SplashscreenView extends State<SplashscreenView> {
  final AppPreferences _appPreferences = instance<AppPreferences>();

  // ignore: unused_field
  Timer? _timer;

  _startDelay() {
    _timer = Timer(const Duration(seconds: AppConstants.splashDelay), _goNext);
  }

  _goNext() async{
     Navigator.pushReplacementNamed(context, Routes.onboardingRoute);
  //  try {
  //     // First check if onboarding has been viewed
  //     final isOnBoardingScreenViewed = await _appPreferences.isOnBoardingScreenViewed();
      
  //     if (!isOnBoardingScreenViewed) {
  //       // User hasn't seen onboarding yet, navigate to onboarding
  //       debugPrint('[SplashScreen] User hasn\'t seen onboarding, navigating to onboarding');
  //       if (mounted) {
  //         Navigator.pushReplacementNamed(context, Routes.onboardingRoute);
  //       }
  //       return;
  //     }
      
  //     // Check if user is already logged in
  //     final isUserLoggedIn = await _appPreferences.isUserLoggedIn();
      
  //     if (isUserLoggedIn) {
  //       // Check if user has remember me enabled with valid credentials
  //       final hasRememberedCredentials = await _appPreferences.hasRememberedCredentials();
        
  //       if (hasRememberedCredentials) {
  //         // User is logged in and has remember me enabled, go directly to main
  //         debugPrint('[SplashScreen] User has remembered credentials, navigating to main');
  //         if (mounted) {
  //           Navigator.pushReplacementNamed(context, Routes.mainRoute);
  //         }
  //         return;
  //       }
  //     }
      
  //     // Default behavior: go to login screen
  //     debugPrint('[SplashScreen] Navigating to login screen');
  //     if (mounted) {
  //       Navigator.pushReplacementNamed(context, Routes.loginRoute);
  //     }
  //   } catch (e) {
  //     debugPrint('[SplashScreen] Error in _goNext: $e');
  //     // In case of error, navigate to login
  //     if (mounted) {
  //       Navigator.pushReplacementNamed(context, Routes.loginRoute);
  //     }
  //   }
    
    // Alternative logic if you want to check onboarding:
    // _appPreferences.isOnBoardingScreenViewed().then((isOnBoardingScreenViewed) {
    //   if (isOnBoardingScreenViewed) {
    //     //navigate login
    //     Navigator.pushReplacementNamed(context, Routes.loginRoute);
    //   } else {
    //     //navigate onboarding
    //     Navigator.pushReplacementNamed(context, Routes.onboardingRoute);
    //   }
    // });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _goNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  ImagesAssets.splashLogo,
                  width: double.infinity,
                  height: AppHeight.h170,
                  fit: BoxFit.contain,
                ),
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      fontFamily: FontConstants.fontFamilyInter,
                      fontSize: AppSize.s36),
                ),
                const SizedBox(height: 5),
                Text(
                  AppStrings.discoverMovies,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppHeight.h30),
                const SizedBox(
                  width: AppWidth.w170,
                  child: LinearProgressIndicator(
                    color: Colors.deepPurpleAccent,
                    backgroundColor: Colors.white24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.loading,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontSize: AppSize.s12),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  Text(
                    AppStrings.version,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: AppSize.s12,
                        color: ColorManager.secondaryWhite),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.copyRight,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: AppSize.s12,
                        color: ColorManager.secondaryWhite),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
