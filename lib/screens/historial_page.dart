import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Añade intl a tu pubspec.yaml si quieres formatear fechas bonitas

class HistorialPage extends StatelessWidget {
  const HistorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Mis Viajes", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: user == null
          ? const Center(child: Text("No identificado"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(user.uid)
                  .collection('historial')
                  .orderBy(
                    'fecha',
                    descending: true,
                  ) // Ordenar por más reciente
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Aún no has hecho viajes."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data =
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;

                    // Convertir timestamp a fecha legible
                    DateTime fecha = (data['fecha'] as Timestamp).toDate();
                    String fechaStr =
                        "${fecha.day}/${fecha.month}/${fecha.year}";

                    // Formatear duración
                    int segundos = data['duracion_segundos'] ?? 0;
                    int minutos = segundos ~/ 60;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.electric_scooter,
                            color: Color(0xFF0066CC),
                          ),
                        ),
                        title: Text(
                          data['marca'] ?? 'Patinete',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("$fechaStr • $minutos min de uso"),
                        trailing: Text(
                          "${(data['total_pagado'] ?? 0).toStringAsFixed(2)}€",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
