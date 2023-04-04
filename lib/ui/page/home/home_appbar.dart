import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:provider/provider.dart';

// Modified from https://github.com/flutter/flutter/issues/117483#issuecomment-1377699454
class FloatingSearchBar extends StatelessWidget {
  const FloatingSearchBar({
    final Key? key,
    this.height = 56,
    required this.trailingIcon,
    required this.supportingText,
  }) : super(key: key);

  final double height;
  final Widget trailingIcon;

  final String supportingText;

  @override
  Widget build(final BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        constraints: const BoxConstraints(minWidth: 360),
        width: double.infinity,
        height: height,
        child: Material(
          elevation: 3,
          color: colorScheme.surface,
          shadowColor: colorScheme.shadow,
          surfaceTintColor: colorScheme.surfaceTint,
          borderRadius: BorderRadius.circular(height / 2),
          child: InkWell(
            onTap: () {
              AnnixRouterDelegate.of(context).to(name: '/search');
            },
            borderRadius: BorderRadius.circular(height / 2),
            highlightColor: Colors.transparent,
            splashFactory: InkRipple.splashFactory,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextField(
                      enabled: false,
                      cursorColor: colorScheme.primary,
                      style: textTheme.bodyLarge,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        hintText: supportingText,
                        hintStyle: textTheme.bodyLarge?.apply(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        fillColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                trailingIcon,
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(final BuildContext context) {
    final anniv = context.watch<AnnivService>();
    final info = anniv.info;

    if (info != null) {
      return SliverToBoxAdapter(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: FloatingSearchBar(
              trailingIcon: IconButton(
                icon: CircleAvatar(
                  child: Text(info.user.nickname.substring(0, 1)),
                ),
                onPressed: () {
                  AnnixRouterDelegate.of(context).to(name: '/server');
                },
              ),
              supportingText: 'Search...',
            ),
          ),
        ),
      );
    } else {
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
}
