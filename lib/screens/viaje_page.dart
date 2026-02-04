import 'dart:async';
import 'package:flutter/material.dart';

class ViajePage extends StatefulWidget {
  final String marca;
  final double precioMinuto;
  final double precioDesbloqueo;
  final String bateria;

  const ViajePage({
    super.key,
    required this.marca,
    required this.precioMinuto,
    required this.precioDesbloqueo,
    required this.bateria,
  });

  @override
  State<ViajePage> createState() => _ViajePageState();
}

class _ViajePageState extends State<ViajePage> {
  int _segundosTranscurridos = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _iniciarContador();
  }

  void _iniciarContador() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _segundosTranscurridos++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatearTiempo(int segundosTotal) {
    int horas = segundosTotal ~/ 3600;
    int minutos = (segundosTotal % 3600) ~/ 60;
    int segundos = segundosTotal % 60;
    return "${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}";
  }

  double _calcularPrecioMinutos() {
    double minutos = _segundosTranscurridos / 60;
    return minutos * widget.precioMinuto;
  }

  @override
  Widget build(BuildContext context) {
    double precioMinutos = _calcularPrecioMinutos();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // BARRA SUPERIOR (Buscador estático de la foto)
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  const Icon(Icons.settings, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.menu),
                          SizedBox(width: 10),
                          Text(
                            "Buscar ciudad",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Spacer(),
                          Icon(Icons.search),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // PANEL DE INFORMACIÓN
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "patinete desbloqueado",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.marca,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text("Patin Nº0230"),
                        ],
                      ),
                      _infoBox(
                        "Bateria\n${widget.bateria}",
                        Icons.battery_charging_full,
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: _infoBox(
                          "Tiempo de uso\n${_formatearTiempo(_segundosTranscurridos)}",
                          null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _infoBox(
                          "Costo minuto:  ${widget.precioMinuto}€",
                          null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  _infoBox(
                    "Precio desglosado\n${widget.precioDesbloqueo}€ + ${precioMinutos.toStringAsFixed(2)}€\nDesbloqueo    minutos \nTotal:  ${(widget.precioDesbloqueo + precioMinutos).toStringAsFixed(2)}€",
                    null,
                    isLarge: true,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _btnAccion(
                          "Estacionar",
                          Colors.blue,
                          () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _btnAccion(
                          "Parar (5 min max)",
                          Colors.red,
                          () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String texto, IconData? icono, {bool isLarge = false}) {
    return Container(
      padding: const EdgeInsets.all(15),
      height: isLarge ? 110 : 80,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          if (icono != null) ...[
            const SizedBox(width: 10),
            Icon(icono, size: 40),
          ],
        ],
      ),
    );
  }

  Widget _btnAccion(String texto, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
