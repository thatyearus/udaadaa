import 'package:dio/dio.dart';
import 'package:udaadaa/utils/constant.dart';

class DioClient {
  static final String _baseUrl = apiUrl;
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(milliseconds: 5000),
      receiveTimeout: const Duration(milliseconds: 3000),
    ),
  );
}
