import 'package:annix/providers.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:flutter/material.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TagList extends ConsumerWidget {
  final Function(WidgetRef, TagEntry) onSelected;

  const TagList({super.key, required this.onSelected});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
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
              tabs: TagType.values
                  .map((final type) => Tab(text: type.name))
                  .toList(),
              isScrollable: true,
            ),
          ),
          FutureBuilder<Map<String, TagEntry>>(
              future: ref.read(metadataProvider).getTags(),
              builder: (final context, final snapshot) {
                if (snapshot.hasData) {
                  final sorted = Map.fromEntries(snapshot.data!.entries.toList()
                    ..sort((final e1, final e2) => e1.key.compareTo(e2.key)));

                  return Expanded(
                    child: TabBarView(
                      children:
                          List.generate(TagType.values.length, (final index) {
                        final type = TagType.values[index];
                        return ListView(
                          children: sorted.values
                              .where((final element) => element.type == type)
                              .map(
                                (final e) => ListTile(
                                  leading:
                                      const Icon(Icons.local_offer_outlined),
                                  title: Text(e.name),
                                  onTap: () => onSelected(ref, e),
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
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t.category)),
      body: TagList(
        onSelected: (final ref, final tag) {
          context.push('/tag', extra: tag.name);
        },
      ),
    );
  }
}
