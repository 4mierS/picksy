import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'boxes.dart';

class PremiumStore extends ChangeNotifier {
  static const _kIsProCached = 'isProCached';
  static const _kLastCheck = 'premiumLastCheck';

  // Product IDs
  static const monthlyId = 'random_builder_monthly';
  static const lifetimeId = 'random_builder_lifetime';

  final InAppPurchase _iap = InAppPurchase.instance;

  bool _isAvailable = false;
  bool _isPro = false;
  bool _isLoading = true;

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
      onError: (_) {},
    );

    // Init IAP
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

    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Query product details
    final ids = <String>{monthlyId, lifetimeId};
    final response = await _iap.queryProductDetails(ids);

    _products = response.productDetails;

    // Restore / query purchases:
    // On Android, queryPastPurchases is deprecated in newer flows; restorePurchases works across.
    await _iap.restorePurchases();

    _isLoading = false;
    notifyListeners();
  }

  ProductDetails? productById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> buyMonthly() async {
    final p = productById(monthlyId);
    if (p == null) return;

    final param = PurchaseParam(productDetails: p);
    // For subscriptions:
    await _iap.buyNonConsumable(purchaseParam: param);
    // NOTE: On Android subscriptions are usually handled via buyNonConsumable in plugin versions that abstract it,
    // but if you run into issues later, we’ll switch to buyConsumable/buyNonConsumable based on platform/product type.
  }

  Future<void> buyLifetime() async {
    final p = productById(lifetimeId);
    if (p == null) return;

    final param = PurchaseParam(productDetails: p);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() async {
    await refresh();
  }

  Future<void> _onPurchasesUpdated(List<PurchaseDetails> purchases) async {
    bool proNow = false;

    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.error) {
        continue;
      }

      // Treat purchased/restored as owned.
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == monthlyId ||
            purchase.productID == lifetimeId) {
          proNow = true;
        }
      }

      // IMPORTANT: complete purchases on iOS (and sometimes Android)
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }

    await _setCachedPro(proNow);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
