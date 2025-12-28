// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:flutter_with_jaspr/components/counter.dart' as _counter;
import 'package:flutter_with_jaspr/components/header.dart' as _header;
import 'package:flutter_with_jaspr/pages/about.dart' as _about;
import 'package:flutter_with_jaspr/pages/todos.dart' as _todos;
import 'package:flutter_with_jaspr/app.dart' as _app;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    _counter.Counter: ClientTarget<_counter.Counter>('counter'),
    _todos.TodoApp: ClientTarget<_todos.TodoApp>('todos'),
  },
  styles: () => [
    ..._counter.CounterState.styles,
    ..._header.Header.styles,
    ..._about.About.styles,
    ..._app.App.styles,
  ],
);
