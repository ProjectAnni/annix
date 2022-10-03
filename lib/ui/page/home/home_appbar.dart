import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/ui/dialogs/anniv_login.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';

class HomeAppBar extends StatelessWidget {
  final SiteUserInfo? info;

  const HomeAppBar({super.key, this.info});

  @override
  Widget build(BuildContext context) {
    if (info != null) {
      return Row(
        children: [
          CircleAvatar(
            child: Text(info!.user.nickname.substring(0, 1)),
          ),
          const SizedBox(width: 8),
          Text('Welcome back, ${info!.user.nickname}.'),
        ],
      );
    } else {
      return Row(
        children: [
          Text(t.server.not_logged_in),
          TextButton(
            child: Text(t.server.login),
            onPressed: () {
              showDialog(
                context: context,
                useRootNavigator: true,
                builder: (context) => AnnivLoginDialog(),
              );
            },
          ),
        ],
      );
    }
  }
}
