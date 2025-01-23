import 'package:http/http.dart' as http;
import 'dart:convert'; // Import for JSON decoding
import 'dart:io';

class DocumentService {
  final String baseUrl;

  DocumentService({required this.baseUrl});

  Future<Map<String, dynamic>> uploadDocument(String filePath) async {
    // Check if the file exists
    if (!File(filePath).existsSync()) {
      throw Exception('File does not exist at the specified path: $filePath');
    }

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    try {
      // Send the request
      final response = await request.send();
      
      // Check the response status
      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the response
        final responseData = await http.Response.fromStream(response);
        return json.decode(responseData.body); // Return the parsed JSON
      } else {
        throw Exception('Failed to upload document: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading document: $e');
    }
  }
}