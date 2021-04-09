import 'package:flutter/material.dart';
import 'package:mung_ge_mung_ge/models/todo.dart';

class TodoItem extends StatelessWidget {
  Todo todo;
  VoidCallback clickCheckbox;
  VoidCallback deleteTodo;
  VoidCallback clickEditBtn;

  TodoItem({
    Key? key,
    required this.todo,
    required this.clickCheckbox,
    required this.deleteTodo,
    required this.clickEditBtn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        deleteTodo();
      },
      child: ListTile(
        key: UniqueKey(),
        title: Container(
          padding: EdgeInsets.only(
              top: 10.0,
              bottom: 10.0,
              left: 5.0,
              right: 20.0
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
              Checkbox(
                value: todo.isDone,
                activeColor: Colors.grey,
                onChanged: (event) => clickCheckbox(),
              ),
              Text(
                todo.content,
                style: TextStyle(
                  fontSize: 16.0,
                  decoration: todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
              Spacer(),
              GestureDetector(
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                ),
                onTap: clickEditBtn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
