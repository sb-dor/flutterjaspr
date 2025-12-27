import 'dart:collection';
import 'dart:convert';

import 'package:flutter_with_jaspr/change_notifier_builder.dart';
import 'package:flutter_with_jaspr/models/item.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:http/http.dart' as http;
import 'package:jaspr/server.dart';

// By using the @client annotation this component will be automatically compiled to javascript and mounted
// on the client. Therefore:
// - this file and any imported file must be compilable for both server and client environments.
// - this component and any child components will be built once on the server during pre-rendering and then
//   again on the client during normal rendering.
class Items extends StatefulComponent {
  const Items({super.key});

  @override
  State<StatefulComponent> createState() => _ItemsState();
}

class _ItemsState extends State<Items> with PreloadStateMixin {
  late final _itemsLoaderController = ItemsLoaderController();

  @override
  Future<void> preloadState() async {
    await _itemsLoaderController.loadItems();
  }

  @override
  Component build(BuildContext context) {
    return ChangeNotifierBuilder(
      listenable: _itemsLoaderController,
      component: (context) {
        return section([
          // Header
          header(classes: 'items-header', [
            h1([.text('📰 Stories')]),
            p(classes: 'header-subtitle', [
              .text('${_itemsLoaderController.items.length} items loaded'),
            ]),
          ]),

          // Items List
          if (_itemsLoaderController.items.isEmpty)
            div(classes: 'empty-state', [
              span(classes: 'empty-icon', [.text('📭')]),
              p([.text('No items to display')]),
              p(classes: 'empty-hint', [.text('Items will appear here once loaded')]),
            ])
          else
            section(classes: 'items-list', [
              ul(classes: 'list', [
                for (final item in _itemsLoaderController.items)
                  li(classes: 'item-card', [
                    div(classes: 'item-content', [
                      // Title
                      if (item.url != null)
                        a(
                          href: item.url ?? '',
                          target: Target.blank,
                          classes: 'item-title-link',
                          [
                            h2(classes: 'item-title', [
                              .text(item.title ?? 'Missing title'),
                            ]),
                            span(classes: 'external-icon', [.text('↗')]),
                          ],
                        )
                      else
                        h2(classes: 'item-title', [
                          .text(item.title ?? 'Missing title'),
                        ]),

                      // Metadata
                      div(classes: 'item-meta', [
                        if (item.by != null)
                          span(classes: 'meta-item author', [
                            span(classes: 'meta-icon', [.text('👤')]),
                            .text(item.by!),
                          ]),
                        if (item.time != null)
                          span(classes: 'meta-item time', [
                            span(classes: 'meta-icon', [.text('🕒')]),
                            .text("${item.time ?? ''}"),
                          ]),
                        if (item.id != null)
                          span(classes: 'meta-item id', [
                            span(classes: 'meta-icon', [.text('#')]),
                            .text('${item.id}'),
                          ]),
                      ]),

                      // Text content
                      if (item.text != null && item.text!.isNotEmpty)
                        div(classes: 'item-text', [
                          p([.text(_stripHtml(item.text!))]),
                        ]),

                      // URL display
                      if (item.url != null)
                        div(classes: 'item-url', [
                          span(classes: 'url-icon', [.text('🔗')]),
                          span(classes: 'url-text', [
                            .text(_getDomain(item.url!)),
                          ]),
                        ]),
                    ]),
                  ]),
              ]),
            ]),
        ]);
      },
    );
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#x27;', "'")
        .replaceAll('&#x2F;', '/')
        .trim();
  }

  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }
}

final class ItemsLoaderController with ChangeNotifier {
  ItemsLoaderController({final http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  final List<Item> _items = [];

  UnmodifiableListView<Item> get items => UnmodifiableListView(_items);

  Future<void> loadItems() async {
    _items.clear();
    notifyListeners();

    final response = await _client.get(Uri.parse('https://hacker-news.firebaseio.com/v0/topstories.json'));

    final ids = jsonDecode(response.body);

    final futures = <Future<http.Response>>[];
    int counter = 0;
    while (counter < 10) {
      futures.add(
        _client.get(
          Uri.parse('https://hacker-news.firebaseio.com/v0/item/${ids[counter]}.json'),
        ),
      );
      counter++;
    }

    final resultOfFutures = await Future.wait(futures);
    for (final response in resultOfFutures) {
      _items.add(Item.fromJson(response.body));
    }

    notifyListeners();

    print(ids);
  }
}
