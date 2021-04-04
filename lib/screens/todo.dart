import 'package:flutter/material.dart';
import 'package:mung_ge_mung_ge/models/todo.dart';
import 'package:mung_ge_mung_ge/screens/components/todo-list.dart';

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


