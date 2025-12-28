// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_with_jaspr/components/counter.dart'
    deferred as _counter;
import 'package:flutter_with_jaspr/pages/todos/todos.dart' deferred as _todos;
import 'package:shared_preferences_web/shared_preferences_web.dart'
    as _shared_preferences_web;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  initialize: () {
    final Registrar registrar = webPluginRegistrar;
    _shared_preferences_web.SharedPreferencesPlugin.registerWith(registrar);
    registrar.registerMessageHandler();
  },
  clients: {
    'counter': ClientLoader(
      (p) => _counter.Counter(),
      loader: _counter.loadLibrary,
    ),
    'todos': ClientLoader((p) => _todos.Todos(), loader: _todos.loadLibrary),
  },
);
