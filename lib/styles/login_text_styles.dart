import 'package:flutter/material.dart';

const String _FAMILY = 'Arimo';

class LoginTextStyles {
  TextStyle heading = const TextStyle(fontFamily: _FAMILY, fontSize: 16, height: 22 / 16);
  TextStyle headingStrong = const TextStyle(fontFamily: _FAMILY, fontSize: 16, height: 22 / 16, fontWeight: FontWeight.bold);
  TextStyle headingSmall = const TextStyle(fontFamily: _FAMILY, fontSize: 14, height: 22 / 14);
  TextStyle headingSmallBold = const TextStyle(fontFamily: _FAMILY, fontSize: 14, height: 22 / 14, fontWeight: FontWeight.bold);

  TextStyle brokerButton = const TextStyle(fontFamily: _FAMILY, fontSize: 14, height: 22 / 14, fontWeight: FontWeight.w500);

  TextStyle banner = const TextStyle(fontFamily: _FAMILY, fontSize: 16, height: 1.05, fontWeight: FontWeight.w500);
  TextStyle bannerBold = const TextStyle(fontFamily: _FAMILY, fontSize: 16, height: 1.05, fontWeight: FontWeight.w700);
}
