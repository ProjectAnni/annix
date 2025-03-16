import 'package:annix/providers.dart';
import 'package:annix/services/lyric/lyric_source.dart';
import 'package:annix/services/lyric/lyric_source_netease.dart';
import 'package:annix/services/lyric/lyric_source_petitlyrics.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum LyricSearchState {
  userInput,
  loading,
  displaySearchResultList,
}

class SearchLyricsDialog extends ConsumerStatefulWidget {
  final Track track;

  const SearchLyricsDialog({super.key, required this.track});

  @override
  ConsumerState<SearchLyricsDialog> createState() => _SearchLyricsDialogState();
}

class _SearchLyricsDialogState extends ConsumerState<SearchLyricsDialog> {
  LyricSearchState _state = LyricSearchState.userInput;

  // Step 1 - Input data
  LyricSources _lyricProvider = LyricSources.PetitLyrics;
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _albumController;

  // Step 2 - Available lyric list
  List<LyricSearchResponse> _searchResult = [];

  LyricSource _getLyricProvider() {
    switch (_lyricProvider) {
      case LyricSources.PetitLyrics:
        return LyricSourcePetitLyrics();
      case LyricSources.Netease:
        return LyricSourceNetease();
    }
  }

  Future<void> _searchLyric() async {
    setState(() {
      _state = LyricSearchState.loading;
    });

    final provider = _getLyricProvider();
    try {
      _searchResult = await provider.search(
        track: widget.track.id,
        title: _titleController.text,
        artist: _artistController.text,
        album: _albumController.text,
      );
      setState(() {
        _state = LyricSearchState.displaySearchResultList;
      });
    } catch (e) {
      setState(() {
        _state = LyricSearchState.userInput;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.track.title);
    _artistController = TextEditingController(text: widget.track.artist);
    _albumController =
        TextEditingController(text: widget.track.disc.album.title);
  }

  @override
  Widget build(final BuildContext context) {
    if (_state == LyricSearchState.userInput) {
      return SimpleDialog(
        title: const Text('Search Lyrics'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          DropdownButtonFormField<LyricSources>(
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Lyric Provider',
            ),
            items: const [
              DropdownMenuItem(
                value: LyricSources.PetitLyrics,
                child: Text('PetitLyrics'),
              ),
              DropdownMenuItem(
                value: LyricSources.Netease,
                child: Text('Netease Music'),
              ),
            ],
            value: _lyricProvider,
            onChanged: (final provider) =>
                _lyricProvider = provider ?? _lyricProvider,
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Title',
            ),
            controller: _titleController,
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Artist',
            ),
            controller: _artistController,
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Album',
            ),
            controller: _albumController,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _searchLyric,
                  child: const Text('Search'),
                ),
              ],
            ),
          )
        ],
      );
    } else if (_state == LyricSearchState.loading) {
      return const SimpleDialog(
        children: [
          Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      );
    } else if (_state == LyricSearchState.displaySearchResultList) {
      return SimpleDialog(
        title: const Text('Search Result'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          SizedBox(
            width: 500,
            height: 300,
            child: _searchResult.isEmpty
                ? Center(child: Text(t.no_lyric_found))
                : ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (final context, final index) {
                      final result = _searchResult[index];
                      return ListTile(
                        title: Text(
                          result.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          result.artists.join('、'),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          final player = ref.read(playbackProvider);
                          // TODO: check whether current playing track is the same as the one being searched
                          result.lyric.then((final lyric) {
                            player.playing.updateLyric(TrackLyric(
                              lyric: lyric,
                              type: widget.track.type,
                            ));
                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          });
                        },
                      );
                    },
                    itemCount: _searchResult.length,
                  ),
          )
        ],
      );
    } else {
      return Container();
    }
  }
}
