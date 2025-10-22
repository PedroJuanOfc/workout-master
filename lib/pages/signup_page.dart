import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe seu e-mail';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Informe sua senha';
    if (v.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Confirme sua senha';
    if (v != _password.text) return 'As senhas não coincidem';
    return null;
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );

      await FirebaseAuth.instance.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada! Faça login para continuar.'),
          ),
        );
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Falha ao criar conta.');
    } catch (e) {
      setState(() => _error = 'Erro inesperado: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).size.width > 500 ? 32.0 : 16.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const FlutterLogo(size: 64),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      hintText: 'voce@email.com',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
                    validator: _validateEmail,
                    enabled: !_loading,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: _loading
                            ? null
                            : () => setState(() => _obscure1 = !_obscure1),
                        icon: Icon(
                          _obscure1 ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    obscureText: _obscure1,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: _validatePassword,
                    enabled: !_loading,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmar senha',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: _loading
                            ? null
                            : () => setState(() => _obscure2 = !_obscure2),
                        icon: Icon(
                          _obscure2 ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    obscureText: _obscure2,
                    validator: _validateConfirm,
                    enabled: !_loading,
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _createAccount,
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.person_add),
                      label: Text(_loading ? 'Criando...' : 'Criar conta'),
                    ),
                  ),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Voltar ao login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
