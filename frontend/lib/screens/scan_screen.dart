import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'dart:io';
import 'package:camera/camera.dart'; // Import for camera functionality
import '../services/document_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final DocumentService documentService = DocumentService(baseUrl: 'http://192.168.1.34:8081');
  bool _isProcessing = false;
  String? _imagePath;
  String? _extractedText;

  // Camera variables
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool isCameraInitialized = false;
  bool isLoading = false;
  bool isFlashOn = false; 
  String? _capturedImagePath;

  // Method to initialize the camera
  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras!.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (!mounted) return;

    setState(() {
      isCameraInitialized = true;
    });
  }

  Future<void> _toggleFlash() async {
    if (!isCameraInitialized) return;

    try {
      isFlashOn = !isFlashOn;
      await _cameraController!.setFlashMode(
        isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
    } catch (e) {
      print('Error toggling flash: $e');
    }
  }

  Future<void> _takePicture() async {
    if (!isCameraInitialized) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Take a picture
      final XFile picture = await _cameraController!.takePicture();
      setState(() {
        _capturedImagePath = picture.path;
      });

      // Upload the document and get the response
      final response = await documentService.uploadDocument(_capturedImagePath!);
      
      setState(() {
        _extractedText = response['extractedData']; // Access the extracted data
      });
    } catch (e) {
      print('Error taking picture: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _scanIdCard() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isProcessing = true;
        _imagePath = image.path; // Set the image path
      });

      try {
        // Upload the document and get the response
        final response = await documentService.uploadDocument(_imagePath!);
        
        // Assuming the response contains an 'extractedData' field
        setState(() {
          _extractedText = response['extractedData']; // Access the extracted data
          _isProcessing = false;
        });
      } catch (e) {
        setState(() {
          _extractedText = null;
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  // Method to handle camera scan button click
  void _onCameraScanPressed() {
    _initializeCamera(); // Initialize the camera
    _takePicture(); // Trigger the camera to take a picture
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('ID Card Scanner', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  height: 200,
                  padding: EdgeInsets.all(16),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb // Check if running on the web
                              ? Image.network(
                                  _imagePath!, // Use a URL or a placeholder for web
                                  fit: BoxFit.contain,
                                )
                              : Image.file(
                                  File(_imagePath!), // Use Image.file for local images
                                  fit: BoxFit.contain,
                                ),
                        )
                      : _capturedImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: kIsWeb // Check if running on the web
                                  ? Image.network(
                                      _capturedImagePath!, // Use a URL or a placeholder for web
                                      fit: BoxFit.contain,
                                    )
                                  : Image.file(
                                      File(_capturedImagePath!), // Use Image.file for local images
                                      fit: BoxFit.contain,
                                    ),
                            )
                          : isCameraInitialized
                              ? AspectRatio(
                                  aspectRatio: _cameraController!.value.aspectRatio,
                                  child: CameraPreview(_cameraController!), // Show camera preview
                                )
                              : Center(child: CircularProgressIndicator()),
                ),
              ),
              SizedBox(height: 20),

              // Extracted Text Card
              if (_extractedText != null)
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      _extractedText!,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: _isProcessing ? null : () {
              _scanIdCard(); // Scan from gallery
              _capturedImagePath = null; // Clear captured image path
            },
            tooltip: 'Scan from Gallery',
            child: Icon(Icons.photo_library),
            backgroundColor: Colors.blue,
          ),
          SizedBox(width: 16), // Space between buttons
          FloatingActionButton(
            onPressed: _isProcessing ? null : () {
              _initializeCamera(); // Initialize the camera
              _takePicture(); // Trigger the camera to take a picture
              _imagePath = null; // Clear image path
            },
            tooltip: 'Scan with Camera',
            child: Icon(Icons.camera_alt),
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }
}