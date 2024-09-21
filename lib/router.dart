import 'package:annix/providers.dart';
import 'package:annix/services/theme.dart';
import 'package:annix/ui/page/intro.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/layout/layout.dart';
import 'package:annix/ui/page/album.dart';
import 'package:annix/ui/page/annil/annil.dart';
import 'package:annix/ui/page/favorite.dart';
import 'package:annix/ui/page/home/home.dart';
import 'package:annix/ui/page/playback_history.dart';
import 'package:annix/ui/page/playlist.dart';
import 'package:annix/ui/page/search.dart';
import 'package:annix/ui/page/server.dart';
import 'package:annix/ui/page/settings/settings.dart';
import 'package:annix/ui/page/settings/settings_log.dart';
import 'package:annix/ui/page/tag/tag_detail.dart';
import 'package:annix/ui/page/tag/tag_list.dart';
import 'package:annix/services/local/database.dart' as db;
import 'package:hooks_riverpod/hooks_riverpod.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _mainNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'main');

GoRouter buildRouter(Ref ref) {
  final anniv = ref.read(annivProvider);
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => anniv.isLogin ? '/home' : '/intro',
      ),
      GoRoute(
        path: '/intro',
        builder: (context, state) => const IntroPage(),
      ),
      ShellRoute(
        navigatorKey: _mainNavigatorKey,
        observers: [
          ThemePopObserver(ref.read(themeProvider)),
          PlayerRouteObserver(ref.read(routerProvider)),
        ],
        builder: (context, state, child) {
          return AnnixLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/album',
            builder: (context, state) {
              if (state.extra is String) {
                // albumId
                final albumId = state.extra as String;
                // ref.read(themeProvider).pushTemporaryTheme(albumId);
                return LoadingAlbumPage(albumId: albumId);
              } else {
                final album = state.extra as Album;
                // ref.read(themeProvider).pushTemporaryTheme(album.albumId);
                return AlbumPage(album: album);
              }
            },
          ),
          GoRoute(
            path: '/tag',
            builder: (context, state) =>
                TagDetailScreen(name: state.extra as String),
          ),
          GoRoute(
            path: '/tags',
            builder: (context, state) => const TagListView(),
          ),
          GoRoute(
            path: '/server',
            builder: (context, state) => const ServerView(),
          ),
          GoRoute(
            path: '/annil',
            builder: (context, state) {
              return AnnilDetailPage(
                annil: state.extra as db.LocalAnnilServer,
              );
            },
          ),
          GoRoute(
            path: '/favorite',
            builder: (context, state) => const FavoritePage(),
          ),
          GoRoute(
            path: '/playlist',
            builder: (context, state) {
              return LoadingPlaylistPage(
                playlistInfo: state.extra as PlaylistInfo,
              );
            },
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) {
              final keyword = state.extra as String?;
              return SearchPage(keyword: keyword);
            },
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/logs',
            builder: (context, state) => const SettingsLogView(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const PlaybackHistoryPage(),
          ),

          /// Shadow route for the expanded SlideUp player panel
          GoRoute(
            path: '/player',
            pageBuilder: (context, state) => CustomTransitionPage(
              name: '/player',
              fullscreenDialog: true,
              opaque: false,
              transitionsBuilder: (_, __, ___, child) => child,
              child: Container(),
            ),
          ),
        ],
      )
    ],
  );
  return router;
}
