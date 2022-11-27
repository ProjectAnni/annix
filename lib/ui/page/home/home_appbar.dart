import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:provider/provider.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final anniv = context.watch<AnnivService>();
    final info = anniv.info;

    if (info != null) {
      return Row(
        children: [
          CircleAvatar(
            child: Text(info.user.nickname.substring(0, 1)),
          ),
          const SizedBox(width: 8),
          Text(info.user.nickname),
        ],
      );
    } else {
      return Row(
        children: [
          Text(t.server.not_logged_in),
          TextButton(
            child: Text(t.server.login),
            onPressed: () {
              AnnixRouterDelegate.of(context).to(name: '/login');
            },
          ),
        ],
      );
    }
  }
}
