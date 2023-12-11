import 'package:ctrader_example_app/l10n/localizations.dart';

extension AppLocalizationsExtention on AppLocalizations {
  String? getServerErrorDescription(String errorCode) => switch (errorCode.toUpperCase()) {
        'NO_QUOTES' => serverErrorNoQuotes,
        'NOT_ENOUGH_MONEY' => serverErrorNotEnoughMoney,
        'POSITION_LOCKED' => serverErrorPositionLocked,
        'TRADING_BAD_VOLUME' => serverErrorTradingBadVolume,
        'PROTECTION_IS_TOO_CLOSE_TO_MARKET' => serverErrorProtectionIsTooCloseToMarket,
        'TRADING_DISABLED' => serverErrorTradingDisabled,
        'UNABLE_TO_CANCEL_ORDER' => serverErrorUnableToCancelOrder,
        'UNABLE_TO_AMEND_ORDER' => serverErrorUnabkeToAmendOrder,
        _ => null,
      };
}
