import 'package:annix/metadata/metadata_source.dart';
import 'package:annix/widgets/draggable_appbar.dart';
import 'package:flutter/material.dart';

class AnnixSetup extends StatefulWidget {
  const AnnixSetup({Key? key}) : super(key: key);

  @override
  _AnnixSetupState createState() => _AnnixSetupState();
}

class _AnnixSetupState extends State<AnnixSetup> {
  int _currentStep = 0;

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
        steps: <Step>[
          Step(
            title: const Text("Metadata"),
            content: MetadataForm(),
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
  final _keyForm = GlobalKey<FormState>();

  MetadataSoruceType _metadataSoruceType = MetadataSoruceType.GitLocal;
  final _pathController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _keyForm,
      child: Column(
        children: [
          DropdownButtonFormField<MetadataSoruceType>(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Metadata Repository URL(Git)',
            ),
            isExpanded: true,
            items: [
              DropdownMenuItem(
                child: Text('Git(Remote)'),
                value: MetadataSoruceType.GitRemote,
              ),
              DropdownMenuItem(
                child: Text('Zip(Remote)'),
                value: MetadataSoruceType.Zip,
              ),
              DropdownMenuItem(
                child: Text('Database(Remote)'),
                value: MetadataSoruceType.Database,
              ),
              DropdownMenuItem(
                child: Text('Git(Local)'),
                value: MetadataSoruceType.GitLocal,
              ),
              DropdownMenuItem(
                child: Text('Folder(Local)'),
                value: MetadataSoruceType.Folder,
              ),
            ],
            value: _metadataSoruceType,
            onChanged: (value) => _metadataSoruceType = value!,
          ),
          TextFormField(
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'URL/Path',
            ),
            controller: _pathController,
          ),
        ],
      ),
    );
  }
}
