/// Stripe configuration for the tennis app.
///
/// **Google Pay & Apple Pay:** When both [publishableKey] and [subscriptionBackendUrl]
/// are set, the subscription screen shows "Pay with Google Pay, Apple Pay or Card".
/// Stripe Payment Sheet displays the correct option per device (Google Pay on Android,
/// Apple Pay on iOS, card on all).
///
/// **Setup:**
/// 1. Get keys from https://dashboard.stripe.com/apikeys
/// 2. Create a backend POST endpoint that creates a PaymentIntent for 4999 cents (€49.99),
///    currency EUR, and returns JSON: { "clientSecret": "pi_xxx_secret_xxx" }
/// 3. Build with: flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_xxx --dart-define=SUBSCRIPTION_BACKEND_URL=https://your-api.com/create-payment
class StripeConfig {
  /// Your Stripe publishable key (pk_test_... or pk_live_...).
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  /// Backend URL that creates a PaymentIntent and returns { "clientSecret": "..." }.
  /// Backend: create PaymentIntent for 4999 cents EUR, return client_secret.
  static const String subscriptionBackendUrl = String.fromEnvironment(
    'SUBSCRIPTION_BACKEND_URL',
    defaultValue: '',
  );

  static bool get isConfigured => publishableKey.isNotEmpty;
  static bool get hasBackend => subscriptionBackendUrl.isNotEmpty;
}
