import 'package:ai_movie_suggestion/presentation/resources/language_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String prefKeyLang = "PREFS_KEY_LANG";
const String keyAccessToken = 'ACCESS_TOKEN';
const String prefKeyIsUserLoggedIn = "PREFS_KEY_IS_USER_LOGGED_IN";

const String prefKeyOnBoardingScreenViewed =
    "PREFS_KEY_ONBOARDING_SCREEN_VIEWED";
  const String _keyRegisterEmail = "REGISTER_EMAIL";

class AppPreferences {
  final SharedPreferences _sharedPreferences;
  AppPreferences(this._sharedPreferences);
  Future<String> getAppLanguage() async {
    String? language = _sharedPreferences.getString(prefKeyLang);
    if (language != null && language.isNotEmpty) {
      return language;
    } else {
      //return default language
      return LanguageType.english.getValue();
    }
  }

  //onBoarding
  Future<void> setOnBoardingScreenViewed() async {
    _sharedPreferences.setBool(prefKeyOnBoardingScreenViewed, true);
  }

  //
  Future<bool> isOnBoardingScreenViewed() async {
    return _sharedPreferences.getBool(prefKeyOnBoardingScreenViewed) ?? false;
  }

  //Token
  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAccessToken, token);
  }

  Future<String?> getAccessToken() async {
    return _sharedPreferences.getString(keyAccessToken);
  }

  Future<void> deleteAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyAccessToken);
  }

  Future<void> updateAccessToken(String newToken) async {
    await _sharedPreferences.setString(keyAccessToken, newToken);
  }

  Future<void> setUserLoggedIn() async {
    _sharedPreferences.setBool(prefKeyIsUserLoggedIn, true);
  }

//
  Future<bool> isUserLoggedIn() async {
    return _sharedPreferences.getBool(prefKeyIsUserLoggedIn) ?? false;
  }


  Future<void> setRegisterEmail(String email) async {
    await _sharedPreferences.setString(_keyRegisterEmail, email);
  }

  String? getRegisterEmail() {
    return _sharedPreferences.getString(_keyRegisterEmail);
  }

  Future<void> removeRegisterEmail() async {
    await _sharedPreferences.remove(_keyRegisterEmail);
  }
}
