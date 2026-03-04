import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(Connectivity connectivity) : _connectivity = connectivity;

  @override
  Future<bool> get isConnected async {
    final startTime = DateTime.now();
    debugPrint(
      '[NetworkInfo] 🔍 Checking connection at ${startTime.toIso8601String()}',
    );

    try {
      final result = await _connectivity.checkConnectivity();
      
      // Handle the result whether it's a List or single value
      final isConnected = _checkConnection(result);

      final elapsed = DateTime.now().difference(startTime);
      
      debugPrint('[NetworkInfo] ⏱️ Check completed in ${elapsed.inMilliseconds}ms');
      debugPrint('[NetworkInfo] 📡 Connectivity Result: $result');
      debugPrint('[NetworkInfo] ✅ Is Connected: $isConnected');

      return isConnected;
    } catch (e, stackTrace) {
      debugPrint('[NetworkInfo] ❌ Error checking connectivity: $e');
      debugPrint('[NetworkInfo] 📋 Stack trace: $stackTrace');
      // Return true to allow the request to proceed
      debugPrint('[NetworkInfo] ⚠️ Assuming connected, letting Dio handle network errors');
      return true;
    }
  }

  bool _checkConnection(dynamic result) {
    // Handle List<ConnectivityResult> (newer versions)
    if (result is List) {
      return result.isNotEmpty && 
             result.any((r) => r != ConnectivityResult.none);
    }
    
    // Handle single ConnectivityResult (older versions)
    if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }
    
    // Unknown type, assume connected
    debugPrint('[NetworkInfo] ⚠️ Unknown connectivity result type: ${result.runtimeType}');
    return true;
  }
}