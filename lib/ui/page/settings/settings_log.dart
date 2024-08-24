import 'package:annix/native/api/logging.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';

class SettingsLogView extends StatelessWidget {
  const SettingsLogView({super.key});

  Icon getLogLevelIconFromString(final String level) {
    switch (level) {
      case 'DEBUG':
        return const Icon(Icons.bug_report_outlined);
      case 'WARN':
        return const Icon(Icons.warning_amber_outlined);
      case 'ERROR':
        return const Icon(Icons.error_outline_outlined);
      case 'INFO':
      default:
        return const Icon(Icons.sms_outlined);
    }
  }

  void showDetailDialog(final BuildContext context, LogEntry log) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (final context) {
        return AlertDialog(
          title: const Text('Detail'),
          content: SingleChildScrollView(
            child: Text(log.structured),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.view_logs),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.delete_outline),
        //     onPressed: () {
        //       final delegate = AnnixRouterDelegate.of(context);
        //       FLog.clearLogs().then((final _) => delegate.popRoute());
        //     },
        //   ),
        // ],
      ),
      body: FutureBuilder<List<LogEntry>>(
        future: readLogs().then((logs) => logs.reversed.toList()),
        builder: (final context, final snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (final context, final index) {
                final log = snapshot.data![index];
                return ListTile(
                  leading: getLogLevelIconFromString(log.level),
                  title: Text(log.message),
                  subtitle: Text(
                      '${log.time}, ${log.module}::${log.file}:${log.line}'),
                  onTap: () => showDetailDialog(context, log),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
        },
      ),
    );
  }
}
