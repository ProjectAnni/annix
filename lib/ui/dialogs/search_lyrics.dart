import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/lyric/lyric_provider.dart';
import 'package:annix/services/lyric/lyric_provider_netease.dart';
import 'package:annix/services/lyric/lyric_provider_petitlyrics.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:annix/i18n/strings.g.dart';

enum LyricSearchState {
  userInput,
  loading,
  displaySearchResultList,
}

class SearchLyricsDialog extends StatefulWidget {
  final TrackInfoWithAlbum track;

  const SearchLyricsDialog({super.key, required this.track});

  @override
  State<SearchLyricsDialog> createState() => _SearchLyricsDialogState();
}

class _SearchLyricsDialogState extends State<SearchLyricsDialog> {
  LyricSearchState _state = LyricSearchState.userInput;

  // Step 1 - Input data
  LyricProviders _lyricProvider = LyricProviders.PetitLyrics;
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _albumController;

  // Step 2 - Available lyric list
  List<LyricSearchResponse> _searchResult = [];

  LyricProvider _getLyricProvider() {
    switch (_lyricProvider) {
      case LyricProviders.PetitLyrics:
        return LyricProviderPetitLyrics();
      case LyricProviders.Netease:
        return LyricProviderNetease();
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
    _albumController = TextEditingController(text: widget.track.albumTitle);
  }

  @override
  Widget build(BuildContext context) {
    if (_state == LyricSearchState.userInput) {
      return SimpleDialog(
        title: const Text("Search Lyrics"),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          DropdownButtonFormField<LyricProviders>(
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: "Lyric Provider",
            ),
            items: const [
              DropdownMenuItem(
                value: LyricProviders.PetitLyrics,
                child: Text("PetitLyrics"),
              ),
              DropdownMenuItem(
                value: LyricProviders.Netease,
                child: Text("Netease Music"),
              ),
            ],
            value: _lyricProvider,
            onChanged: (provider) =>
                _lyricProvider = provider ?? _lyricProvider,
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Title",
            ),
            controller: _titleController,
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Artist",
            ),
            controller: _artistController,
          ),
          TextFormField(
            decoration: const InputDecoration(
              labelText: "Album",
            ),
            controller: _albumController,
          ),
          ButtonBar(
            children: [
              TextButton(
                onPressed: _searchLyric,
                child: const Text("Search"),
              ),
            ],
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
        title: const Text("Search Result"),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          SizedBox(
            width: 500,
            height: 300,
            child: _searchResult.isEmpty
                ? Center(child: Text(t.no_lyric_found))
                : ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final result = _searchResult[index];
                      return ListTile(
                        title: Text(
                          result.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          result.artists.join("、"),
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          final player = context.read<PlaybackService>();
                          result.lyric.then((lyric) {
                            player.playing?.updateLyric(TrackLyric(
                              lyric: lyric,
                              type: widget.track.type,
                            ));
                            Navigator.of(context, rootNavigator: true).pop();
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
