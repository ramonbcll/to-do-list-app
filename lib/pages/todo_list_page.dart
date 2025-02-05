import 'package:flutter/material.dart';
import 'package:todolist2/models/todo.dart';
import 'package:todolist2/widgets/todo_list_item.dart';
import 'package:todolist2/repositories/todo_repository.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todos = [];
  Todo? deletedTodo;
  int? deletedTodoIndex;
  String? errorText;
  
  List<Todo>? allDeletedTodos = [];

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: 'Adicione uma tarefa',
                          hintText: 'Ex: Estudar Flutter',
                          errorText: errorText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        String text = todoController.text;

                        if (text.isEmpty) {
                          setState(() {
                            errorText = "Campo obrigatório";
                          });
                          return;
                        }

                        setState(() {
                          todos.add(
                            Todo(
                              title: text,
                              dateTime: DateTime.now(),
                            ),
                          );
                          todoController.clear();
                          errorText = null;
                        });
                        todoRepository.saveTodoList(todos);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (var todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child:
                          Text("Você possui ${todos.length} tarefas pendentes"),
                    ),
                    ElevatedButton(
                      onPressed: showDeleteToDosConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Text("Limpar lista"),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoIndex = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Tarefa ${todo.title} removida com sucesso"),
        action: SnackBarAction(
          label: "Desfazer",
          onPressed: () {
            setState(() {
              todos.insert(deletedTodoIndex!, deletedTodo!);
              todoRepository.saveTodoList(todos);
            });
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void showDeleteToDosConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Limpar tudo?"),
        content: const Text("Deseja realmente limpar tudo?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteAllTodos();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  void deleteAllTodos() {
    allDeletedTodos = List.from(todos);

    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Todas as tarefas foram removidas"),
        action: SnackBarAction(
          label: "Desfazer",
          onPressed: () {
            setState(() {
              todos = List.from(allDeletedTodos!);
              todoRepository.saveTodoList(todos);
            });
          },
        ),
        duration: const Duration(seconds: 8),
      ),
    );
  }
}
