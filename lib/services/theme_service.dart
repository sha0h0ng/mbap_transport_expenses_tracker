import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  StreamController<Color> themeStreamController =
      StreamController<Color>.broadcast();
  SharedPreferences? prefs;

  Stream<Color> getThemeStream() {
    return themeStreamController.stream;
  }

  void setTheme(Color selectedTheme, String stringTheme) {
    themeStreamController.add(selectedTheme);
    prefs!.setString('selectedTheme', stringTheme);
    debugPrint('Theme: ' + stringTheme);
  }

  void loadTheme() async {
    prefs = await SharedPreferences.getInstance();
    Color currentTheme = Colors.deepPurple;
    if (prefs!.containsKey('selectedTheme')) {
      String selectedTheme = prefs!.getString('selectedTheme')!;
      if (selectedTheme == 'deepPurple')
        currentTheme = Colors.deepPurple;
      else if (selectedTheme == 'blue')
        currentTheme = Colors.blue;
      else if (selectedTheme == 'green')
        currentTheme = Colors.green;
      else if (selectedTheme == 'red') currentTheme = Colors.red;
    }
    themeStreamController.add(currentTheme);
  }
}
