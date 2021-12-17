import 'package:annix/services/global.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AnnixSettings extends StatefulWidget {
  const AnnixSettings({Key? key}) : super(key: key);

  @override
  _AnnixSettingsState createState() => _AnnixSettingsState();
}

class _AnnixSettingsState extends State<AnnixSettings> {
  bool _initializingAnnilClients = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlatformTextButton(
          child: Text('Initialize Annil Clients'),
          onPressed: _initializingAnnilClients
              ? null
              : () async {
                  setState(() {
                    _initializingAnnilClients = true;
                  });
                  await Global.anniv!.setAnnilClients();
                  setState(() {
                    _initializingAnnilClients = false;
                  });
                },
        ),
      ],
    );
  }
}
