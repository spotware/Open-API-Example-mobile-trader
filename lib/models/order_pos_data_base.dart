import 'package:ctrader_example_app/models/symbol_data.dart';
import 'package:ctrader_example_app/models/trader_data.dart';

abstract class OrderPosDataBase {
  OrderPosDataBase(this.trader, this.id, this.symbolId);

  final TraderData trader;
  final int id;
  final int symbolId;
  bool isBuy = true;
  int volume = 0;
  int rate = 0;
  String measurementUnits = '';
  bool garanteedStopLoss = false;

  int? takeProfit;
  int? stopLoss;
  bool trailingStopLoss = false;

  DateTime opened = DateTime.now();
  DateTime _updated = DateTime.fromMillisecondsSinceEpoch(0);

  int? get currentRate;
  int? get trailingStopDistance;
  int? calculateTakeProfitExtremeRate();
  int? calculateStopLossExtremeRate();

  SymbolData? get symbol => trader.tree.symbol(symbolId);
  double get humanicVolume => SymbolData.humanicVolume(volume);
  String get formattedVolume {
    return symbol?.details?.formattedVolume(system: volume) ?? SymbolData.formattedVolumeDefault(system: volume);
  }

  String get formattedVolumeWithUnits {
    if (measurementUnits.isNotEmpty) return '$formattedVolume $measurementUnits';
    return symbol?.details?.formattedVolumeWithUnits(system: volume) ?? formattedVolume;
  }

  String formattedRate({int? system, double? humanic}) {
    if (system == null && humanic == null) return '----';
    if (symbol?.details != null) return symbol!.details!.formattedRate(system: system, humanic: humanic);

    return SymbolData.formattedRateDefault(system: system, humanic: humanic);
  }

  bool isUpdatedBefore(int ts) => _updated.millisecondsSinceEpoch <= ts;
  bool isUpdatedAfter(int ts) => _updated.millisecondsSinceEpoch > ts;
  void updateTimestamp([int? ts]) => _updated = ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : DateTime.now();

  void update(dynamic data);

  void updateTrailingStopValue(double value) {
    stopLoss = SymbolData.systemRateFromHumanic(value);
  }
}
