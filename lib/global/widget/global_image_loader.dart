import 'package:flutter/material.dart';
import 'package:home_widgets/utils/enum.dart';

class GlobalImageLoader extends StatelessWidget {
  const GlobalImageLoader({
    super.key,
    required this.imagePath,
    this.imageFor = ImageFor.asset,
    this.height,
    this.width,
    this.fit,
  });
  final String imagePath;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final ImageFor? imageFor;
  @override
  Widget build(BuildContext context) {
    if (imageFor == ImageFor.network) {
      return Image.network(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, exception, stackTrace) => const Text('😢'),
      );
    } else {
      return Image.asset(
        imagePath,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, exception, stackTrace) => const Text('😢'),
      );
    }
  }
}

 