import 'package:flutter/material.dart';
import 'package:mung_ge_mung_ge/models/todo.dart';
import 'package:mung_ge_mung_ge/screens/components/todo-item.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final void Function(int index) clickCheckbox;
  final void Function(int index) deleteTodo;
  final void Function(int index) clickEditBtn;
  final void Function(int oldIndex, int newIndex) onReorderTodoList;

  TodoList({
    required this.todos,
    required this.clickCheckbox,
    required this.deleteTodo,
    required this.clickEditBtn,
    required this.onReorderTodoList,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: ReorderableListView(
          onReorder: this.onReorderTodoList,
          children: <Widget>[
            for (int index = 0; index < todos.length; index++)
              TodoItem(
                key: ValueKey(todos[index]),
                todo: todos[index],
                clickCheckbox: () => clickCheckbox(index),
                deleteTodo: () => deleteTodo(index),
                clickEditBtn: () => clickEditBtn(index),
              ),
          ],
        ),
      ),
    );
  }
}
