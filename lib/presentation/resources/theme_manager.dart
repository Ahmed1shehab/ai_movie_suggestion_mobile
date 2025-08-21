import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/font_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/styles_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';

ThemeData getDefaultApplicationTheme() {
  return ThemeData(
    // main colors of the app
    primaryColor: ColorManager.primary,
    disabledColor: ColorManager.grey,
    splashColor: ColorManager.primary,
    // card view theme
    cardTheme: CardThemeData(
      color: ColorManager.white,
      shadowColor: ColorManager.grey,
      elevation: AppSize.s4,
    ),
    // app bar theme
    appBarTheme: AppBarTheme(
        centerTitle: true,
        color: ColorManager.primary,
        elevation: AppSize.s4,
        shadowColor: ColorManager.secondaryPrimary,
        titleTextStyle: getRegularStyle(
            fontSize: FontSize.s24, color: ColorManager.secondaryBlack)),
    // button theme
    buttonTheme: ButtonThemeData(
        shape: const StadiumBorder(),
        disabledColor: ColorManager.grey,
        buttonColor: ColorManager.primary,
        splashColor: ColorManager.secondaryPrimary),
    // elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorManager.primary,
        foregroundColor: ColorManager.white,
        textStyle:
            getSemiBoldStyle(color: ColorManager.white, fontSize: FontSize.s16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.s12),
        ),
      ),
    ),
    // text theme
    textTheme: TextTheme(
      displayLarge: getSemiBoldStyle(
        color: ColorManager.secondaryBlack,
        fontSize: FontSize.s24,
      ),
      headlineLarge: getBoldStyle(
        color: ColorManager.white,
        fontSize: FontSize.s24,
      ),
      displayMedium: getMediumStyle(
        color: ColorManager.black,
      ),
      labelLarge: getBoldStyle(
        color: ColorManager.black,
        fontSize: FontSize.s24,
      ),
      bodySmall: getRegularStyle(
        color: ColorManager.grey,
        fontSize: FontSize.s14,
      ),
      bodyMedium: getRegularStyle(
        color: ColorManager.black,
        fontSize: FontSize.s14,
      ),
      labelSmall: getSemiBoldStyle(
        color: ColorManager.white,
        fontSize: FontSize.s12,
      ),
      titleSmall: getSemiBoldStyle(
        color: ColorManager.black,
        fontSize: FontSize.s14,
      ),
    ),

    //input decoration {TextField, TextFormField}
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(AppPadding.p12),
      filled: true,
      fillColor: ColorManager.white,
      hintStyle:
          getRegularStyle(color: ColorManager.grey, fontSize: FontSize.s14),
      labelStyle:
          getMediumStyle(color: ColorManager.grey, fontSize: FontSize.s14),
      errorStyle: getRegularStyle(
        color: ColorManager.error,
      ),
      prefixIconColor: ColorManager.grey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorManager.grey, width: AppSize.s1_5),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSize.s8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: ColorManager.primary, width: AppSize.s1_5),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSize.s8),
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorManager.error, width: AppSize.s1_5),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSize.s8),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: ColorManager.primary, width: AppSize.s1_5),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppSize.s8),
        ),
      ),
    ),
  );
}
