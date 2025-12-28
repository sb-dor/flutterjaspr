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
          header(
            styles: Styles(
              padding: .symmetric(vertical: 32.px, horizontal: 24.px),
              shadow: .combine([
                BoxShadow(
                  offsetX: 0.px,
                  offsetY: 4.px,
                  blur: 10.px,
                ),
              ]),
              color: .rgb(255, 255, 255),
              backgroundColor: .rgb(37, 99, 235),
            ),
            [
              h1(
                styles: Styles(
                  margin: .only(bottom: 8.px),
                  fontSize: 36.px,
                  fontWeight: FontWeight.bold,
                  letterSpacing: (-0.5).px,
                ),
                [.text('📰 Stories')],
              ),
              p(
                styles: Styles(
                  opacity: 0.9,
                  fontSize: 16.px,
                  fontWeight: FontWeight.w500,
                ),
                [
                  .text('${_itemsLoaderController.items.length} items loaded'),
                ],
              ),
            ],
          ),

          // Items List
          if (_itemsLoaderController.items.isEmpty)
            div(
              styles: Styles(
                padding: .all(64.px),
                margin: .all(24.px),
                radius: BorderRadius.circular(16.px),
                textAlign: TextAlign.center,
                backgroundColor: Color.rgb(248, 250, 252),
              ),
              [
                span(
                  styles: Styles(
                    display: Display.block,
                    margin: .only(bottom: 16.px),
                    fontSize: 64.px,
                  ),
                  [.text('📭')],
                ),
                p(
                  styles: Styles(
                    margin: .only(bottom: 8.px),
                    color: Color.rgb(30, 41, 59),
                    fontSize: 20.px,
                    fontWeight: FontWeight.w600,
                  ),
                  [.text('No items to display')],
                ),
                p(
                  styles: Styles(
                    color: Color.rgb(100, 116, 139),
                    fontSize: 14.px,
                  ),
                  classes: 'empty-hint',
                  [.text('Items will appear here once loaded')],
                ),
              ],
            )
          else
            section(
              styles: Styles(
                maxWidth: 1200.px,
                padding: .all(24.px),
                margin: .symmetric(horizontal: Unit.auto),
              ),
              [
                ul(
                  styles: Styles(
                    display: Display.grid,
                    padding: .zero,
                    margin: .zero,
                    gap: Gap.all(24.px),
                    listStyle: ListStyle.none,
                  ),
                  [
                    for (final item in _itemsLoaderController.items)
                      li(
                        styles: Styles(
                          backgroundColor: Color.rgb(255, 255, 255),
                          radius: BorderRadius.circular(12.px),
                          padding: .all(24.px),
                          shadow: BoxShadow(
                            offsetX: 0.px,
                            offsetY: 2.px,
                            blur: 8.px,
                            color: Color.rgb(0, 0, 5),
                          ),
                          border: Border.all(
                            color: Color.rgb(226, 232, 240),
                            width: 1.px,
                          ),
                          transition: Transition(
                            'all',
                            duration: Duration(milliseconds: 200),
                            curve: .ease,
                          ),
                          raw: {
                            '&:hover': 'box-shadow: 0 8px 24px rgba(0,0,0,0.12); transform: translateY(-2px);',
                          },
                        ),
                        [
                          div(
                            styles: Styles(
                              display: Display.flex,
                              flexDirection: FlexDirection.column,
                              gap: Gap.all(16.px),
                            ),
                            [
                              // Title
                              if (item.url != null)
                                a(
                                  href: item.url ?? '',
                                  target: Target.blank,
                                  styles: Styles(
                                    display: Display.flex,
                                    alignItems: AlignItems.center,
                                    gap: Gap.all(8.px),
                                    color: Color.rgb(30, 41, 59),
                                    textDecoration: TextDecoration.none,
                                    raw: {
                                      '&:hover': 'color: rgb(37, 99, 235);',
                                    },
                                  ),
                                  [
                                    h2(
                                      styles: Styles(
                                        margin: .zero,
                                        fontSize: 20.px,
                                        fontWeight: FontWeight.w700,
                                        lineHeight: 1.4.em,
                                      ),
                                      [
                                        .text(item.title ?? 'Missing title'),
                                      ],
                                    ),
                                    span(
                                      styles: Styles(
                                        opacity: 0.6,
                                        fontSize: 14.px,
                                      ),
                                      [.text('↗')],
                                    ),
                                  ],
                                )
                              else
                                h2(
                                  styles: Styles(
                                    margin: .zero,
                                    color: Color.rgb(30, 41, 59),
                                    fontSize: 20.px,
                                    fontWeight: FontWeight.w700,
                                    lineHeight: 1.4.em,
                                  ),
                                  [
                                    .text(item.title ?? 'Missing title'),
                                  ],
                                ),

                              // Metadata
                              div(
                                styles: Styles(
                                  display: Display.flex,
                                  flexWrap: FlexWrap.wrap,
                                  gap: Gap.all(16.px),
                                  color: Color.rgb(100, 116, 139),
                                  fontSize: 14.px,
                                ),
                                [
                                  if (item.by != null)
                                    span(
                                      styles: Styles(
                                        display: Display.flex,
                                        alignItems: AlignItems.center,
                                        gap: Gap.all(6.px),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      [
                                        span(classes: 'meta-icon', [.text('👤')]),
                                        .text(item.by!),
                                      ],
                                    ),
                                  if (item.time != null)
                                    span(
                                      styles: Styles(
                                        display: Display.flex,
                                        alignItems: AlignItems.center,
                                        gap: Gap.all(6.px),
                                      ),
                                      [
                                        span(classes: 'meta-icon', [.text('🕒')]),
                                        .text("${item.time ?? ''}"),
                                      ],
                                    ),
                                  if (item.id != null)
                                    span(
                                      styles: Styles(
                                        display: Display.flex,
                                        alignItems: AlignItems.center,
                                        gap: Gap.all(6.px),
                                      ),
                                      [
                                        span(classes: 'meta-icon', [.text('#')]),
                                        .text('${item.id}'),
                                      ],
                                    ),
                                ],
                              ),

                              // Text content
                              if (item.text != null && item.text!.isNotEmpty)
                                div(
                                  styles: Styles(
                                    padding: .all(16.px),
                                    border: Border.all(
                                      color: Color.rgb(226, 232, 240),
                                      width: 1.px,
                                    ),
                                    radius: BorderRadius.circular(8.px),
                                    color: Color.rgb(71, 85, 105),
                                    fontSize: 14.px,
                                    lineHeight: 1.6.em,
                                    backgroundColor: Color.rgb(248, 250, 252),
                                  ),
                                  [
                                    p(
                                      styles: Styles(
                                        margin: .zero,
                                      ),
                                      [.text(_stripHtml(item.text!))],
                                    ),
                                  ],
                                ),

                              // URL display
                              if (item.url != null)
                                div(
                                  styles: Styles(
                                    display: Display.flex,
                                    padding: .symmetric(
                                      vertical: 8.px,
                                      horizontal: 12.px,
                                    ),
                                    radius: BorderRadius.circular(6.px),
                                    alignItems: AlignItems.center,
                                    gap: Gap.all(8.px),
                                    color: Color.rgb(100, 116, 139),
                                    fontSize: 13.px,
                                    backgroundColor: Color.rgb(241, 245, 249),
                                    raw: {
                                      'width': 'fit-content',
                                    },
                                  ),
                                  [
                                    span(classes: 'url-icon', [.text('🔗')]),
                                    span(classes: 'url-text', [
                                      .text(_getDomain(item.url!)),
                                    ]),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
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
