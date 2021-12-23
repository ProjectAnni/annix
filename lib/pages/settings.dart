import 'package:annix/services/global.dart';
import 'package:annix/widgets/platform_widgets/platform_list.dart';
import 'package:flutter/widgets.dart';

class AnnixSettings extends StatefulWidget {
  const AnnixSettings({Key? key}) : super(key: key);

  @override
  _AnnixSettingsState createState() => _AnnixSettingsState();
}

class _AnnixSettingsState extends State<AnnixSettings> {
  bool _initializingAnnilClients = false;

  @override
  Widget build(BuildContext context) {
    return PlatformListView(children: [
      PlatformListTile(
        title: Text('Initialize Annil Clients'),
        onTap: () async {
          if (!_initializingAnnilClients) {
            setState(() {
              _initializingAnnilClients = true;
            });
            await Global.anniv!.setAnnilClients();
            setState(() {
              _initializingAnnilClients = false;
            });
          }
        },
      )
    ]);
  }
}
