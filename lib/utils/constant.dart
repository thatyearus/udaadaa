import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
export 'theme/colors.dart';
export 'theme/spacing.dart';
export 'theme/text_style.dart';

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
final String supabaseUrl = dotenv.env['SUPABASE_URL']!;
final String supabaseKey = dotenv.env['SUPABASE_KEY']!;

final supabase = Supabase.instance.client;
