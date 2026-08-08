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
        'role': 0, // Merchant (0 in UserRole enum)
      });
    } on DioException catch (e) {
      // Attempt to extract a meaningful error message from the backend response
      String serverMessage = '';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          if (data.containsKey('message') && data['message'] != null) {
            serverMessage = data['message'] as String;
          } else if (data.containsKey('errors') && data['errors'] != null) {
            // Concatenate validation error messages if provided as a map of lists
            if (data['errors'] is Map) {
              serverMessage = (data['errors'] as Map)
                  .values
                  .expand((v) => v as List)
                  .join('؛ ');
            }
          }
        }
      }
      if (serverMessage.isEmpty) {
        serverMessage = e.response?.statusCode == 400 ? 'بيانات غير صالحة' : 'حدث خطأ في الاتصال بالخادم';
      }
      throw Exception(serverMessage);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع');
    }
  }
}
