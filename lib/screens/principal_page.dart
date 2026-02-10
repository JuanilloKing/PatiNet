import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'viaje_page.dart';
import 'historial_page.dart';

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  int _selectedIndex = 0;
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  BitmapDescriptor? _greenIcon;
  BitmapDescriptor? _blueIcon;
  BitmapDescriptor? _yellowIcon; // Añadido para Tier (si quisieras usarlo)

  Set<Marker> _markers = {};

  // --- VARIABLES PARA FILTROS ---
  bool _mostrarFiltros = false; // Controla si se ve el menú
  double _filtroBateria = 0.0; // Valor del slider (0% a 100%)

  // Estado de los checkboxes
  Map<String, bool> _empresasSeleccionadas = {
    'Lime': true,
    'Bird': true,
    'Tier': true,
  };

  // Cache de los datos crudos de Firestore para poder filtrar localmente
  List<DocumentSnapshot> _todosLosPatinetes = [];

  static const CameraPosition _puntoInicial = CameraPosition(
    target: LatLng(36.6850, -6.1260),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  Future<void> _inicializarDatos() async {
    try {
      _greenIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(25, 25)),
        'assets/imagenes/scooter-green.png',
      );
      _blueIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(25, 25)),
        'assets/imagenes/scooter-blue.png',
      );
      // Si tienes un icono amarillo para Tier, cárgalo aquí, si no usaremos el verde por defecto
    } catch (e) {
      debugPrint("Error cargando assets: $e");
    }
    _escucharPatinetes();
  }

  void _escucharPatinetes() {
    FirebaseFirestore.instance.collection('patinetes').snapshots().listen((
      snapshot,
    ) {
      if (!mounted) return;

      // 1. Guardamos los datos crudos
      _todosLosPatinetes = snapshot.docs;

      // 2. Aplicamos los filtros actuales para generar los marcadores
      _aplicarFiltrosYActualizarMapa();
    });
  }

  // --- LÓGICA DE FILTRADO ---
  // --- LÓGICA DE FILTRADO MEJORADA Y ROBUSTA ---
  void _aplicarFiltrosYActualizarMapa() {
    Set<Marker> nuevosMarcadores = {};

    for (var doc in _todosLosPatinetes) {
      final data = doc.data() as Map<String, dynamic>;

      // 1. Coordenadas
      double? lat = double.tryParse(data['latitud'].toString());
      double? lng = double.tryParse(data['longitud'].toString());
      if (lat == null || lng == null) continue;

      // 2. Batería (ROBUSTO: Extraer solo números para evitar errores con %)
      // Ejemplo: "86%" -> "86" -> 86
      String bateriaRaw = data['bateria']?.toString() ?? '0';
      String bateriaDigitos = bateriaRaw.replaceAll(RegExp(r'[^0-9]'), '');
      int bateriaNivel = int.tryParse(bateriaDigitos) ?? 0;

      // 3. Detectar Empresa (Normalizar a minúsculas)
      // Usamos tanto el nombre como el color para asegurar que lo detectamos
      String nombreRaw = (data['nombre']?.toString() ?? '').toLowerCase();
      String colorRaw = (data['color']?.toString() ?? '').toLowerCase();

      String empresaDetectada = 'Desconocida';

      // Si el nombre contiene "lime" O el color es "verde" -> Es Lime
      if (nombreRaw.contains('lime') || colorRaw == 'verde') {
        empresaDetectada = 'Lime';
      }
      // Si el nombre contiene "bird" O el color es "azul" -> Es Bird
      else if (nombreRaw.contains('bird') || colorRaw == 'azul') {
        empresaDetectada = 'Bird';
      } else if (nombreRaw.contains('tier')) {
        empresaDetectada = 'Tier';
      }

      // --- APLICAR FILTROS ---

      // A) Filtro Batería: Si tiene menos batería de la que pedimos, fuera.
      if (bateriaNivel < _filtroBateria) continue;

      // B) Filtro Empresa:
      // Si detectamos la empresa, comprobamos si su casilla está marcada.
      if (empresaDetectada != 'Desconocida') {
        if (_empresasSeleccionadas[empresaDetectada] != true) {
          continue; // Si "Lime" está desmarcado, no lo mostramos.
        }
      }

      // --- ASIGNAR ICONO ---
      BitmapDescriptor icono = BitmapDescriptor.defaultMarker;
      if (empresaDetectada == 'Lime')
        icono = _greenIcon ?? BitmapDescriptor.defaultMarker;
      else if (empresaDetectada == 'Bird')
        icono = _blueIcon ?? BitmapDescriptor.defaultMarker;

      nuevosMarcadores.add(
        Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(lat, lng),
          icon: icono,
          onTap: () => _mostrarDetalles(
            data['nombre'] ?? 'Patinete',
            data['precio'] ?? '0.00€',
            data['bateria'] ?? '0%',
            data['autonomia'] ?? '0 km',
            data['imagen'] ?? 'assets/imagenes/mapa.png',
          ),
        ),
      );
    }

    setState(() {
      _markers = nuevosMarcadores;
    });
  }

  // --- WIDGET DEL MENÚ DE FILTROS ---
  Widget _buildMenuFiltros() {
    return Positioned(
      top: 120,
      left: 15,
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Rango batería",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Slider(
              value: _filtroBateria,
              min: 0,
              max: 100,
              activeColor: Colors.purple,
              inactiveColor: Colors.purple.withOpacity(0.2),
              onChanged: (val) {
                setState(() => _filtroBateria = val);
              },
            ),
            Text(
              "${_filtroBateria.toInt()}% - Aprox: ${_calcularKm(_filtroBateria)} km",
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 15),

            // CHECKBOXES EMPRESAS
            const Text(
              "Empresas",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 5),
            _buildCheckboxEmpresa("Lime", Colors.green),
            _buildCheckboxEmpresa("Bird", Colors.blue),
            const SizedBox(height: 15),

            // BOTÓN APLICAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _aplicarFiltrosYActualizarMapa();
                  setState(() => _mostrarFiltros = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066CC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Aplicar",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calcularKm(double bateria) {
    // Estimación simple: 100% = 25km (puedes ajustar la fórmula)
    return ((bateria / 100) * 25).toStringAsFixed(0);
  }

  Widget _buildCheckboxEmpresa(String nombre, Color color) {
    return Row(
      children: [
        const Text("• ", style: TextStyle(fontSize: 20)),
        Text(nombre, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 5),
        Icon(
          Icons.electric_scooter,
          color: color,
          size: 20,
        ), // Icono del patinete
        const Spacer(),
        // Checkbox personalizado visualmente negro/gris oscuro
        Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: _empresasSeleccionadas[nombre],
            activeColor: Colors.black87,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (val) {
              setState(() {
                _empresasSeleccionadas[nombre] = val!;
              });
            },
          ),
        ),
      ],
    );
  }

  // --- VISTA DEL MAPA ---
  Widget _buildMapaView() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _puntoInicial,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          markers: _markers,
          zoomControlsEnabled: false,
          onMapCreated: (controller) => _mapController = controller,
        ),

        // MENÚ DE FILTROS (Solo visible si _mostrarFiltros es true)
        if (_mostrarFiltros) _buildMenuFiltros(),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                // BOTÓN SETTINGS CONECTADO
                _buildSearchIcon(
                  Icons.tune,
                  size: 30,
                  onPressed: () {
                    setState(() {
                      _mostrarFiltros =
                          !_mostrarFiltros; // Alternar visibilidad
                    });
                  },
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
                      onSubmitted: (t) => _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          const LatLng(36.6850, -6.1260),
                          16,
                        ),
                      ),
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
      ],
    );
  }

  // --- RESTO DEL CÓDIGO (PERFIL, DETALLES, ETC) SIN CAMBIOS IMPORTANTES ---

  Widget _buildPerfilView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/imagenes/usuario.png'),
              ),
              const SizedBox(height: 15),
              const Text(
                "Eduardo Sumariva Salgado",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Nv 3 - Patinete Enjoyer",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildPerfilItem("Editar Nombre", null),
                    _buildPerfilItem("Editar Apellidos", null),
                    _buildPerfilItem(
                      "Ultimos viajes",
                      "Ver",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistorialPage(),
                          ),
                        );
                      },
                    ),
                    _buildPerfilItem("Mas información", "Detalles"),
                    _buildPerfilItem("Modificar método de pago", "Modificar"),
                    _buildPerfilItem("Tamaño de letra", "Mediano"),
                    ListTile(
                      title: const Text("Aceptas recopilar datos"),
                      trailing: Switch(
                        value: true,
                        onChanged: (v) {},
                        activeColor: Colors.green,
                      ),
                    ),
                    _buildPerfilItem("Leer terminos legales", "Aquí"),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066CC),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text(
                  "Cerrar sesión",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerfilItem(
    String title,
    String? trailingText, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: const TextStyle(color: Color(0xFF0066CC)),
            ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSearchIcon(
    IconData icon, {
    double size = 24,
    VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black, size: size),
        onPressed: onPressed,
      ),
    );
  }

  void _mostrarDetalles(
    String marca,
    String precio,
    String bateria,
    String autonomia,
    String imagenRuta,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                marca,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Image.asset(imagenRuta, height: 120, fit: BoxFit.contain),
              const SizedBox(height: 15),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildInfoCell(
                    "Batería",
                    bateria,
                    Icons.battery_charging_full,
                  ),
                  _buildInfoCell("Autonomía", autonomia, Icons.bolt),
                  _buildInfoCell("Precio desbloqueo", "1.50€", Icons.lock_open),
                  _buildInfoCell(
                    "Precio por minuto",
                    precio,
                    Icons.timer_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066CC),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViajePage(
                        marca: marca,
                        bateria: bateria,
                        precioMinuto:
                            double.tryParse(
                              precio.replaceAll('€', '').trim(),
                            ) ??
                            0.45,
                        precioDesbloqueo: 1.50,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Coger patinete",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCell(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0 ? _buildMapaView() : _buildPerfilView(),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.black12, width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedIndex = 0),
                  child: Container(
                    color: _selectedIndex == 0
                        ? const Color(0xFF92C7C7)
                        : Colors.white,
                    child: const Icon(Icons.map, size: 35, color: Colors.black),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedIndex = 1),
                  child: Container(
                    color: _selectedIndex == 1
                        ? const Color(0xFF92C7C7)
                        : Colors.white,
                    child: const Icon(
                      Icons.person_outline,
                      size: 35,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
