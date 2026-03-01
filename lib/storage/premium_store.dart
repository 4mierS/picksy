import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'boxes.dart';

class PremiumStore extends ChangeNotifier {
  static const _kIsProCached = 'isProCached';
  static const _kLastCheck = 'premiumLastCheck';

  // Product IDs
  // static const monthlyId = 'picksy_monthly';
  static const lifetimeId = 'picksy_lifetime';

  final InAppPurchase _iap = InAppPurchase.instance;

  bool _isAvailable = false;
  bool _isPro = false;

  bool _isLoading = false;

  bool get isAvailable => _isAvailable;
  bool get isPro => _isPro;
  bool get isLoading => _isLoading;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => List.unmodifiable(_products);

  StreamSubscription<List<PurchaseDetails>>? _sub;

  PremiumStore() {
    _boot();
  }

  Future<void> _boot() async {
    // Load cached state immediately (fast UX)
    _loadCached();

    // Start listening to purchase updates
    _sub = _iap.purchaseStream.listen(
      _onPurchasesUpdated,
      onDone: () => _sub?.cancel(),
      onError: (_) {
        // optional: log in debug only
      },
    );

    // Init IAP (does not block Pro usage)
    await refresh();
  }

  void _loadCached() {
    final box = Boxes.box(Boxes.settings);
    _isPro = box.get(_kIsProCached, defaultValue: false) as bool;
    notifyListeners();
  }

  Future<void> _setCachedPro(bool value) async {
    _isPro = value;
    await Boxes.box(Boxes.settings).put(_kIsProCached, value);
    await Boxes.box(
      Boxes.settings,
    ).put(_kLastCheck, DateTime.now().toIso8601String());
    notifyListeners();
  }

  /// Call this on app start and from "Restore purchases".
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isAvailable = await _iap.isAvailable();
      if (!_isAvailable) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Query product details
      final ids = <String>{lifetimeId};
      final response = await _iap.queryProductDetails(ids);
      _products = response.productDetails;

      if (kDebugMode) {
        debugPrint('IAP notFoundIDs: ${response.notFoundIDs}');
        for (final p in _products) {
          debugPrint(
            'IAP product: id=${p.id} price=${p.price} title=${p.title}',
          );
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }

  ProductDetails? productById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // Future<void> buyMonthly() async {
  //   final p = productById(monthlyId);
  //   if (p == null) return;

  //   final param = PurchaseParam(productDetails: p);

  //   // NOTE:
  //   // Subscriptions can work differently depending on Play Console + plugin version.
  //   // This might still work for you, but if monthly causes issues, keep Lifetime only.
  //   await _iap.buyNonConsumable(purchaseParam: param);
  // }

  Future<void> buyLifetime() async {
    final p = productById(lifetimeId);
    if (p == null) return;

    final param = PurchaseParam(productDetails: p);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _iap.restorePurchases();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Debug-only: toggles Pro status without a real purchase.
  Future<void> toggleDebugPro() async {
    assert(() {
      return true;
    }(), 'toggleDebugPro must only be called in debug mode');
    if (!kDebugMode) return;
    await _setCachedPro(!_isPro);
  }

  Future<void> _onPurchasesUpdated(List<PurchaseDetails> purchases) async {
    if (purchases.isEmpty) return;

    bool foundOwned = false;

    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.error) {
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (
        //purchase.productID == monthlyId ||
        purchase.productID == lifetimeId) {
          foundOwned = true;
        }
      }

      // IMPORTANT: complete purchases on iOS (and sometimes Android)
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }

    if (foundOwned) {
      await _setCachedPro(true);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
