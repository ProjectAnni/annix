import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/pages/root/base.dart';
import 'package:annix/pages/tag.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:annix/utils/context_extension.dart';

class TagsView extends StatelessWidget {
  const TagsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AnnivController anniv = Get.find();

    return DefaultTabController(
      length: TagType.values.length,
      child: Column(
        children: [
          BaseAppBar(
            title: Text(I18n.ALBUMS.tr),
          ),
          TabBar(
            labelColor: context.textTheme.titleMedium?.color,
            indicatorColor: context.colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: TagType.values.map((type) => Tab(text: type.name)).toList(),
            isScrollable: true,
          ),
          Expanded(
            child: TabBarView(
              children: List.generate(9, (index) {
                final type = TagType.values[index];
                return ListView(
                  children: anniv.tags.values
                      .where((element) => element.type == type)
                      .map((e) => ListTile(
                            leading: Icon(Icons.local_offer_outlined),
                            title: Text(e.name),
                            onTap: () {
                              Get.to(
                                () => TagScreen(name: e.name),
                                duration: Duration(milliseconds: 300),
                              );
                            },
                          ))
                      .toList(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
