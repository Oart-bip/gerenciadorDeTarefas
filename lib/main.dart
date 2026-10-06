import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class TaskProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _tarefas = [
    {'titulo': 'Estudar Flutter', 'feita': false},
    {'titulo': 'Fazer trabalho', 'feita': false},
    {'titulo': 'Revisar conteúdo', 'feita': false},
  ];

  List<Map<String, dynamic>> get tarefas => _tarefas;
  int get total => _tarefas.length;
  int get concluidas => _tarefas.where((t) => t['feita']).length;
  int get pendentes => total - concluidas;

  void adicionar(String titulo) {
    _tarefas.add({'titulo': titulo, 'feita': false});
    notifyListeners();
  }

  void remover(int i) {
    _tarefas.removeAt(i);
    notifyListeners();
  }

  void alternar(int i) {
    _tarefas[i]['feita'] = !_tarefas[i]['feita'];
    notifyListeners();
  }
}

void main() {
  runApp(

    ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: const MaterialApp(home: Home()),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _aba = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_aba == 0 ? 'Minhas Tarefas' : 'Resumo'),
        backgroundColor: Colors.blue,
      ),
      body: _aba == 0 ? const PaginaTarefas() : const PaginaResumo(),
      floatingActionButton: _aba == 0
          ? FloatingActionButton(
              onPressed: () => _dialogoAdicionar(context),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _aba,
        onTap: (i) => setState(() => _aba = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tarefas'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Resumo'),
        ],
      ),
    );
  }

  void _dialogoAdicionar(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nova tarefa'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
              
                context.read<TaskProvider>().adicionar(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}

class PaginaTarefas extends StatelessWidget {
  const PaginaTarefas({super.key});

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<TaskProvider>();

    if (provider.tarefas.isEmpty) {
      return const Center(child: Text('Nenhuma tarefa cadastrada.'));
    }

    return ListView.builder(
      itemCount: provider.tarefas.length,
      itemBuilder: (context, i) {
        final t = provider.tarefas[i];
        return ListTile(
          leading: Checkbox(
            value: t['feita'],
            onChanged: (_) => context.read<TaskProvider>().alternar(i),
          ),
          title: Text(
            t['titulo'],
            style: TextStyle(
              decoration: t['feita'] ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => context.read<TaskProvider>().remover(i),
          ),
        );
      },
    );
  }
}


class PaginaResumo extends StatelessWidget {
  const PaginaResumo({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Consumer<TaskProvider>(
      builder: (context, p, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total: ${p.total}', style: const TextStyle(fontSize: 24)),
            Text(
              'Concluídas: ${p.concluidas}',
              style: const TextStyle(fontSize: 24),
            ),
            Text(
              'Pendentes: ${p.pendentes}',
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
