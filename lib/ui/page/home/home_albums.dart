import 'package:annix/services/annil/client.dart';
import 'package:annix/global.dart';
import 'package:annix/ui/page/home/home_title.dart';
import 'package:annix/ui/widgets/album_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:annix/i18n/strings.g.dart';

class HomeAlbums extends StatelessWidget {
  const HomeAlbums({super.key});

  @override
  Widget build(BuildContext context) {
    final height = Global.isDesktop ? 280.0 : 240.0;

    return SliverToBoxAdapter(
      child: Column(
        children: [
          HomeTitle(
            title: t.albums,
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
                      child: AlbumGrid(
                        albumId: albumId,
                        width: height - 32,
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
