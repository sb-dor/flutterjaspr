import 'package:jaspr/jaspr.dart';

import 'todos.vm.dart' if (dart.library.js_interop) 'todos.web.dart';

// A simple [StatelessComponent] with a [build] method
@client
class Todos extends StatelessComponent {
  const Todos({super.key});

  @override
  Component build(BuildContext context) {
    return TodoApp();
  }
}
