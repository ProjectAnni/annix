import 'package:annix/models/anniv.dart';
import 'package:annix/services/audio.dart';
import 'package:annix/services/global.dart';
import 'package:annix/widgets/platform_widgets/platform_list.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

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
              PlatformTextButton(
                child: Text('Search'),
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
                    .map((e) => PlatformListTile(
                          title: Text(e.title),
                          subtitle: Marquee(
                            text: e.artist,
                            pauseAfterRound: Duration(seconds: 2),
                            scrollToEnd: true,
                            marqueeShortText: false,
                          ),
                          onTap: () async {
                            await Global.audioService.pause();

                            var i = 1;
                            Global.audioService.playlist =
                                ConcatenatingAudioSource(
                              useLazyPreparation: true,
                              children: await Future.wait(
                                  e.discs[0].tracks.map<Future<AudioSource>>(
                                (s) => Global.annil.getAudio(
                                  albumId: e.albumId,
                                  discId: 1,
                                  trackId: i++,
                                ),
                              )),
                            );
                            await Global.audioService.init(force: true);
                            Provider.of<AnnilPlaylist>(context, listen: false)
                                .resetPlaylist();
                            await Global.audioService.play();
                          },
                        ))
                    .toList(),
          ),
        ),
      ],
    );
  }
}
