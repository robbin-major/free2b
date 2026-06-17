import 'package:cached_network_image/cached_network_image.dart';
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

  @override
  Widget build(BuildContext context) {
    final String url = imageUrl?.trim() ?? '';
    final Widget image = url.isEmpty
        ? _fallbackImage()
        : CachedNetworkImage(
            imageUrl: url,
            height: height,
            width: width,
            fit: fit,
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
}
