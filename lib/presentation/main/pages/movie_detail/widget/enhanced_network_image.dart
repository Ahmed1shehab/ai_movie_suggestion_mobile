import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class EnhancedNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const EnhancedNetworkImage({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.fill,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!_isValidImageUrl(imageUrl)) {
      return _buildErrorWidget();
    }

    final cleanUrl = _cleanImageUrl(imageUrl!);

    return CachedNetworkImage(
      imageUrl: cleanUrl,
      width: width,
      height: height,
      fit: fit,
      // Remove memCacheWidth to avoid potential issues
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) {
        debugPrint('Image loading error for URL: $url');
        debugPrint('Error: $error');
        return _buildErrorWidget();
      },
      // Add these properties to handle network issues
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
      // Add timeout handling
      httpHeaders: const {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      },
    );
  }

  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      
      // Check if it's a valid HTTP/HTTPS URL
      if (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        return false;
      }
      
      // Check if it has a host
      if (!uri.hasAuthority || uri.host.isEmpty) {
        return false;
      }
      
      // Check for common image extensions
      final path = uri.path.toLowerCase();
      final supportedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
      
      // If no extension, assume it might be a dynamic image URL
      if (!supportedExtensions.any((ext) => path.endsWith(ext))) {
        // Check if it's a dynamic image URL (contains image-related keywords)
        if (!path.contains('image') && 
            !path.contains('img') && 
            !path.contains('photo') && 
            !path.contains('picture') &&
            !url.contains('w=') && // Width parameter
            !url.contains('h=')) { // Height parameter
          debugPrint('Potentially invalid image URL: $url');
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('URL parsing error: $e');
      return false;
    }
  }

  String _cleanImageUrl(String url) {
    // Remove any whitespace
    url = url.trim();
    
    // Fix common URL issues
    if (url.startsWith('//')) {
      url = 'https:$url';
    }
    
    // Encode special characters if needed
    try {
      final uri = Uri.parse(url);
      return uri.toString();
    } catch (e) {
      debugPrint('URL cleaning error: $e');
      return url;
    }
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(
            Icons.image_not_supported,
            color: Colors.grey,
            size: 40,
          ),
        );
  }
}