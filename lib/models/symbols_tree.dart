import 'package:ctrader_example_app/main.dart';
import 'package:ctrader_example_app/models/asset_data.dart';
import 'package:ctrader_example_app/models/symbol_data.dart';
import 'package:ctrader_example_app/models/trader_data.dart';
import 'package:ctrader_example_app/remote/proto.dart' as proto;

class SymbolsTree {
  SymbolsTree(this.trader);

  final TraderData trader;
  final Map<int, AssetClassData> _classes = <int, AssetClassData>{};
  final List<SymbolCategoryData> _categories = <SymbolCategoryData>[];
  final Map<int, SymbolData> _symbols = <int, SymbolData>{};
  final Map<int, AssetData> _assets = <int, AssetData>{};
  final Set<int> _favoriteIds = <int>{};
  final Map<int, List<proto.ProtoOADynamicLeverageTier>> _leverages = <int, List<proto.ProtoOADynamicLeverageTier>>{};
  final Set<int> _collapsedCategoris = <int>{};

  Iterable<AssetClassData> get assetClasses => _classes.values;

  AssetClassData? assetClass(int? id) => _classes.containsKey(id) ? _classes[id] : null;
  SymbolCategoryData? symbolCategory(int? id) {
    if (id != null && _categories.any((SymbolCategoryData cat) => cat.id == id)) {
      return _categories.firstWhere((SymbolCategoryData cat) => cat.id == id);
    } else {
      return null;
    }
  }

  SymbolData? symbol(int? id) => _symbols.containsKey(id) ? _symbols[id] : null;
  AssetData? asset(int? id) => _assets.containsKey(id) ? _assets[id] : null;
  Iterable<int> get favoriteSymbolIds => _favoriteIds;
  Iterable<SymbolData> get favoriteSymbols {
    final List<SymbolData> symbols = <SymbolData>[];

    for (final int id in _favoriteIds) {
      final SymbolData? symbol = this.symbol(id);
      if (symbol != null) symbols.add(symbol);
    }

    return symbols;
  }

  SymbolData? symbolByAssetPair(int firstAssetId, int secondAssetId) {
    for (final SymbolData symbol in _symbols.values) {
      if (symbol.baseAssetId == firstAssetId && symbol.quoteAssetId == secondAssetId) return symbol;
      if (symbol.baseAssetId == secondAssetId && symbol.quoteAssetId == firstAssetId) return symbol;
    }

    return null;
  }

  void handleAssetsResponse(List<proto.ProtoOAAsset> assets) {
    _assets.clear();
    for (final proto.ProtoOAAsset a in assets) {
      _assets[a.assetId] = AssetData.fromProto(this, a);
    }
  }

  void handleAssetClassResponse(List<proto.ProtoOAAssetClass> classes) {
    _classes.clear();
    for (final proto.ProtoOAAssetClass c in classes) {
      _classes[c.id] = AssetClassData.fromProto(this, c);
    }
  }

  void handleSymbolCategoryResponse(List<proto.ProtoOASymbolCategory> categories) {
    _categories.clear();

    categories.sort((proto.ProtoOASymbolCategory a, proto.ProtoOASymbolCategory b) {
      if (a.sortingNumber == null || b.sortingNumber == null) return 0;

      return a.sortingNumber!.compareTo(b.sortingNumber!);
    });

    for (final proto.ProtoOASymbolCategory c in categories) {
      final SymbolCategoryData category = SymbolCategoryData.fromProto(c);
      _categories.add(category);
      assetClass(c.assetClassId)?.addCategory(category);
    }
  }

  void handleSymbolsResponse(List<proto.ProtoOALightSymbol> symbols) {
    _symbols.clear();
    for (final proto.ProtoOALightSymbol s in symbols) {
      final SymbolCategoryData? category = symbolCategory(s.symbolCategoryId);
      if (category != null) {
        final SymbolData symbol = SymbolData.fromLight(category, s);
        _symbols[s.symbolId] = symbol;
        category.addSymbol(symbol);
      }
    }
  }

  void restoreFavoriteSymbols(Iterable<int> ids) {
    _favoriteIds.clear();
    _favoriteIds.addAll(ids);

    for (final int id in _favoriteIds) {
      symbol(id)?.isFavorite = true;
    }
  }

  void addFavoriteSymbol(int symbolId) {
    _symbols[symbolId]!.isFavorite = true;
    _favoriteIds.add(symbolId);
  }

  void removeFavoriteSymbol(int symbolId) {
    _favoriteIds.remove(symbolId);
    _symbols[symbolId]!.isFavorite = false;
  }

  bool isFavorite(int symbolId) => _favoriteIds.contains(symbolId);
  void toggleFavoriteSymbol(int symbolId) => isFavorite(symbolId) ? removeFavoriteSymbol(symbolId) : addFavoriteSymbol(symbolId);

  bool hasLeverage(int leverageId) => _leverages.containsKey(leverageId);
  void addLeverage(proto.ProtoOADynamicLeverage leverage) => _leverages[leverage.leverageId] = leverage.tiers;
  List<proto.ProtoOADynamicLeverageTier>? leveragesBy(int? id) => _leverages[id];

  Iterable<int> get collapsedCategories => _collapsedCategoris;
  bool isCategoryCollapsed(int? id) => _collapsedCategoris.contains(id);
  void collapseCategory(int? id) => id != null ? _collapsedCategoris.add(id) : null;
  void expandCategory(int? id) => id != null ? _collapsedCategoris.remove(id) : null;
  void toggleCategory(int? id) => isCategoryCollapsed(id) ? expandCategory(id) : collapseCategory(id);
  void restoreCollapsedCategories(Iterable<int> ids) => _collapsedCategoris.addAll(ids);

  Iterable<SymbolData> findSymbolForSimultaneousTrading({required String name}) {
    final Set<SymbolData> result = <SymbolData>{};
    for (final SymbolData symbol in _symbols.values) {
      if (symbol.name == name) result.add(symbol);
    }

    if (name.length > 5) {
      RegExp regExp = RegExp(r'^' + name.substring(0, 6) + r'$');
      for (final SymbolData symbol in _symbols.values) {
        if (regExp.hasMatch(symbol.name)) result.add(symbol);
      }

      regExp = RegExp(r'^' + name.substring(0, 3) + '/' + name.substring(3, 6) + r'$');
      for (final SymbolData symbol in _symbols.values) {
        if (regExp.hasMatch(symbol.name)) result.add(symbol);
      }

      regExp = RegExp(r'^' + name.substring(0, 6));
      for (final SymbolData symbol in _symbols.values) {
        if (regExp.hasMatch(symbol.name)) result.add(symbol);
      }
    }

    for (final List<String> item in SYMBOL_PAIRS) {
      name = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
      if (item.contains(name)) {
        for (final SymbolData symbol in _symbols.values) {
          final String nameToCheck = symbol.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
          if (item.contains(nameToCheck)) result.add(symbol);
        }
      }
    }

    return result;
  }
}

class AssetClassData {
  AssetClassData(this.tree, this.id, this.name);
  AssetClassData.fromProto(this.tree, proto.ProtoOAAssetClass assetClass)
      : id = assetClass.id,
        name = assetClass.name ?? 'NO_NAME';

  final SymbolsTree tree;
  final int id;
  final String name;
  final List<SymbolCategoryData> categories = <SymbolCategoryData>[];

  void addCategory(SymbolCategoryData category) {
    category.assetClass = this;
    categories.add(category);
  }

  TraderData get trader => tree.trader;
  bool get hasSymbols => categories.any((SymbolCategoryData c) => c.hasSymbols);
  bool get hasEnabledSymbols => categories.any((SymbolCategoryData c) => c.hasEnabledSymbols);
  List<SymbolData> get symbols => categories.fold(<SymbolData>[], (List<SymbolData> prev, SymbolCategoryData cat) {
        prev.addAll(cat.symbols);
        return prev;
      });
}

class SymbolCategoryData {
  SymbolCategoryData(this.id, this.name, this.assetClass);
  SymbolCategoryData.fromProto(proto.ProtoOASymbolCategory category)
      : id = category.id,
        name = category.name;

  final int id;
  final String name;
  late AssetClassData assetClass;
  final List<SymbolData> symbols = <SymbolData>[];

  SymbolsTree get tree => assetClass.tree;
  TraderData get trader => assetClass.trader;
  bool get isCollapsed => tree.isCategoryCollapsed(id);

  bool get hasSymbols => symbols.isNotEmpty;
  bool get hasEnabledSymbols => symbols.any((SymbolData s) => s.enabled);
  void addSymbol(SymbolData symbol) {
    symbols.add(symbol);
  }
}
