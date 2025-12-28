import 'package:jaspr/jaspr.dart';

class ChangeNotifierBuilder extends StatefulComponent {
  const ChangeNotifierBuilder({
    super.key,
    required this.listenable,
    required this.builder,
  });

  final Listenable listenable;
  final Component Function(BuildContext context) builder;

  @override
  State<ChangeNotifierBuilder> createState() => _ChangeNotifierBuilderState();
}

class _ChangeNotifierBuilderState extends State<ChangeNotifierBuilder> {
  @override
  void initState() {
    super.initState();
    component.listenable.addListener(_listener);
  }

  @override
  void dispose() {
    component.listenable.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Component build(BuildContext context) {
    return component.builder(context);
  }
}
