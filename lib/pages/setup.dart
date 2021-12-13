import 'package:annix/metadata/metadata_source.dart';
import 'package:annix/metadata/sources/file.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/platform.dart';
import 'package:annix/widgets/draggable_appbar.dart';
import 'package:annix/widgets/platform_stepper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoActionSheetAction,
        showCupertinoModalPopup,
        CupertinoActionSheet;
import 'package:flutter/material.dart'
    show Step, StepperType, DropdownButton, DropdownMenuItem;
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
            Navigator.of(context).pushReplacementNamed('/home');
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
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: DraggableAppBar(
        title: Text("Annix Setup"),
      ),
      body: PlatformStepper(
        currentStep: _currentStep,
        type: AnniPlatform.isDesktop
            ? StepperType.horizontal
            : StepperType.vertical,
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              PlatformTextButton(
                onPressed: onPrev,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text('BACK'),
                ),
              ),
              PlatformTextButton(
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
        SimpleRow(
          left: Text('Repo Type'),
          right: PlatformWidget(
            // TODO: wrap as a widget
            material: (context, platform) => DropdownButton<MetadataSoruceType>(
              value: metadataSoruceType,
              onChanged: (value) => metadataSoruceType = value!,
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
                // Local target is only supported for Desktop
                ...(AnniPlatform.isDesktop
                    ? [
                        DropdownMenuItem(
                          child: Text('Git(Local)'),
                          value: MetadataSoruceType.GitLocal,
                          enabled: false,
                        ),
                        DropdownMenuItem(
                          child: Text('Folder(Local)'),
                          value: MetadataSoruceType.Folder,
                        ),
                      ]
                    : []),
              ],
            ),
            cupertino: (context, platform) => PlatformTextButton(
                child: Text(metadataSoruceType.toString()),
                onPressed: () {
                  showCupertinoModalPopup<void>(
                    context: context,
                    builder: (BuildContext context) => CupertinoActionSheet(
                      actions: <CupertinoActionSheetAction>[
                        CupertinoActionSheetAction(
                          child: const Text('Git'),
                          onPressed: () {
                            setState(() {
                              metadataSoruceType = MetadataSoruceType.GitRemote;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: const Text('Zip'),
                          onPressed: () {
                            setState(() {
                              metadataSoruceType = MetadataSoruceType.Zip;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: const Text('Database'),
                          onPressed: () {
                            setState(() {
                              metadataSoruceType = MetadataSoruceType.Database;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ...(AnniPlatform.isDesktop
                            ? [
                                CupertinoActionSheetAction(
                                  child: const Text('Git(Local)'),
                                  onPressed: () {
                                    setState(() {
                                      metadataSoruceType =
                                          MetadataSoruceType.GitLocal;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                CupertinoActionSheetAction(
                                  child: const Text('Local Folder'),
                                  onPressed: () {
                                    setState(() {
                                      metadataSoruceType =
                                          MetadataSoruceType.Folder;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ]
                            : []),
                      ],
                    ),
                  );
                }),
          ),
        ),
        // for local metadata source, use path picker
        isLocalMetadataSource
            ? SimpleRow(
                left: Text('Path'),
                right: PlatformTextButton(
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
            : SimpleRow(
                left: Text('URL'),
                right: FractionallySizedBox(
                  widthFactor: 0.4,
                  child: PlatformTextField(
                    controller: urlController,
                  ),
                ),
              ),
      ],
    );
  }
}

class SimpleRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  const SimpleRow({Key? key, required this.left, required this.right})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [this.left, this.right],
    );
  }
}
