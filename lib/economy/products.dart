/// RevenueCat product & entitlement identifiers.
/// See goro-spec.md §3.3 / §4. Diegetic monetization: each site tool is a
/// physical intervention in the physics sim, sold as a RevenueCat product.
library;

/// Consumable "site tools" — each maps to a physics effect (see tools.dart).
class ProductIds {
  ProductIds._();

  // Consumables
  static const steadyingCable = 'tool_steadying_cable';
  static const quickDryCement = 'tool_quick_dry_cement';
  static const counterweight = 'tool_counterweight';
  static const safetyNet = 'tool_safety_net'; // the revive / money beat

  // Subscription (entitlement)
  static const architectPass = 'architect_pass';

  // Non-consumable
  static const removeAds = 'remove_ads';
}

/// Entitlement identifiers configured in the RevenueCat dashboard.
class EntitlementIds {
  EntitlementIds._();
  static const architect = 'architect'; // unlocks skins, expeditions, discounts
  static const adsRemoved = 'ads_removed';
}

/// The offering identifier the paywall reads from.
const kDefaultOfferingId = 'default';
