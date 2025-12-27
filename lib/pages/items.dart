import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

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

class _ItemsState extends State<Items> {
  @override
  Component build(BuildContext context) {
    return div([]);
  }

  @css
  static List<StyleRule> get styles => [
    css('ol').styles(maxWidth: 500.px),
  ];
}
