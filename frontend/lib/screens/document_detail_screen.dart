import 'package:flutter/material.dart';
import '../models/document_model.dart';

class DocumentDetailScreen extends StatelessWidget {
  final Document document;

  const DocumentDetailScreen({Key? key, required this.document})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (document.hasData) ...[
              Text(document.extractedData ?? 'No data'),
            ] else ...[
              const Center(
                child: Text('No text extracted'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
