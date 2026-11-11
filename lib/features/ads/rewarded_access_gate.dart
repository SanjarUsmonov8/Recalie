import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:recalie/features/plans/plan_access.dart';
import 'package:recalie/features/walnuts/walnut_controller.dart';

enum _AccessChoice { walnuts, rewardedAd }

class RewardedAccessGate {
  RewardedAccessGate._();

  static const _androidTestRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const _androidProductionRewardedAdUnitId =
      'ca-app-pub-5785529344181904/2104953921';

  static bool get _isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static String get _adUnitId => kReleaseMode
      ? const String.fromEnvironment(
          'ADMOB_REWARDED_AD_UNIT_ID',
          defaultValue: _androidProductionRewardedAdUnitId,
        )
      : _androidTestRewardedAdUnitId;

  static Future<bool> requestAccess(
    BuildContext context, {
    required String contentName,
  }) async {
    if (RecaliePlanScope.of(context).plan == RecalieMembershipPlan.pro) {
      return true;
    }
    final choice = await showDialog<_AccessChoice>(
      context: context,
      builder: (dialogContext) => _AccessChoiceDialog(
        contentName: contentName,
        onWalnuts: () => Navigator.of(dialogContext).pop(_AccessChoice.walnuts),
        onRewardedAd: () =>
            Navigator.of(dialogContext).pop(_AccessChoice.rewardedAd),
      ),
    );
    if (!context.mounted || choice == null) return false;

    if (choice == _AccessChoice.walnuts) {
      final walnuts = WalnutScope.of(context);
      final spent = await walnuts.spend(35);
      if (!context.mounted) return spent;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            spent
                ? '35 walnuts used. Access granted.'
                : 'You need 35 walnuts. You currently have ${walnuts.balance}.',
          ),
        ),
      );
      return spent;
    }

    return _showRewardedAd(context);
  }

  static Future<bool> _showRewardedAd(BuildContext context) async {
    if (!_isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rewarded ads are currently available on Android.'),
        ),
      );
      return false;
    }

    final loadFuture = _loadRewardedAd();
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _LoadingAdDialog(),
      ),
    );

    final ad = await loadFuture;
    if (!context.mounted) {
      ad?.dispose();
      return false;
    }
    Navigator.of(context, rootNavigator: true).pop();

    if (ad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The ad could not be loaded. Check your connection and try again.',
          ),
        ),
      );
      return false;
    }

    final completion = Completer<bool>();
    var earnedReward = false;
    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (dismissedAd) {
        dismissedAd.dispose();
        if (!completion.isCompleted) completion.complete(earnedReward);
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        failedAd.dispose();
        debugPrint('Recalie rewarded ad failed to show: $error');
        if (!completion.isCompleted) completion.complete(false);
      },
    );
    ad.show(
      onUserEarnedReward: (_, _) {
        earnedReward = true;
      },
    );
    final granted = await completion.future;
    if (!granted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finish the ad to open this content.')),
      );
    }
    return granted;
  }

  static Future<RewardedAd?> _loadRewardedAd() {
    final completion = Completer<RewardedAd?>();
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Recalie rewarded ad loaded successfully.');
          completion.complete(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('Recalie rewarded ad failed to load: $error');
          completion.complete(null);
        },
      ),
    );
    return completion.future;
  }
}

class _AccessChoiceDialog extends StatelessWidget {
  const _AccessChoiceDialog({
    required this.contentName,
    required this.onWalnuts,
    required this.onRewardedAd,
  });

  final String contentName;
  final VoidCallback onWalnuts;
  final VoidCallback onRewardedAd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AlertDialog(
      icon: Icon(Icons.lock_open_rounded, color: colors.primary, size: 34),
      title: const Text('Open this content?'),
      content: Text(
        'Use 35 walnuts or watch a short ad to access $contentName.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        OutlinedButton.icon(
          onPressed: onWalnuts,
          icon: const Icon(Icons.eco_rounded),
          label: const Text('Use 35 walnuts'),
        ),
        FilledButton.icon(
          onPressed: onRewardedAd,
          icon: const Icon(Icons.play_circle_fill_rounded),
          label: const Text('Watch an ad'),
        ),
      ],
    );
  }
}

class _LoadingAdDialog extends StatelessWidget {
  const _LoadingAdDialog();

  @override
  Widget build(BuildContext context) => const PopScope(
    canPop: false,
    child: AlertDialog(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(width: 16),
          Text('Preparing ad…'),
        ],
      ),
    ),
  );
}
