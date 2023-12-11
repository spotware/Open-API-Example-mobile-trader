import 'dart:async';
import 'dart:math';

import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localization_helper.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/logger.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/asset_data.dart';
import 'package:ctrader_example_app/models/internal_application_error.dart';
import 'package:ctrader_example_app/models/position_data.dart';
import 'package:ctrader_example_app/models/symbol_data.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/popups/popup.dart';
import 'package:ctrader_example_app/popups/popup_manager.dart';
import 'package:ctrader_example_app/remote/proto.dart';
import 'package:ctrader_example_app/remote/remote_api.dart';
import 'package:ctrader_example_app/states/app_state.dart';
import 'package:ctrader_example_app/states/simultaneous_trading_state.dart';
import 'package:ctrader_example_app/states/user_state.dart';
import 'package:ctrader_example_app/widgets/button_primary.dart';
import 'package:ctrader_example_app/widgets/buy_sell_increment_field.dart';
import 'package:ctrader_example_app/widgets/side_menu.dart';
import 'package:ctrader_example_app/widgets/symbol_buy_sell.dart';
import 'package:ctrader_example_app/widgets/wrapped_appbar.dart';
import 'package:ctrader_example_app/widgets/wrapped_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class BuySellScreen extends StatefulWidget {
  const BuySellScreen({super.key, required this.isBuy, required this.symbolId});

  static const String ROUTE_NAME = '/activity/open';

  final bool isBuy;
  final int symbolId;

  @override
  State<BuySellScreen> createState() => _BuySellScreenState();
}

class _BuySellScreenState extends State<BuySellScreen> {
  late final Timer _expMarginReqTimer;
  final Map<String, dynamic> _cachedData = <String, dynamic>{};
  bool _isBuy = false;
  double _marginBuy = -1;
  double _marginSell = -1;
  int _tradingAmount = 0;
  int _whenRateIs = -1;
  bool _dateTimePicker = false;
  DateTime? _gtdDateTime;
  int _takeProfit = -1;
  int _stopLoss = -1;
  int _trailingStop = -1;
  Timer? _timeIncrementTimer;
  double _expMarginConvertRate = 1;

  @override
  void initState() {
    super.initState();

    _isBuy = widget.isBuy;

    final UserState userState = GetIt.I<UserState>();
    final SymbolData? symbol = userState.selectedTrader.tree.symbol(widget.symbolId);
    if (symbol == null) return;

    symbol.getDetailsData().then((_) {
      _tradingAmount = symbol.details?.data.minVolume ?? _tradingAmount;
      userState
          .resotreSymbolVolume(traderId: userState.selectedTraderId, symbolId: symbol.id)
          .then((int? value) => setState(() => _tradingAmount = value ?? _tradingAmount));

      if (userState.selectedTrader.isLimitedRisk) _onToggleSL(true);

      _expMarginReqTimer = Timer.periodic(
        const Duration(seconds: 2),
        (Timer timer) => _updateExpactedMargin().then((_) => mounted ? setState(() {}) : null),
      );
      _updateExpactedMargin();
    });
  }

  @override
  void dispose() {
    _expMarginReqTimer.cancel();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _correctTradingAmount();
    _correctLimitRate();
    _correctGTDDate();
    _correctTPRate();
    _correcntSLRate();
    _correctTSValue();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final SymbolData? symbol = context.watch<UserState>().selectedTrader.tree.symbol(widget.symbolId);

    return Scaffold(
      appBar: WrappedAppBar(
        title: "${_isBuy ? l10n.buy : l10n.sell} ${symbol != null ? symbol.name.toUpperCase() : ""}",
        showBack: true,
      ),
      drawer: const SideMenu(),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          SymbolBuySell(
            symbol: symbol,
            isSelected: true,
            onAction: (int? symbolId, bool isBuy) {
              if (!isBuy && symbol?.details?.data.enableShortSelling == false) {
                GetIt.I<PopupManager>().showSymbolDisabledForShortTrading(l10n);
              } else {
                setState(() {
                  _isBuy = isBuy;
                  _correctTPRate();
                  _correcntSLRate();
                });
              }
            },
            highlightBuy: _isBuy,
            highlightSell: !_isBuy,
          ),
          for (final Widget i in _amountSection(l10n, symbol)) i,
          _divider(),
          _sectionHeader(l10n.buySellWhenRateIs(_isBuy ? l10n.buy : l10n.sell), _whenRateIs > 0, false, _onToggleWhenRateIs),
          if (_whenRateIs > 0)
            for (final Widget item in _whenRateIsSection(l10n, symbol)) item,
          _divider(),
          _sectionHeader(l10n.takeProfit, _isTPEnabled, false, _onToggleTP),
          if (_isTPEnabled)
            for (final Widget item in _takeProfitSection(l10n, symbol)) item,
          _divider(),
          _sectionHeader(l10n.stopLoss, _isSLEnabled, symbol?.trader.isLimitedRisk == true, _onToggleSL),
          if (_isSLEnabled)
            for (final Widget item in _stopLossSection(l10n, symbol)) item,
          _divider(),
          _sectionHeader(l10n.trailingStop, _trailingStop > 0, false, _onToggleTS),
          if (_trailingStop > 0)
            for (final Widget item in _trailingStopSection(l10n, symbol)) item,
          _divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ButtonPrimary(label: _isBuy ? l10n.buy : l10n.sell, onTap: _onTapActionButton),
          ),
        ]),
      ),
    );
  }

  Widget _divider() => Container(color: THEME.dividerLight(), height: 1);

  List<Widget> _amountSection(AppLocalizations l10n, SymbolData? symbol) {
    final SymbolDetailsData? details = symbol?.details;
    final int margin = _margin(_tradingAmount);
    String expectedMargin = 'n/a';
    int decimals = 0;

    if (details != null) {
      decimals = details.data.minVolume < 10 || details.data.stepVolume < 10 ? 2 : (details.data.minVolume < 100 || details.data.stepVolume < 100 ? 1 : 0);
    }

    if (margin > 0) {
      expectedMargin = symbol?.trader.formattedMoneyWithCurrency(cents: margin) ?? expectedMargin;
    } else if (symbol?.trader.isLimitedRisk == true) {
      expectedMargin = symbol!.trader.formattedMoneyWithCurrency(money: _expMarginConvertRate * _expextedLoss(symbol));
    }

    return <Widget>[
      const SizedBox(height: 20),
      Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(child: Container()),
          BuySellIncrementField(
            decimals: decimals,
            value: _tradingAmount / 100,
            minVolume: (details?.data.minVolume ?? 0) / 100,
            maxVolume: (details?.data.maxVolume ?? 0) / 100,
            step: (details?.data.stepVolume ?? 0) / 100,
            minusButtonDisabled: (details?.data.minVolume ?? 0) >= _tradingAmount,
            plusButtonDisabled: _isAmountPlusBtnDisabled(details),
            onChange: _onAmountChanged,
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(details?.data.measurementUnits ?? '', style: THEME.texts.bodyMedium),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text('${l10n.expectedMargin}: $expectedMargin', style: THEME.texts.bodyRegular),
      const SizedBox(height: 16),
    ];
  }

  Widget _sectionHeader(String label, bool isExpanded, bool disabledSwitch, Function(bool) onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: IntrinsicHeight(
          child: Row(children: <Widget>[
        Text(label, style: THEME.texts.headingBold),
        const Spacer(),
        WrappedSwitch(selected: isExpanded, disabled: disabledSwitch, onChange: onChange),
      ])),
    );
  }

  List<Widget> _whenRateIsSection(AppLocalizations l10n, SymbolData? symbol) {
    final int rate = (_isBuy ? symbol?.ask : symbol?.bid) ?? -1;
    final double distance = (_whenRateIs - rate).abs() / rate * 100;

    return <Widget>[
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
          if (_dateTimePicker)
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
                colorFilter: (_dateTimePicker ? THEME.buySellTimerIconSelected() : THEME.buySellTimerIcon()).asFilter,
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
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(l10n.cancelOrderBy, style: THEME.texts.bodyBold),
      ),
      const SizedBox(height: 8),
      Row(children: <Widget>[
        const SizedBox(width: 16),
        _incrementTimeButton('minus', true, () => _incrementTime(-1)),
        const SizedBox(width: 12),
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
        const SizedBox(width: 12),
        _incrementTimeButton('plus', true, () => _incrementTime(1)),
        const Spacer(),
        GestureDetector(
          onTap: _selectGTDDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: THEME.inputBorder()),
            ),
            child: Text(_gtdDateTime!.formatted('d MMM y'), style: THEME.texts.inputIncremenet, softWrap: false),
          ),
        ),
        const SizedBox(width: 16),
      ]),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _takeProfitSection(AppLocalizations l10n, SymbolData? symbol) {
    String expProfitStr = '---';

    if (symbol != null) {
      final int? rate = _whenRateIs < 0 ? (_isBuy ? symbol.ask : symbol.bid) : _whenRateIs;
      final int tpRateDist = ((rate ?? _takeProfit) - _takeProfit).abs();
      final double expProfit = SymbolData.humanicRateFromSystem(tpRateDist) * _tradingAmount / 100;
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
        minusButtonDisabled: _isTPMinusBtnDisabled(symbol),
        plusButtonDisabled: _isTPPlusBtnDisabled(symbol),
        onChange: _onChangeTP,
      ),
      const SizedBox(height: 6),
      Text('${l10n.expectedProfit}: $expProfitStr', style: THEME.texts.bodyRegular),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _stopLossSection(AppLocalizations l10n, SymbolData? symbol) {
    String expLossStr = '---';
    if (symbol != null) {
      final double expLoss = _expextedLoss(symbol);
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
        minusButtonDisabled: _isSLMinusBtnDisabled(symbol),
        plusButtonDisabled: _isSLPlusBtnDisabled(symbol),
        onChange: _onChangeSL,
      ),
      const SizedBox(height: 6),
      Text(
        '${l10n.expectedLoss}: $expLossStr',
        style: THEME.texts.bodyRegular,
      ),
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _trailingStopSection(AppLocalizations l10n, SymbolData? symbol) {
    final int digits = symbol?.details?.data.digits ?? 5;
    final int pipPos = symbol?.details?.data.pipPosition ?? 0;
    final int decimals = digits - pipPos;
    int? rate = _whenRateIs < 0 ? (_isBuy ? symbol?.ask : symbol?.bid) : _whenRateIs;
    if (rate != null) rate += (_isBuy ? -1 : 1) * _trailingStop;

    return <Widget>[
      Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(child: Container()),
          BuySellIncrementField(
            value: _trailingStop / pow(10, 5 - pipPos),
            decimals: min(decimals, 1),
            minVolume: 0,
            step: 1 / pow(10, min(decimals, 1)),
            minusButtonDisabled: _isTSMinusBtnDisabled(symbol),
            plusButtonDisabled: _isTSPlusBtnDisabled(symbol),
            onChange: _onChangeTS,
          ),
          Expanded(child: Container(alignment: Alignment.center, child: Text(l10n.pips, style: THEME.texts.bodyMedium))),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        '${l10n.expected}: ${symbol?.details?.formattedRate(system: rate)}',
        style: THEME.texts.bodyRegular,
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _incrementTimeButton(String iconName, bool isEnabled, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: (LongPressStartDetails details) {
        onTap();
        _timeIncrementTimer = Timer.periodic(const Duration(milliseconds: 200), (Timer timer) {
          if (mounted) {
            onTap();
          } else {
            timer.cancel();
          }
        });
      },
      onLongPressEnd: (LongPressEndDetails details) {
        _timeIncrementTimer?.cancel();
      },
      child: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints.tight(const Size(34, 34)),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: THEME.inputBorder()),
          borderRadius: BorderRadius.circular(2),
        ),
        child: SvgPicture.asset('assets/svg/$iconName.svg', width: 8, colorFilter: THEME.onBackground().asFilter),
      ),
    );
  }

  bool get _isTPEnabled => _takeProfit >= 0;
  bool get _isSLEnabled => _stopLoss >= 0 && !_isTSEnabled;
  bool get _isTSEnabled => _trailingStop >= 0;
  DateTime get _defaultGTDValue {
    return DateTime.now().add(const Duration(hours: 1)).updateTime(seconds: 0, milliseconds: 0, microseconds: 0);
  }

  int _margin(int volume) => ((_isBuy ? _marginBuy : _marginSell) * volume).round();

  double _expextedLoss(SymbolData symbol) {
    if (_trailingStop.isNegative) {
      final int? rate = _whenRateIs < 0 ? (_isBuy ? symbol.ask : symbol.bid) : _whenRateIs;
      final int slRateDist = ((rate ?? _stopLoss) - _stopLoss).abs();
      return SymbolData.humanicRateFromSystem(slRateDist) * _tradingAmount / 100;
    } else {
      return SymbolData.humanicRateFromSystem(_trailingStop) * _tradingAmount / 100;
    }
  }

  bool _isAmountPlusBtnDisabled(SymbolDetailsData? details) {
    return details == null || details.data.maxVolume <= _tradingAmount || _margin(_tradingAmount + details.data.stepVolume) > details.symbol.trader.freeMargin;
  }

  bool _isTPMinusBtnDisabled(SymbolData? symbol) {
    if (symbol == null || symbol.details == null) return true;

    final int direction = _isBuy ? 1 : -1;
    final int rate = _whenRateIs < 0 ? (_isBuy ? symbol.ask : symbol.bid) ?? 0 : _whenRateIs;
    final int correctionRate = (rate + direction * symbol.takeProfitDisatance).toInt();

    return (_isBuy && _takeProfit <= correctionRate) || (!_isBuy && _takeProfit <= (symbol.pipSize ?? 0));
  }

  bool _isTPPlusBtnDisabled(SymbolData? symbol) {
    if (symbol == null || symbol.details == null) return true;

    final int direction = _isBuy ? 1 : -1;
    final int rate = _whenRateIs < 0 ? (_isBuy ? symbol.ask : symbol.bid) ?? 0 : _whenRateIs;
    final int correctionRate = (rate + direction * symbol.takeProfitDisatance).toInt();

    return !_isBuy && _takeProfit >= correctionRate;
  }

  bool _isSLMinusBtnDisabled(SymbolData? symbol) {
    if (symbol == null || symbol.details == null) return true;

    final int direction = _isBuy ? -1 : 1;
    final int rate = _whenRateIs < 0 ? (_isBuy ? symbol.bid : symbol.ask) ?? 0 : _whenRateIs;
    final int distance = symbol.stopLossDistance + (_whenRateIs > 0 ? symbol.spread : 0);
    final int correctionRate = (rate + direction * distance).toInt();

    return (_isBuy && _stopLoss <= (symbol.pipSize ?? 0)) || (!_isBuy && _stopLoss <= correctionRate);
  }

  bool _isSLPlusBtnDisabled(SymbolData? symbol) {
    if (symbol == null || symbol.details == null) return true;

    final int direction = _isBuy ? -1 : 1;
    final int rate = _whenRateIs < 0 ? (_isBuy ? symbol.bid : symbol.ask) ?? 0 : _whenRateIs;
    final int distance = symbol.stopLossDistance + (_whenRateIs > 0 ? symbol.spread : 0);
    final int correctionRate = (rate + direction * distance).toInt();

    return _isBuy && _stopLoss >= correctionRate;
  }

  bool _isTSMinusBtnDisabled(SymbolData? symbol) {
    if (symbol == null || symbol.details == null) return true;

    return _trailingStop <= max(symbol.stopLossDistance, 5 * (symbol.pipSize ?? 1)) + symbol.spread;
  }

  bool _isTSPlusBtnDisabled(SymbolData? symbol) {
    if (symbol == null || symbol.details == null) return true;

    return symbol.bid != null && _trailingStop >= symbol.bid!;
  }

  Future<void> _updateExpactedMargin() async {
    final TraderData trader = GetIt.I<UserState>().selectedTrader;
    final SymbolData? symbol = trader.tree.symbol(widget.symbolId);

    if (symbol == null) return;
    if (symbol.details == null) await symbol.getDetailsData();

    if (!trader.isLimitedRisk || trader.limitedRiskMarginCalculationStrategy == ProtoOALimitedRiskMarginCalculationStrategy.accordingToLeverage) {
      final RemoteApi remoteApi = trader.remoteApi;
      final ProtoOAExpectedMarginRes marginResp = await remoteApi.sendExpectedMargin(
        symbol.trader.id,
        symbol.id,
        <int>[symbol.details!.data.minVolume],
      );

      final ProtoOAExpectedMargin margin = marginResp.margin.first;
      _marginBuy = margin.buyMargin / margin.volume;
      _marginSell = margin.sellMargin / margin.volume;
    } else {
      _expMarginConvertRate = await symbol.quoteAsset?.getConversionRateToAsset(trader.currencyId) ?? 1;

      if (trader.limitedRiskMarginCalculationStrategy == ProtoOALimitedRiskMarginCalculationStrategy.accordingToGsl) {
        _marginBuy = _marginSell = -1;
      } else {
        final ProtoOAExpectedMarginRes marginResp = await trader.remoteApi.sendExpectedMargin(
          symbol.trader.id,
          symbol.id,
          <int>[symbol.details!.data.minVolume],
        );

        final ProtoOAExpectedMargin margin = marginResp.margin.first;
        _marginBuy = margin.buyMargin / margin.volume;
        _marginSell = margin.sellMargin / margin.volume;

        final double expectedLoss = _expextedLoss(symbol);
        final double serverCalcs = trader.currencyAsset!.humanicValue(_margin(_tradingAmount));
        final double localCalcs = _expMarginConvertRate * expectedLoss;

        if (serverCalcs < localCalcs) _marginBuy = _marginSell = -1;
      }
    }
  }

  void _onAmountChanged(double value) {
    int amount = SymbolData.systemVolume(value);

    final SymbolData? symbol = GetIt.I<UserState>().selectedTrader.tree.symbol(widget.symbolId);
    if (symbol != null && symbol.details != null) {
      final int stepVolume = symbol.details!.data.stepVolume;
      amount = amount ~/ stepVolume * stepVolume;
    }

    _tradingAmount = amount;
    _correctTradingAmount();

    setState(() {});
  }

  void _onToggleWhenRateIs(bool enable) {
    final SymbolData? symbol = GetIt.I<UserState>().selectedTrader.tree.symbol(widget.symbolId);
    if (symbol == null) return;

    if (enable && ((_isBuy && symbol.ask != null) || (!_isBuy && symbol.bid != null))) {
      _whenRateIs = (_isBuy ? symbol.ask! * 1.001 : symbol.bid! * 0.999).round();
      if (symbol.details != null) {
        final int multiplier = pow(10, 5 - symbol.details!.data.digits).toInt();
        _whenRateIs = (_whenRateIs / multiplier).round() * multiplier;
      }
    } else {
      _whenRateIs = -1;
    }
    setState(() {});
  }

  void _onChangeLimitRate(SymbolData? symbol, double value) {
    _whenRateIs = SymbolData.systemRateFromHumanic(value);

    _correctLimitRate();
    _correctTPRate();
    _correcntSLRate();
    _correctTSValue();

    setState(() {});
  }

  void _toggleDateTimeSection() {
    _gtdDateTime ??= _defaultGTDValue;

    setState(() => _dateTimePicker = !_dateTimePicker);
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

  void _incrementTime(int minutes) {
    if (_gtdDateTime != null) {
      _gtdDateTime = _gtdDateTime!.add(Duration(minutes: minutes));
      _correctGTDDate();
      setState(() {});
    }
  }

  void _onToggleTP(bool enable) {
    if (enable) {
      final int? cached = _cachedData['takeProfit'] as int?;
      if (cached != null) {
        _takeProfit = cached;
        _correctTPRate();
      } else {
        final SymbolData? symbol = GetIt.I<UserState>().selectedTrader.tree.symbol(widget.symbolId);
        final ProtoOASymbol? details = symbol?.details?.data;

        if (symbol == null || details == null) return;

        final int direction = _isBuy ? 1 : -1;
        final int rate = _whenRateIs < 0 ? (_isBuy ? symbol.ask : symbol.bid) ?? 0 : _whenRateIs;
        _takeProfit = (rate + direction * symbol.takeProfitDisatance * 2).toInt();
      }
    } else {
      _takeProfit = -1;
    }

    setState(() {});
  }

  void _onChangeTP(double tp) {
    _takeProfit = SymbolData.systemRateFromHumanic(tp);

    _correctTPRate();
    setState(() {});
  }

  void _onToggleSL(bool enable) {
    if (enable) {
      _trailingStop = -1;

      final int? cached = _cachedData['stopLoss'] as int?;
      if (cached != null) {
        _stopLoss = cached;
        _correcntSLRate();
      } else {
        final SymbolData? symbol = GetIt.I<UserState>().selectedTrader.tree.symbol(widget.symbolId);
        final ProtoOASymbol? details = symbol?.details?.data;

        if (symbol == null || details == null) return;

        final int direction = _isBuy ? -1 : 1;
        final int rate = _whenRateIs < 0 ? (_isBuy ? symbol.bid : symbol.ask) ?? 0 : _whenRateIs;
        _stopLoss = (rate + direction * symbol.stopLossDistance * 2).toInt();
        if (_whenRateIs > 0) _stopLoss += direction * symbol.spread;
      }
    } else {
      _stopLoss = -1;
    }

    setState(() {});
  }

  void _onChangeSL(double sl) {
    _stopLoss = SymbolData.systemRateFromHumanic(sl);

    _correcntSLRate();
    setState(() {});
  }

  void _onToggleTS(bool enable) {
    if (enable) {
      _stopLoss = -1;

      final int? cached = _cachedData['trailingStop'] as int?;
      if (cached != null) {
        _trailingStop = cached;
      } else {
        final SymbolData? symbol = GetIt.I<UserState>().selectedTrader.tree.symbol(widget.symbolId);
        final ProtoOASymbol? details = symbol?.details?.data;

        if (symbol == null || details == null) return;

        _trailingStop = symbol.stopLossDistance * 2;
      }
      _correctTSValue();
    } else {
      _trailingStop = -1;

      if (GetIt.I<UserState>().selectedTrader.isLimitedRisk) _onToggleSL(true);
    }

    setState(() {});
  }

  void _onChangeTS(double ts) {
    final SymbolData? symbol = GetIt.I<UserState>().selectedTrader.tree.symbol(widget.symbolId);
    final int decimals = 5 - (symbol?.details?.data.pipPosition ?? 0);

    if ((symbol?.details?.data.pipPosition ?? 0) > 1) ts = (ts * 10).round() / 10;

    _trailingStop = (ts * pow(10, decimals)).round();

    setState(() => _correctTSValue());
  }

  void _correctTradingAmount() {
    final UserState userState = GetIt.I<UserState>();
    final ProtoOASymbol? details = userState.selectedTrader.tree.symbol(widget.symbolId)?.details?.data;

    if (details == null) return;

    final int freeMargin = userState.selectedTrader.freeMargin;
    _tradingAmount = max(_tradingAmount, details.minVolume);
    if (_margin(_tradingAmount) > freeMargin) {
      if (details.minVolume < _tradingAmount) {
        int step = 0;
        while (_margin(_tradingAmount - step * details.stepVolume) > freeMargin) {
          step++;
        }
        _tradingAmount = max(_tradingAmount - step * details.stepVolume, details.minVolume);
      }
    }
  }

  void _correctLimitRate() {
    if (_whenRateIs > 0) {
      final SymbolData? symbol = GetIt.I<UserState>().selectedTrader.tree.symbol(widget.symbolId);
      if (symbol == null || symbol.details == null) return;

      final int? rate = _isBuy ? symbol.ask : symbol.bid;
      _whenRateIs = symbol.details!.cutOffExtraDigitsFromRate(_whenRateIs, _whenRateIs < (rate ?? 0));

      if (rate == null) return;

      if (symbol.trader.isLimitedRisk && _whenRateIs <= symbol.stopLossDistance + symbol.spread + symbol.pipSize!) {
        _whenRateIs = symbol.stopLossDistance + symbol.spread + symbol.pipSize!;
      } else if (_whenRateIs == rate) {
        _whenRateIs += (_isBuy ? 1 : -1) * pow(10, 5 - symbol.details!.data.digits).toInt();
      }
    }
  }

  void _correctGTDDate() {
    if (_dateTimePicker) {
      _gtdDateTime ??= _defaultGTDValue;
      final Duration diff = _gtdDateTime!.difference(DateTime.now());
      if (diff.inMinutes < 2) {
        _gtdDateTime = DateTime.now().add(const Duration(minutes: 3)).updateTime(seconds: 0, milliseconds: 0, microseconds: 0);
      }
    }
  }

  void _correctTPRate() {
    if (!_isTPEnabled) return;

    final SymbolData? symbol = GetIt.I<UserState>().selectedTrader.tree.symbol(widget.symbolId);
    final ProtoOASymbol? details = symbol?.details?.data;

    if (symbol == null || details == null) return;

    _takeProfit = max(symbol.details!.cutOffExtraDigitsFromRate(_takeProfit, !_isBuy), symbol.pipSize!);

    final int direction = _isBuy ? 1 : -1;
    final int rate = _whenRateIs < 0 ? (_isBuy ? symbol.ask : symbol.bid) ?? 0 : _whenRateIs;
    final int correctionRate = (rate + direction * symbol.takeProfitDisatance).toInt();

    if (_isBuy && _takeProfit < correctionRate) {
      _takeProfit = correctionRate;
    } else if (!_isBuy && _takeProfit > correctionRate) {
      _takeProfit = correctionRate;
    }
    _cachedData['takeProfit'] = _takeProfit;
  }

  void _correcntSLRate() {
    if (!_isSLEnabled) return;

    final SymbolData? symbol = GetIt.I<UserState>().selectedTrader.tree.symbol(widget.symbolId);
    final ProtoOASymbol? details = symbol?.details?.data;

    if (symbol == null || details == null) return;

    _stopLoss = max(symbol.details!.cutOffExtraDigitsFromRate(_stopLoss, _isBuy), symbol.pipSize!);

    final int direction = _isBuy ? -1 : 1;
    final int rate = _whenRateIs < 0 ? (_isBuy ? symbol.bid : symbol.ask) ?? 0 : _whenRateIs;
    final int distance = symbol.stopLossDistance + (_whenRateIs >= 0 ? symbol.spread : 0);
    final int correctionRate = (rate + direction * distance).toInt();

    if (_isBuy && _stopLoss > correctionRate) {
      _stopLoss = correctionRate;
    } else if (!_isBuy && _stopLoss < correctionRate) {
      _stopLoss = correctionRate;
    }

    _cachedData['stopLoss'] = _stopLoss;
  }

  void _correctTSValue() {
    if (_trailingStop < 0) return;

    final SymbolData? symbol = GetIt.I<UserState>().selectedTrader.tree.symbol(widget.symbolId);
    final ProtoOASymbol? details = symbol?.details?.data;

    if (symbol == null || details == null) return;

    final int distance = symbol.stopLossDistance + symbol.spread;
    _trailingStop = max(max(distance, 5 * (symbol.pipSize ?? 10)), _trailingStop);
    if (symbol.bid != null) _trailingStop = min(_trailingStop, symbol.bid!);

    _cachedData['trailingStop'] = _trailingStop;
  }

  void _onTapActionButton() {
    final SimultaneousTrdaingState simultaneousState = GetIt.I<SimultaneousTrdaingState>();
    final UserState userState = GetIt.I<UserState>();
    final TraderData trader = userState.selectedTrader;
    if (trader.accessRights.index >= ProtoOAAccessRights.closeOnly.index) {
      GetIt.I<PopupManager>().showTraderSelection(AppLocalizations.of(context)!, trader, false);
      return;
    }

    final SymbolData? symbol = userState.selectedTrader.tree.symbol(widget.symbolId);
    if (symbol == null) {
      Logger.log(() => "Can't get symbol data to send request");
      GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
      return;
    }

    if (simultaneousState.isAccountPaired(userState.selectedTraderId)) {
      _openActivityForSimultaneousTrading(userState, simultaneousState, trader, symbol);
    } else {
      _openActivityForSingleAccount(userState, symbol);
    }
  }

  Future<void> _openActivityForSimultaneousTrading(
    UserState userState,
    SimultaneousTrdaingState simultaneousState,
    TraderData trader,
    SymbolData symbol,
  ) async {
    final SymbolDetailsData? symbolDetails = symbol.details;
    final PopupResult result = await GetIt.I<PopupManager>().askToOpenSimultaneousPosition(
      AppLocalizations.of(context)!,
      _whenRateIs <= 0,
      _isBuy,
      symbol.name,
    );

    if (!result.agree) return;
    if (result.payload['all'] != true) return _openActivityForSingleAccount(userState, symbol);

    final Map<int, Iterable<SymbolData>> pairedSymbols = <int, Iterable<SymbolData>>{};
    pairedSymbols[trader.id] = <SymbolData>[symbol];
    for (final int traderId in simultaneousState.pariedAccounts) {
      if (traderId == trader.id) continue;

      final TraderData? pairedTrader = userState.trader(traderId);
      pairedSymbols[traderId] = pairedTrader?.tree.findSymbolForSimultaneousTrading(name: symbol.name) ?? <SymbolData>[];
    }

    final List<int> notPairedAccounts = <int>[];
    for (final int traderId in pairedSymbols.keys) {
      if (pairedSymbols[traderId] == null || pairedSymbols[traderId]!.isEmpty) notPairedAccounts.add(traderId);
    }

    if (notPairedAccounts.isNotEmpty) {
      GetIt.I<PopupManager>().showSimultaneousSymbolPairNotFound(AppLocalizations.of(context)!, symbol.name, notPairedAccounts);
      pairedSymbols.removeWhere((int key, Iterable<SymbolData> value) => notPairedAccounts.contains(key));
    }

    GetIt.I<AppState>().setUIBlocked(true);
    final bool isLimit = _isBuy ? symbol.ask! > _whenRateIs : symbol.bid! < _whenRateIs;
    final int? ask = symbol.ask;
    final int? bid = symbol.bid;
    final int tradingAmount = _tradingAmount;
    final Map<int, int> pairedActivities = <int, int>{};
    for (final int traderId in pairedSymbols.keys) {
      final TraderData trader = userState.trader(traderId)!;
      final Iterable<SymbolData> symbols = pairedSymbols[traderId]!;
      bool success = false;

      for (final SymbolData symbol in symbols) {
        try {
          pairedActivities[trader.id] = await (_whenRateIs < 0
              ? _openPosition(trader, symbol, symbolDetails, tradingAmount, ask: ask, bid: bid, noErrorPopup: true)
              : _openOrder(trader, symbol, symbolDetails, isLimit, noErrorPopup: true));
          success = true;
          break;
        } catch (err) {
          Logger.error('Error occurred at opening new activity: ${err.runtimeType}("$err")');
          if (err is InternalApplicationError && err.code == InternalApplicationErrorCodes.SYMBOL_NOT_INITIALIZED) {
            GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
          }
        }
      }

      if (!success) GetIt.I<PopupManager>().showSimultaneousExecutionFaildPopup(AppLocalizations.of(context)!, trader.name, symbol.name);
    }

    if (pairedActivities.length > 1) {
      if (_whenRateIs < 0) {
        simultaneousState.pairPositions(pairedActivities);
      } else {
        simultaneousState.pairOrders(pairedActivities);
      }
    }

    GetIt.I<AppState>().setUIBlocked(false);
    Navigator.pop(context);
  }

  Future<void> _openActivityForSingleAccount(UserState userState, SymbolData symbol) async {
    GetIt.I<AppState>().setUIBlocked(true);

    try {
      if (_whenRateIs < 0) {
        await _openPosition(userState.selectedTrader, symbol, symbol.details, _tradingAmount);
      } else {
        await _openOrder(userState.selectedTrader, symbol, symbol.details, _isBuy ? symbol.ask! > _whenRateIs : symbol.bid! < _whenRateIs);
      }

      Navigator.pop(context);
    } catch (err) {
      Logger.error('Error occurred at opening new activity: ${err.runtimeType}("$err")');
      if (err is InternalApplicationError && err.code == InternalApplicationErrorCodes.SYMBOL_NOT_INITIALIZED) {
        GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
      }
    }

    GetIt.I<AppState>().setUIBlocked(false);
  }

  Future<int> _openOrder(TraderData trader, SymbolData symbol, SymbolDetailsData? symbolDetails, bool isLimit, {bool noErrorPopup = false}) async {
    final RemoteApi remoteAPI = trader.remoteApi;

    try {
      final ProtoOAExecutionEvent resp = await _handleRequestAndValidate(
        trader,
        symbol,
        remoteAPI.sendNewOrderForOrder(
          trader.id,
          symbol.id,
          _isBuy,
          _tradingAmount,
          isLimit,
          SymbolData.humanicRateFromSystem(_whenRateIs),
          takeProfit: _isTPEnabled ? (_takeProfit - _whenRateIs).abs() : null,
          trailingStop: _isTSEnabled,
          stopLoss: _isTSEnabled ? _trailingStop : (_isSLEnabled ? (_stopLoss - _whenRateIs).abs() : null),
          expirationTimestamp: _gtdDateTime?.millisecondsSinceEpoch,
          guaranteedStopLoss: trader.isLimitedRisk,
        ),
        noError: noErrorPopup,
      );

      final UserState userState = GetIt.I<UserState>();
      userState.saveSymbolVolume(traderId: userState.selectedTraderId, symbolId: symbol.id, volume: _tradingAmount);

      if (_isTSEnabled) GetIt.I<UserState>().trailingStopValues.updateForOrder(trader.id, resp.order!.orderId, _trailingStop);

      GetIt.I<PopupManager>().showPendingOrderWasCreated(AppLocalizations.of(context)!, resp, symbolDetails: symbolDetails);

      return resp.order!.orderId;
    } on InternalApplicationError {
      rethrow;
    } catch (err) {
      Logger.error('Error occurred for new order for trader(${trader.id}) with symbol(${symbol.id}): (${err.runtimeType}) $err');
      GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
      throw 'Error occured for new order execution for trader(${trader.id}) with symbol(${symbol.id})';
    }
  }

  Future<int> _openPosition(
    TraderData trader,
    SymbolData symbol,
    SymbolDetailsData? symbolDetails,
    int tradingAmount, {
    int? ask,
    int? bid,
    bool noErrorPopup = false,
  }) async {
    final int? rate = _isBuy ? (ask ?? symbol.ask) : (symbol.bid ?? bid);
    final RemoteApi remoteAPI = trader.remoteApi;

    throwIf(rate == null, InternalApplicationError(InternalApplicationErrorCodes.SYMBOL_NOT_INITIALIZED, 'Symbol rate is not initialized'));

    try {
      ProtoOAExecutionEvent resp = await _handleRequestAndValidate(
        trader,
        symbol,
        remoteAPI.sendNewOrderForPosition(
          trader.id,
          symbol.id,
          _isBuy,
          tradingAmount,
          takeProfit: _isTPEnabled ? (_takeProfit - rate!).abs() : null,
          trailingStop: _isTSEnabled,
          stopLoss: _isTSEnabled ? _trailingStop : (_isSLEnabled ? (_stopLoss - rate!).abs() : null),
          guaranteedStopLoss: trader.isLimitedRisk,
        ),
        noError: noErrorPopup,
      );

      final PositionData? position = trader.positionsManager.activityBy(id: resp.position?.positionId);
      final bool posHadSLTP = position?.takeProfit != null || position?.stopLoss != null;

      final UserState userState = GetIt.I<UserState>();
      userState.saveSymbolVolume(traderId: userState.selectedTraderId, symbolId: symbol.id, volume: tradingAmount);

      // waiting for order with execution type orderFilled
      resp = await _handleRequestAndValidate(trader, symbol, remoteAPI.waitForResponse(resp.cmdId!), noError: noErrorPopup);

      if (resp.position!.tradeData.volume == 0) {
        // opened previously position is closed on NETTING account by opening similar positions with opposit direction
        // closing popup is showing in main handler of ProtoOAExecutionEvent

        // clear cached data of trailing stop value for closed position
        userState.trailingStopValues.clearFromPosition(trader.id, resp.position!.positionId);
      } else {
        // update cached trailing stop values
        if (_isTSEnabled) {
          userState.trailingStopValues.updateForPosition(trader.id, resp.position!.positionId, _trailingStop);
        } else {
          userState.trailingStopValues.clearFromPosition(trader.id, resp.position!.positionId);
        }

        final bool isPostionDecrease = resp.position!.tradeData.tradeSide != resp.order!.tradeData.tradeSide;
        final bool isPositionReversed = !isPostionDecrease && resp.position!.tradeData.volume < resp.order!.executedVolume!;
        final bool isSLTPEndabled = _isTPEnabled || _isSLEnabled || _isTSEnabled;
        bool sltpError = false;

        if (posHadSLTP && isPositionReversed) {
          // position is reversed, need to wait for cancel sltp execution event
          try {
            final ProtoMessage cancelSLTP = await remoteAPI.waitForResponse(resp.cmdId!);
            if (cancelSLTP is! ProtoOAExecutionEvent ||
                cancelSLTP.order!.orderType != ProtoOAOrderType.stopLossTakeProfit ||
                cancelSLTP.executionType != ProtoOAExecutionType.orderCancelled) {
              _validateOpenActivityResponseForSuccess(resp, trader, symbol, noError: noErrorPopup);
              sltpError = true;
            } else {
              resp.position = cancelSLTP.position;
            }
          } catch (err) {
            Logger.error('Some error occurred when reversing an position and waited for sltp cancel event of previous order', err);
            sltpError = true;
          }
        }

        if (isPostionDecrease && isSLTPEndabled && !posHadSLTP) {
          // no need to wait for sltp event
        } else if ((isPositionReversed && isSLTPEndabled) || (!isPositionReversed && (posHadSLTP || isSLTPEndabled))) {
          // wait for sltp replaced || accepted
          try {
            final ProtoMessage sltpResp = await remoteAPI.waitForResponse(resp.cmdId!);
            if (sltpResp is! ProtoOAExecutionEvent ||
                sltpResp.order!.orderType != ProtoOAOrderType.stopLossTakeProfit ||
                (sltpResp.executionType != ProtoOAExecutionType.orderAccepted && sltpResp.executionType != ProtoOAExecutionType.orderReplaced)) {
              _validateOpenActivityResponseForSuccess(resp, trader, symbol, noError: noErrorPopup);
              sltpError = true;
            } else {
              resp.position = sltpResp.position;
            }
          } catch (err) {
            Logger.error('Error occurred for sltpOrder of position ${err.runtimeType}($err)');
            sltpError = true;
          }
        }

        GetIt.I<PopupManager>().handleNewPositionOpenedEvent(AppLocalizations.of(context)!, resp, symbolDetails: symbolDetails, sltpError: sltpError);
      }

      return resp.position!.positionId;
    } on InternalApplicationError {
      rethrow;
    } catch (err) {
      Logger.error('Error occurred for new position for trader(${trader.id}) with symbol(${symbol.id}): (${err.runtimeType}) $err');
      GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
      throw 'Error occured for new position execution for trader(${trader.id}) with symbol(${symbol.id})';
    }
  }

  Future<ProtoOAExecutionEvent> _handleRequestAndValidate(TraderData trader, SymbolData symbol, Future<ProtoMessage> future, {required bool noError}) async {
    try {
      final ProtoMessage resp = await future;
      _validateOpenActivityResponseForSuccess(resp, trader, symbol, noError: noError);

      return resp as ProtoOAExecutionEvent;
    } on InternalApplicationError {
      rethrow;
    } on ProtoOAErrorRes catch (err) {
      Logger.log(() => 'new order eroor for trader(${trader.id}) with symbol(${symbol.id}): ${err.errorCode}: ${err.description}');
      if (!noError) {
        final AppLocalizations l10n = AppLocalizations.of(context)!;
        GetIt.I<PopupManager>().showError(l10n, l10n.getServerErrorDescription(err.errorCode) ?? err.description ?? err.errorCode);
      }
      throw InternalApplicationError(
        InternalApplicationErrorCodes.SERVER_ERROR,
        'Server error for new order for ${trader.login}(${trader.id})=> ${symbol.name}(${symbol.id})',
      );
    } on Exception catch (exc) {
      Logger.error('Exception executed for new order for trader(${trader.id}) with symbol(${symbol.id}): (${exc.runtimeType}) $exc');
      if (!noError) GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
      throw InternalApplicationError(
        InternalApplicationErrorCodes.INTERNAL_ERROR,
        'Exception occured for new order execution ${trader.login}(${trader.id})=> ${symbol.name}(${symbol.id})',
      );
    } catch (err) {
      Logger.error('Error occurred for new order for trader(${trader.id}) with symbol(${symbol.id}): (${err.runtimeType}) $err');
      if (!noError) GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
      throw InternalApplicationError(
        InternalApplicationErrorCodes.INTERNAL_ERROR,
        'Error occured for new order execution for ${trader.login}(${trader.id})=> ${symbol.name}(${symbol.id})',
      );
    }
  }

  bool _validateOpenActivityResponseForSuccess(ProtoMessage resp, TraderData trader, SymbolData symbol, {required bool noError}) {
    final String type = _whenRateIs < 0 ? 'position' : 'order';

    if (resp is ProtoOAOrderErrorEvent) {
      Logger.log(() => 'Server error for new $type for trader(${trader.id}) with symbol(${symbol.id}): ${resp.errorCode}#${resp.description}');
      if (!noError) GetIt.I<PopupManager>().showNewOrderError(AppLocalizations.of(context)!, resp);
      throw InternalApplicationError(
        InternalApplicationErrorCodes.SERVER_ERROR,
        'Server error for ${trader.login}(${trader.id})=>${symbol.name}(${symbol.id}): #${resp.errorCode}:${resp.description}',
      );
    } else if (resp is ProtoOAExecutionEvent) {
      if (resp.errorCode != null) {
        Logger.log(() => 'Server error ${resp.errorCode} for new $type for trader(${trader.id}) with symbol (${symbol.id})');
        if (!noError) {
          final AppLocalizations l10n = AppLocalizations.of(context)!;
          GetIt.I<PopupManager>().showError(l10n, l10n.getServerErrorDescription(resp.errorCode!) ?? resp.errorCode!);
        }
        throw InternalApplicationError(
          InternalApplicationErrorCodes.SERVER_ERROR,
          'Server error for ${trader.login}(${trader.id})=>${symbol.name}(${symbol.id}): ${resp.errorCode}',
        );
      } else if (resp.executionType == ProtoOAExecutionType.orderRejected || resp.executionType == ProtoOAExecutionType.orderCancelled) {
        Logger.log(() => 'Server rejected or canceled new $type for trader(${trader.id}) with symbol(${symbol.id})');
        if (!noError) GetIt.I<PopupManager>().showOrderExecutionFaild(AppLocalizations.of(context)!, resp.order!.orderId);
        throw InternalApplicationError(
          InternalApplicationErrorCodes.SERVER_REJECTED,
          'Server ${resp.executionType.name} ${resp.order!.orderType.name}: ${trader.login}(${trader.id})=>${symbol.name}(${symbol.id})',
        );
      } else if (resp.executionType != ProtoOAExecutionType.orderAccepted &&
          resp.executionType != ProtoOAExecutionType.orderFilled &&
          resp.executionType != ProtoOAExecutionType.orderPartialFill) {
        Logger.error('Unhandeled state of response for new $type for trader(${trader.id}) with symbol(${symbol.id})');
        if (!noError) GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
        throw InternalApplicationError(
          InternalApplicationErrorCodes.UNHANDELED_STATE,
          'Unhandeled executionType(${resp.executionType.name}) for ${trader.login}(${trader.id})=>${symbol.name}(${symbol.id})',
        );
      } else {
        return true;
      }
    } else {
      Logger.error('Unhandled response type(${resp.runtimeType}) for new $type for trader(${trader.id}) with symbol(${symbol.id})');
      if (!noError) GetIt.I<PopupManager>().showSomeErrorOccurred(AppLocalizations.of(context)!);
      throw InternalApplicationError(
        InternalApplicationErrorCodes.UNHANDELED_STATE,
        'Unhandeled response type(${resp.runtimeType}) for ${trader.login}(${trader.id})=>${symbol.name}(${symbol.id})',
      );
    }
  }
}
