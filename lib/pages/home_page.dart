import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _increment() => setState(() => _counter++);

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Você saiu da conta')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text('Home • $email'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Você está autenticado no Firebase!'),
            const SizedBox(height: 16),
            Text(
              'Contador: $_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _increment,
              icon: const Icon(Icons.add),
              label: const Text('Incrementar'),
            ),
          ],
        ),
      ),
    );
  }
}
