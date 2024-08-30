import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
