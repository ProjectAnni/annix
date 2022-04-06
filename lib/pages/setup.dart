import 'package:annix/metadata/metadata_source_anniv.dart';
import 'package:annix/metadata/metadata_source_sqlite.dart';
import 'package:annix/services/anniv.dart';
import 'package:annix/services/global.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AnnixSetup extends StatefulWidget {
  const AnnixSetup({Key? key}) : super(key: key);

  @override
  _AnnixSetupState createState() => _AnnixSetupState();
}

class _AnnixSetupState extends State<AnnixSetup> {
  bool _useExternalMetadata = false;
  bool isLocalSource = false;

  TextEditingController _urlController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String? _databasePath;

  void _completeSetup() async {
    // validate data first
    if (!_emailController.text.contains('@')) {
      // TODO: invalid email
      print("invalid email");
      return;
    } else if (_urlController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      print("empty field");
      // TODO: empty field
      return;
    } else {
      try {
        // initialize Anniv
        Global.anniv = await AnnivClient.create(
          url: _urlController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

        // initialize metadata source
        if (_databasePath == null) {
          // use Anniv as metadata source
          Global.metadataSource = AnnivMetadataSource();
        } else {
          // use database as metadata source
          if (_databasePath!.startsWith('http')) {
            // TODO: Download from URL
            throw UnimplementedError();
          }
          final metadataSource = SqliteMetadataSource(dbPath: _databasePath!);
          await metadataSource.prepare();
          // TODO: validate database
          // TODO: persist database path
          Global.metadataSource = metadataSource;
        }
        setState(() {
          Navigator.of(context).pushReplacementNamed('/home');
        });
      } catch (e) {
        // TODO: failed to login
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Annix Setup"),
        actions: [
          PlatformIconButton(
            icon: Icon(context.platformIcons.checkMark),
            padding: EdgeInsets.zero,
            onPressed: _completeSetup,
          )
        ],
      ),
      body: Column(
        children: [
          SimpleRow(
            left: Text('Anniv Server URL'),
            right: PlatformTextField(
              hintText: 'URL',
              controller: _urlController,
            ),
          ),
          SimpleRow(
            left: Text('Email'),
            right: PlatformTextField(
              hintText: 'Email',
              controller: _emailController,
            ),
          ),
          SimpleRow(
            left: Text('Password'),
            right: PlatformTextField(
              hintText: 'Password',
              obscureText: true,
              controller: _passwordController,
            ),
          ),
          SimpleRow(
            padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
            left: Text('Use external metadata source'),
            right: PlatformSwitch(
              value: _useExternalMetadata,
              onChanged: (value) {
                setState(() {
                  _useExternalMetadata = value;
                });
              },
            ),
          ),
          ...(_useExternalMetadata
              ? [
                  SimpleRow(
                    padding:
                        EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 8),
                    left: Text('Local source'),
                    right: PlatformSwitch(
                      value: isLocalSource,
                      onChanged: (value) {
                        setState(() {
                          isLocalSource = value;
                          _databasePath = null;
                        });
                      },
                    ),
                  ),
                  SimpleRow(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    left: Align(
                        alignment: Alignment.topLeft, child: Text('URL/Path')),
                    right: isLocalSource
                        // select local source
                        ? PlatformTextButton(
                            padding: EdgeInsets.zero,
                            alignment: Alignment.topRight,
                            child: Text(_databasePath ?? "[Not Selected]"),
                            onPressed: () async {
                              FilePickerResult? selected =
                                  await FilePicker.platform.pickFiles(
                                allowMultiple: false,
                                allowedExtensions: const ['db'],
                              );
                              setState(() {
                                if (selected?.paths.length == 1) {
                                  _databasePath = selected?.paths[0];
                                } else {
                                  _databasePath = null;
                                }
                              });
                            },
                          )
                        // input remote source
                        : PlatformTextField(
                            onChanged: (value) {
                              _databasePath = value;
                            },
                          ),
                  ),
                ]
              : [])
        ],
      ),
    );
  }
}

class SimpleRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets padding;

  const SimpleRow({
    Key? key,
    required this.left,
    required this.right,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding = const EdgeInsets.all(8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: left,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: right,
            ),
          ),
        ],
      ),
    );
  }
}
