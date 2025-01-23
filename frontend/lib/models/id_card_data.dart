class IdCardData {
  final String? cin;
  final String? fullName;
  final String? dateOfBirth;
  final String? placeOfBirth;
  final String? address;
  final String? expiryDate;
  final String? sex;

  IdCardData({
    this.cin,
    this.fullName,
    this.dateOfBirth,
    this.placeOfBirth,
    this.address,
    this.expiryDate,
    this.sex,
  });

  factory IdCardData.fromOcrText(String text) {
    final normalizedText = text.toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
    print('Normalized OCR Text: $normalizedText');

    String? extractValue(List<String> patterns) {
      for (var pattern in patterns) {
        final RegExp exp =
            RegExp(pattern, multiLine: true, caseSensitive: false);
        final match = exp.firstMatch(normalizedText);
        if (match != null && match.groupCount >= 1) {
          return match.group(1)?.trim();
        }
      }
      return null;
    }

    return IdCardData(
      cin: extractValue([
        r'(?:CARTE.*?IDENTITE|CIN).*?([A-Z][A-Z0-9]\d{5,6})',
        r'\b([A-Z][A-Z0-9]\d{5,6})\b',
      ]),
      fullName: extractValue([
        r'(?:NOM.*?PRENOM|الاسم الشخصي والعائلي).*?([A-Z\s]+?)(?=\d|DATE|LIEU|NEE?|$)',
        r'(?:NOM|NAME).*?([A-Z\s]+?)(?=PRENOM|DATE|LIEU|$)',
      ]),
      dateOfBirth: extractValue([
        r'(?:DATE.*?NAISSANCE|تاريخ الازدياد).*?(\d{1,2}[-/. ]\d{1,2}[-/. ]\d{4})',
        r'NEE? (?:LE|A).*?(\d{1,2}[-/. ]\d{1,2}[-/. ]\d{4})',
      ]),
      placeOfBirth: extractValue([
        r'(?:LIEU.*?NAISSANCE|مكان الازدياد).*?([A-Z\s-]+?)(?=\d|DATE|ADRESSE|$)',
        r'NEE? A\s+([A-Z\s-]+?)(?=LE|\d|DATE|$)',
      ]),
      address: extractValue([
        r'(?:ADRESSE|العنوان).*?([^\.]+?)(?=DATE|SEXE|VALABLE|$)',
        r'DEMEURANT.*?([^\.]+?)(?=DATE|SEXE|VALABLE|$)',
      ]),
      expiryDate: extractValue([
        r'(?:VALABLE.*?JUSQU|صالحة إلى غاية).*?(\d{1,2}[-/. ]\d{1,2}[-/. ]\d{4})',
        r'(?:VALIDITE|EXPIRATION).*?(\d{1,2}[-/. ]\d{1,2}[-/. ]\d{4})',
      ]),
      sex: extractValue([
        r'(?:SEXE|الجنس)\s*[:\.]?\s*([MF])',
        r'\b[MF]\b',
      ]),
    );
  }

  @override
  String toString() {
    return '''
    CIN: $cin
    Full Name: $fullName
    Date of Birth: $dateOfBirth
    Place of Birth: $placeOfBirth
    Address: $address
    Expiry Date: $expiryDate
    Sex: $sex
    ''';
  }
}
