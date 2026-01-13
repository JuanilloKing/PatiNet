import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PatiNet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0066CC)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'PatiNet',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              
              // Placeholder de imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/imagenes/mapa.png', 
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.contain, 
                ),
              ),
              const SizedBox(height: 40),
              const SizedBox(height: 40),

              const Text(
                'Todas las marcas de\npatinetes, en una sola app',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Text(
                'Compara precios, y elige el que más te convenga',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 60),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrincipalPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Inicia Sesión', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {},
                child: const Text('¿No tienes cuenta?', style: TextStyle(color: Color(0xFF0066CC))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- PANTALLA PRINCIPAL (Mapa y Buscador) ---
class PrincipalPage extends StatelessWidget {
  const PrincipalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos un Stack para poner el buscador y el menú sobre el mapa
      body: Stack(
        children: [
          // 1. FONDO: Aquí irá el mapa real más adelante. 
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFE5E5E5),
            child: Image.asset(
              'assets/imagenes/mapa_principal.png', // De momento, tan solo es una captura de pantalla.
              fit: BoxFit.cover,
            ),
          ),

          // 2. BARRA DE BÚSQUEDA SUPERIOR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  // Botón de filtros (izquierda)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune, color: Colors.black),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Caja de búsqueda
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar ciudad',
                          prefixIcon: Icon(Icons.menu),
                          suffixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. MENÚ INFERIOR (Simulado para que coincida con Figma)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.black12, width: 1)),
              ),
              child: Row(
                children: [
                  // Botón Mapa (Activo)
                  Expanded(
                    child: Container(
                      color: const Color(0xFF92C7C7), // El color verdoso de tu Figma
                      child: const Icon(Icons.map, size: 35, color: Colors.black),
                    ),
                  ),
                  // Botón Perfil
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: const Icon(Icons.person_outline, size: 35, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}