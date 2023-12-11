import 'dart:convert';

import 'package:ctrader_example_app/main.dart';
import 'package:flutter/services.dart';

class SymbolIcons {
  SymbolIcons();

  late final Map<String, String> _icons;

  Future<void> init(String path) async {
    final String jsonStr = await rootBundle.loadString(path);
    final dynamic json = jsonDecode(jsonStr);
    _icons = Map.castFrom<String, dynamic, String, String>(json as Map<String, dynamic>);
  }

  String getIconNameBySymbolName(String? name) {
    if (name != null) {
      String modifiedName = name.toUpperCase();
      if (_icons.containsKey(modifiedName)) return _icons[modifiedName]!;

      modifiedName = modifiedName.replaceAll(RegExp('[^A-Z0-9]'), '');
      if (_icons.containsKey(modifiedName)) return _icons[modifiedName]!;

      if (modifiedName.length > 6) {
        modifiedName = modifiedName.substring(0, 6);
        if (_icons.containsKey(modifiedName)) return _icons[modifiedName]!;
      }

      for (final List<String> item in SYMBOL_PAIRS) {
        modifiedName = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
        if (item.contains(modifiedName)) {
          for (final String asset in item) {
            if (_icons.containsKey(asset)) return _icons[asset]!;
          }
        }
      }
    }

    return _icons['undefined']!;
  }
}
