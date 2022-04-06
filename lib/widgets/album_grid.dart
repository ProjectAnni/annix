import 'package:annix/models/metadata.dart';
import 'package:annix/pages/album_info.dart';
import 'package:annix/services/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class AlbumGrid extends StatefulWidget {
  final String albumId;
  final Widget cover;
  final String tag;

  AlbumGrid({
    Key? key,
    required this.albumId,
    required this.cover,
    String? tag,
  })  : this.tag = tag ?? Uuid().v4().toString(),
        super(key: key);

  @override
  _AlbumGridState createState() => _AlbumGridState();
}

class _AlbumGridState extends State<AlbumGrid> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 16,
      child: FutureBuilder<Album?>(
        future: Global.metadataSource!.getAlbum(albumId: widget.albumId),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          return InkWell(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: widget.tag,
                  child: widget.cover,
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    '${snapshot.data?.title}',
                    style: Get.textTheme.bodyLarge?.copyWith(
                      backgroundColor: Get.theme.colorScheme.primaryContainer
                          .withOpacity(0.8),
                    ),
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            onTap: () {
              Get.to(
                () => AlbumInfoScreen(
                  albumInfo: snapshot.data!.toAlbumInfo(),
                  tag: widget.tag,
                ),
                duration: Duration(milliseconds: 300),
              );
            },
          );
        },
      ),
    );
  }
}
