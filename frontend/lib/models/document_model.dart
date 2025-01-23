class Document {
  final int? id;
  final String fileName;
  final String? extractedData;
  final DateTime? uploadDate;
  final DateTime? processedDate;
  final String status;
  final String? errorMessage;

  Document({
    this.id,
    required this.fileName,
    this.extractedData,
    this.uploadDate,
    this.processedDate,
    required this.status,
    this.errorMessage,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      fileName: json['fileName'] ?? '',
      extractedData: json['extractedData'] as String?,
      uploadDate: json['uploadDate'] != null
          ? DateTime.parse(json['uploadDate'])
          : null,
      processedDate: json['processedDate'] != null
          ? DateTime.parse(json['processedDate'])
          : null,
      status: json['status'] ?? 'PENDING',
      errorMessage: json['errorMessage'],
    );
  }

  // Add a getter to check if data is available
  bool get hasData => extractedData?.isNotEmpty ?? false;
}
