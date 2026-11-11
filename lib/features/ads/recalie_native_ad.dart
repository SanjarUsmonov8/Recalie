import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:recalie/features/plans/plan_access.dart';

enum RecalieNativeAdFormat { compact, large }

class RecalieNativeAdCard extends StatefulWidget {
  const RecalieNativeAdCard({
    super.key,
    this.format = RecalieNativeAdFormat.compact,
    this.margin = EdgeInsets.zero,
  });

  final RecalieNativeAdFormat format;
  final EdgeInsetsGeometry margin;

  @override
  State<RecalieNativeAdCard> createState() => _RecalieNativeAdCardState();
}

class _RecalieNativeAdCardState extends State<RecalieNativeAdCard> {
  static const _androidTestNativeAdUnitId =
      'ca-app-pub-3940256099942544/2247696110';
  static const _androidProductionNativeAdUnitId =
      'ca-app-pub-5785529344181904/3445210890';

  NativeAd? _ad;
  bool _loaded = false;
  Brightness? _brightness;

  bool get _isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  String get _adUnitId => kReleaseMode
      ? const String.fromEnvironment(
          'ADMOB_NATIVE_AD_UNIT_ID',
          defaultValue: _androidProductionNativeAdUnitId,
        )
      : _androidTestNativeAdUnitId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final plan = RecaliePlanScope.maybeOf(context)?.plan;
    if (!_isSupported || plan?.showsAds == false) {
      _ad?.dispose();
      _ad = null;
      _loaded = false;
      return;
    }
    final currentBrightness = Theme.of(context).brightness;
    if (_ad == null || _brightness != currentBrightness) {
      _loadAd(currentBrightness);
    }
  }

  void _loadAd(Brightness brightness) {
    _ad?.dispose();
    _ad = null;
    _loaded = false;
    _brightness = brightness;

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = brightness == Brightness.dark;
    final background = dark ? const Color(0xFF172033) : Colors.white;
    final primaryText = dark ? Colors.white : const Color(0xFF101828);
    final secondaryText = dark
        ? const Color(0xFFBCC7DA)
        : const Color(0xFF526079);

    final ad = NativeAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (loadedAd) {
          if (!mounted || loadedAd != _ad) return;
          debugPrint('Recalie native ad loaded successfully.');
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (failedAd, error) {
          failedAd.dispose();
          if (!mounted || failedAd != _ad) return;
          setState(() {
            _ad = null;
            _loaded = false;
          });
          debugPrint('Recalie native ad failed to load: $error');
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.format == RecalieNativeAdFormat.large
            ? TemplateType.medium
            : TemplateType.small,
        mainBackgroundColor: background,
        cornerRadius: 24,
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: primaryText,
          size: widget.format == RecalieNativeAdFormat.large ? 18 : 16,
          style: NativeTemplateFontStyle.bold,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: secondaryText,
          size: 13,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: secondaryText,
          size: 12,
        ),
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: colors.primary,
          size: 14,
          style: NativeTemplateFontStyle.bold,
        ),
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    final plan = RecaliePlanScope.maybeOf(context)?.plan;
    if (!_isSupported || plan?.showsAds == false || !_loaded || ad == null) {
      return const SizedBox.shrink();
    }
    final height = widget.format == RecalieNativeAdFormat.large ? 320.0 : 112.0;
    return Padding(
      padding: widget.margin,
      child: Semantics(
        label: 'Advertisement',
        child: Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: double.infinity,
            height: height,
            child: AdWidget(ad: ad),
          ),
        ),
      ),
    );
  }
}
