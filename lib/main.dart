import 'package:flutter/material.dart';
import 'di/service_locator.dart';
import 'app.dart';

void main() async {
  // Necessário antes de abrir o banco SQLite fora do runApp.
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const PiramidGameApp());
}
