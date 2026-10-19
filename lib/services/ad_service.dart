import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  /// Google AdMob Interstitial Ad Unit ID
  static const String interstitialAdUnitId =
      'ca-app-pub-7637877671794221/1212365031';

  InterstitialAd? _interstitialAd;
  bool _isLoading = false;

  /// Initialize Google Mobile Ads SDK and pre-load first interstitial ad
  Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
      loadInterstitialAd();
    } catch (e) {
      developer.log('Error initializing AdMob: $e', name: 'AdService');
    }
  }

  /// Preload an interstitial ad
  void loadInterstitialAd() {
    if (_isLoading || _interstitialAd != null) return;
    _isLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;
          _setupAdCallbacks(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          developer.log(
            'Failed to load interstitial ad: ${error.message} (code: ${error.code})',
            name: 'AdService',
          );
          _interstitialAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  void _setupAdCallbacks(InterstitialAd ad, {VoidCallback? onComplete}) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        onComplete?.call();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, AdError error) {
        developer.log(
          'Failed to show interstitial ad: ${error.message}',
          name: 'AdService',
        );
        ad.dispose();
        _interstitialAd = null;
        onComplete?.call();
        loadInterstitialAd();
      },
    );
  }

  /// Show the preloaded interstitial ad.
  /// Calls [onComplete] after the ad is closed or if no ad is available,
  /// ensuring the app flow is never interrupted.
  void showInterstitialAd({VoidCallback? onComplete}) {
    if (_interstitialAd == null) {
      loadInterstitialAd();
      onComplete?.call();
      return;
    }

    _setupAdCallbacks(_interstitialAd!, onComplete: onComplete);
    _interstitialAd!.show();
  }
}
