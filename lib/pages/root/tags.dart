import 'package:annix/i18n/i18n.dart';
import 'package:annix/metadata/metadata_types.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/pages/root/base.dart';
import 'package:annix/pages/tag.dart';
import 'package:annix/services/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:annix/utils/context_extension.dart';

class TagsView extends StatelessWidget {
  const TagsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: TagType.values.length,
      child: Column(
        children: [
          BaseAppBar(
            title: Text(I18n.CATEGORY.tr),
          ),
          TabBar(
            labelColor: context.textTheme.titleMedium?.color,
            indicatorColor: context.colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: TagType.values.map((type) => Tab(text: type.name)).toList(),
            isScrollable: true,
          ),
          FutureBuilder<Map<String, TagEntry>>(
              future: Global.metadataSource.future.then(
                (metadata) => metadata.getTags(),
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final sorted = Map.fromEntries(snapshot.data!.entries.toList()
                    ..sort((e1, e2) => e1.key.compareTo(e2.key)));

                  return Expanded(
                    child: TabBarView(
                      children: List.generate(9, (index) {
                        final type = TagType.values[index];
                        return ListView(
                          children: sorted.values
                              .where((element) => element.type == type)
                              .map((e) => ListTile(
                                    leading: Icon(Icons.local_offer_outlined),
                                    title: Text(e.name),
                                    onTap: () {
                                      Get.to(
                                        () => TagScreen(name: e.name),
                                        id: 1,
                                      );
                                    },
                                  ))
                              .toList(),
                        );
                      }),
                    ),
                  );
                } else {
                  return Expanded(
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
              }),
        ],
      ),
    );
  }
}
