import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/ui/dialogs/anniv_login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          Text("Welcome back, ${info!.user.nickname}."),
        ],
      );
    } else {
      return Row(
        children: [
          Text(I18n.NOT_LOGGED_IN.tr),
          TextButton(
            child: Text(I18n.LOGIN.tr),
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
