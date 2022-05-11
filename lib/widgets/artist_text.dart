import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

Artist readArtist(_ArtistParser reader) {
  String name = "";
  final children = <Artist>[];

  // Read artist name
  while (reader.idx < reader.data.length) {
    if (reader.data[reader.idx] == "、") {
      if (reader.data[reader.idx + 1] == "、") {
        reader.idx += 1;
        name = name + "、";
      } else {
        break;
      }
    } else if (reader.data[reader.idx] == "（" ||
        reader.data[reader.idx] == "）") {
      break;
    } else {
      name = name + reader.data[reader.idx];
    }
    reader.idx += 1;
  }
  // Read children
  if (reader.data.length > reader.idx && reader.data[reader.idx] == "（") {
    reader.idx += 1;
    do {
      children.add(readArtist(reader));
      reader.idx += 1;
    } while (
        reader.data.length > reader.idx && reader.data[reader.idx - 1] == "、");
  }

  return Artist(name: name, children: children);
}

List<Artist> readArtists(_ArtistParser reader) {
  final res = <Artist>[];
  res.add(readArtist(reader));
  while (reader.data.length > reader.idx && reader.data[reader.idx] == "、") {
    reader.idx += 1;
    res.add(readArtist(reader));
  }
  return res;
}

class ArtistText extends StatelessWidget {
  final String artist;
  final List<Artist> artists;
  final TextStyle? style;
  final TextOverflow? overflow;

  final fullArtist = false.obs;

  ArtistText(String artist, {Key? key, this.overflow, this.style})
      : artist = artist,
        artists = readArtists(_ArtistParser(data: artist, idx: 0)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        fullArtist.value = !fullArtist.value;
      },
      child: Obx(
        () => Text(
          fullArtist.value ? artist : artists.map((e) => e.name).join("、"),
          style: style,
          overflow: overflow,
        ),
      ),
    );
  }
}
