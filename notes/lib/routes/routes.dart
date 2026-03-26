
import 'package:flutter/widgets.dart';
import 'package:notes/pages/notes_page.dart';
import 'package:notes/pages/settings_page.dart';

class Routes {
  static Map<String, Widget> routes = {
    '/notesPage': NotesPage(),
    '/settingPage': SettingsPage()

  };
}
