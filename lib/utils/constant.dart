import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:udaadaa/data/dio_client.dart';
import 'package:udaadaa/utils/analytics/analytics.dart';
export 'theme/colors.dart';
export 'theme/spacing.dart';
export 'theme/text_style.dart';
export 'theme/theme.dart';
export 'random_nickname_generator.dart';

final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 50,
    colors: true,
    printEmojis: true,
  ),
);

final String apiUrl = dotenv.env['API_URL']!;
final String redirectUrl = dotenv.env['REDIRECT_URL']!;
final String supabaseUrl = dotenv.env['SUPABASE_URL']!;
final String supabaseKey = dotenv.env['SUPABASE_KEY']!;
final String amplitudeToken = dotenv.env['AMPLITUDE_TOKEN']!;
final String mixpanelToken = dotenv.env['MIXPANEL_TOKEN']!;
final String schemeName = dotenv.env['SCHEME_NAME']!;
final String hostName = dotenv.env['HOST_NAME']!;
final String initialChatEndPoint = dotenv.env['INITIAL_CHAT_END_POINT']!;

final supabase = Supabase.instance.client;
final dioClient = DioClient();

final Analytics analytics = Analytics();
