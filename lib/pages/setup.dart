import 'package:annix/metadata/metadata_source.dart';
import 'package:annix/metadata/sources/file.dart';
import 'package:annix/services/global.dart';
import 'package:annix/widgets/draggable_appbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class AnnixSetup extends StatefulWidget {
  const AnnixSetup({Key? key}) : super(key: key);

  @override
  _AnnixSetupState createState() => _AnnixSetupState();
}

class _AnnixSetupState extends State<AnnixSetup> {
  int _currentStep = 0;

  GlobalKey<_MetadataFormState> _metaFormKey = GlobalKey();

  Future<void> onNext() async {
    if (_currentStep == 0) {
      // Metadata Form
      switch (_metaFormKey.currentState!.metadataSoruceType) {
        case MetadataSoruceType.Folder:
          if (_metaFormKey.currentState!.path != null) {
            // TODO: save to shared_preferences
            Global.metadataSource = FileMetadataSource(
                localSource: _metaFormKey.currentState!.path!);
            // TODO: Go to next step instead of finish
            Navigator.of(context).pushReplacementNamed('/home_desktop');
            // setState(() {
            //   _currentStep++;
            // });
          }
          break;
        default:
          throw UnimplementedError();
      }
    }
  }

  Future<void> onPrev() async {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DraggableAppBar(
        appBar: AppBar(
          title: Text("Annix Setup"),
        ),
      ),
      body: Stepper(
        currentStep: _currentStep,
        type: StepperType.horizontal,
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: onPrev,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text('BACK'),
                ),
              ),
              TextButton(
                onPressed: onNext,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text('NEXT'),
                ),
              ),
            ],
          ),
        ),
        steps: <Step>[
          Step(
            title: const Text("Metadata"),
            content: MetadataForm(
              key: _metaFormKey,
            ),
          ),
          Step(
            title: const Text("Annil"),
            // TODO: setup annil
            content: Text("Setup annil here."),
          ),
          Step(
            title: const Text("Anniv"),
            // TODO: setup anniv
            content: Text("Setup anniv here."),
          ),
          Step(
            title: const Text("Finish"),
            // TODO: finish
            content: Text("You've done everything."),
          ),
        ],
      ),
    );
  }
}

class MetadataForm extends StatefulWidget {
  const MetadataForm({Key? key}) : super(key: key);

  @override
  _MetadataFormState createState() => _MetadataFormState();
}

class _MetadataFormState extends State<MetadataForm> {
  MetadataSoruceType metadataSoruceType = MetadataSoruceType.Folder;
  String? path;
  final urlController = TextEditingController();

  bool get isLocalMetadataSource {
    switch (metadataSoruceType) {
      case MetadataSoruceType.GitLocal:
      case MetadataSoruceType.Folder:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('Metadata Repository Type'),
          trailing: FractionallySizedBox(
            widthFactor: 0.4,
            child: DropdownButton<MetadataSoruceType>(
              value: metadataSoruceType,
              onChanged: (value) => metadataSoruceType = value!,
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  child: Text('Git'),
                  value: MetadataSoruceType.GitRemote,
                  enabled: false,
                ),
                DropdownMenuItem(
                  child: Text('Zip'),
                  value: MetadataSoruceType.Zip,
                  enabled: false,
                ),
                DropdownMenuItem(
                  child: Text('Database'),
                  value: MetadataSoruceType.Database,
                  enabled: false,
                ),
                DropdownMenuItem(
                  child: Text('Git(Local)'),
                  value: MetadataSoruceType.GitLocal,
                  enabled: false,
                ),
                DropdownMenuItem(
                  child: Text('Folder(Local)'),
                  value: MetadataSoruceType.Folder,
                ),
              ],
            ),
          ),
        ),
        // for local metadata source, use path picker
        isLocalMetadataSource
            ? ListTile(
                title: Text('Path'),
                trailing: TextButton(
                  child: Text(path ?? "[Not Selected]"),
                  onPressed: () async {
                    String? selectedDirectory =
                        await FilePicker.platform.getDirectoryPath();
                    setState(() {
                      path = selectedDirectory;
                    });
                  },
                ),
              )
            // else, input repo url
            : ListTile(
                title: Text('URL'),
                trailing: FractionallySizedBox(
                  widthFactor: 0.4,
                  child: TextField(
                    controller: urlController,
                  ),
                ),
              ),
      ],
    );
  }
}
