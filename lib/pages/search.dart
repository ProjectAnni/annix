import 'package:annix/models/anniv.dart';
import 'package:annix/pages/album_info.dart';
import 'package:annix/services/global.dart';
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

  Widget _buildAlbumList() {
    if (_result?.albums == null || _result?.albums?.isEmpty == true) {
      return Container();
    } else {
      return Expanded(
        flex: 1,
        child: PlatformListView(
          children: _result!.albums!
              .map(
                (e) => PlatformListTile(
                  title: Text(e.title),
                  subtitle: Text(
                    e.artist,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    // AnnixDesktopRouter.navigator.push(platformPageRoute(
                    //   context: context,
                    //   builder: (context) => AnnixAlbumInfo(albumInfo: e),
                    // ));
                  },
                ),
              )
              .toList(),
        ),
      );
    }
  }

  Widget _buildTrackList() {
    if (_result?.tracks == null || _result?.tracks?.isEmpty == true) {
      return Container();
    } else {
      return Expanded(
        flex: 1,
        child: PlatformListView(
          children: _result!.tracks!
              .map(
                (e) => PlatformListTile(
                  title: Text(e.info.title),
                  subtitle: Text(
                    e.info.artist,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    await Global.audioService.setPlaylist([
                      await Global.annil.getAudio(
                        albumId: e.track.albumId,
                        discId: e.track.discId,
                        trackId: e.track.trackId,
                      )
                    ]);
                    await Global.audioService.play();
                  },
                ),
              )
              .toList(),
        ),
      );
    }
  }

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
        _buildAlbumList(),
        _buildTrackList(),
      ],
    );
  }
}
