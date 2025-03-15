import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

class AlbumTitleText extends StatelessWidget {
  final String title;
  const AlbumTitleText({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.labelMedium?.copyWith(
        color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
