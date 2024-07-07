import 'package:annix/providers.dart';
import 'package:annix/ui/dialogs/loading.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeActionGrid extends ConsumerWidget {
  const HomeActionGrid({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: context.isDesktopOrLandscape
          ? 4 /* display all buttons in one line on desktop */
          : 2 /* on mobile */,
      semanticChildCount: 4,
      childAspectRatio: context.isDesktopOrLandscape ? 1 : 3.6,
      shrinkWrap: true,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        HomeActionButton(
          icon: const Icon(Icons.favorite_outline),
          title: t.my_favorite,
          onPressed: () {
            ref.read(routerProvider).to(name: '/favorite');
          },
        ),
        HomeActionButton(
          icon: const Icon(Icons.shuffle),
          title: t.playback.shuffle,
          onPressed: () {
            showLoadingDialog(context);
            ref.read(playbackProvider).fullShuffleMode().then(
              (final value) {
                Navigator.of(context, rootNavigator: true).pop();
              },
            );
          },
        ),
        HomeActionButton(
          icon: const Icon(Icons.history),
          title: t.recent_played,
          onPressed: () {
            ref.read(routerProvider).to(name: '/history');
          },
        ),
        HomeActionButton(
          icon: const Icon(Icons.download),
          title: t.download,
          onPressed: () {
            ref.read(routerProvider).to(name: '/downloading');
          },
        ),
      ],
    );
  }
}

class HomeActionButton extends StatelessWidget {
  final Icon icon;
  final String title;
  final VoidCallback? onPressed;

  const HomeActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(final BuildContext context) {
    return ElevatedButton.icon(
      icon: icon,
      label: Text(title),
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        minimumSize: Size.infinite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
