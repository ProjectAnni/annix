import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

class DragHandle extends StatelessWidget {
  const DragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        height: 4,
        width: 32,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.onSurfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
