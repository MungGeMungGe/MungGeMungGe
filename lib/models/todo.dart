class Todo {
  String content; // 할일 내용
  bool isDone; // 할일 완료 여부

  Todo ({
    required this.content,
    this.isDone = false
  });
}