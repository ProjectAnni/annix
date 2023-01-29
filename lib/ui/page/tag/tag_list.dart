import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:flutter/material.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:provider/provider.dart';
import 'package:annix/i18n/strings.g.dart';

class TagList extends StatelessWidget {
  final Function(TagEntry) onSelected;

  const TagList({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: TagType.values.length,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              labelColor: context.textTheme.titleMedium?.color,
              indicatorColor: context.colorScheme.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: TagType.values.map((type) => Tab(text: type.name)).toList(),
              isScrollable: true,
            ),
          ),
          FutureBuilder<Map<String, TagEntry>>(
              future: context.read<MetadataService>().getTags(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final sorted = Map.fromEntries(snapshot.data!.entries.toList()
                    ..sort((e1, e2) => e1.key.compareTo(e2.key)));

                  return Expanded(
                    child: TabBarView(
                      children: List.generate(TagType.values.length, (index) {
                        final type = TagType.values[index];
                        return ListView(
                          children: sorted.values
                              .where((element) => element.type == type)
                              .map(
                                (e) => ListTile(
                                  leading:
                                      const Icon(Icons.local_offer_outlined),
                                  title: Text(e.name),
                                  onTap: () => onSelected(e),
                                ),
                              )
                              .toList(),
                        );
                      }),
                    ),
                  );
                } else {
                  return const Expanded(
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

class TagListView extends StatelessWidget {
  const TagListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.category),
        centerTitle: true,
      ),
      body: TagList(
        onSelected: (tag) {
          AnnixRouterDelegate.of(context).to(
            name: '/tag',
            arguments: tag.name,
          );
        },
      ),
    );
  }
}
