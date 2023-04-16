// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mini_quiz_creator/layouts/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart';
import 'layouts/home.dart';
import 'layouts/otp.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://przvyntsigxljcvmzyos.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InByenZ5bnRzaWd4bGpjdm16eW9zIiwicm9sZSI6ImFub24iLCJpYXQiOjE2Nzc5MDk5NTAsImV4cCI6MTk5MzQ4NTk1MH0.SR7cteHreLMDz234A9dqOONCVzIerpDDgrflTl2jR_Q',
    schema: "gmat",
  );

  runApp(App());
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  ThemeMode themeMode = ThemeMode.system;
  ColorSeed colorSelected = ColorSeed.baseColor;

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        colorSelected = ColorSeed.values[prefs.getInt("selectedTheme") ?? 0];
      });
    });
    super.initState();
  }

  bool get useLightMode {
    switch (themeMode) {
      case ThemeMode.system:
        return SchedulerBinding.instance.window.platformBrightness ==
            Brightness.light;
      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
    }
  }

  void handleBrightnessChange(bool useLightMode) {
    setState(() {
      themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void handleColorSelect(int value) async {
    setState(() {
      colorSelected = ColorSeed.values[value];
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("selectedTheme", value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Mini Quiz Creator",
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: colorSelected.color,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: colorSelected.color,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      routes: {
        '/': (context) => Home(
              useLightMode: useLightMode,
              useMaterial3: true,
              colorSelected: colorSelected,
              handleBrightnessChange: handleBrightnessChange,
              handleColorSelect: handleColorSelect,
            ),
        '/login': (context) => LoginScreen(),
        '/otp': (context) => OtpScreen(),
      },
      initialRoute: supabase.auth.currentUser != null ? '/' : '/login',
    );
  }
}
