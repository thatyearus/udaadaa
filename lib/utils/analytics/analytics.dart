import 'package:amplitude_flutter/amplitude.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:udaadaa/utils/constant.dart';

class Analytics {
  final FirebaseAnalytics _gaAnalytics = FirebaseAnalytics.instance;
  final FirebaseAnalyticsObserver _observer;
  late Mixpanel _mixpanel;
  final Amplitude _amplitude =
      Amplitude.getInstance(instanceName: "udaadaa_local");

  Analytics._internal()
      : _observer =
            FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);

  static final Analytics _instance = Analytics._internal();

  factory Analytics() => _instance;

  Future<void> init() async {
    _mixpanel = await Mixpanel.init(mixpanelToken, trackAutomaticEvents: true);
    _amplitude.init(amplitudeToken);
  }

  FirebaseAnalyticsObserver get observer => _observer;

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    try {
      logger.d("Logging event: $name with parameters: $parameters");
      await _gaAnalytics.logEvent(name: name, parameters: parameters);
      _mixpanel.track(name, properties: parameters);
      _amplitude.logEvent(name, eventProperties: parameters);
    } catch (e) {
      logger.e("Error logging event: $e");
    }
  }
}
