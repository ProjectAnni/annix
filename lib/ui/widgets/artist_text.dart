import 'package:annix/ui/route/delegate.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

// https://github.com/ProjectAnni/anniw/blob/d1770ded6cffb1c7c4ed74205b7d40ae8ec18998/src/utils/helper.ts#L62
class _ArtistParser {
  String data;
  int idx;

  _ArtistParser({required this.data, required this.idx});
}

class Artist {
  final String name;
  final List<Artist> children;

  Artist({required this.name, required this.children});
}

Artist _readArtist(final _ArtistParser reader) {
  String name = '';
  final children = <Artist>[];

  // Read artist name
  while (reader.idx < reader.data.length) {
    if (reader.data[reader.idx] == '、') {
      if (reader.data[reader.idx + 1] == '、') {
        reader.idx += 1;
        name = '$name、';
      } else {
        break;
      }
    } else if (reader.data[reader.idx] == '（' ||
        reader.data[reader.idx] == '）') {
      break;
    } else {
      name = name + reader.data[reader.idx];
    }
    reader.idx += 1;
  }
  // Read children
  if (reader.data.length > reader.idx && reader.data[reader.idx] == '（') {
    reader.idx += 1;
    do {
      children.add(_readArtist(reader));
      reader.idx += 1;
    } while (
        reader.data.length > reader.idx && reader.data[reader.idx - 1] == '、');
  }

  return Artist(name: name, children: children);
}

List<Artist> _readArtists(final _ArtistParser reader) {
  final res = <Artist>[];
  res.add(_readArtist(reader));
  while (reader.data.length > reader.idx && reader.data[reader.idx] == '、') {
    reader.idx += 1;
    res.add(_readArtist(reader));
  }
  return res;
}

class ArtistText extends StatefulWidget {
  final String artist;
  final List<Artist> artists;
  final TextStyle? style;
  final TextOverflow? overflow;
  final bool expandable;

  bool get isExtensible =>
      expandable && artist.contains('（') && artist.contains('）');

  ArtistText(
    this.artist, {
    this.overflow = TextOverflow.ellipsis,
    this.style,
    this.expandable = true,
    super.key,
  }) : artists = _readArtists(_ArtistParser(data: artist, idx: 0));

  @override
  State<ArtistText> createState() => _ArtistTextState();
}

class _ArtistTextState extends State<ArtistText> {
  bool fullArtist = false;

  void toggleExtend() {
    setState(() {
      fullArtist = !fullArtist;
    });
  }

  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: () {
        AnnixRouterDelegate.of(context)
            .off(name: '/search', arguments: widget.artist);
      },
      onLongPress: toggleExtend,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              fullArtist
                  ? widget.artist
                  : widget.artists.map((final e) => e.name).join('、'),
              style: widget.style,
              overflow: widget.overflow,
              maxLines: 1,
            ),
          ),
          if (widget.isExtensible && context.isDesktopOrLandscape)
            IconButton(
              onPressed: toggleExtend,
              isSelected: fullArtist,
              icon: const Icon(Icons.arrow_forward_ios_outlined),
              selectedIcon: const Icon(Icons.arrow_back_ios_outlined),
              iconSize: 12,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              // must be specified on iOS to remove _InputPadding
              // https://github.com/flutter/flutter/issues/96995#issuecomment-1018763723
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }
}
