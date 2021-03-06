import 'package:annix/i18n/i18n.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsLogView extends StatelessWidget {
  const SettingsLogView({Key? key}) : super(key: key);

  Icon getLogLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.DEBUG:
        return Icon(Icons.bug_report_outlined);
      case LogLevel.WARNING:
        return Icon(Icons.warning_amber_outlined);
      case LogLevel.ERROR:
      case LogLevel.FATAL:
        return Icon(Icons.error_outline_outlined);
      case LogLevel.INFO:
      default:
        return Icon(Icons.sms_outlined);
    }
  }

  void showDetailDialog(Log log) {
    Get.dialog(
      AlertDialog(
        title: Text('Detail'),
        content: SingleChildScrollView(
          child: Text(
            log.exception.toString() +
                '\n' +
                (log.stacktrace != "null"
                    ? log.stacktrace ?? ""
                    : "No stacktrace"),
          ),
        ),
        actions: [
          TextButton(
            child: Text("Close"),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.SETTINGS_LOGS.tr),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline),
            onPressed: () async {
              await FLog.clearLogs();
              Get.back();
            },
          ),
          // TODO: Log filter
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                // PopupMenuItem(
                //   value: 'clear',
                //   child: Text('Clear'),
                // ),
              ];
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.filter_alt_outlined),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Log>>(
        future: FLog.getAllLogs().then((value) => value.reversed.toList()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final log = snapshot.data![index];
                return ListTile(
                  leading: getLogLevelIcon(log.logLevel!),
                  title: Text(log.text ?? "[No log message]"),
                  subtitle: Text(
                      '${DateTime.fromMillisecondsSinceEpoch(log.timeInMillis!)}, ${log.className}.${log.methodName}'),
                  onTap: () => showDetailDialog(log),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator(strokeWidth: 2));
          }
        },
      ),
    );
  }
}
