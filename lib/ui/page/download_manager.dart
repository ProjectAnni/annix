import 'package:annix/providers.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/download/download_models.dart';
import 'package:annix/services/download/download_task.dart';
import 'package:annix/utils/bytes.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DownloadManagerPage extends ConsumerWidget {
  const DownloadManagerPage({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final downloadManager = ref.watch(downloadManagerProvider);

    final audios = <DownloadTask>[];
    final others = <DownloadTask>[];
    for (final task in downloadManager.tasks) {
      if (task.category == DownloadCategory.audio) {
        audios.add(task);
      } else {
        others.add(task);
      }
    }

    final body = DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              labelColor: context.textTheme.titleMedium?.color,
              indicatorColor: context.colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              isScrollable: true,
              tabs: const [
                Tab(text: 'Music'),
                Tab(text: 'Others'),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: TabBarView(
              children: [
                ListView.builder(
                  itemBuilder: (final context, final index) {
                    final task = audios[index];
                    return DownloadTaskListTile(task: task);
                  },
                  itemCount: audios.length,
                ),
                ListView.builder(
                  itemBuilder: (final context, final index) {
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

    return Scaffold(
      appBar: AppBar(title: Text(t.download_manager)),
      body: body,
    );
  }
}

class DownloadTaskListTile extends ConsumerWidget {
  final DownloadTask task;

  const DownloadTaskListTile({required this.task, super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final taskProvider = ChangeNotifierProvider((final _) => task);
    final downloadTask = ref.watch(taskProvider);

    final totalBytes = downloadTask.progress.total ??
        (downloadTask.status == DownloadTaskStatus.completed
            ? downloadTask.progress.current
            : -1);
    final Widget downloadProgressText = downloadTask.status ==
            DownloadTaskStatus.completed
        ? const Icon(Icons.check)
        : downloadTask.status == DownloadTaskStatus.failed
            ? const Icon(Icons.error)
            : downloadTask.status == DownloadTaskStatus.paused
                ? const Icon(Icons.pause)
                : Text(
                    '${bytesToString(downloadTask.progress.current)} / ${bytesToString(totalBytes)}');

    if (downloadTask.data is TrackDownloadTaskData) {
      final track = downloadTask.data as TrackDownloadTaskData;
      return ListTile(
        title: Text(track.info.title),
        subtitle: Text(
          track.info.albumTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: downloadProgressText,
        onTap: () {
          if (downloadTask.status == DownloadTaskStatus.completed) {
            final player = ref.read(playbackProvider);
            player.setPlayingQueue(
                [AnnilAudioSource(track: track.info, quality: track.quality)]);
          }
        },
      );
    }

    return ListTile(
      title: Text(downloadTask.url),
      leading: DownloadCategoryIcon(category: downloadTask.category),
      subtitle: downloadProgressText,
      trailing: IconButton(
        icon: const Icon(Icons.cancel),
        onPressed: () {
          //
        },
      ),
    );
  }
}

class DownloadCategoryIcon extends StatelessWidget {
  final DownloadCategory category;

  const DownloadCategoryIcon({required this.category, super.key});

  @override
  Widget build(final BuildContext context) {
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
