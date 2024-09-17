import 'package:annix/i18n/strings.g.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AnnivNotLoginCard extends ConsumerWidget {
  const AnnivNotLoginCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16, right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.server.not_logged_in,
              style: context.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              t.server.anniv_features,
              style: context.textTheme.bodyMedium,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                child: Text(t.server.login),
                onPressed: () {
                  context.push('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
