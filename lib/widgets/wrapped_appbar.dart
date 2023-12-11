import 'package:ctrader_example_app/extensions.dart';
import 'package:ctrader_example_app/l10n/localizations.dart';
import 'package:ctrader_example_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WrappedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WrappedAppBar({super.key, required this.title, this.showBack});

  final String title;
  final bool? showBack;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leadingWidth: showBack == true ? 100 : kToolbarHeight,
      leading: showBack == true ? _backButton(context) : _menuButton(context),
      title: Text(title),
    );
  }

  Widget _menuButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Scaffold.of(context).openDrawer(),
      child: Center(
        child: SvgPicture.asset('assets/svg/burger.svg', colorFilter: THEME.onBackground().asFilter),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.transparent,
        child: Row(children: <Widget>[
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/svg/arrow_back.svg',
              width: 8,
              height: 16,
              colorFilter: THEME.onBackground().asFilter,
            ),
          ),
          Text(AppLocalizations.of(context)!.back, style: THEME.texts.bodyBold),
        ]),
      ),
    );
  }
}
