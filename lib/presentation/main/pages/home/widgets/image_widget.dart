import 'package:ai_movie_suggestion/app/functions.dart';
import 'package:ai_movie_suggestion/presentation/resources/color_manager.dart';
import 'package:ai_movie_suggestion/presentation/resources/values_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

Widget buildNetworkImage({
  required String? imageUrl,
  required double width,
  required double height,
  BoxFit fit = BoxFit.fitHeight,
  Widget? placeholder,
  Widget? errorWidget,
}) {
  if (!isValidUrl(imageUrl)) {
    return _buildErrorPlaceholder(width, height, errorWidget);
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(AppSize.s8),
    child: CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      // Remove memory cache dimensions that might cause decode issues
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      // Add error handling for image decoding
      imageBuilder: (context, imageProvider) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSize.s8),
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
              onError: (exception, stackTrace) {
                debugPrint('Image decoration error: $exception');
              },
            ),
          ),
        );
      },
      placeholder: (context, url) =>
          placeholder ?? _buildLoadingPlaceholder(width, height),
      errorWidget: (context, url, error) {
        debugPrint('Network image error: $error');
        return _buildErrorPlaceholder(width, height, errorWidget);
      },
    ),
  );
}

Widget _buildLoadingPlaceholder(double width, double height) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: ColorManager.grey,
      borderRadius: BorderRadius.circular(AppSize.s8),
    ),
    child: const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2.0),
      ),
    ),
  );
}

Widget _buildErrorPlaceholder(
    double width, double height, Widget? errorWidget) {
  return errorWidget ??
      Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: ColorManager.grey,
          borderRadius: BorderRadius.circular(AppSize.s8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              color: ColorManager.cardColor,
              size: math.min(width * 0.25, 32),
            ),
            const SizedBox(height: 4),
            if (width > 60 && height > 60)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  'Image unavailable',
                  style: TextStyle(
                    color: ColorManager.cardColor,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      );
}

class RobustNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const RobustNetworkImage({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty || !_isValidUrl(imageUrl!)) {
      return _buildErrorPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: Container(
        width: width,
        height: height,
        child: Image.network(
          imageUrl!,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return _buildLoadingPlaceholder();
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Image loading error: $error');
            // Fallback to CachedNetworkImage for better error handling
            return CachedNetworkImage(
              imageUrl: imageUrl!,
              width: width,
              height: height,
              fit: fit,
              placeholder: (context, url) => _buildLoadingPlaceholder(),
              errorWidget: (context, url, error) {
                debugPrint('CachedNetworkImage error: $error');
                return _buildErrorPlaceholder();
              },
            );
          },
        ),
      ),
    );
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Widget _buildLoadingPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            ),
          ),
        );
  }

  Widget _buildErrorPlaceholder() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_not_supported,
                color: Colors.grey[600],
                size: math.min(width * 0.25, 32),
              ),
              const SizedBox(height: 4),
              if (width > 60 && height > 60)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Image unavailable',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        );
  }
}
