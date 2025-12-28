import 'package:flutter_with_jaspr/change_notifier_builder.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../constants/theme.dart';

class CounterChangeNotifier with ChangeNotifier {
  int counter = 0;

  void increment() {
    counter++;
    notifyListeners();
  }

  void decrement() {
    counter--;
    notifyListeners();
  }
}

@client
class Counter extends StatefulComponent {
  const Counter({super.key});

  @override
  State<Counter> createState() => CounterState();
}

class CounterState extends State<Counter> {
  final _counterController = CounterChangeNotifier();

  @override
  Component build(BuildContext context) {
    return ChangeNotifierBuilder(
      listenable: _counterController,
      builder: (context) => div([
        div(classes: 'counter', [
          button(
            onClick: () {
              _counterController.decrement();
            },
            [.text('-')],
          ),
          span([.text('${_counterController.counter}')]),

          button(
            onClick: () {
              _counterController.increment();
            },
            [.text('+')],
          ),
        ]),
      ]),
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.counter', [
      css('&').styles(
        display: .flex,
        padding: .symmetric(vertical: 10.px),
        border: .symmetric(
          vertical: .solid(color: primaryColor, width: 2.px),
        ),
        alignItems: .center,
      ),
      css('button', [
        css('&').styles(
          display: .flex,
          width: 2.em,
          height: 2.em,
          border: .unset,
          radius: .all(.circular(2.em)),
          cursor: .pointer,
          justifyContent: .center,
          alignItems: .center,
          fontSize: 2.rem,
          backgroundColor: Colors.transparent,
        ),
        css('&:hover').styles(
          backgroundColor: const Color('#0001'),
        ),
      ]),
      css('span').styles(
        minWidth: 2.5.em,
        padding: .symmetric(horizontal: 2.rem),
        boxSizing: .borderBox,
        color: primaryColor,
        textAlign: .center,
        fontSize: 4.rem,
      ),
    ]),
  ];
}
