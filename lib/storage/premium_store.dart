import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'boxes.dart';

class PremiumStore extends ChangeNotifier {
  static const _kIsProCached = 'isProCached';
  static const _kLastCheck = 'premiumLastCheck';

  // Product IDs
  static const monthlyId = 'picksy_monthly';
  static const lifetimeId = 'picksy_lifetime';

  final InAppPurchase _iap = InAppPurchase.instance;

  bool _isAvailable = false;
  bool _isPro = false;

  // ✅ Start: nicht "true" festnageln, sonst kann UI hängen bleiben
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
  /// ✅ Important: UI should NOT depend on restorePurchases finishing.
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
      final ids = <String>{monthlyId, lifetimeId};
      final response = await _iap.queryProductDetails(ids);
      _products = response.productDetails;

      // ✅ Unblock UI now (even if restore takes long / "hangs")
      _isLoading = false;
      notifyListeners();

      // 🔁 Restore in background (do not await)
      unawaited(_iap.restorePurchases());
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

  Future<void> buyMonthly() async {
    final p = productById(monthlyId);
    if (p == null) return;

    final param = PurchaseParam(productDetails: p);

    // NOTE:
    // Subscriptions can work differently depending on Play Console + plugin version.
    // This might still work for you, but if monthly causes issues, keep Lifetime only.
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> buyLifetime() async {
    final p = productById(lifetimeId);
    if (p == null) return;

    final param = PurchaseParam(productDetails: p);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() async {
    // ✅ Keep it simple
    await refresh();
  }

  Future<void> _onPurchasesUpdated(List<PurchaseDetails> purchases) async {
    // ✅ Crucial: never wipe cached Pro if stream is empty
    if (purchases.isEmpty) return;

    bool foundOwned = false;

    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.error) {
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == monthlyId ||
            purchase.productID == lifetimeId) {
          foundOwned = true;
        }
      }

      // IMPORTANT: complete purchases on iOS (and sometimes Android)
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }

    // ✅ Only set true if we actually saw ownership
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
