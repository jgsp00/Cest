import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Despensa',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: kBg,
      colorScheme: const ColorScheme.dark(primary: kAccent, surface: kCard),
    ),
    home: const PantallaCarga(),
  );
}
