enum InternalApplicationErrorCodes {
  SYMBOL_NOT_INITIALIZED,
  SYMBOL_RATES_NOT_INITIALIZED,
  SERVER_ERROR,
  SERVER_REJECTED,
  UNHANDELED_STATE,
  INTERNAL_ERROR,
}

class InternalApplicationError extends Error {
  InternalApplicationError(this.code, this.description);

  InternalApplicationErrorCodes code;
  String description;

  @override
  String toString() => '#${code.name}: $description';
}
