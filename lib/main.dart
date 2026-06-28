import 'package:flutter/material.dart';
import 'di/service_locator.dart';
import 'app.dart';

void main() async {
  // Necessário antes de usar SharedPreferences fora do runApp.
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const PiramidGameApp());
}
