import 'dart:math';

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/models/asset_data.dart';
import 'package:ctrader_example_app/models/pair.dart';
import 'package:ctrader_example_app/models/symbols_tree.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/remote/proto.dart' as proto;
import 'package:ctrader_example_app/remote/remote_api.dart';
import 'package:ctrader_example_app/remote/remote_api_manager.dart';
import 'package:ctrader_example_app/remote/spot_sub_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:timezone/timezone.dart' as tz;

const int _SYSTEM_CONVERTION_RATE = 100000;

class SymbolData {
  SymbolData.fromLight(this.category, proto.ProtoOALightSymbol symbol)
      : id = symbol.symbolId,
        name = symbol.symbolName ?? 'NO_NAME',
        enabled = symbol.enabled == true,
        baseAssetId = symbol.baseAssetId!,
        quoteAssetId = symbol.quoteAssetId!,
        description = symbol.description;

  final int id;
  final String name;
  final bool enabled;
  final int baseAssetId;
  final int quoteAssetId;
  final SymbolCategoryData category;
  bool isFavorite = false;
  int? ask;
  int? bid;
  int? sessionClose;
  int dailyChangePips = 0;
  double dailyChangePercents = 0;
  String? description;
  SymbolDetailsData? details;

  static double humanicRateFromSystem(int rate) => rate / _SYSTEM_CONVERTION_RATE;
  static int systemRateFromHumanic(double rate) => (rate * _SYSTEM_CONVERTION_RATE).round();
  static String formattedRateDefault({int? system, double? humanic}) {
    if (system == null && humanic == null) return '----';

    return (humanic ?? humanicRateFromSystem(system!)).toString();
  }

  static double humanicVolume(int volume) => volume / 100;
  static int systemVolume(double volume) => (volume * 100).round();
  static String formattedVolumeDefault({int? system, double? humanic}) {
    if (system == null && humanic == null) return '----';

    system ??= systemVolume(humanic!);
    humanic ??= humanicVolume(system);

    return humanic.toComaSeparated(decimals: system % 100 == 0 ? 0 : (system % 10 == 0 ? 1 : 2));
  }

  AssetClassData get assetClass => category.assetClass;
  SymbolsTree get tree => category.tree;
  TraderData get trader => category.trader;
  AssetData? get baseAsset => tree.asset(baseAssetId);
  AssetData? get quoteAsset => tree.asset(quoteAssetId);

  String get formattedSellRate => details?.formattedRate(system: bid) ?? SymbolData.formattedRateDefault(system: bid);
  String get formattedBuyRate => details?.formattedRate(system: ask) ?? SymbolData.formattedRateDefault(system: ask);
  String get formattedDailyChangePips => (dailyChangePips / 100000).toString();
  String get formattedDailyChangePercents => '${(dailyChangePercents * 100).toStringAsFixed(2)}%';
  String get units => details?.data.measurementUnits ?? baseAsset?.units ?? 'n/a';

  int get spread => bid != null && ask != null ? ask! - bid! : 0;
  int? get pipSize => details?.pipSize;

  int get stopLossDistance {
    if (details == null) return 5;

    final int digits = details!.data.digits;
    final int pipSize = this.pipSize ?? 1;
    final int slDistance = trader.isLimitedRisk ? (details!.data.gslDistance ?? 0) : (details!.data.slDistance ?? details!.data.gslDistance ?? 0);
    int distance;

    if (details!.data.distanceSetIn == proto.ProtoOASymbolDistanceType.symbolDistanceInPercentage) {
      final int rate = (((ask ?? 0) + (bid ?? 0)) / 2).round();
      distance = (rate * slDistance / 10000 / pipSize).round() * pipSize;
    } else {
      distance = slDistance * pow(10, 5 - digits).round();
    }

    return details!.cutOffExtraDigitsFromRate(max(distance, 5 * pipSize), false);
  }

  int get takeProfitDisatance {
    if (details == null) return 5;

    final int digits = details!.data.digits;
    final int pip = pipSize ?? 1;
    int distance = 5 * pip;

    if (details!.data.tpDistance != null) {
      if (details!.data.distanceSetIn == proto.ProtoOASymbolDistanceType.symbolDistanceInPercentage) {
        final int rate = (((ask ?? 0) + (bid ?? 0)) / 2).round();
        distance = (rate * details!.data.tpDistance! / 10000 / pip).round() * pip;
      } else {
        distance = details!.data.tpDistance! * pow(10, 5 - digits).round();
      }
    }

    return details!.cutOffExtraDigitsFromRate(max(distance, 5 * pip), false);
  }

  List<Pair<tz.TZDateTime, tz.TZDateTime>> scheduleInDates() {
    final List<Pair<tz.TZDateTime, tz.TZDateTime>> result = <Pair<tz.TZDateTime, tz.TZDateTime>>[];

    if (details?.data.schedule != null) {
      final tz.Location tzLocation = tz.getLocation(details?.data.scheduleTimeZone ?? 'UTC');
      final DateTime sunday = DateTime.now().previousSundayMidnight();

      for (final proto.ProtoOAInterval interval in details!.data.schedule!) {
        final tz.TZDateTime start = tz.TZDateTime(tzLocation, sunday.year, sunday.month, sunday.day, 0, 0, interval.startSecond);
        final tz.TZDateTime end = tz.TZDateTime(tzLocation, sunday.year, sunday.month, sunday.day, 0, 0, interval.endSecond);

        result.add(Pair<tz.TZDateTime, tz.TZDateTime>(start.toLocal(), end.toLocal()));
      }
    }

    return result;
  }

  bool isMarketClosed() {
    final DateTime now = DateTime.now();
    final List<proto.ProtoOAHoliday> holidays = details?.holidays ?? <proto.ProtoOAHoliday>[];

    if (holidays.isNotEmpty) {
      for (final proto.ProtoOAHoliday holiday in holidays) {
        final DateTime starts = holiday.startDateTime().toLocal();
        final DateTime ends = holiday.endDateTime().toLocal();

        if (starts.isBefore(now) && ends.isAfter(now)) return true;
      }
    }

    final List<Pair<tz.TZDateTime, tz.TZDateTime>> schedule = scheduleInDates();
    if (schedule.isNotEmpty) {
      bool isOpen = false;
      for (final Pair<tz.TZDateTime, tz.TZDateTime> p in schedule) {
        isOpen = isOpen || (p.first.isBefore(now) && p.second.isAfter(now));
      }

      return !isOpen;
    }

    return false;
  }

  void handleSpotEvent(proto.ProtoOASpotEvent event) {
    ask = event.ask ?? ask;
    bid = event.bid ?? bid;
    sessionClose = event.sessionClose ?? sessionClose;
    if (bid != null && sessionClose != null) {
      dailyChangePips = bid! - sessionClose!;
      dailyChangePercents = dailyChangePips / sessionClose!;
    }
  }

  Future<SymbolDetailsData> getDetailsData() async {
    if (details != null) return Future<SymbolDetailsData>.value(details);

    await GetIt.I<RemoteAPIManager>().getAPI(demo: trader.demo).sendSymbolById(trader.id, <int>[id]);
    return details!;
  }

  Future<SymbolData> getUpdatedRates() async {
    final SpotSubscriptionManager spotSubscriptionManager = trader.subscriptionManagerApi;

    if (spotSubscriptionManager.isSymbolSubscribedForSpots(id)) return this;

    final RemoteApi remoteApi = trader.remoteApi;
    await remoteApi.subscribeForSpots(trader.id, <int>[id]);
    await remoteApi.unsubscribeFromSpots(trader.id, <int>[id]);

    return this;
  }
}

class SymbolDetailsData {
  SymbolDetailsData(this.symbol, this.data);

  proto.ProtoOASymbol data;
  SymbolData symbol;
  List<proto.ProtoOAHoliday>? _holidays;

  List<proto.ProtoOADynamicLeverageTier>? get leverages => symbol.category.assetClass.tree.leveragesBy(data.leverageId);
  int get pipSize => 1 * pow(10, 5 - data.pipPosition).toInt();

  List<proto.ProtoOAHoliday>? get holidays {
    if (_holidays != null) return _holidays;
    if (data.holiday == null) return null;

    final DateTime now = DateTime.now();
    final Iterable<proto.ProtoOAHoliday> holidays = data.holiday!.where((proto.ProtoOAHoliday holiday) {
      if (holiday.isRecurring && holiday.endDateTime().isBefore(now)) {
        DateTime date = holiday.endDateTime();
        do {
          date = DateTime(date.year + 1, date.month, date.day);
        } while (date.isBefore(now));
        holiday.holidayDate = date.daysSinceEpoch;

        return true;
      } else {
        return holiday.endDateTime().isAfter(now);
      }
    });

    _holidays = holidays.toList();
    _holidays!.sort((proto.ProtoOAHoliday a, proto.ProtoOAHoliday b) => a.holidayDate - b.holidayDate);

    return _holidays;
  }

  int cutOffExtraDigitsFromRate(int rate, bool floor) {
    final int multiplier = pow(10, 5 - data.digits).toInt();
    final double divided = rate / multiplier;

    return (floor ? divided.floor() : divided.ceil()) * multiplier;
  }

  String formattedPips({int? system, double? humanic}) {
    if (system == null && humanic == null) return '----';

    system ??= SymbolData.systemRateFromHumanic(humanic!);

    final double pips = system / pipSize;
    return '${pips.toComaSeparated(decimals: min(data.digits - data.pipPosition, 1))} pips';
  }

  String formattedRate({int? system, double? humanic}) {
    if (system == null && humanic == null) return '----';

    humanic ??= SymbolData.humanicRateFromSystem(system!);
    return humanic.toComaSeparated(decimals: data.digits);
  }

  String formattedVolume({int? system, double? humanic}) {
    if (system == null && humanic == null) return '----';

    humanic ??= SymbolData.humanicVolume(system!);

    final int vol = min(data.minVolume, data.stepVolume);
    return humanic.toComaSeparated(decimals: vol % 100 == 0 ? 0 : (vol % 10 == 0 ? 1 : 2));
  }

  String formattedVolumeWithUnits({int? system, double? humanic}) {
    return formattedVolume(system: system, humanic: humanic) + ' ' + (data.measurementUnits ?? symbol.baseAsset?.units ?? '');
  }
}
