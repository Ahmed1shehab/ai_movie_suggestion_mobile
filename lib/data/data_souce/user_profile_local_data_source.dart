import 'package:ai_movie_suggestion/data/network/error_handler.dart';
import 'package:ai_movie_suggestion/data/response/response.dart';
import 'package:flutter/foundation.dart';

const CACHE_USER_PROFILE = 'CACHE_USER_PROFILE';
// Cache time interval: 1 hour in milliseconds
const USER_PROFILE_CACHE_TIME_INTERVAL = 60 * 60 * 1000; // 1 hour in milliseconds

abstract class UserProfileLocalDataSource {
  Future<UserProfileResponse> getUserProfile(String userId);
  Future<void> saveUserProfile(String userId, UserProfileResponse userProfileResponse);
  void clearUserProfileCache();
  void removeUserProfileFromCache(String userId);
  bool isUserProfileCacheValid(String userId);
}

class UserProfileLocalDataSourceImpl implements UserProfileLocalDataSource {
  Map<String, CachedUserProfile> userProfileCacheMap = Map();

  // Generate cache key for user profile
  String _generateUserProfileCacheKey(String userId) {
    return '${CACHE_USER_PROFILE}_$userId';
  }

  @override
  Future<UserProfileResponse> getUserProfile(String userId) async {
    String cacheKey = _generateUserProfileCacheKey(userId);
    CachedUserProfile? cachedItem = userProfileCacheMap[cacheKey];
    
    if (kDebugMode) {
      print("🔍 Looking for user profile cache key: $cacheKey");
      print("🗂️ Available user profile cache keys: ${userProfileCacheMap.keys.toList()}");
      print("📦 User profile cache item found: ${cachedItem != null}");
      if (cachedItem != null) {
        print("⏰ User profile cache valid: ${cachedItem.isValid(USER_PROFILE_CACHE_TIME_INTERVAL)}");
        print("⏱️ Cache age: ${DateTime.now().millisecondsSinceEpoch - cachedItem.cacheTime}ms");
        print("⏳ Cache expires in: ${USER_PROFILE_CACHE_TIME_INTERVAL - (DateTime.now().millisecondsSinceEpoch - cachedItem.cacheTime)}ms");
      }
    }
    
    if (cachedItem != null && cachedItem.isValid(USER_PROFILE_CACHE_TIME_INTERVAL)) {
      if (kDebugMode) {
        print("✅ Cache hit for user profile: $userId");
      }
      return cachedItem.data as UserProfileResponse;
    } else {
      if (kDebugMode) {
        if (cachedItem != null) {
          print("❌ Cache expired for user profile: $userId");
        } else {
          print("❌ Cache miss for user profile: $userId");
        }
      }
      throw ErrorHandler.handle(DataSource.CACHE_ERROR);
    }
  }

  @override
  Future<void> saveUserProfile(String userId, UserProfileResponse userProfileResponse) async {
    String cacheKey = _generateUserProfileCacheKey(userId);
    userProfileCacheMap[cacheKey] = CachedUserProfile(userProfileResponse);
    
    if (kDebugMode) {
      print("💾 Saved user profile to cache with key: $cacheKey");
      print("📊 User profile cache size: ${userProfileCacheMap.length}");
      print("👤 Saved profile for user: $userId");
    }
  }

  @override
  void clearUserProfileCache() {
    userProfileCacheMap.clear();
    if (kDebugMode) {
      print("🗑️ User profile cache cleared");
    }
  }

  @override
  void removeUserProfileFromCache(String userId) {
    String cacheKey = _generateUserProfileCacheKey(userId);
    userProfileCacheMap.remove(cacheKey);
    if (kDebugMode) {
      print("🗑️ Removed user profile from cache: $userId");
    }
  }

  @override
  bool isUserProfileCacheValid(String userId) {
    String cacheKey = _generateUserProfileCacheKey(userId);
    CachedUserProfile? cachedItem = userProfileCacheMap[cacheKey];
    return cachedItem != null && cachedItem.isValid(USER_PROFILE_CACHE_TIME_INTERVAL);
  }

  // Helper method to remove expired user profile cache items
  void removeExpiredUserProfiles() {
    int removedCount = 0;
    userProfileCacheMap.removeWhere((key, cachedItem) {
      bool isExpired = !cachedItem.isValid(USER_PROFILE_CACHE_TIME_INTERVAL);
      if (isExpired) removedCount++;
      return isExpired;
    });
    
    if (kDebugMode) {
      print("🧹 Removed $removedCount expired user profile items");
    }
  }

  // Helper method to get user profile cache size
  int getUserProfileCacheSize() {
    return userProfileCacheMap.length;
  }

  // Helper method to check if specific user profile is cached and valid
  bool isUserProfileCached(String userId) {
    String cacheKey = _generateUserProfileCacheKey(userId);
    CachedUserProfile? cachedItem = userProfileCacheMap[cacheKey];
    return cachedItem != null && cachedItem.isValid(USER_PROFILE_CACHE_TIME_INTERVAL);
  }

  // Helper method to get all user profile cache keys (useful for debugging)
  List<String> getAllUserProfileCacheKeys() {
    return userProfileCacheMap.keys.toList();
  }

  // Helper method to get user profile cache statistics
  Map<String, dynamic> getUserProfileCacheStats() {
    int totalItems = userProfileCacheMap.length;
    int validItems = 0;
    int expiredItems = 0;

    userProfileCacheMap.forEach((key, cachedItem) {
      if (cachedItem.isValid(USER_PROFILE_CACHE_TIME_INTERVAL)) {
        validItems++;
      } else {
        expiredItems++;
      }
    });

    return {
      'totalItems': totalItems,
      'validItems': validItems,
      'expiredItems': expiredItems,
      'cacheValidityDuration': '${USER_PROFILE_CACHE_TIME_INTERVAL ~/ (1000 * 60)} minutes',
    };
  }

  // Helper method to get time until cache expiry for a specific user
  Duration? getTimeUntilExpiry(String userId) {
    String cacheKey = _generateUserProfileCacheKey(userId);
    CachedUserProfile? cachedItem = userProfileCacheMap[cacheKey];
    
    if (cachedItem == null) return null;
    
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int expiryTime = cachedItem.cacheTime + USER_PROFILE_CACHE_TIME_INTERVAL;
    int remainingTime = expiryTime - currentTime;
    
    return remainingTime > 0 ? Duration(milliseconds: remainingTime) : Duration.zero;
  }

  // Helper method to force refresh a user profile (removes from cache)
  void forceRefreshUserProfile(String userId) {
    removeUserProfileFromCache(userId);
    if (kDebugMode) {
      print("🔄 Forced refresh for user profile: $userId");
    }
  }

  // Helper method to get cached user IDs
  List<String> getCachedUserIds() {
    return userProfileCacheMap.keys
        .map((key) => key.replaceFirst('${CACHE_USER_PROFILE}_', ''))
        .toList();
  }
}

class CachedUserProfile {
  dynamic data;
  int cacheTime = DateTime.now().millisecondsSinceEpoch;

  CachedUserProfile(this.data);
}

extension CachedUserProfileExtension on CachedUserProfile {
  bool isValid(int expirationTimeInMillis) {
    int currentTimeInMillis = DateTime.now().millisecondsSinceEpoch;
    bool isValid = currentTimeInMillis - cacheTime <= expirationTimeInMillis;
    return isValid;
  }

  // Get age of cache item
  Duration getCacheAge() {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int ageInMillis = currentTime - cacheTime;
    return Duration(milliseconds: ageInMillis);
  }

  // Get time until expiry
  Duration getTimeUntilExpiry(int expirationTimeInMillis) {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int expiryTime = cacheTime + expirationTimeInMillis;
    int remainingTime = expiryTime - currentTime;
    return remainingTime > 0 ? Duration(milliseconds: remainingTime) : Duration.zero;
  }
}