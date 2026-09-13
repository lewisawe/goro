import 'package:purchases_flutter/purchases_flutter.dart';

import 'products.dart';

/// Thin wrapper around the RevenueCat SDK (purchases_flutter).
/// See goro-spec.md §5.3 and the 2026 Flutter codelab:
/// https://revenuecat.github.io/codelabs/flutter.html
///
/// The Android API key lives in an untracked secrets file (gitignored).
/// Sandbox / test purchases are sufficient for Next Gen judging.
class PurchasesService {
  PurchasesService._();
  static final instance = PurchasesService._();

  bool _configured = false;

  /// Call once at startup with the RevenueCat Android API key.
  Future<void> configure(String androidApiKey) async {
    if (_configured) return;
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(androidApiKey));
    _configured = true;
  }

  /// Fetch the current offering (packages shown in the paywall).
  Future<Offering?> currentOffering() async {
    final offerings = await Purchases.getOfferings();
    return offerings.current ?? offerings.all[kDefaultOfferingId];
  }

  /// Purchase a package. Returns updated CustomerInfo on success.
  /// Throws PlatformException on failure (let the UI handle it).
  Future<CustomerInfo> buy(Package package) async {
    final result = await Purchases.purchasePackage(package);
    return result.customerInfo;
  }

  Future<CustomerInfo> restore() => Purchases.restorePurchases();

  /// True if the given entitlement is currently active.
  Future<bool> hasEntitlement(String entitlementId) async {
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.containsKey(entitlementId);
  }

  bool get isConfigured => _configured;
}
