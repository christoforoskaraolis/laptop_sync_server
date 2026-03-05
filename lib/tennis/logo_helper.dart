import 'dart:convert';

import 'package:image_picker/image_picker.dart';

/// Picks a tournament logo and returns a data URL to store in [Tournament.logoPath]:
/// "data:image/jpeg;base64,...". Works on mobile and web.
/// Returns null if pick fails or user cancels.
Future<String?> pickAndSaveTournamentLogo() async {
  final picker = ImagePicker();
  final xFile = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 512,
    maxHeight: 512,
    imageQuality: 85,
  );
  if (xFile == null) return null;
  final bytes = await xFile.readAsBytes();
  return 'data:image/jpeg;base64,${base64Encode(bytes)}';
}

/// Returns true if [logoPath] is a base64 data URL.
bool isLogoDataUrl(String? logoPath) =>
    logoPath != null && logoPath.startsWith('data:image');
