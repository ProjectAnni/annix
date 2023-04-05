import 'package:annix/providers.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final info = ref.watch(annivProvider.select((final v) => v.info));
    if (info == null) {
      return const _NotLoginAppBar();
    }

    final child = SearchBar(
      hintText: 'Search...',
      trailing: [
        IconButton(
          icon: CircleAvatar(
            child: Text(info.user.nickname.substring(0, 1)),
          ),
          onPressed: () {
            AnnixRouterDelegate.of(context).to(name: '/server');
          },
        )
      ],
      onTap: () {
        AnnixRouterDelegate.of(context).to(name: '/search');
      },
    );

    return SliverToBoxAdapter(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class _NotLoginAppBar extends StatelessWidget {
  const _NotLoginAppBar();

  @override
  Widget build(final BuildContext context) {
    return SliverAppBar.large(
      title: Row(
        children: [
          Text(t.server.not_logged_in),
          TextButton(
            child: Text(t.server.login),
            onPressed: () {
              AnnixRouterDelegate.of(context).to(name: '/login');
            },
          ),
        ],
      ),
    );
  }
}
