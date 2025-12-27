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
        return div(classes: 'items-container', [
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

  @css
  static List<StyleRule> get styles => [
    css('.items-container').styles(
      minHeight: 100.vh,
      maxWidth: 900.px,
      padding: .all(.auto),
      margin: .all(.auto),
      fontFamily: FontFamily.list([FontFamily('Inter'), FontFamily('system-ui')]),
      backgroundColor: .currentColor,
    ),
    css('.items-header').styles(
      padding: .all(.auto),
      margin: .all(.auto),
      radius: BorderRadius.circular(16.px),
      shadow: .combine([
        BoxShadow(
          color: Colors.red,
          offsetX: 0.px,
          offsetY: 2.px,
          blur: 8.px,
        ),
      ]),
      textAlign: TextAlign.center,
      backgroundColor: Colors.white,
    ),
    css('.items-header h1').styles(
      margin: .only(bottom: 0.5.rem),
      fontSize: 2.5.rem,
      fontWeight: FontWeight.w800,
    ),
    css('.header-subtitle').styles(
      color: Colors.green,
      fontSize: 1.rem,
      fontWeight: FontWeight.w500,
    ),
    css('.empty-state').styles(
      padding: .all(4.rem),
      radius: BorderRadius.circular(16.px),
      color: Colors.orange,
      textAlign: TextAlign.center,
      backgroundColor: Colors.white,
    ),

    css('.empty-icon').styles(
      display: Display.block,
      margin: .only(bottom: 1.rem),
      fontSize: 4.rem,
    ),

    css('.empty-hint').styles(
      margin: .only(top: 0.5.rem),
      fontSize: 0.875.rem,
    ),

    // List Styles
    css('.items-list').styles(
      display: Display.block,
    ),

    css('.list').styles(
      display: Display.flex,
      padding: .all(.zero),
      margin: .all(.zero),
      flexDirection: FlexDirection.column,
      listStyle: ListStyle.none,
    ),

    // Item Card
    css('.item-card').styles(
      padding: .all(1.75.rem),
      radius: BorderRadius.circular(16.px),
      shadow: .combine([
        BoxShadow(
          color: Colors.orange,
          offsetX: 0.px,
          offsetY: 2.px,
          blur: 8.px,
        ),
      ]),
      backgroundColor: Colors.white,
    ),

    css('.item-card:hover').styles(
      shadow: .combine([
        BoxShadow(
          offsetX: 0.px,
          offsetY: 8.px,
          blur: 24.px,
        ),
      ]),
    ),

    css('.item-content').styles(
      display: Display.flex,
      flexDirection: FlexDirection.column,
    ),

    // Title
    css('.item-title-link').styles(
      display: Display.flex,
      alignItems: AlignItems.center,
      color: Colors.orange,
      textDecoration: TextDecoration.none,
    ),

    css('.item-title-link:hover').styles(
      color: Colors.orange,
    ),

    css('.item-title-link:hover .external-icon').styles(),

    css('.item-title').styles(
      margin: .all(.zero),
      color: Colors.orange,
      fontSize: 1.5.rem,
      fontWeight: FontWeight.w700,
      lineHeight: .pixels(1.3),
    ),

    css('.external-icon').styles(
      color: Colors.orange,
      fontSize: 1.rem,
    ),

    // Metadata
    css('.item-meta').styles(
      display: Display.flex,
      flexWrap: FlexWrap.wrap,
      alignItems: AlignItems.center,
    ),

    css('.meta-item').styles(
      display: Display.flex,
      alignItems: AlignItems.center,
      color: Colors.orange,
      fontSize: 0.875.rem,
      fontWeight: FontWeight.w500,
    ),

    css('.meta-icon').styles(
      fontSize: 1.rem,
    ),

    css('.author').styles(
      color: Colors.orange,
      fontWeight: FontWeight.w600,
    ),

    css('.time').styles(
      color: Colors.orange,
    ),

    css('.id').styles(
      color: Colors.orange,
    ),

    // Text Content
    css('.item-text').styles(
      padding: .all(1.rem),
      border: .only(
        left: BorderSide.solid(color: Colors.orange, width: 3.px),
      ),
      radius: BorderRadius.circular(12.px),
      color: Colors.orange,
    ),

    css('.item-text p').styles(
      margin: .all(.zero),
      color: Colors.orange,
      fontSize: 0.9375.rem,
    ),

    // URL
    css('.item-url').styles(
      display: Display.flex,
      padding: .all(0.75.rem),
      radius: BorderRadius.circular(8.px),
      alignItems: AlignItems.center,
      fontSize: 0.875.rem,
      backgroundColor: Colors.orange,
    ),

    css('.url-icon').styles(
      fontSize: 1.rem,
    ),

    css('.url-text').styles(
      color: Colors.orange,
      fontFamily: .initial,
      fontWeight: FontWeight.w600,
    ),
  ];
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
