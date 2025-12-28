import 'dart:collection';
import 'package:flutter_with_jaspr/change_notifier_builder.dart';
import 'package:flutter_with_jaspr/models/todo.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class TodoApp extends StatefulComponent {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final _todoController = TodoController();
  final _inputId = 'todo-input';

  @override
  Component build(BuildContext context) {
    return ChangeNotifierBuilder(
      listenable: _todoController,
      component: (context) {
        final completedCount = _todoController.todos.where((t) => t.isCompleted).length;
        final totalCount = _todoController.todos.length;

        return section(
          styles: Styles(
            minHeight: 100.vh,
            padding: .all(24.px),
            backgroundColor: Color.rgb(248, 250, 252),
          ),
          [
            // Container
            div(
              styles: Styles(
                maxWidth: 800.px,
                margin: .symmetric(horizontal: Unit.auto),
              ),
              [
                // Header
                header(
                  styles: Styles(
                    padding: .symmetric(vertical: 48.px, horizontal: 32.px),
                    margin: .only(bottom: 32.px),
                    radius: BorderRadius.circular(20.px),
                    shadow: BoxShadow(
                      offsetX: 0.px,
                      offsetY: 8.px,
                      blur: 24.px,
                      color: Color.rgb(99, 102, 241),
                    ),
                    backgroundColor: Color.rgb(99, 102, 241),
                  ),
                  [
                    h1(
                      styles: Styles(
                        margin: .zero,
                        color: Color.rgb(255, 255, 255),
                        fontSize: 42.px,
                        fontWeight: FontWeight.bold,
                        letterSpacing: (-1).px,
                        textAlign: TextAlign.center,
                      ),
                      [.text('✨ My Tasks')],
                    ),
                    p(
                      styles: Styles(
                        margin: .only(top: 12.px),
                        color: Color.rgb(255, 255, 255),
                        fontSize: 16.px,
                        textAlign: TextAlign.center,
                      ),
                      [
                        .text('$completedCount of $totalCount completed'),
                      ],
                    ),
                  ],
                ),

                // Add Todo Form
                div(
                  styles: Styles(
                    backgroundColor: Color.rgb(255, 255, 255),
                    padding: .all(24.px),
                    radius: BorderRadius.circular(16.px),
                    shadow: BoxShadow(
                      offsetX: 0.px,
                      offsetY: 2.px,
                      blur: 8.px,
                      color: Color.rgb(0, 0, 5),
                    ),
                    margin: .only(bottom: 24.px),
                  ),
                  [
                    div(
                      styles: Styles(
                        display: Display.flex,
                        gap: Gap.all(12.px),
                      ),
                      [
                        input(
                          id: _inputId,
                          type: InputType.text,
                          value: 'Add a new task...',
                          styles: Styles(
                            flex: Flex(grow: 1),
                            padding: .symmetric(vertical: 14.px, horizontal: 20.px),
                            fontSize: 16.px,
                            border: Border.all(
                              color: Color.rgb(226, 232, 240),
                              width: 2.px,
                            ),
                            radius: BorderRadius.circular(10.px),
                            color: Color.rgb(30, 41, 59),
                            raw: {
                              'outline': 'none',
                              '&:focus': 'border-color: rgb(99, 102, 241);',
                            },
                          ),
                          events: {
                            'keypress': (event) {
                              if (event.type == 'Enter') {
                                _addTodo();
                              }
                            },
                          },
                        ),
                        button(
                          styles: Styles(
                            padding: .symmetric(vertical: 14.px, horizontal: 28.px),
                            backgroundColor: Color.rgb(99, 102, 241),
                            color: Color.rgb(255, 255, 255),
                            border: .none,
                            radius: BorderRadius.circular(10.px),
                            fontSize: 16.px,
                            fontWeight: FontWeight.w600,
                            cursor: Cursor.pointer,
                            transition: Transition(
                              'all',
                              duration: Duration(milliseconds: 200),
                              curve: .ease,
                            ),
                            raw: {
                              '&:hover': 'background-color: rgb(79, 70, 229); transform: translateY(-1px);',
                              '&:active': 'transform: translateY(0);',
                            },
                          ),
                          events: {
                            'click': (event) => _addTodo(),
                          },
                          [.text('Add Task')],
                        ),
                      ],
                    ),
                  ],
                ),

                // Filter Buttons
                div(
                  styles: Styles(
                    display: Display.flex,
                    gap: Gap.all(8.px),
                    margin: .only(bottom: 24.px),
                    justifyContent: JustifyContent.center,
                  ),
                  [
                    for (final filter in TodoFilter.values)
                      button(
                        styles: Styles(
                          padding: .symmetric(vertical: 10.px, horizontal: 20.px),
                          border: Border.all(
                            color: _todoController.currentFilter == filter
                                ? Color.rgb(99, 102, 241)
                                : Color.rgb(226, 232, 240),
                            width: 2.px,
                          ),

                          radius: BorderRadius.circular(8.px),
                          cursor: Cursor.pointer,
                          transition: Transition(
                            'all',
                            duration: Duration(milliseconds: 200),
                            curve: .ease,
                          ),
                          color: _todoController.currentFilter == filter
                              ? Color.rgb(255, 255, 255)
                              : Color.rgb(100, 116, 139),
                          fontSize: 14.px,
                          fontWeight: FontWeight.w600,
                          backgroundColor: _todoController.currentFilter == filter
                              ? Color.rgb(99, 102, 241)
                              : Color.rgb(255, 255, 255),
                          raw: {
                            '&:hover': 'transform: translateY(-1px);',
                          },
                        ),
                        onClick: () => _todoController.setFilter(filter),
                        [.text(_getFilterLabel(filter))],
                      ),
                  ],
                ),

                // Todo List
                if (_todoController.filteredTodos.isEmpty)
                  div(
                    styles: Styles(
                      padding: .all(64.px),
                      backgroundColor: Color.rgb(255, 255, 255),
                      radius: BorderRadius.circular(16.px),
                      textAlign: TextAlign.center,
                      shadow: BoxShadow(
                        offsetX: 0.px,
                        offsetY: 2.px,
                        blur: 8.px,
                        color: Color.rgb(0, 0, 5),
                      ),
                    ),
                    [
                      span(
                        styles: Styles(
                          display: Display.block,
                          fontSize: 64.px,
                          margin: .only(bottom: 16.px),
                        ),
                        [.text('📝')],
                      ),
                      p(
                        styles: Styles(
                          margin: .zero,
                          color: Color.rgb(100, 116, 139),
                          fontSize: 18.px,
                        ),
                        [.text(_getEmptyMessage())],
                      ),
                    ],
                  )
                else
                  ul(
                    styles: Styles(
                      display: Display.flex,
                      padding: .zero,
                      margin: .zero,
                      flexDirection: FlexDirection.column,
                      gap: Gap.all(12.px),
                      listStyle: ListStyle.none,
                    ),
                    [
                      for (final todo in _todoController.filteredTodos)
                        li(
                          styles: Styles(
                            padding: .all(20.px),
                            border: Border.all(
                              color: Color.rgb(226, 232, 240),
                              width: 1.px,
                            ),
                            radius: BorderRadius.circular(12.px),
                            shadow: BoxShadow(
                              offsetX: 0.px,
                              offsetY: 2.px,
                              blur: 6.px,
                              color: Color.rgb(0, 0, 5),
                            ),
                            transition: Transition(
                              'all',
                              duration: Duration(milliseconds: 200),
                              curve: .ease,
                            ),
                            backgroundColor: Color.rgb(255, 255, 255),
                            raw: {
                              '&:hover': 'box-shadow: 0 4px 12px rgba(0,0,0,0.08);',
                            },
                          ),
                          [
                            div(
                              styles: Styles(
                                display: Display.flex,
                                alignItems: AlignItems.center,
                                gap: Gap.all(16.px),
                              ),
                              [
                                // Checkbox
                                button(
                                  styles: Styles(
                                    width: 24.px,
                                    height: 24.px,
                                    border: Border.all(
                                      color: todo.isCompleted ? Color.rgb(34, 197, 94) : Color.rgb(203, 213, 225),
                                      width: 2.px,
                                    ),
                                    radius: BorderRadius.circular(6.px),
                                    backgroundColor: todo.isCompleted
                                        ? Color.rgb(34, 197, 94)
                                        : Color.rgb(255, 255, 255),
                                    cursor: Cursor.pointer,
                                    transition: Transition(
                                      'all',
                                      duration: Duration(milliseconds: 200),
                                      curve: .ease,
                                    ),
                                    display: Display.flex,
                                    alignItems: AlignItems.center,
                                    justifyContent: JustifyContent.center,
                                    color: Color.rgb(255, 255, 255),
                                    fontSize: 14.px,
                                    raw: {
                                      'flex-shrink': '0',
                                      '&:hover': 'transform: scale(1.1);',
                                    },
                                  ),
                                  events: {
                                    'click': (event) => _todoController.toggleTodo(todo.id),
                                  },
                                  [
                                    if (todo.isCompleted) .text('✓'),
                                  ],
                                ),

                                // Todo Text
                                span(
                                  styles: Styles(
                                    flex: Flex(grow: 1),
                                    fontSize: 16.px,
                                    color: todo.isCompleted ? Color.rgb(148, 163, 184) : Color.rgb(30, 41, 59),
                                    textDecoration: todo.isCompleted ? TextDecoration.inherit : TextDecoration.none,
                                    transition: Transition(
                                      'all',
                                      duration: Duration(milliseconds: 200),
                                      curve: .ease,
                                    ),
                                  ),
                                  [.text(todo.title)],
                                ),

                                // Delete Button
                                button(
                                  styles: Styles(
                                    padding: .all(8.px),
                                    backgroundColor: Color.rgb(254, 226, 226),
                                    color: Color.rgb(220, 38, 38),
                                    border: Border.none,
                                    radius: BorderRadius.circular(8.px),
                                    cursor: Cursor.pointer,
                                    fontSize: 18.px,
                                    transition: Transition(
                                      'all',
                                      duration: Duration(milliseconds: 200),
                                      curve: .ease,
                                    ),
                                    raw: {
                                      'flex-shrink': '0',
                                      '&:hover':
                                          'background-color: rgb(239, 68, 68); color: rgb(255, 255, 255); transform: scale(1.1);',
                                    },
                                  ),
                                  events: {
                                    'click': (event) => _todoController.deleteTodo(todo.id),
                                  },
                                  [.text('🗑️')],
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _addTodo() {
    // final input = document.getElementById(_inputId) as InputElement?;
    // if (input != null && input.value.trim().isNotEmpty) {
    //   _todoController.addTodo(input.value.trim());
    //   input.value = '';
    // }
  }

  String _getFilterLabel(TodoFilter filter) {
    switch (filter) {
      case TodoFilter.all:
        return 'All';
      case TodoFilter.active:
        return 'Active';
      case TodoFilter.completed:
        return 'Completed';
    }
  }

  String _getEmptyMessage() {
    switch (_todoController.currentFilter) {
      case TodoFilter.all:
        return 'No tasks yet. Add one above!';
      case TodoFilter.active:
        return 'No active tasks. Great job!';
      case TodoFilter.completed:
        return 'No completed tasks yet.';
    }
  }
}

class TodoController with ChangeNotifier {
  final List<Todo> _todos = [];
  TodoFilter _currentFilter = TodoFilter.all;

  UnmodifiableListView<Todo> get todos => UnmodifiableListView(_todos);
  TodoFilter get currentFilter => _currentFilter;

  List<Todo> get filteredTodos {
    switch (_currentFilter) {
      case TodoFilter.all:
        return _todos;
      case TodoFilter.active:
        return _todos.where((t) => !t.isCompleted).toList();
      case TodoFilter.completed:
        return _todos.where((t) => t.isCompleted).toList();
    }
  }

  void addTodo(String title) {
    _todos.add(
      Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
      ),
    );
    notifyListeners();
  }

  void toggleTodo(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(isCompleted: !_todos[index].isCompleted);
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void setFilter(TodoFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }
}
