import 'package:ai_movie_suggestion/presentation/resources/language_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const String prefKeyLang = "PREFS_KEY_LANG";
const String keyAccessToken = 'ACCESS_TOKEN';
const String prefKeyIsUserLoggedIn = "PREFS_KEY_IS_USER_LOGGED_IN";
const String prefKeyOnBoardingScreenViewed =
    "PREFS_KEY_ONBOARDING_SCREEN_VIEWED";
const String _keyRegisterEmail = "REGISTER_EMAIL";
const String _keyWatchlistMovies = "WATCHLIST_MOVIES";
// New keys for remember me functionality
const String _keyRememberMe = "REMEMBER_ME";
const String _keyRememberedEmail = "REMEMBERED_EMAIL";
const String _keyRememberedPassword = "REMEMBERED_PASSWORD";
// New key for chat history
const String _keyChatHistory = "CHAT_HISTORY";
// New key for liked movies
const String _keyLikedMovies = "LIKED_MOVIES";

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

  // ============ REMEMBER ME METHODS ============

  /// Save remember me preference and credentials
  Future<void> setRememberMe(bool rememberMe, {String? email, String? password}) async {
    await _sharedPreferences.setBool(_keyRememberMe, rememberMe);
    
    if (rememberMe && email != null && password != null) {
      // Only save credentials if remember me is true and credentials are provided
      await _sharedPreferences.setString(_keyRememberedEmail, email);
      await _sharedPreferences.setString(_keyRememberedPassword, password);
    } else if (!rememberMe) {
      // If remember me is false, clear saved credentials
      await _sharedPreferences.remove(_keyRememberedEmail);
      await _sharedPreferences.remove(_keyRememberedPassword);
    }
  }

  /// Get remember me preference
  Future<bool> getRememberMe() async {
    return _sharedPreferences.getBool(_keyRememberMe) ?? false;
  }

  /// Get remembered email
  Future<String?> getRememberedEmail() async {
    return _sharedPreferences.getString(_keyRememberedEmail);
  }

  /// Get remembered password
  Future<String?> getRememberedPassword() async {
    return _sharedPreferences.getString(_keyRememberedPassword);
  }

  /// Check if user has valid remembered credentials
  Future<bool> hasRememberedCredentials() async {
    final rememberMe = await getRememberMe();
    final email = await getRememberedEmail();
    final password = await getRememberedPassword();
    
    return rememberMe && 
           email != null && email.isNotEmpty && 
           password != null && password.isNotEmpty;
  }

  /// Clear all remember me data
  Future<void> clearRememberMe() async {
    await _sharedPreferences.remove(_keyRememberMe);
    await _sharedPreferences.remove(_keyRememberedEmail);
    await _sharedPreferences.remove(_keyRememberedPassword);
  }

  /// Get remembered credentials as a map
  Future<Map<String, String?>> getRememberedCredentials() async {
    return {
      'email': await getRememberedEmail(),
      'password': await getRememberedPassword(),
    };
  }

  // ============ WATCHLIST METHODS ============

  /// Get the list of watchlisted movie IDs
  Future<List<int>> getWatchlistMovieIds() async {
    final String? watchlistJson =
        _sharedPreferences.getString(_keyWatchlistMovies);
    if (watchlistJson == null || watchlistJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(watchlistJson);
      return decodedList.map((id) => int.parse(id.toString())).toList();
    } catch (e) {
      // If there's an error parsing, return empty list and clear corrupted data
      await _sharedPreferences.remove(_keyWatchlistMovies);
      return [];
    }
  }

  /// Add a movie ID to the watchlist
  Future<void> addToWatchlist(int movieId) async {
    final List<int> currentWatchlist = await getWatchlistMovieIds();

    if (!currentWatchlist.contains(movieId)) {
      currentWatchlist.add(movieId);
      await _saveWatchlistIds(currentWatchlist);
    }
  }

  /// Remove a movie ID from the watchlist
  Future<void> removeFromWatchlist(int movieId) async {
    final List<int> currentWatchlist = await getWatchlistMovieIds();

    if (currentWatchlist.contains(movieId)) {
      currentWatchlist.remove(movieId);
      await _saveWatchlistIds(currentWatchlist);
    }
  }

  /// Check if a movie is in the watchlist
  Future<bool> isMovieInWatchlist(int movieId) async {
    final List<int> watchlistIds = await getWatchlistMovieIds();
    return watchlistIds.contains(movieId);
  }

  /// Toggle movie in watchlist (add if not present, remove if present)
  /// Returns true if movie was added, false if removed
  Future<bool> toggleMovieInWatchlist(int movieId) async {
    final bool isCurrentlyInWatchlist = await isMovieInWatchlist(movieId);

    if (isCurrentlyInWatchlist) {
      await removeFromWatchlist(movieId);
      return false; // Movie was removed
    } else {
      await addToWatchlist(movieId);
      return true; // Movie was added
    }
  }

  /// Get the count of movies in watchlist
  Future<int> getWatchlistCount() async {
    final List<int> watchlistIds = await getWatchlistMovieIds();
    return watchlistIds.length;
  }

  /// Clear all movies from watchlist
  Future<void> clearWatchlist() async {
    await _sharedPreferences.remove(_keyWatchlistMovies);
  }

  /// Private method to save the watchlist IDs
  Future<void> _saveWatchlistIds(List<int> movieIds) async {
    final String watchlistJson = jsonEncode(movieIds);
    await _sharedPreferences.setString(_keyWatchlistMovies, watchlistJson);
  }

  /// Get watchlist as a Set for faster lookups (optional utility method)
  Future<Set<int>> getWatchlistMovieIdsSet() async {
    final List<int> watchlistIds = await getWatchlistMovieIds();
    return watchlistIds.toSet();
  }

  // ============ LIKED MOVIES METHODS ============

  /// Get the list of liked movie IDs
  Future<List<int>> getLikedMovieIds() async {
    final String? likedMoviesJson =
        _sharedPreferences.getString(_keyLikedMovies);
    if (likedMoviesJson == null || likedMoviesJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(likedMoviesJson);
      return decodedList.map((id) => int.parse(id.toString())).toList();
    } catch (e) {
      // If there's an error parsing, return empty list and clear corrupted data
      await _sharedPreferences.remove(_keyLikedMovies);
      return [];
    }
  }

  /// Add a movie ID to the liked movies list
  Future<void> addToLikedMovies(int movieId) async {
    final List<int> currentLikedMovies = await getLikedMovieIds();

    if (!currentLikedMovies.contains(movieId)) {
      currentLikedMovies.add(movieId);
      await _saveLikedMovieIds(currentLikedMovies);
    }
  }

  /// Remove a movie ID from the liked movies list
  Future<void> removeFromLikedMovies(int movieId) async {
    final List<int> currentLikedMovies = await getLikedMovieIds();

    if (currentLikedMovies.contains(movieId)) {
      currentLikedMovies.remove(movieId);
      await _saveLikedMovieIds(currentLikedMovies);
    }
  }

  /// Check if a movie is in the liked movies list
  Future<bool> isMovieInLikedMovies(int movieId) async {
    final List<int> likedMovieIds = await getLikedMovieIds();
    return likedMovieIds.contains(movieId);
  }

  /// Toggle movie in liked movies list (add if not present, remove if present)
  /// Returns true if movie was added, false if removed
  Future<bool> toggleMovieInLikedMovies(int movieId) async {
    final bool isCurrentlyLiked = await isMovieInLikedMovies(movieId);

    if (isCurrentlyLiked) {
      await removeFromLikedMovies(movieId);
      return false; // Movie was removed
    } else {
      await addToLikedMovies(movieId);
      return true; // Movie was added
    }
  }

  /// Get the count of liked movies
  Future<int> getLikedMoviesCount() async {
    final List<int> likedMovieIds = await getLikedMovieIds();
    return likedMovieIds.length;
  }

  /// Clear all movies from liked movies list
  Future<void> clearLikedMovies() async {
    await _sharedPreferences.remove(_keyLikedMovies);
  }

  /// Private method to save the liked movie IDs
  Future<void> _saveLikedMovieIds(List<int> movieIds) async {
    final String likedMoviesJson = jsonEncode(movieIds);
    await _sharedPreferences.setString(_keyLikedMovies, likedMoviesJson);
  }

  /// Get liked movies as a Set for faster lookups (optional utility method)
  Future<Set<int>> getLikedMovieIdsSet() async {
    final List<int> likedMovieIds = await getLikedMovieIds();
    return likedMovieIds.toSet();
  }

  // ============ CHAT HISTORY METHODS ============

  /// Save chat history to preferences
  /// Each message is stored as a map with text, isUser, timestamp, and optional movieDetail
  Future<void> saveChatHistory(List<Map<String, dynamic>> chatMessages) async {
    try {
      final String chatHistoryJson = jsonEncode(chatMessages);
      await _sharedPreferences.setString(_keyChatHistory, chatHistoryJson);
    } catch (e) {
      // Handle encoding errors silently
      print('Error saving chat history: $e');
    }
  }

  /// Get chat history from preferences
  /// Returns a list of maps representing chat messages
  Future<List<Map<String, dynamic>>> getChatHistory() async {
    final String? chatHistoryJson = _sharedPreferences.getString(_keyChatHistory);
    
    if (chatHistoryJson == null || chatHistoryJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decodedList = jsonDecode(chatHistoryJson);
      return decodedList.map((message) => Map<String, dynamic>.from(message)).toList();
    } catch (e) {
      // If there's an error parsing, return empty list and clear corrupted data
      await _sharedPreferences.remove(_keyChatHistory);
      return [];
    }
  }

  /// Check if chat history exists
  Future<bool> hasChatHistory() async {
    final List<Map<String, dynamic>> history = await getChatHistory();
    return history.isNotEmpty;
  }

  /// Clear all chat history
  Future<void> clearChatHistory() async {
    await _sharedPreferences.remove(_keyChatHistory);
  }

  /// Add a single message to chat history
  Future<void> addMessageToChatHistory(Map<String, dynamic> message) async {
    final List<Map<String, dynamic>> currentHistory = await getChatHistory();
    currentHistory.add(message);
    await saveChatHistory(currentHistory);
  }

  /// Get the count of messages in chat history
  Future<int> getChatHistoryCount() async {
    final List<Map<String, dynamic>> history = await getChatHistory();
    return history.length;
  }

  /// Update the last message in chat history (useful for updating with movie details)
  Future<void> updateLastMessageInChatHistory(Map<String, dynamic> updatedMessage) async {
    final List<Map<String, dynamic>> currentHistory = await getChatHistory();
    
    if (currentHistory.isNotEmpty) {
      currentHistory[currentHistory.length - 1] = updatedMessage;
      await saveChatHistory(currentHistory);
    }
  }

  /// Remove the last N messages from chat history
  Future<void> removeLastMessagesFromChatHistory(int count) async {
    final List<Map<String, dynamic>> currentHistory = await getChatHistory();
    
    if (currentHistory.length >= count) {
      final int newLength = currentHistory.length - count;
      final List<Map<String, dynamic>> trimmedHistory = currentHistory.sublist(0, newLength);
      await saveChatHistory(trimmedHistory);
    }
  }

  /// Limit chat history to a maximum number of messages (keeps the most recent ones)
  Future<void> limitChatHistory(int maxMessages) async {
    final List<Map<String, dynamic>> currentHistory = await getChatHistory();
    
    if (currentHistory.length > maxMessages) {
      final List<Map<String, dynamic>> limitedHistory = 
          currentHistory.sublist(currentHistory.length - maxMessages);
      await saveChatHistory(limitedHistory);
    }
  }

  // Add this method to your AppPreferences class to properly handle logout

/// Complete logout method that clears all user data
Future<void> performCompleteLogout() async {
  try {
    // Clear authentication token
    await deleteAccessToken();
    
    // Clear user login status
    await _sharedPreferences.setBool(prefKeyIsUserLoggedIn, false);
    
    // Clear registration email
    await removeRegisterEmail();
    
    // Clear remember me data
    await clearRememberMe();
    
    // Clear watchlist data
    await clearWatchlist();
    
    // Clear liked movies data
    await clearLikedMovies();
    
    // Clear chat history
    await clearChatHistory();
    
    // Optional: Uncomment these if you want to reset these preferences too
    // Clear language preference
    // await _sharedPreferences.remove(prefKeyLang);
    
    // Clear onboarding status (user will see onboarding again)
    // await _sharedPreferences.remove(prefKeyOnBoardingScreenViewed);
    
    print('Complete logout successful - all user data cleared');
  } catch (e) {
    print('Error during complete logout: $e');
    rethrow;
  }
}

/// Method to set user as logged out
Future<void> setUserLoggedOut() async {
  await _sharedPreferences.setBool(prefKeyIsUserLoggedIn, false);
}

/// Verify all critical user data has been cleared
Future<Map<String, bool>> verifyLogoutDataCleared() async {
  return {
    'tokenCleared': (await getAccessToken()) == null,
    'userLoggedOut': !(await isUserLoggedIn()),
    'registerEmailCleared': getRegisterEmail() == null,
    'rememberMeCleared': !(await getRememberMe()),
    'watchlistCleared': (await getWatchlistMovieIds()).isEmpty,
    'likedMoviesCleared': (await getLikedMovieIds()).isEmpty,
    'chatHistoryCleared': !(await hasChatHistory()),
  };
}
}