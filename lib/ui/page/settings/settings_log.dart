import 'package:annix/ui/route/delegate.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';

class SettingsLogView extends StatelessWidget {
  const SettingsLogView({super.key});

  Icon getLogLevelIcon(final LogLevel level) {
    switch (level) {
      case LogLevel.DEBUG:
        return const Icon(Icons.bug_report_outlined);
      case LogLevel.WARNING:
        return const Icon(Icons.warning_amber_outlined);
      case LogLevel.ERROR:
      case LogLevel.FATAL:
        return const Icon(Icons.error_outline_outlined);
      case LogLevel.INFO:
      default:
        return const Icon(Icons.sms_outlined);
    }
  }

  void showDetailDialog(final BuildContext context, final Log log) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (final context) {
        return AlertDialog(
          title: const Text('Detail'),
          content: SingleChildScrollView(
            child: Text(
              '${log.exception}\n${log.stacktrace != "null" ? log.stacktrace ?? "" : "No stacktrace"}',
            ),
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
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.view_logs),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              final delegate = AnnixRouterDelegate.of(context);
              FLog.clearLogs().then((final _) => delegate.popRoute());
            },
          ),
          // TODO: Log filter
          PopupMenuButton(
            itemBuilder: (final context) {
              return [
                // PopupMenuItem(
                //   value: 'clear',
                //   child: Text('Clear'),
                // ),
              ];
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.filter_alt_outlined),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Log>>(
        future:
            FLog.getAllLogs().then((final value) => value.reversed.toList()),
        builder: (final context, final snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (final context, final index) {
                final log = snapshot.data![index];
                return ListTile(
                  leading: getLogLevelIcon(log.logLevel!),
                  title: Text(log.text ?? '[No log message]'),
                  subtitle: Text(
                      '${DateTime.fromMillisecondsSinceEpoch(log.timeInMillis!)}, ${log.className}.${log.methodName}'),
                  onTap: () => showDetailDialog(context, log),
                );
              },
            );
          } else {
            return const Center(
                child: CircularProgressIndicator(strokeWidth: 2));
          }
        },
      ),
    );
  }
}
