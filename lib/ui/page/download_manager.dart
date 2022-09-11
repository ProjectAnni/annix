import 'package:annix/global.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/download/download_manager.dart';
import 'package:annix/services/download/download_models.dart';
import 'package:annix/services/download/download_task.dart';
import 'package:annix/services/player.dart';
import 'package:annix/utils/bytes.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:annix/i18n/strings.g.dart';

class DownloadManagerPage extends StatelessWidget {
  const DownloadManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.download_manager)),
      body: ChangeNotifierProvider.value(
        value: Global.downloadManager,
        child: Consumer<DownloadManager>(
          builder: (context, manager, child) {
            final audios = <DownloadTask>[];
            final others = <DownloadTask>[];
            for (final task in manager.tasks) {
              if (task.category == DownloadCategory.audio) {
                audios.add(task);
              } else {
                others.add(task);
              }
            }

            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: context.textTheme.titleMedium?.color,
                    indicatorColor: context.colorScheme.primary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    tabs: const [
                      Tab(text: "Music"),
                      Tab(text: "Others"),
                    ],
                  ),
                  Expanded(
                    flex: 1,
                    child: TabBarView(
                      children: [
                        ListView.builder(
                          itemBuilder: (context, index) {
                            final task = audios[index];
                            return DownloadTaskListTile(task: task);
                          },
                          itemCount: audios.length,
                        ),
                        ListView.builder(
                          itemBuilder: (context, index) {
                            final task = others[index];
                            return DownloadTaskListTile(task: task);
                          },
                          itemCount: others.length,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class DownloadTaskListTile extends StatelessWidget {
  final DownloadTask task;

  const DownloadTaskListTile({required this.task, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: task,
      child: Consumer<DownloadTask>(
        builder: (context, task, child) {
          final totalBytes = task.progress.total ??
              (task.status == DownloadTaskStatus.completed
                  ? task.progress.current
                  : -1);
          final Widget downloadProgressText = task.status ==
                  DownloadTaskStatus.completed
              ? const Icon(Icons.check)
              : Text(
                  "${bytesToString(task.progress.current)} / ${bytesToString(totalBytes)}");

          if (task.data is TrackInfoWithAlbum) {
            final track = task.data as TrackInfoWithAlbum;
            return ListTile(
              title: Text(track.title),
              subtitle: Text(
                track.albumTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: downloadProgressText,
              onTap: () {
                if (task.status == DownloadTaskStatus.completed) {
                  final player = context.read<PlayerService>();
                  player.setPlayingQueue([AnnilAudioSource(track: track)]);
                }
              },
            );
          }

          return ListTile(
            title: Text(task.url),
            leading: DownloadCategoryIcon(category: task.category),
            subtitle: downloadProgressText,
            trailing: IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                //
              },
            ),
          );
        },
      ),
    );
  }
}

class DownloadCategoryIcon extends StatelessWidget {
  final DownloadCategory category;

  const DownloadCategoryIcon({required this.category, super.key});

  @override
  Widget build(BuildContext context) {
    switch (category) {
      case DownloadCategory.audio:
        return const Icon(Icons.audio_file);
      case DownloadCategory.cover:
        return const Icon(Icons.image);
      case DownloadCategory.database:
        return const Icon(Icons.table_chart);
    }
  }
}
