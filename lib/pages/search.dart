import 'package:annix/models/anniv.dart';
import 'package:annix/pages/album_info.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/route.dart';
import 'package:annix/widgets/platform_widgets/platform_list.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:annix/utils/platform_icons.dart';

class AnnixSearch extends StatefulWidget {
  const AnnixSearch({Key? key}) : super(key: key);

  @override
  _AnnixSearchState createState() => _AnnixSearchState();
}

class _AnnixSearchState extends State<AnnixSearch> {
  TextEditingController _controller = TextEditingController();
  SearchResult? _result;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: PlatformTextField(
                  controller: _controller,
                ),
              ),
              PlatformIconButton(
                icon: Icon(context.icons.search),
                onPressed: () async {
                  final result = await Global.anniv!.search(_controller.text,
                      searchAlbums: true, searchTracks: true);
                  setState(() {
                    _result = result;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: PlatformListView(
            children: _result == null
                ? []
                : _result!.albums!
                    .map(
                      (e) => PlatformListTile(
                        title: Text(e.title),
                        subtitle: Text(e.artist),
                        onTap: () async {
                          AnnixDesktopRouter.navigator.push(platformPageRoute(
                            context: context,
                            builder: (context) => AnnixAlbumInfo(albumInfo: e),
                          ));
                        },
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }
}
