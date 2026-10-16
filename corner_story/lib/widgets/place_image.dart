import 'package:flutter/material.dart';

import '../theme/corner_theme.dart';
import '../services/place_photos.dart';

/// An empty image must not imply that an unrelated design photo is this venue.
class PlaceImage extends StatelessWidget {
  const PlaceImage({super.key, required this.source, this.compact = false});
  final String source;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: CornerColors.surfaceContainer,
      child: Center(
        child: compact
            ? Icon(
                Icons.place_outlined,
                size: 24,
                color: CornerColors.secondary,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.photo_outlined,
                    size: 32,
                    color: CornerColors.secondary,
                  ),
                  SizedBox(height: 10),
                  Text('PHOTO NOT ADDED', style: CornerTypography.labelCaps),
                ],
              ),
      ),
    );
    if (source.isEmpty) return placeholder;
    final resolvedSource = placePhotoUrls[source] ?? source;
    if (resolvedSource.startsWith('assets/')) {
      return Image.asset(
        resolvedSource,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stack) => placeholder,
      );
    }
    return Image.network(
      resolvedSource,
      fit: BoxFit.cover,
      errorBuilder: (_, error, stack) => placeholder,
    );
  }
}
