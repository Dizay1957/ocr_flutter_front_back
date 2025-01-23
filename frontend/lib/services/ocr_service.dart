import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';
import '../models/document_model.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  final Dio _dio = Dio()
    ..options.connectTimeout = const Duration(seconds: 30)
    ..options.receiveTimeout = const Duration(seconds: 30)
    ..options.validateStatus = (status) => status! < 500;

  Future<String> extractText(String imagePath) async {
    try {
      final XFile pickedFile = XFile(imagePath);
      final bytes = await pickedFile.readAsBytes();

      print('Connecting to: ${ApiConfig.baseUrl}${ApiConfig.uploadEndpoint}');
      
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await _dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.uploadEndpoint}',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
          followRedirects: true,
          validateStatus: (status) => true,
        ),
      );

      print('Response received: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final document = Document.fromJson(response.data);
        return document.extractedData ?? '';
      }

      throw Exception('Server error: ${response.statusCode}');
    } on DioException catch (e) {
      print('Connection error: ${e.message}');
      print('Error type: ${e.type}');
      print('Error response: ${e.response}');
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout - Please check your internet connection');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Failed to process image: $e');
    }
  }

  scanImage(String imagePath) {}
}
