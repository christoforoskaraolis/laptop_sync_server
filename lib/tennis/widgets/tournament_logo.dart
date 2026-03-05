import 'dart:convert';

import 'package:flutter/material.dart';

import '../logo_helper.dart';

/// Shows tournament logo from [logoPath] (data URL or file path) or a placeholder.
class TournamentLogo extends StatelessWidget {
  final String? logoPath;
  final double size;
  final BoxShape shape;

  const TournamentLogo({
    super.key,
    this.logoPath,
    this.size = 80,
    this.shape = BoxShape.circle,
  });

  @override
  Widget build(BuildContext context) {
    if (logoPath == null || logoPath!.isEmpty) {
      return _placeholder(context);
    }
    if (isLogoDataUrl(logoPath)) {
      try {
        final base64 = logoPath!.split(',').last;
        final bytes = base64Decode(base64);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: shape,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {
        return _placeholder(context);
      }
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        Icons.emoji_events,
        size: size * 0.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
