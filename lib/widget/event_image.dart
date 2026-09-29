import 'dart:developer' as developer;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/utils/assets.dart';

class EventImage extends StatelessWidget {
  const EventImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  static int _instrumentedBuildCount = 0;

  static int get instrumentedBuildCount => _instrumentedBuildCount;

  @override
  Widget build(BuildContext context) {
    final String url = imageUrl?.trim() ?? '';
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double logicalWidth = width != null && width!.isFinite
        ? width!
        : mediaQuery.size.width;
    final int memCacheWidth = _targetPixels(
      logicalWidth,
      mediaQuery.devicePixelRatio,
    );
    final int? memCacheHeight = height == null || !height!.isFinite
        ? null
        : _targetPixels(height!, mediaQuery.devicePixelRatio);

    if (kDebugMode || kProfileMode) {
      _instrumentedBuildCount++;
      developer.Timeline.instantSync(
        'EventImage.build',
        arguments: <String, Object>{
          'build': _instrumentedBuildCount,
          'remote': url.isNotEmpty,
          'memCacheWidth': memCacheWidth,
          if (memCacheHeight != null) 'memCacheHeight': memCacheHeight,
        },
      );
    }

    final Widget image = url.isEmpty
        ? _fallbackImage()
        : CachedNetworkImage(
            imageUrl: url,
            height: height,
            width: width,
            fit: fit,
            memCacheWidth: memCacheWidth,
            memCacheHeight: memCacheHeight,
            placeholder: (context, url) => _fallbackImage(),
            errorWidget: (context, url, error) => _fallbackImage(),
          );

    final Widget sizedImage = SizedBox(
      height: height,
      width: width,
      child: image,
    );

    if (borderRadius == null) {
      return sizedImage;
    }

    return ClipRRect(
      borderRadius: borderRadius!,
      child: sizedImage,
    );
  }

  Widget _fallbackImage() {
    return Image.asset(
      TempImage.tempImage1,
      height: height,
      width: width,
      fit: fit,
    );
  }

  int _targetPixels(double logicalDimension, double devicePixelRatio) {
    return (logicalDimension * devicePixelRatio)
        .ceil()
        .clamp(1, 2048)
        .toInt();
  }
}
