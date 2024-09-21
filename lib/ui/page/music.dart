import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MusicPage extends HookConsumerWidget {
  const MusicPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final bodyFocusNode = useFocusNode();
    final searchController = useSearchController();

    return Scaffold(
      appBar: AppBar(
        title: SearchAnchor.bar(
          searchController: searchController,
          barLeading: const Icon(Icons.search),
          barHintText: 'Search your library',
          barElevation: WidgetStateProperty.all(0),
          suggestionsBuilder: (context, controller) {
            return [
              ListTile(
                leading: Icon(Icons.history),
                title: Text('history 1'),
              )
            ];
          },
          onSubmitted: (value) {
            bodyFocusNode.requestFocus();
            searchController.closeView('');
            context.push('/search', extra: value);
          },
          viewHintText: 'Tracks, albums, artists, and more',
          viewLeading: BackButton(
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              context.pop();
              bodyFocusNode.requestFocus();
            },
          ),
        ),
        elevation: 0,
      ),
      body: Focus(
        focusNode: bodyFocusNode,
        child: Text('123'),
      ),
    );
  }
}
