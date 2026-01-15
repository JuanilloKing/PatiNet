import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

// --- PANTALLA DE LOGIN ---
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
                      MaterialPageRoute(
                        builder: (context) => const PrincipalPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Inicia Sesión',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: const Text(
                  '¿No tienes cuenta?',
                  style: TextStyle(color: Color(0xFF0066CC)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- PANTALLA PRINCIPAL ---
class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  late GoogleMapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  BitmapDescriptor? _greenIcon;
  BitmapDescriptor? _blueIcon;
  Set<Marker> _markers = {};

  static const CameraPosition _puntoInicial = CameraPosition(
    target: LatLng(36.6850, -6.1260),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
  }

  // Carga los marcadores con la función de abrir ventana al pulsar (onTap)
  Future<void> _loadCustomMarkers() async {
    _greenIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(50, 50)),
      'assets/imagenes/scooter-green.png',
    );
    _blueIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(50, 50)),
      'assets/imagenes/scooter-blue.png',
    );

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('p_verde_1'),
          position: const LatLng(36.6870, -6.1260),
          icon: _greenIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => _mostrarDetalles(
            'Lime Nº5432',
            '0,20€/min',
            '85%',
            'Kilómetros de autonomía: 20 km',
            Colors.green,
          ),
        ),
        Marker(
          markerId: const MarkerId('p_azul_1'),
          position: const LatLng(36.6830, -6.1280),
          icon: _blueIcon ?? BitmapDescriptor.defaultMarker,
          onTap: () => _mostrarDetalles(
            'Bird Nº01238',
            '0,25€/min',
            '64%',
            'Kilómetros de autonomía: 16 km',
            Colors.blue,
          ),
        ),
      };
    });
  }

  // LA VENTANA DE TU FIGMA
  void _mostrarDetalles(
    String marca,
    String precio,
    String bateria,
    String autonomia,
    Color color,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Para que la tarjeta flote
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.electric_scooter, color: color, size: 40),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marca,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        precio,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        autonomia,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      const Icon(Icons.battery_3_bar, color: Colors.green),
                      Text(
                        bateria,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Reservar ahora',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _buscarYFijarZona(String texto) {
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(const LatLng(36.6850, -6.1260), 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _puntoInicial,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),

          // BARRA DE BÚSQUEDA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 5),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune, color: Colors.black),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 5),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: _buscarYFijarZona,
                        decoration: const InputDecoration(
                          hintText: 'Buscar ciudad o zona',
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

          // MENÚ INFERIOR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.black12, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: const Color(0xFF92C7C7),
                      child: const Icon(
                        Icons.map,
                        size: 35,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Icon(
                      Icons.person_outline,
                      size: 35,
                      color: Colors.black,
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
