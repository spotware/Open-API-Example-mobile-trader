import 'package:flutter/material.dart';

class TrailingStopValues extends ChangeNotifier {
  TrailingStopValues();

  final Map<int, Map<int, int>> _orders = <int, Map<int, int>>{};
  final Map<int, Map<int, int>> _positions = <int, Map<int, int>>{};

  void fromJSON(Map<String, dynamic> json) {
    if (json.containsKey('orders')) {
      final Map<String, dynamic> orders = json['orders'] as Map<String, dynamic>;
      for (final String traderId in orders.keys) {
        final Map<String, dynamic> ordersForTrader = orders[traderId] as Map<String, dynamic>;
        _orders[int.parse(traderId)] = ordersForTrader.map((String orderId, dynamic value) => MapEntry<int, int>(int.parse(orderId), value as int));
      }
    }

    if (json.containsKey('positions')) {
      final Map<String, dynamic> positions = json['positions'] as Map<String, dynamic>;
      for (final String traderId in positions.keys) {
        final Map<String, dynamic> positionsForTrader = positions[traderId] as Map<String, dynamic>;
        _positions[int.parse(traderId)] = positionsForTrader.map((String positionId, dynamic value) => MapEntry<int, int>(int.parse(positionId), value as int));
      }
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'orders': _orders.map((int traderId, Map<int, int> value) => MapEntry<String, Map<String, int>>(
              traderId.toString(),
              value.map((int orderId, int value) => MapEntry<String, int>(
                    orderId.toString(),
                    value,
                  )),
            )),
        'positions': _positions.map((int traderId, Map<int, int> value) => MapEntry<String, Map<String, int>>(
              traderId.toString(),
              value.map((int positionId, int value) => MapEntry<String, int>(
                    positionId.toString(),
                    value,
                  )),
            )),
      };

  int? valueOfOrder(int traderId, int orderId) => _orders[traderId]?[orderId];
  int? valueOfPosition(int traderId, int positionId) => _positions[traderId]?[positionId];

  void updateForOrder(int traderId, int orderId, int pipsRate) {
    _orders[traderId] ??= <int, int>{};
    _orders[traderId]![orderId] = pipsRate;

    notifyListeners();
  }

  void updateForPosition(int traderId, int positionId, int pipsRate) {
    _positions[traderId] ??= <int, int>{};
    _positions[traderId]![positionId] = pipsRate;

    notifyListeners();
  }

  void clearFromOrder(int traderId, int orderId) {
    _orders[traderId]?.removeWhere((int k, int v) => k == orderId);

    notifyListeners();
  }

  void clearFromPosition(int traderId, int positionId) {
    _positions[traderId]?.removeWhere((int k, int v) => k == positionId);

    notifyListeners();
  }

  void clearAll() {
    _orders.clear();
    _positions.clear();

    notifyListeners();
  }
}
