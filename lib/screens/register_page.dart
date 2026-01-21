import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _aceptaTerminos = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildBlueBox("Nombre", "Mark")),
                const SizedBox(width: 10),
                Expanded(child: _buildBlueBox("Apellidos", "Johnson")),
              ],
            ),
            _buildBlueBox("Correo:", "ejemplo@ejemplo.com", controller: _emailController),
            _buildBlueBox("Contraseña:", "**********", isPassword: true, controller: _passController),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(value: _aceptaTerminos, onChanged: (val) => setState(() => _aceptaTerminos = val!)),
                const Text("Aceptas terminos y condiciones", style: TextStyle(color: Color(0xFF0066CC))),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  if (_aceptaTerminos) {
                    try {
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passController.text.trim(),
                      );
                      Navigator.pop(context);
                    } catch (e) { print(e); }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066CC), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: const Text("Registrar", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlueBox(String label, String hint, {bool isPassword = false, TextEditingController? controller}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF0066CC), borderRadius: BorderRadius.circular(25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextField(
            controller: controller, obscureText: isPassword,
            decoration: InputDecoration(
              filled: true, fillColor: Colors.white, hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}