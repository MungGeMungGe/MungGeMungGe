import 'package:flutter/material.dart';
import 'package:mung_ge_mung_ge/models/todo.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Todo> _todos = []; // 할일 리스트
  late TextEditingController _controller; // 할일 입력 TextField Controller
  late FocusNode _focusNode; // 할일 입력 TextField FocusNode
  int? editingTodoIndex; // 수정 중인 할의 index

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
        onTap: () { // 키보드 외 다른 화면 터치 시
          if (_focusNode.hasFocus) { // 키보드가 내려가는 작업
            _focusNode.unfocus();
          }
          if (editingTodoIndex != null) {
            cancelEditTodo();
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
              todos: _todos,
              clickCheckbox: clickCheckbox,
              deleteTodo: deleteTodo,
              clickEditBtn: clickEditBtn,
              onReorderTodoList: reorderTodos,
            ),
          ],
        ),
      ),
    );
  }

  // 할일 List Reorder 시 호출
  reorderTodos(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final Todo todo = _todos.removeAt(oldIndex);
      _todos.insert(newIndex, todo);
    });
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
      _todos.add(todo);
      _controller.clear();
    });
  }

  // 할일 수정
  editTodo(String text) {
    setState(() {
      _todos[editingTodoIndex!].content = text;
    });
    cancelEditTodo();
  }

  // 할일 완료 Checkbox Click
  clickCheckbox(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
    });
  }

  // 할일 삭제
  deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
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
      () {
        _controller.text = _todos[index].content;
        _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
      }
    );
  }

  // 할일 수정 취
  cancelEditTodo() {
    setState(() {
      editingTodoIndex = null;
      _controller.text = '';
    });
  }
}

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

