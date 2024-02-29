import 'package:flutter/material.dart';
import 'package:tulu_proxy_setter/ui/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark().copyWith(
            // textTheme: GoogleFonts.latoTextTheme(),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 147, 229, 250),
              brightness: Brightness.dark,
              surface: const Color.fromARGB(255, 42, 51, 59),
            ),
            scaffoldBackgroundColor: const Color.fromARGB(255, 50, 58, 60),
            inputDecorationTheme: const InputDecorationTheme().copyWith(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15)))),
        home: const HomeScreen());
  }
}
