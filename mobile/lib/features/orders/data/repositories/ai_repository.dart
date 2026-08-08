import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/ai_order_response.dart';

class AiRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      return null;
    }
  }

  Future<AiOrderResponse> uploadVoiceOrder(String audioPath, int merchantId) async {
    final position = await getCurrentLocation();

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(audioPath, filename: 'order_audio.m4a'),
    });

    String queryParams = '';
    if (position != null) {
      queryParams = '?lat=${position.latitude}&lon=${position.longitude}';
    }

    try {
      final response = await _apiClient.dio.post(
        '/ai/voice/order/$merchantId$queryParams',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return AiOrderResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to upload voice order: $e');
    }
  }

  Future<AiOrderResponse> sendChatMessage(String sessionId, String message, int merchantId) async {
    final position = await getCurrentLocation();
    
    final payload = {
      'transcript': message,
      'lat': position?.latitude,
      'lon': position?.longitude,
    };

    try {
      final response = await _apiClient.dio.post(
        '/ai/order/$merchantId',
        data: payload,
      );

      return AiOrderResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to send chat message: $e');
    }
  }
}
