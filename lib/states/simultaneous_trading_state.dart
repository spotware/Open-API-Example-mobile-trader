import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SimultaneousTradingPrefKeys { accounts, pairedPositions, pairedOrders }

class SimultaneousTrdaingState extends ChangeNotifier {
  SimultaneousTrdaingState() {
    _restoreState().then((_) => notifyListeners());
  }

  List<int> _pairedAccounts = <int>[];
  List<Map<int, int>> _pairedPositions = <Map<int, int>>[];
  List<Map<int, int>> _pairedOrders = <Map<int, int>>[];

  bool get enabled => _pairedAccounts.isNotEmpty;
  bool get hasPairedPosition => _pairedPositions.isNotEmpty;
  bool get hasPairedOrders => _pairedOrders.isNotEmpty;
  Iterable<int> get pariedAccounts => _pairedAccounts;

  bool isAccountPaired(int accountId) => _pairedAccounts.contains(accountId);
  bool isAccountHasPaierdPositions(int accountId) => _pairedPositions.any((Map<int, int> pairs) => pairs.containsKey(accountId));
  bool isAccountHasPaierdOrders(int accountId) => _pairedOrders.any((Map<int, int> pairs) => pairs.containsKey(accountId));
  bool isPositionPaired(int accountId, int id) => _pairedPositions.any((Map<int, int> pair) => pair[accountId] == id);
  bool isOrderPaired(int accountId, int id) => _pairedOrders.any((Map<int, int> pair) => pair[accountId] == id);

  String _pairsToJSON(List<Map<int, int>> list) {
    final List<Map<String, int>> newList = <Map<String, int>>[];
    for (final Map<int, int> map in list) {
      newList.add(map.map((int key, int value) => MapEntry<String, int>(key.toString(), value)));
    }

    return jsonEncode(newList);
  }

  List<Map<int, int>> _pairsFromJSON(String json) {
    final List<dynamic> jsonList = jsonDecode(json) as List<dynamic>;
    // final List<Map<String, int>> castList = List.castFrom<dynamic, Map<String, int>>(jsonList);
    final List<Map<int, int>> formattedList = <Map<int, int>>[];
    for (final dynamic item in jsonList) {
      formattedList.add((item as Map<String, dynamic>).map(
        (String key, dynamic value) => MapEntry<int, int>(int.parse(key), value as int),
      ));
    }

    return formattedList;
  }

  Future<void> _restoreState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<dynamic> accountsJson = jsonDecode(prefs.getString(SimultaneousTradingPrefKeys.accounts.toString()) ?? '[]') as List<dynamic>;
    _pairedAccounts = List.castFrom<dynamic, int>(accountsJson).toList();
    _pairedPositions = _pairsFromJSON(prefs.getString(SimultaneousTradingPrefKeys.pairedPositions.toString()) ?? '[]');
    _pairedOrders = _pairsFromJSON(prefs.getString(SimultaneousTradingPrefKeys.pairedOrders.toString()) ?? '[]');
  }

  Future<void> _saveState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SimultaneousTradingPrefKeys.accounts.toString(), jsonEncode(_pairedAccounts));
    prefs.setString(SimultaneousTradingPrefKeys.pairedPositions.toString(), _pairsToJSON(_pairedPositions));
    prefs.setString(SimultaneousTradingPrefKeys.pairedPositions.toString(), _pairsToJSON(_pairedPositions));
    prefs.setString(SimultaneousTradingPrefKeys.pairedOrders.toString(), _pairsToJSON(_pairedOrders));
  }

  void pairAccounts(List<int> accounts) {
    _pairedAccounts = accounts.toList();
    _saveState();

    notifyListeners();
  }

  void unpairAccounts(List<int> accounts) {
    for (final int accId in accounts) {
      for (int i = _pairedPositions.length - 1; i >= 0; i--) {
        final Map<int, int> pairs = _pairedPositions[i];
        pairs.removeWhere((int traderId, int posId) => traderId == accId);
        if (pairs.length <= 1) _pairedPositions.remove(pairs);
      }

      for (int i = _pairedOrders.length - 1; i >= 0; i--) {
        final Map<int, int> pairs = _pairedOrders[i];
        pairs.removeWhere((int traderId, int posId) => traderId == accId);
        if (pairs.length <= 1) _pairedOrders.remove(pairs);
      }
      
      _pairedAccounts.remove(accId);
    }

    _saveState();
    notifyListeners();
  }

  void pairPositions(Map<int, int> pairs) {
    _pairedPositions.add(pairs);
    _saveState();

    notifyListeners();
  }

  void pairOrders(Map<int, int> pairs) {
    _pairedOrders.add(pairs);
    _saveState();

    notifyListeners();
  }

  void disable() {
    _pairedAccounts.clear();
    _pairedPositions.clear();
    _pairedOrders.clear();
    _saveState();

    notifyListeners();
  }

  Map<int, int> getPairedOrders(int accountId, int id) {
    return _pairedOrders.firstWhere(
      (Map<int, int> pair) => pair[accountId] == id,
      orElse: () => <int, int>{},
    );
  }

  void removeOrderFromPair(int accountId, int orderId) {
    for (int i = _pairedOrders.length - 1; i >= 0; i--) {
      final Map<int, int> pair = _pairedOrders[i];
      if (pair[accountId] == orderId) {
        pair.remove(accountId);

        if (pair.length <= 1) _pairedOrders.remove(pair);
        _saveState();

        notifyListeners();
        return;
      }
    }
  }

  Map<int, int> getPairedPositions(int accountId, int id) {
    return _pairedPositions.firstWhere(
      (Map<int, int> pair) => pair[accountId] == id,
      orElse: () => <int, int>{},
    );
  }

  void removePositionFromPair(int accountId, int id) {
    for (int i = _pairedPositions.length - 1; i >= 0; i--) {
      final Map<int, int> pair = _pairedPositions[i];
      if (pair[accountId] == id) {
        pair.remove(accountId);

        if (pair.length <= 1) _pairedPositions.remove(pair);
        _saveState();

        notifyListeners();
        return;
      }
    }
  }
}
