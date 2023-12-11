import 'dart:math';

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/models/internal_application_error.dart';
import 'package:ctrader_example_app/models/symbol_data.dart';
import 'package:ctrader_example_app/models/symbols_tree.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/remote/proto.dart' as proto;

class AssetData {
  AssetData.fromProto(this.tree, proto.ProtoOAAsset asset)
      : assetId = asset.assetId,
        digits = asset.digits ?? 5,
        name = asset.name,
        displayName = asset.displayName;

  final Map<int, Iterable<int>> _conversionsMap = <int, Iterable<int>>{};
  final SymbolsTree tree;
  final int assetId;
  int digits;
  String name;
  String? displayName;

  TraderData get trader => tree.trader;
  String get units => displayName ?? name;
  double humanicValue(int value) => value / pow(10, digits);
  String formattedValue(double value, {bool? units}) {
    return value.toComaSeparated(decimals: digits) + (units == true ? this.units : '');
  }

  Future<double> getConversionRateToAsset(int assetId) async {
    if (assetId == this.assetId) return 1.0;

    if (!_conversionsMap.containsKey(assetId) || _conversionsMap[assetId]!.isEmpty) {
      final SymbolData? symbol = tree.symbolByAssetPair(this.assetId, assetId);
      if (symbol != null) {
        _conversionsMap[assetId] = <int>[symbol.id];
      } else {
        final proto.ProtoOASymbolsForConversionRes conversionRes = await trader.remoteApi.sendSymbolsForConversion(trader.id, this.assetId, assetId);
        _conversionsMap[assetId] = conversionRes.symbol.map((proto.ProtoOALightSymbol e) => e.symbolId);
      }
    }

    final Iterable<int>? symbols = _conversionsMap[assetId];
    if (symbols == null || symbols.isEmpty)
      throw InternalApplicationError(InternalApplicationErrorCodes.INTERNAL_ERROR, "can't find conversion symbols from $name to ${tree.asset(assetId)?.name}");

    int convAssetId = this.assetId;
    double result = 1.0;

    for (final int id in symbols) {
      final SymbolData? symbol = await tree.symbol(id)?.getUpdatedRates();
      if (symbol == null) throw InternalApplicationError(InternalApplicationErrorCodes.SYMBOL_NOT_INITIALIZED, "can't find symbol with id $id");
      if (symbol.bid == null)
        throw InternalApplicationError(InternalApplicationErrorCodes.SYMBOL_RATES_NOT_INITIALIZED, 'bid rate not initialized for ${symbol.name}');

      if (convAssetId == symbol.baseAssetId) {
        result *= SymbolData.humanicRateFromSystem(symbol.bid!);
        convAssetId = symbol.quoteAssetId;
      } else {
        result /= SymbolData.humanicRateFromSystem(symbol.bid!);
        convAssetId = symbol.baseAssetId;
      }
    }

    return result;
  }
}
