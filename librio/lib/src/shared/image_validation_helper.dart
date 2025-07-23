import 'package:flutter/material.dart';

class ImageValidationHelper {
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    if (url.startsWith('file://') || !url.startsWith('http')) return false;

    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  static ImageProvider? getImageProvider(String? url) {
    if (isValidImageUrl(url)) {
      return NetworkImage(url!);
    }
    return null;
  }

  static bool shouldShowFallback(String? url) {
    return !isValidImageUrl(url);
  }
}
