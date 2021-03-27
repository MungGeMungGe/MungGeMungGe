import 'package:flutter/material.dart';
import 'package:mung_ge_mung_ge/models/todo.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Todo> todos = [];
  late TextEditingController _controller;
  late FocusNode _focusNode;
  int? editingTodoIndex; // 수정 중인 Todo의 index

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO'),
      ),
      body: GestureDetector(
        onTap: () {
          if (_focusNode.hasFocus) {
            _focusNode.unfocus();
          }
          if (editingTodoIndex != null) {
            editingTodoIndex = null;
            _controller.text = '';
          }
        },
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: (text) => submitText(text),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                hintText: 'Add a new task',
              ),
            ),
            TodoList(
              todos: todos,
              clickCheckbox: clickCheckbox,
              deleteTodo: deleteTodo,
              clickEditBtn: clickEditBtn,
            ),
          ],
        ),
      ),
    );
  }

  // Text Field 'Enter' 입력 시
  submitText(String text) {
    if (text.isEmpty == true) { return; }

    // 현재 할일 수정 중인 경우
    if (editingTodoIndex != null) {
      editTodo(text);
      return;
    }

    addTodo(text);
  }

  // 새로운 할일 추가
  addTodo(String text) {
    Todo todo = Todo(content: text);
    setState(() {
      todos.add(todo);
      _controller.clear();
    });
  }

  // 할일 수정
  editTodo(String text) {
    setState(() {
      todos[editingTodoIndex!].content = text;
      editingTodoIndex = null;
      _controller.text = '';
    });
  }

  // 할일 완료 Checkbox Click
  clickCheckbox(int index) {
    setState(() {
      todos[index].isDone = !todos[index].isDone;
    });
  }

  // 할일 삭제
  deleteTodo(int index) {
    setState(() {
      todos.removeAt(index);
    });
  }

  // 할일 수정 버튼 클릭 시
  clickEditBtn(int index) {
    setState(() {
      editingTodoIndex = index;
      _focusNode.requestFocus();
    });
    Future.delayed(
      Duration(microseconds: 500),
      () { _controller.text = todos[index].content; }
    );
  }
}

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final void Function(int index) clickCheckbox;
  final void Function(int index) deleteTodo;
  final void Function(int index) clickEditBtn;

  TodoList({
    required this.todos,
    required this.clickCheckbox,
    required this.deleteTodo,
    required this.clickEditBtn,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: ListView.builder(
          itemCount: todos.length,
          itemBuilder: (BuildContext context, int index) {
            return TodoItem(
              todo: todos[index],
              clickCheckbox: () => clickCheckbox(index),
              deleteTodo: () => deleteTodo(index),
              clickEditBtn: () => clickEditBtn(index),
            );
          },
        ),
      ),
    );
  }
}


class TodoItem extends StatelessWidget {
  Todo todo;
  VoidCallback clickCheckbox;
  VoidCallback deleteTodo;
  VoidCallback clickEditBtn;
  
  TodoItem({
    required this.todo,
    required this.clickCheckbox,
    required this.deleteTodo,
    required this.clickEditBtn,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) {
        deleteTodo();
      },
      child: ListTile(
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
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
                onChanged: (event) {
                  clickCheckbox();
                },
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
                onTap: () => clickEditBtn(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

