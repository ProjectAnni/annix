import 'package:annix/i18n/i18n.dart';
import 'package:annix/services/annil/client.dart';
import 'package:annix/global.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/page/home/home_title.dart';
import 'package:annix/ui/widgets/album_grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:provider/provider.dart';

class HomeAlbums extends StatelessWidget {
  const HomeAlbums({super.key});

  @override
  Widget build(BuildContext context) {
    final height = Global.isDesktop ? 280.0 : 240.0;
    final MetadataService metadata =
        Provider.of<MetadataService>(context, listen: false);

    return SliverToBoxAdapter(
      child: Column(
        children: [
          HomeTitle(
            title: I18n.ALBUMS.tr,
            icon: Icons.album_outlined,
            padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
          ),
          SizedBox(
            height: height,
            child: Consumer<CombinedOnlineAnnilClient>(
              builder: (context, annil, child) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: annil.albums.length,
                  itemBuilder: (context, index) {
                    final albumId = annil.albums[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FutureBuilder<Album?>(
                        future: metadata.getAlbum(albumId: albumId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (!snapshot.hasData) {
                              return Container(
                                width: 0,
                              );
                            } else {
                              return AlbumGrid(
                                album: snapshot.data!,
                                width: height - 32,
                              );
                            }
                          } else {
                            return DummyAlbumGrid(width: height - 32.0);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
