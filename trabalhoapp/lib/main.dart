import 'package:flutter/material.dart';

void main() {
  runApp(const TrabalhoApp());
}

class TrabalhoApp extends StatefulWidget {
  const TrabalhoApp({Key? key}) : super(key: key);

  @override
  State<TrabalhoApp> createState() => _TrabalhoAppState();
}

class _TrabalhoAppState extends State<TrabalhoApp> {
  bool isDarkTheme = false;

  // lista de tarefas e lista de compras guardadas aqui no nível raiz
  final List<Map<String, dynamic>> tasks = [];
  final List<Map<String, dynamic>> shoppingItems = [];

  void toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
  }

  // métodos para atualizar tarefas
  void addTask(String title) {
    setState(() {
      tasks.add({'title': title, 'done': false});
    });
  }

  void toggleTaskDone(int index) {
    setState(() {
      tasks[index]['done'] = !tasks[index]['done'];
    });
  }

  void removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  // métodos para atualizar lista de compras
  void addShoppingItem(String title) {
    setState(() {
      shoppingItems.add({'title': title, 'done': false});
    });
  }

  void toggleShoppingItemDone(int index) {
    setState(() {
      shoppingItems[index]['done'] = !shoppingItems[index]['done'];
    });
  }

  void removeShoppingItem(int index) {
    setState(() {
      shoppingItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'trabalhoapp',
      theme: isDarkTheme ? ThemeData.dark() : ThemeData(primarySwatch: Colors.teal),
      home: HomePage(
        isDarkTheme: isDarkTheme,
        toggleTheme: toggleTheme,
        tasks: tasks,
        addTask: addTask,
        toggleTaskDone: toggleTaskDone,
        removeTask: removeTask,
        shoppingItems: shoppingItems,
        addShoppingItem: addShoppingItem,
        toggleShoppingItemDone: toggleShoppingItemDone,
        removeShoppingItem: removeShoppingItem,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDarkTheme;
  final VoidCallback toggleTheme;

  final List<Map<String, dynamic>> tasks;
  final Function(String) addTask;
  final Function(int) toggleTaskDone;
  final Function(int) removeTask;

  final List<Map<String, dynamic>> shoppingItems;
  final Function(String) addShoppingItem;
  final Function(int) toggleShoppingItemDone;
  final Function(int) removeShoppingItem;

  const HomePage({
    Key? key,
    required this.isDarkTheme,
    required this.toggleTheme,
    required this.tasks,
    required this.addTask,
    required this.toggleTaskDone,
    required this.removeTask,
    required this.shoppingItems,
    required this.addShoppingItem,
    required this.toggleShoppingItemDone,
    required this.removeShoppingItem,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('tarefas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'estatísticas de tarefas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StatisticsPage(tasks: widget.tasks),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'lista de compras',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShoppingListPage(
                    shoppingItems: widget.shoppingItems,
                    addShoppingItem: widget.addShoppingItem,
                    toggleShoppingItemDone: widget.toggleShoppingItemDone,
                    removeShoppingItem: widget.removeShoppingItem,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'configurações',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(
                    isDarkTheme: widget.isDarkTheme,
                    toggleTheme: widget.toggleTheme,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'sobre',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            },
          ),
        ],
      ),
      body: widget.tasks.isEmpty
          ? const Center(
              child: Text('nenhuma tarefa adicionada!', style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              itemCount: widget.tasks.length,
              itemBuilder: (context, index) {
                final task = widget.tasks[index];
                return Dismissible(
                  key: Key(task['title'] + index.toString()), // Optimized key
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    widget.removeTask(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('tarefa removida')),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      task['title'],
                      style: TextStyle(
                        decoration: task['done'] ? TextDecoration.lineThrough : null,
                        color: task['done'] ? Colors.grey : null,
                        fontSize: 18,
                      ),
                    ),
                    trailing: Checkbox(
                      value: task['done'],
                      onChanged: (value) {
                        widget.toggleTaskDone(index);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskPage()),
          );
          if (newTask != null && newTask.trim().isNotEmpty) {
            widget.addTask(newTask);
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'adicionar tarefa',
      ),
    );
  }
}

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    if (_controller.text.trim().isEmpty) return;
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('adicionar tarefa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'tarefa',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: const Text('salvar')),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller
    super.dispose();
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('sobre')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'este aplicativo foi criado para o trabalho de flutter.\n\n'
          'funcionalidades:\n'
          '- adicionar tarefas\n'
          '- marcar tarefas como concluídas\n'
          '- remover tarefas deslizando\n'
          '- adicionar itens à lista de compras\n' // Added functionality
          '- marcar itens de compra como concluídos\n' // Added functionality
          '- remover itens de compra deslizando\n' // Added functionality
          '- tema claro e escuro nas configurações\n'
          '- estatísticas simples de tarefas\n'
          '- estatísticas simples de lista de compras\n\n' // Added functionality
          'equipe: Caio Queiroz, Pedro Souza',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final bool isDarkTheme;
  final VoidCallback toggleTheme;

  const SettingsPage({Key? key, required this.isDarkTheme, required this.toggleTheme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('configurações')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.brightness_6, size: 28),
            const SizedBox(width: 10),
            const Text('tema escuro'),
            const Spacer(),
            Switch(
              value: isDarkTheme,
              onChanged: (_) => toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }
}

class StatisticsPage extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;

  const StatisticsPage({Key? key, required this.tasks}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = tasks.length;
    final done = tasks.where((t) => t['done'] == true).length;

    return Scaffold(
      appBar: AppBar(title: const Text('estatísticas de tarefas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('tarefas totais: $total', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('tarefas concluídas: $done', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              color: Colors.teal, // Added color for progress bar
            ),
          ],
        ),
      ),
    );
  }
}

class ShoppingListPage extends StatefulWidget {
  final List<Map<String, dynamic>> shoppingItems;
  final Function(String) addShoppingItem;
  final Function(int) toggleShoppingItemDone;
  final Function(int) removeShoppingItem;

  const ShoppingListPage({
    Key? key,
    required this.shoppingItems,
    required this.addShoppingItem,
    required this.toggleShoppingItemDone,
    required this.removeShoppingItem,
  }) : super(key: key);

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final TextEditingController _controller = TextEditingController();

  void _addItem() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.addShoppingItem(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('lista de compras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'estatísticas de compras',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShoppingStatisticsPage(shoppingItems: widget.shoppingItems),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'adicionar item',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addItem, child: const Text('adicionar')),
              ],
            ),
          ),
          Expanded(
            child: widget.shoppingItems.isEmpty
                ? const Center(
                    child: Text('nenhum item na lista de compras!', style: TextStyle(fontSize: 18)),
                  )
                : ListView.builder(
                    itemCount: widget.shoppingItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.shoppingItems[index];
                      return Dismissible(
                        key: Key(item['title'] + index.toString()),
                        onDismissed: (_) {
                          widget.removeShoppingItem(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('item removido da lista de compras')),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          title: Text(
                            item['title'],
                            style: TextStyle(
                              decoration: item['done'] ? TextDecoration.lineThrough : null,
                              color: item['done'] ? Colors.grey : null,
                            ),
                          ),
                          trailing: Checkbox(
                            value: item['done'],
                            onChanged: (_) => widget.toggleShoppingItemDone(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller
    super.dispose();
  }
}

class ShoppingStatisticsPage extends StatelessWidget {
  final List<Map<String, dynamic>> shoppingItems;

  const ShoppingStatisticsPage({Key? key, required this.shoppingItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = shoppingItems.length;
    final done = shoppingItems.where((item) => item['done'] == true).length;

    return Scaffold(
      appBar: AppBar(title: const Text('estatísticas de compras')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('itens totais: $total', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('itens concluídos: $done', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              color: Colors.teal, // Added color for progress bar
            ),
          ],
        ),
      ),
    );
  }
}