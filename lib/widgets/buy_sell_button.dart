import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:flutter/material.dart';

class BuySellButton extends StatefulWidget {
  const BuySellButton(this.isBuy, this.rate, this.onTap, {super.key, this.highlight});

  final bool isBuy;
  final String rate;
  final bool? highlight;
  final void Function(bool isBuy) onTap;

  @override
  State<BuySellButton> createState() => _BuySellButtonState();
}

class _BuySellButtonState extends State<BuySellButton> with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _animation;

  double? _rate;
  int _direction = 0;
  bool highlighted = false;
  Color _background = THEME.buySellBackground;
  Color _border = THEME.buySellBorder;
  Color _rateColor = THEME.onBackground();

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(_animController);
    _animation.addListener(() {
      setState(() {
        final Color regularBG = widget.highlight == true ? THEME.buySellSelectedBackground() : THEME.buySellBackground;
        final Color directionBG = _direction > 0 ? THEME.buySellUpBackground : THEME.buySellDownBackground;
        _background = Color.alphaBlend(
          directionBG.withAlpha((_animation.value * directionBG.alpha).toInt()),
          regularBG,
        );

        final Color directionBorder = _direction > 0 ? THEME.buySellUpBorder : THEME.buySellDownBorder;
        _border = Color.alphaBlend(
          directionBorder.withAlpha((directionBorder.alpha * _animation.value).toInt()),
          THEME.buySellBorder,
        );

        final Color directionRate = _direction > 0 ? THEME.green : THEME.red;
        _rateColor = Color.alphaBlend(
          directionRate.withAlpha((directionRate.alpha * _animation.value).toInt()),
          THEME.onBackground(),
        );
      });
    });
    highlighted = widget.highlight == true;
    _background = highlighted ? THEME.buySellSelectedBackground() : THEME.buySellBackground;
  }

  @override
  void dispose() {
    _animController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    final double? rate = double.tryParse(widget.rate.replaceAll(RegExp('[^0-9.]'), ''));
    if (rate != null && _rate == null) {
      _rate = rate;
    } else if (rate != null && rate != _rate) {
      _direction = rate > _rate! ? 1 : -1;
      _animController.reset();
      _animController.animateTo(1);
      _rate = rate;
    }

    if (highlighted != (widget.highlight == true)) {
      highlighted = widget.highlight == true;
      _background = highlighted ? THEME.buySellSelectedBackground() : THEME.buySellBackground;
    }

    return GestureDetector(
      onTap: () => widget.onTap(widget.isBuy),
      child: Container(
        constraints: const BoxConstraints.expand(height: 40),
        decoration: BoxDecoration(
          color: _background,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(widget.isBuy ? l10n.buy : l10n.sell, style: THEME.texts.bodyRegular.copyWith(height: 1)),
          Text(widget.rate, style: THEME.texts.headingSmall.copyWith(height: 1, color: _rateColor)),
        ]),
      ),
    );
  }
}
