import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_dto.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<AuthResponseDto> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final dto = AuthResponseDto.fromJson(response.data);
      // Save token for future authenticated requests
      await _apiClient.saveToken(dto.token);
      return dto;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      }
      throw Exception('حدث خطأ في الاتصال بالخادم: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع');
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      await _apiClient.dio.post('/auth/register', data: {
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': 1, // Merchant
      });
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['message'] ?? 'بيانات غير صالحة');
      }
      throw Exception('حدث خطأ في الاتصال بالخادم: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع');
    }
  }
}
