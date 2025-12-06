import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_repo.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  String _role = 'passenger';
  final AuthService _auth = AuthService();
  final FirestoreRepo _repo = FirestoreRepo();
  bool _loading = false;
  String? _error;

  void _signUp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cred = await _auth.signUp(_emailController.text.trim(), _passwordController.text.trim());
      final uid = cred.user?.uid;
      if (uid != null) {
        await _repo.createUserProfile(
          uid: uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _role,
        );
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Miilto — Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full name')),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone (optional)')),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Role:'),
                  const SizedBox(width: 8),
                  DropdownButton<String>(value: _role, items: const [
                    DropdownMenuItem(value: 'passenger', child: Text('Passenger')),
                    DropdownMenuItem(value: 'driver', child: Text('Driver')),
                  ], onChanged: (v) { if (v != null) setState(() => _role = v); }),
                ],
              ),
              const SizedBox(height: 16),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _loading ? null : _signUp,
                child: _loading ? const CircularProgressIndicator() : const Text('Create account'),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Back to login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

