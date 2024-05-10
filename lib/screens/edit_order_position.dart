import 'dart:async';
import 'dart:math';

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localization_helper.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/logger.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/asset_data.dart';
import 'package:ctrader_example_app/models/order_data.dart';
import 'package:ctrader_example_app/models/order_pos_data_base.dart';
import 'package:ctrader_example_app/models/position_data.dart';
import 'package:ctrader_example_app/models/symbol_data.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/popups/popup.dart';
import 'package:ctrader_example_app/popups/popup_manager.dart';
import 'package:ctrader_example_app/remote/proto.dart';
import 'package:ctrader_example_app/remote/remote_api.dart';
import 'package:ctrader_example_app/remote/remote_api_manager.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/simultaneous_trading_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:ctrader_example_app/widgets/button_primary.dart';
import 'package:ctrader_example_app/widgets/buy_sell_increment_field.dart';
import 'package:ctrader_example_app/widgets/wrapped_appbar.dart';
import 'package:ctrader_example_app/widgets/wrapped_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class _SectionData {
  bool enabled = false;
  int? value;

  void disable() {
    enabled = false;
    value = null;
  }

  void enable(int? value) {
    enabled = true;
    this.value = value;
  }
}

class EditOrderPositionScreen extends StatefulWidget {
  const EditOrderPositionScreen({super.key, this.orderId, this.positionId})
      : assert(orderId != null || positionId != null, 'To open edit screen at least one of id should be provided');

  static const String ROUTE_NAME = '/activity/edit';

  final int? orderId;
  final int? positionId;

  @override
  State<EditOrderPositionScreen> createState() => _EditOrderPositionScreenState();
}

class _EditOrderPositionScreenState extends State<EditOrderPositionScreen> {
  final Map<String, dynamic> _cachedData = <String, dynamic>{};
  int _tradingAmount = 0;
  int _whenRateIs = 0;
  DateTime? _gtdDateTime;
  int _takeProfit = -1;
  int _stopLoss = -1;
  final _SectionData _trailingStop = _SectionData();
  double _marginBuy = -1;
  double _marginSell = -1;

  OrderData? _order;
  PositionData? _position;
  Timer? _expMarginReqTimer;

  bool get _isOrder => widget.orderId != null;
  bool get _isTPEnabled => _takeProfit >= 0;
  bool get _isSLEnabled => !_trailingStop.enabled && _stopLoss >= 0;
  // bool get _isTSEnabled => _trailingStop.enabled;
  OrderPosDataBase get _orderPosData => _order ?? _position!;

  int _margin(int volume) => ((_orderPosData.isBuy ? _marginBuy : _marginSell) * volume).round();

  DateTime get _defaultGTDValue {
    return DateTime.now().add(const Duration(hours: 1)).updateTime(seconds: 0, milliseconds: 0, microseconds: 0);
  }

  bool _isAmountPlusBtnDisabled(SymbolDetailsData? details) {
    return details == null || details.data.maxVolume <= _tradingAmount || _margin(_tradingAmount + details.data.stepVolume) > details.symbol.trader.freeMargin;
  }

  bool get _isTPMinusBtnDisabled {
    final OrderPosDataBase data = _orderPosData;
    final SymbolData? symbol = data.symbol;
    final int? profitDisatance = symbol?.takeProfitDisatance;
    final int? rate = _isOrder ? _whenRateIs : (data.isBuy ? symbol?.ask : symbol?.bid);

    return rate == null || profitDisatance == null || (data.isBuy && _takeProfit <= (rate + profitDisatance * (data.isBuy ? 1 : -1)));
  }

  bool get _isTPPlusBtnDisabled {
    final OrderPosDataBase data = _orderPosData;
    final SymbolData? symbol = data.symbol;
    final int? profitDisatance = symbol?.takeProfitDisatance;
    final int? rate = _isOrder ? _whenRateIs : (data.isBuy ? symbol?.ask : symbol?.bid);

    return rate == null || profitDisatance == null || (!data.isBuy && _takeProfit >= (rate + profitDisatance * (data.isBuy ? 1 : -1)));
  }

  bool get _isSLMinusBtnDisabled {
    final OrderPosDataBase data = _orderPosData;
    final SymbolData? symbol = data.symbol;
    final int? lossDistance = symbol?.stopLossDistance;
    final int? rate = _isOrder ? _whenRateIs : (data.isBuy ? symbol?.bid : symbol?.ask);

    return rate == null ||
        lossDistance == null ||
        (!data.isBuy && _stopLoss <= (rate + (data.isBuy ? -1 : 1) * (lossDistance + (_isOrder ? symbol?.spread ?? 1 : 1))));
  }

  bool get _isSLPlusBtnDisabled {
    final OrderPosDataBase data = _orderPosData;
    final SymbolData? symbol = data.symbol;
    final int? lossDistance = symbol?.stopLossDistance;
    final int? rate = _isOrder ? _whenRateIs : (data.isBuy ? symbol?.bid : symbol?.ask);

    return rate == null ||
        lossDistance == null ||
        (data.isBuy && _stopLoss >= (rate + (lossDistance + (_isOrder ? symbol?.spread ?? 1 : 1)) * (data.isBuy ? -1 : 1)));
  }

  bool get _isTSMinusBtnDisabled {
    if (!_trailingStop.enabled) return true;
    if (_trailingStop.value == null) return false;

    final SymbolData? symbol = _orderPosData.symbol;
    if (symbol?.details == null) return true;

    final int tsRate = _orderPosData.rate + (_orderPosData.isBuy ? -1 : 1) * _trailingStop.value!;
    final int rate = _isOrder ? _whenRateIs : (_orderPosData.isBuy ? symbol!.ask! : symbol!.bid!);
    final int extremeRate = rate + (_orderPosData.isBuy ? -1 : 1) * (symbol!.stopLossDistance + symbol.spread);

    return _orderPosData.isBuy ? tsRate >= extremeRate : tsRate <= extremeRate;
  }

  bool get _isTSPlusBtnDisabled {
    if (!_trailingStop.enabled) return true;
    if (_trailingStop.value == null) return false;

    final SymbolData? symbol = _orderPosData.symbol;
    if (symbol?.details == null) return true;

    final int tsRate = _orderPosData.rate + (_orderPosData.isBuy ? -1 : 1) * _trailingStop.value!;

    return _orderPosData.isBuy && tsRate <= symbol!.pipSize!;
  }

  bool get _isActionBtnDisabled {
    if (_isOrder) {
      final OrderData order = _orderPosData as OrderData;

      return (order.volume == _tradingAmount) &&
          (order.rate == _whenRateIs) &&
          order.expireAt == _gtdDateTime &&
          ((order.takeProfit == null && _takeProfit <= 0) || order.takeProfit == _takeProfit) &&
          ((order.stopLoss == null && _stopLoss <= 0) || order.stopLoss == _stopLoss) &&
          ((!order.trailingStopLoss && !_trailingStop.enabled) || order.trailingStopDistance == _trailingStop.value);
    } else {
      final PositionData position = _orderPosData as PositionData;

      return (position.stopLoss == _stopLoss || (_stopLoss < 0 && position.stopLoss == null)) &&
          (position.takeProfit == _takeProfit || (_takeProfit < 0 && position.takeProfit == null)) &&
          ((!position.trailingStopLoss && !_trailingStop.enabled) || (position.trailingStopDistance == _trailingStop.value));
    }
  }

  @override
  void initState() {
    super.initState();

    final TraderData trader = GetIt.I<UserState>().selectedTrader;
    if (_isOrder) {
      _order = trader.ordersManager.activityBy(id: widget.orderId);
      if (_order?.expireAt != null) _gtdDateTime = _order!.expireAt!.add(Duration.zero);
      _expMarginReqTimer = Timer.periodic(
        const Duration(seconds: 2),
        (Timer timer) => _updateExpactedMargin().then((_) => mounted ? setState(() {}) : null),
      );
      _updateExpactedMargin().then((_) => setState(() {}));
    } else {
      _position = trader.positionsManager.activityBy(id: widget.positionId);
    }

    if (_order == null && _position == null) {
      Timer.run(() {
        GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
        Navigator.pop(context);
      });
      return;
    }

    final OrderPosDataBase data = _orderPosData;
    _tradingAmount = data.volume;
    _whenRateIs = data.rate;
    _takeProfit = data.takeProfit ?? _takeProfit;

    _trailingStop.enabled = _orderPosData.trailingStopLoss;
    if (_trailingStop.enabled) {
      _trailingStop.value = _orderPosData.trailingStopDistance;
    } else {
      _stopLoss = _orderPosData.stopLoss ?? -1;
    }

    final SymbolData? symbol = data.symbol;
    if (symbol?.id != null) {
      GetIt.I<RemoteAPIManager>().getSpotSubscriptionManager(demo: trader.demo).subscribe(trader.id, <int>[symbol!.id]);

      if (symbol.details == null) {
        GetIt.I<RemoteAPIManager>().getAPI(demo: trader.demo).sendSymbolById(trader.id, <int>[symbol.id]);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _correctTakeProfit();
    _correctStopLoss();
    _correctTrailingStop();
  }

  @override
  void dispose() {
    _expMarginReqTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TraderData trader = context.watch<UserState>().selectedTrader;
    final OrderPosDataBase orderPosData = _orderPosData;
    final SymbolData? symbol = trader.tree.symbol(orderPosData.symbolId);

    return Scaffold(
      appBar: WrappedAppBar(
        title: _isOrder ? l10n.editOrder : l10n.editPosition,
        showBack: true,
      ),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          if (_isOrder)
            for (final Widget w in _orderHeader(l10n, orderPosData as OrderData)) w,
          if (!_isOrder)
            for (final Widget w in _positionHeader(l10n, orderPosData as PositionData)) w,
          const SizedBox(height: 4),
          if (_isOrder)
            for (final Widget w in _amountSection(l10n, symbol)) w,
          if (_isOrder)
            for (final Widget w in _whenRateIsSection(l10n, symbol)) w,
          Container(height: 1, color: THEME.dividerLight()),
          _sectionHeader(l10n.takeProfit, _isTPEnabled, false, _toggleTakeProfit),
          if (_isTPEnabled)
            for (final Widget w in _takeProfitSection(l10n, orderPosData, symbol)) w,
          Container(height: 1, color: THEME.dividerLight()),
          _sectionHeader(l10n.stopLoss, _isSLEnabled, _orderPosData.garanteedStopLoss, _toggleStopLoss),
          if (_isSLEnabled)
            for (final Widget w in _stopLossSection(l10n, orderPosData, symbol)) w,
          Container(height: 1, color: THEME.dividerLight()),
          _sectionHeader(l10n.trailingStop, _trailingStop.enabled, false, _toggleTrailingStop),
          if (_trailingStop.enabled)
            for (final Widget w in _trailingStopSection(l10n, symbol, orderPosData.isBuy, orderPosData.volume)) w,
          Container(height: 1, color: THEME.dividerLight()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ButtonPrimary(label: l10n.edit, disabled: _isActionBtnDisabled, onTap: _onTapActionButton),
          ),
        ]),
      ),
    );
  }

  List<Widget> _positionHeader(AppLocalizations l10n, PositionData position) {
    return <Widget>[
      const SizedBox(height: 4),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(position.isBuy ? l10n.buy : l10n.sell, style: THEME.texts.headingRegular),
        const SizedBox(width: 6),
        Text(position.symbol?.name ?? '----', style: THEME.texts.headingRegular),
        const Spacer(),
        Text(
          position.formattedPnlWithCurrency,
          style: THEME.texts.headingBold.copyWith(color: position.netPnl < 0 ? THEME.red : THEME.green),
        ),
        const SizedBox(width: 16),
      ]),
      const SizedBox(height: 4),
      Container(height: 1, color: THEME.dividerLight()),
      const SizedBox(height: 4),
      _headerLine(l10n.positionId, position.id.toString()),
      _headerLine(l10n.amount, position.formattedVolumeWithUnits),
      _headerLine(l10n.openingPrice, position.formattedRate(system: position.rate)),
      _headerLine(l10n.currentRate, position.formattedRate(system: position.currentRate)),
      _headerLine(l10n.openTime, position.opened.formatted()),
    ];
  }

  List<Widget> _orderHeader(AppLocalizations l10n, OrderData order) {
    return <Widget>[
      const SizedBox(height: 4),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        Text(order.isBuy ? l10n.buy : l10n.sell, style: THEME.texts.headingRegular),
        const SizedBox(width: 6),
        Text(order.symbol?.name ?? '----', style: THEME.texts.headingRegular),
        const Spacer(),
        Text('@${order.formattedRate(system: order.rate)}', style: THEME.texts.headingBold),
        const SizedBox(width: 16),
      ]),
      const SizedBox(height: 4),
      Container(height: 1, color: THEME.dividerLight()),
      const SizedBox(height: 4),
      _headerLine(l10n.orderId, order.id.toString()),
      _headerLine(l10n.currentRate, order.formattedRate(system: order.currentRate)),
      _headerLine(l10n.goodTill, order.expireAt == null ? l10n.cancelled : order.expireAt!.formatted()),
      _headerLine(l10n.creationTime, order.opened.formatted()),
    ];
  }

  Widget _headerLine(String label, String value) {
    return Row(children: <Widget>[
      const SizedBox(width: 16),
      Text(label, style: THEME.texts.bodyMedium),
      const Spacer(),
      Text(value, style: THEME.texts.bodyMedium),
      const SizedBox(width: 16),
    ]);
  }

  Widget _sectionHeader(String label, bool isExpanded, bool isDisabled, Function(bool) onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: IntrinsicHeight(
        child: Row(children: <Widget>[
          Text(label, style: THEME.texts.headingBold),
          const Spacer(),
          WrappedSwitch(selected: isExpanded, onChange: onChange, disabled: isDisabled),
        ]),
      ),
    );
  }

  List<Widget> _amountSection(AppLocalizations l10n, SymbolData? symbol) {
    final SymbolDetailsData? details = symbol?.details;
    final int margin = _margin(_tradingAmount);
    int decimals = 0;
    if (details != null) {
      decimals = details.data.minVolume < 10 || details.data.stepVolume < 10 ? 2 : (details.data.minVolume < 100 || details.data.stepVolume < 100 ? 1 : 0);
    }

    return <Widget>[
      Container(height: 1, color: THEME.dividerLight()),
      const SizedBox(height: 16),
      Flex(direction: Axis.horizontal, children: <Widget>[
        const Spacer(),
        BuySellIncrementField(
          decimals: decimals,
          value: _tradingAmount / 100,
          minVolume: (details?.data.minVolume ?? 0) / 100,
          maxVolume: (details?.data.maxVolume ?? 0) / 100,
          step: (details?.data.stepVolume ?? 0) / 100,
          minusButtonDisabled: (details?.data.minVolume ?? 0) >= _tradingAmount,
          plusButtonDisabled: _isAmountPlusBtnDisabled(details),
          onChange: _onChangeTradingAmount,
        ),
        Expanded(child: Center(child: Text(details?.data.measurementUnits ?? 'n/a', style: THEME.texts.bodyMedium))),
      ]),
      const SizedBox(height: 6),
      Text(
        "${l10n.expectedMargin}: ${margin > 0 && symbol != null ? symbol.trader.formattedMoneyWithCurrency(cents: margin) : "n/a"}",
        style: THEME.texts.bodyRegular,
      ),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _whenRateIsSection(AppLocalizations l10n, SymbolData? symbol) {
    final int? rate = _orderPosData.currentRate;
    final double distance = rate != null ? (_whenRateIs - rate).abs() / rate * 100 : 0;

    return <Widget>[
      Container(height: 1, color: THEME.dividerLight()),
      _sectionHeader(l10n.buySellWhenRateIs(_orderPosData.isBuy ? l10n.buy : l10n.sell), true, false, (_) => null),
      Stack(children: <Widget>[
        Column(children: <Widget>[
          const SizedBox(height: 6),
          BuySellIncrementField(
            value: SymbolData.humanicRateFromSystem(_whenRateIs),
            minVolume: 0,
            step: 1 / pow(10, symbol?.details?.data.digits ?? 0),
            decimals: symbol?.details?.data.digits ?? 0,
            onChange: (double value) => _onChangeLimitRate(symbol, value),
          ),
          const SizedBox(height: 8),
          Text('${l10n.distance}: ${distance.toComaSeparated(decimals: 2)}%', style: THEME.texts.bodyMedium),
          const SizedBox(height: 8),
          if (_gtdDateTime != null)
            for (final Widget item in _dateTimePickerSection()) item,
        ]),
        Positioned(
          right: 16,
          top: 8,
          child: GestureDetector(
            onTap: _toggleDateTimeSection,
            child: Container(
              color: Colors.transparent,
              child: SvgPicture.asset(
                'assets/svg/timer.svg',
                width: 32,
                height: 32,
                colorFilter: (_gtdDateTime != null ? THEME.buySellTimerIconSelected() : THEME.buySellTimerIcon()).asFilter,
              ),
            ),
          ),
        ),
      ]),
    ];
  }

  List<Widget> _dateTimePickerSection() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return <Widget>[
      Container(
          alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(l10n.cancelOrderBy, style: THEME.texts.bodyBold)),
      const SizedBox(height: 8),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        const Spacer(),
        GestureDetector(
          onTap: _selectGTDTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: THEME.inputBorder()),
            ),
            child: Text(_gtdDateTime!.formatted('HH:mm'), style: THEME.texts.inputIncremenet),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _selectGTDDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: THEME.inputBorder()),
            ),
            child: Text(_gtdDateTime!.formatted('d MMMM y'), style: THEME.texts.inputIncremenet, softWrap: false),
          ),
        ),
        const SizedBox(width: 16),
      ]),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _takeProfitSection(AppLocalizations l10n, OrderPosDataBase data, SymbolData? symbol) {
    String expProfitStr = '---';

    if (symbol != null) {
      final int rate = _isOrder ? _whenRateIs : data.rate;
      final int tpRateDist = data.isBuy ? _takeProfit - rate : rate - _takeProfit;
      final double expProfit = SymbolData.humanicRateFromSystem(tpRateDist) * data.humanicVolume;
      final AssetData? asset = symbol.trader.tree.asset(symbol.quoteAssetId);
      expProfitStr = asset?.formattedValue(expProfit, units: true) ?? expProfit.toString();
    }

    return <Widget>[
      const SizedBox(height: 6),
      BuySellIncrementField(
        decimals: symbol?.details?.data.digits ?? 0,
        value: SymbolData.humanicRateFromSystem(_takeProfit),
        minVolume: 0,
        step: 1 / pow(10, symbol?.details?.data.digits ?? 0),
        minusButtonDisabled: _isTPMinusBtnDisabled,
        plusButtonDisabled: _isTPPlusBtnDisabled,
        onChange: _onChangeTakeProfit,
      ),
      const SizedBox(height: 6),
      Text('${l10n.expectedProfit}: $expProfitStr', style: THEME.texts.bodyRegular),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _stopLossSection(AppLocalizations l10n, OrderPosDataBase data, SymbolData? symbol) {
    String expLossStr = '---';
    if (symbol != null) {
      final int rate = _isOrder ? _whenRateIs : data.rate;
      final int slRateDist = data.isBuy ? rate - _stopLoss : _stopLoss - rate;
      final double expLoss = SymbolData.humanicRateFromSystem(slRateDist) * data.humanicVolume;
      final AssetData? asset = symbol.trader.tree.asset(symbol.quoteAssetId);
      expLossStr = asset?.formattedValue(expLoss, units: true) ?? expLoss.toString();
    }

    return <Widget>[
      const SizedBox(height: 6),
      BuySellIncrementField(
        decimals: symbol?.details?.data.digits ?? 0,
        value: SymbolData.humanicRateFromSystem(_stopLoss),
        minVolume: 0,
        step: 1 / pow(10, symbol?.details?.data.digits ?? 0),
        minusButtonDisabled: _isSLMinusBtnDisabled,
        plusButtonDisabled: _isSLPlusBtnDisabled,
        onChange: _onChangeStopLoss,
      ),
      const SizedBox(height: 6),
      Text(
        '${l10n.expectedLoss}: $expLossStr',
        style: THEME.texts.bodyRegular,
      ),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _trailingStopSection(AppLocalizations l10n, SymbolData? symbol, bool isBuy, int volume) {
    final int digits = symbol?.details?.data.digits ?? 5;
    final int pipPos = symbol?.details?.data.pipPosition ?? 0;
    final int decimals = digits - pipPos;
    final bool isTSCurrent = _orderPosData.trailingStopDistance == _trailingStop.value || (_trailingStop.value == null);
    final int? rate;

    if (isTSCurrent) {
      rate = _orderPosData.stopLoss;
    } else {
      rate = (_isOrder ? _whenRateIs : _orderPosData.rate) + (isBuy ? -1 : 1) * (_trailingStop.value ?? 0);
    }

    return <Widget>[
      const SizedBox(height: 16),
      Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          const Spacer(),
          BuySellIncrementField(
            value: _trailingStop.value == null ? null : _trailingStop.value! / pow(10, 5 - pipPos),
            decimals: min(decimals, 1),
            minVolume: 0,
            step: 1 / pow(10, min(decimals, 1)),
            minusButtonDisabled: _isTSMinusBtnDisabled,
            plusButtonDisabled: _isTSPlusBtnDisabled,
            onChange: _onChangeTrailingStop,
          ),
          Expanded(child: Center(child: Text(l10n.pips, style: THEME.texts.bodyMedium))),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        '${isTSCurrent ? l10n.currently : l10n.expected}: ${symbol?.details?.formattedRate(system: rate) ?? SymbolData.formattedRateDefault(system: rate)}',
        style: THEME.texts.bodyRegular,
      ),
      const SizedBox(height: 16),
    ];
  }

  void _onChangeTradingAmount(double value) {
    final int amount = SymbolData.systemVolume(value);
    if (_margin(amount) > GetIt.I<UserState>().selectedTrader.freeMargin) return;

    setState(() => _tradingAmount = amount);
  }

  void _correctLimitRate() {
    if (_whenRateIs > 0) {
      final SymbolData? symbol = _orderPosData.symbol;
      if (symbol == null || symbol.details == null) return;

      _whenRateIs = symbol.details!.cutOffExtraDigitsFromRate(_whenRateIs, _orderPosData.isBuy);

      final int? rate = _orderPosData.currentRate;
      if (rate == null) return;

      if (_whenRateIs == rate) {
        _whenRateIs += (_orderPosData.isBuy ? 1 : -1) * pow(10, 5 - symbol.details!.data.digits).toInt();
      }
    }
  }

  void _correctGTDDate() {
    if (_gtdDateTime != null) {
      final Duration diff = _gtdDateTime!.difference(DateTime.now());
      if (diff.inMinutes < 2) {
        _gtdDateTime = DateTime.now().add(const Duration(minutes: 3)).updateTime(seconds: 0, milliseconds: 0, microseconds: 0);
      }
    }
  }

  void _toggleTakeProfit(bool enable) {
    if (enable) {
      final OrderPosDataBase data = _orderPosData;
      if (data.takeProfit != null) {
        _takeProfit = data.takeProfit!;
      } else if (_cachedData['takeProfit'] != null) {
        _takeProfit = _cachedData['takeProfit'] as int;
      } else {
        final int? rate = _isOrder ? _whenRateIs : data.currentRate;
        final int? profitDisatance = data.symbol?.takeProfitDisatance;

        if (rate != null && profitDisatance != null) {
          _takeProfit = rate + 2 * profitDisatance * (data.isBuy ? 1 : -1);
        }
      }
      _correctTakeProfit();
    } else {
      _takeProfit = -1;
    }

    setState(() {});
  }

  void _onChangeTakeProfit(double value) {
    _takeProfit = SymbolData.systemRateFromHumanic(value);
    _correctTakeProfit();
    setState(() {});
  }

  void _correctTakeProfit() {
    if (!_isTPEnabled) return;

    final OrderPosDataBase data = _orderPosData;
    final SymbolData? symbol = data.symbol;
    final int? takeProfitDisatance = symbol?.takeProfitDisatance;
    final int? rate = _isOrder ? _whenRateIs : (data.isBuy ? symbol?.ask : symbol?.bid);

    if (takeProfitDisatance == null || rate == null) return;

    _takeProfit = symbol!.details!.cutOffExtraDigitsFromRate(_takeProfit, !_orderPosData.isBuy);

    final int extremeRate = rate + takeProfitDisatance * (data.isBuy ? 1 : -1);
    if ((data.isBuy && _takeProfit < extremeRate) || (!data.isBuy && _takeProfit > extremeRate)) {
      _takeProfit = extremeRate;
    }

    _cachedData['takeProfit'] = _takeProfit;
  }

  void _toggleStopLoss(bool enable) {
    if (enable) {
      _trailingStop.disable();

      final OrderPosDataBase data = _orderPosData;
      if (data.stopLoss != null) {
        _stopLoss = data.stopLoss!;
      } else if (_cachedData['stopLoss'] != null) {
        _stopLoss = _cachedData['stopLoss'] as int;
      } else {
        final int? rate = _isOrder ? _whenRateIs : data.currentRate;
        final int? lossDistance = data.symbol?.stopLossDistance;
        final int direction = data.isBuy ? -1 : 1;

        if (rate != null && lossDistance != null) {
          _stopLoss = rate + lossDistance * 2 * direction;
          if (_isOrder) _stopLoss += (data.symbol?.spread ?? 0) * direction;
        }
        _correctStopLoss();
      }
    } else {
      _stopLoss = -1;
    }

    setState(() {});
  }

  void _onChangeStopLoss(double value) {
    _stopLoss = SymbolData.systemRateFromHumanic(value);

    _correctStopLoss();
    setState(() {});
  }

  void _correctStopLoss() {
    if (!_isSLEnabled) return;

    final OrderPosDataBase data = _orderPosData;
    final SymbolData? symbol = data.symbol;
    final int? lossDistance = symbol?.stopLossDistance;
    final int? rate = _isOrder ? _whenRateIs : (data.isBuy ? symbol?.bid : symbol?.ask);

    if (rate == null || lossDistance == null) return;

    _stopLoss = symbol!.details!.cutOffExtraDigitsFromRate(_stopLoss, false);

    final int extremeRate = rate + (lossDistance + (_isOrder ? symbol.spread : 0)) * (data.isBuy ? -1 : 1);
    if ((data.isBuy && _stopLoss > extremeRate) || (!data.isBuy && _stopLoss < extremeRate)) {
      _stopLoss = extremeRate;
    }

    _cachedData['stopLoss'] = _stopLoss;
  }

  void _toggleTrailingStop(bool enable) {
    if (enable) {
      _stopLoss = -1;

      final OrderPosDataBase data = _orderPosData;
      if (_orderPosData.trailingStopLoss) {
        _trailingStop.enable(data.trailingStopDistance);
      } else if (_cachedData['trailingStop'] != null) {
        _trailingStop.enable(_cachedData['trailingStop'] as int);
      } else {
        _trailingStop.enable((data.symbol?.stopLossDistance ?? -1) * 2);
      }
      _correctTrailingStop();
    } else {
      _trailingStop.disable();

      if (_orderPosData.garanteedStopLoss) _toggleStopLoss(true);
    }

    setState(() {});
  }

  void _onChangeTrailingStop(double value) {
    final SymbolData? symbol = _orderPosData.symbol;

    if (symbol != null && symbol.details != null) {
      if (symbol.details!.data.pipPosition > 1) value = (value * 10).round() / 10;
      _trailingStop.value = (value * symbol.pipSize!).round();
      _correctTrailingStop();
      setState(() {});
    }
  }

  void _correctTrailingStop() {
    if (!_trailingStop.enabled) return;

    final SymbolData? symbol = _orderPosData.symbol;
    if (_trailingStop.value == null || symbol?.details == null) return;

    final int tsRate = _orderPosData.rate + _trailingStop.value! * (_orderPosData.isBuy ? -1 : 1);
    final int rate = _isOrder ? _whenRateIs : (_orderPosData.isBuy ? symbol!.ask! : symbol!.bid!);
    final int extremeRate = rate + (_orderPosData.isBuy ? -1 : 1) * (symbol!.stopLossDistance + symbol.spread);

    if (_orderPosData.isBuy && tsRate > extremeRate) {
      _trailingStop.value = _orderPosData.rate - extremeRate;
    } else if (!_orderPosData.isBuy && tsRate < extremeRate) {
      _trailingStop.value = extremeRate - _orderPosData.rate;
    }

    _cachedData['trailingStop'] = _trailingStop.value;
  }

  Future<void> _updateExpactedMargin() async {
    final UserState userState = GetIt.I<UserState>();
    final TraderData trader = userState.selectedTrader;
    final SymbolData? symbol = trader.tree.symbol(_orderPosData.symbolId);
    final ProtoOASymbol? details = symbol?.details?.data;

    if (symbol == null || details == null) return;

    final RemoteApi remoteApi = trader.remoteApi;

    if (symbol.details == null) await remoteApi.sendSymbolById(symbol.trader.id, <int>[symbol.id]);

    final ProtoOAExpectedMarginRes marginResp = await remoteApi.sendExpectedMargin(
      symbol.trader.id,
      symbol.id,
      <int>[symbol.details!.data.minVolume],
    );
    final ProtoOAExpectedMargin margin = marginResp.margin.first;
    _marginBuy = margin.buyMargin / margin.volume;
    _marginSell = margin.sellMargin / margin.volume;
  }

  void _onChangeLimitRate(SymbolData? symbol, double value) {
    _whenRateIs = SymbolData.systemRateFromHumanic(value);

    _correctLimitRate();
    _correctTakeProfit();
    _correctStopLoss();
    _correctTrailingStop();

    setState(() {});
  }

  void _toggleDateTimeSection() {
    if (_gtdDateTime == null) {
      _gtdDateTime = _defaultGTDValue;
    } else {
      _gtdDateTime = null;
    }

    setState(() {});
  }

  Future<void> _selectGTDTime() async {
    _gtdDateTime ??= _defaultGTDValue;

    final TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_gtdDateTime!));
    if (time != null) {
      _gtdDateTime = _gtdDateTime!.updateTime(hours: time.hour, minutes: time.minute);
      _correctGTDDate();
      setState(() {});
    }
  }

  Future<void> _selectGTDDate() async {
    _gtdDateTime ??= _defaultGTDValue;
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: _gtdDateTime!,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().addPeriod(years: 1),
    );

    if (newDate != null) {
      _correctGTDDate();
      setState(() {
        _gtdDateTime = newDate.updateTime(hours: _gtdDateTime?.hour ?? 0, minutes: _gtdDateTime?.minute ?? 0);
      });
    }
  }

  Future<void> _onTapActionButton() async {
    if (_orderPosData.symbol?.details == null) {
      GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
      return;
    }

    if (_isOrder) {
      final OrderData order = _order!;
      final bool isLimit = order.isBuy ? order.currentRate! > _whenRateIs : order.currentRate! < _whenRateIs;

      GetIt.I<AppState>().setUIBlocked(true);
      if (order.isLimit == isLimit) {
        int? trailingStop;
        int? stopLoss;
        if (_trailingStop.enabled && order.trailingStopDistance == _trailingStop.value) {
          trailingStop = order.trailingStopDistance;
          stopLoss = order.stopLoss;
        } else if (_trailingStop.enabled) {
          trailingStop = _trailingStop.value;
          stopLoss = _whenRateIs + (order.isBuy ? -1 : 1) * _trailingStop.value!;
        } else if (_isSLEnabled) {
          stopLoss = _stopLoss;
        }

        final bool? sucess = await _order?.editOrder(
          context,
          _whenRateIs,
          _tradingAmount,
          stopLoss: stopLoss,
          takeProfit: _isTPEnabled ? _takeProfit : null,
          trailingStop: _trailingStop.enabled ? trailingStop : null,
          expiresAtTs: _gtdDateTime?.millisecondsSinceEpoch,
        );
        if (sucess == true) Navigator.pop(context);
      } else {
        if (!GetIt.I<UserState>().dontShowReversOrderPopup) {
          final PopupResult result = await GetIt.I<PopupManager>().askToCancelOrderBeforeNewOne(AppLocalizations.of(context)!, order.id);
          if (!result.agree) {
            GetIt.I<AppState>().setUIBlocked(false);
            return;
          } else if (result.payload[Popup.PAYLOAD_CHECKBOX_KEY] == true) GetIt.I<UserState>().setDontShowReversOrderPopup();
        }

        final SimultaneousTrdaingState simultaneousState = GetIt.I<SimultaneousTrdaingState>();
        if (simultaneousState.isOrderPaired(order.trader.id, order.id)) {
          final Map<int, int> pairedOrders = simultaneousState.getPairedOrders(order.trader.id, order.id);

          final PopupResult result = await GetIt.I<PopupManager>().askToApplySimultaneousChanges(AppLocalizations.of(context)!, false, pairedOrders.keys);
          if (result.agree && result.payload['all'] != true) {
            simultaneousState.removeOrderFromPair(order.trader.id, order.id);
            final int? newId = await _replaceOrderWithNew(order, order.symbol?.details);
            if (newId != null && newId > 0) Navigator.pop(context);
          } else if (result.agree) {
            final SymbolDetailsData? symbolDetails = order.symbol?.details;
            final Map<int, int> newPair = <int, int>{};
            for (final int accId in pairedOrders.keys.toList()) {
              try {
                final TraderData trader = GetIt.I<UserState>().trader(accId)!;
                final OrderData order = trader.ordersManager.activityBy(id: pairedOrders[accId])!;
                final int? newId = await _replaceOrderWithNew(order, symbolDetails);
                if (newId != null) {
                  simultaneousState.removeOrderFromPair(trader.id, order.id);
                  if (newId > 0) newPair[trader.id] = newId;
                }
              } catch (e) {
                Logger.error('Error occurred', e);
              }
            }
            simultaneousState.pairOrders(newPair);
            if (newPair.isNotEmpty) Navigator.pop(context);
          }
        } else {
          final int? newId = await _replaceOrderWithNew(order, order.symbol?.details);
          if (newId != null && newId > 0) Navigator.pop(context);
        }
      }
      GetIt.I<AppState>().setUIBlocked(false);
    } else {
      GetIt.I<AppState>().setUIBlocked(true);
      final bool? updated = await _position?.editPosition(
        context,
        takeProfit: _isTPEnabled ? _takeProfit : null,
        trailingStop: _trailingStop.enabled ? _trailingStop.value : null,
        stopLoss: !_trailingStop.enabled && _isSLEnabled ? _stopLoss : null,
      );
      GetIt.I<AppState>().setUIBlocked(false);
      if (updated == true) Navigator.pop(context);
    }
  }

  Future<int?> _replaceOrderWithNew(OrderData oldOrder, SymbolDetailsData? symbolDetails) async {
    final bool closed = await oldOrder.cancelOrder(context, force: true);
    if (closed) {
      final TraderData trader = oldOrder.trader;
      final RemoteApi remoteAPI = trader.remoteApi;
      try {
        final ProtoMessage resp = await remoteAPI.sendNewOrderForOrder(
          trader.id,
          oldOrder.symbolId,
          oldOrder.isBuy,
          _tradingAmount,
          !oldOrder.isLimit,
          SymbolData.humanicRateFromSystem(_whenRateIs),
          expirationTimestamp: _gtdDateTime?.millisecondsSinceEpoch,
          takeProfit: _isTPEnabled ? (_takeProfit - oldOrder.currentRate!).abs() : null,
          trailingStop: _trailingStop.enabled,
          stopLoss: _trailingStop.enabled ? _trailingStop.value : (_isSLEnabled ? (_whenRateIs - _stopLoss).abs() : null),
          guaranteedStopLoss: trader.isLimitedRisk,
        );

        if (resp is ProtoOAExecutionEvent && resp.executionType == ProtoOAExecutionType.orderAccepted) {
          GetIt.I<PopupManager>().showPendingOrderWasCreated(AppLocalizations.of(context)!, resp, symbolDetails: symbolDetails);
          return resp.order!.orderId;
        } else if (resp is ProtoOAOrderErrorEvent) {
          Logger.error('Error occurred for opening new order', e);
          final AppLocalizations l10n = AppLocalizations.of(context)!;
          GetIt.I<PopupManager>().showError(l10n, l10n.getServerErrorDescription(resp.errorCode) ?? resp.description ?? resp.errorCode);
        }

        return null;
      } on ProtoOAErrorRes catch (e) {
        Logger.error('Error occurred for opening new order', e);
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        GetIt.I<PopupManager>().showError(l10n, l10n.getServerErrorDescription(e.errorCode) ?? e.description ?? e.errorCode);
        return null;
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }
}
