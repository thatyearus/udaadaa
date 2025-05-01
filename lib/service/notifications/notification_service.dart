import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:udaadaa/utils/constant.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotification() async {
    // 1. Android 초기 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 2. iOS 초기 설정 (권한 요청 제거!)
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false, // ❌ 권한은 나중에 요청할 거니까 false
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    // 3. 통합 초기 설정
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // 4. 초기화만
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        logger.d("🔔 Notification Response: ${notificationResponse.payload}");
      },
    );

    // 5. 타임존 설정
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    logger.d("✅ Notification Service Initialized (only init, no permission)");
  }

  static Future<void> ensurePermissions() async {
    final iosPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // iOS 권한 요청
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android 권한 요청 (Android 13+)
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    logger.d("🔐 권한 요청 완료 (ensurePermissions 실행됨)");
  }

  static Future<void> showNotification(String title, String body,
      {String? payload}) async {
    try {
      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'udaadaa',
        '우다다',
        channelDescription: '우다다 푸시 알림',
        importance: Importance.max,
        priority: Priority.high,
        color: AppColors.primary,
      );

      const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

      const platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      logger.d("✅ 알림 설정 완료, show() 호출 직전");

      await flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      logger.d("✅ 알림 표시 완료");
    } catch (e, stack) {
      logger.e("❌ 알림 표시 중 오류 발생: $e");
      logger.e(stack);
    }
  }

  static Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    int hour,
    int minute,
    DateTime date, {
    String? payload,
  }) async {
    // 🔐 알림 예약 전에 권한 먼저 확인 및 요청
    await ensurePermissions();

    final now = tz.TZDateTime.now(tz.local);
    logger.d("🕒 현재 시각 (tz): $now");

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      logger.w("⛔ 과거 시간($scheduledDate)은 예약하지 않음 ➡️ 내일로 설정 변경");

      // 하루 뒤로 이동
      final newDate = date.add(Duration(days: 1));
      scheduledDate = tz.TZDateTime(
        tz.local,
        newDate.year,
        newDate.month,
        newDate.day,
        hour,
        minute,
      );

      logger.d("📅 변경된 예약 시간: $scheduledDate");
    }

    logger.d("🗓️ 예약 알림 설정");
    logger.d("📌 ID: $id");
    logger.d("📢 제목: $title");
    logger.d("📝 내용: $body");
    logger.d("🕒 예약 시간: $scheduledDate");
    logger.d("📦 페이로드: $payload");

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'udaadaa',
      '우다다',
      channelDescription: '우다다 푸시 알림',
      importance: Importance.max,
      priority: Priority.high,
      color: AppColors.primary,
    );

    const platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      logger.d("✅ 예약 알림 등록 완료!");
    } catch (e, stack) {
      logger.e("❌ 예약 알림 등록 실패: $e");
      logger.e(stack);
    }
  }

  static Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
