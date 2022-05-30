import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/pages/playlist/playlist_album.dart';
import 'package:annix/services/global.dart';
import 'package:f_logs/model/flog/flog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class AlbumGrid extends StatelessWidget {
  final String albumId;
  final String tag;

  AlbumGrid({
    Key? key,
    required this.albumId,
    String? tag,
  })  : this.tag = tag ?? Uuid().v4().toString(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    AnnilController annil = Get.find();

    return Card(
      clipBehavior: Clip.hardEdge,
      child: FutureBuilder<Album?>(
        future: Global.metadataSource!.getAlbum(albumId: albumId),
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            FLog.error(
              text: "Failed to fetch metadata",
              exception: snapshot.error,
            );
          }

          return InkWell(
            child: Stack(
              fit: StackFit.expand,
              children: [
                annil.cover(albumId: albumId),
                snapshot.hasData
                    ? Container(
                        alignment: Alignment.bottomLeft,
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                          '${snapshot.data?.title}',
                          style: context.textTheme.bodyLarge?.copyWith(
                            backgroundColor: context
                                .theme.colorScheme.secondaryContainer
                                .withOpacity(0.8),
                          ),
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : Container(),
              ],
            ),
            onTap: () {
              if (snapshot.hasData) {
                Get.to(
                  () => AlbumDetailScreen(album: snapshot.data!),
                  duration: Duration(milliseconds: 300),
                );
              }
            },
          );
        },
      ),
    );
  }
}
