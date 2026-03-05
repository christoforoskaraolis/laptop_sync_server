import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

import 'config/stripe_config.dart';
import 'models/user.dart';

/// Amount in cents for premium subscription (€49.99).
const int premiumAmountCents = 4999;

/// Result of attempting to pay for premium subscription.
enum PaymentResult { success, cancelled, failed, notConfigured }

/// Handles Stripe Payment Sheet for premium subscription.
/// Payment Sheet shows Google Pay, Apple Pay, and Card based on device.
class PaymentService {
  static bool _initialized = false;

  /// Call once at app startup (e.g. before showing subscription screen).
  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (!StripeConfig.isConfigured) return;
    Stripe.publishableKey = StripeConfig.publishableKey;
    Stripe.merchantIdentifier = 'TennisTournaments';
    await Stripe.instance.applySettings();
    _initialized = true;
  }

  /// Fetches PaymentIntent client secret from your backend.
  /// Backend should create a PaymentIntent for [premiumAmountCents] EUR and return { "clientSecret": "pi_xxx_secret_xxx" }.
  static Future<String?> _fetchClientSecretFromBackend() async {
    if (!StripeConfig.hasBackend) return null;
    try {
      final uri = Uri.parse(StripeConfig.subscriptionBackendUrl);
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': premiumAmountCents,
          'currency': 'eur',
        }),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      return data?['clientSecret'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Runs the payment flow: fetches client secret, shows Payment Sheet (Google Pay / Apple Pay / Card).
  /// Returns [PaymentResult.success] if the user completed payment.
  static Future<PaymentResult> payForPremiumSubscription() async {
    if (!StripeConfig.isConfigured) return PaymentResult.notConfigured;

    await ensureInitialized();

    String? clientSecret = await _fetchClientSecretFromBackend();
    if (clientSecret == null || clientSecret.isEmpty) {
      return PaymentResult.notConfigured;
    }

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Tennis Tournaments',
          googlePay: PaymentSheetGooglePay(
            merchantCountryCode: 'DE',
            currencyCode: 'EUR',
            testEnv: StripeConfig.publishableKey.startsWith('pk_test_'),
          ),
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'DE',
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return PaymentResult.success;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return PaymentResult.cancelled;
      }
      return PaymentResult.failed;
    } catch (_) {
      return PaymentResult.failed;
    }
  }
}
