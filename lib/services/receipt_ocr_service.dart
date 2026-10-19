import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Result of parsing raw OCR text into structured receipt fields.
class ParsedReceiptData {
  final String vendor;
  final double amount;
  final DateTime date;
  final String category;

  ParsedReceiptData({
    required this.vendor,
    required this.amount,
    required this.date,
    required this.category,
  });
}

class ReceiptOCRService {
  static final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  /// Runs on-device OCR on the given image and returns the raw recognized text.
  static Future<String> scanReceipt(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText result = await _recognizer.processImage(inputImage);
      return result.text;
    } catch (_) {
      return '';
    }
  }

  /// Extracts vendor, amount, date and a best-guess category from raw OCR text.
  static ParsedReceiptData parseReceiptText(String rawText) {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final vendor = lines.isNotEmpty ? lines.first : 'Unknown Vendor';
    final amount = _extractAmount(rawText);
    final date = _extractDate(rawText) ?? DateTime.now();
    final category = _classifyCategory('$vendor $rawText');

    return ParsedReceiptData(
      vendor: vendor,
      amount: amount,
      date: date,
      category: category,
    );
  }

  static double _extractAmount(String text) {
    // Prefer a line that explicitly mentions "total"
    final totalMatch = RegExp(
      r'(total|amount due|grand total)[^\d]{0,10}(\d+[.,]\d{2})',
      caseSensitive: false,
    ).firstMatch(text);

    if (totalMatch != null) {
      final raw = totalMatch.group(2)!.replaceAll(',', '.');
      return double.tryParse(raw) ?? 0.0;
    }

    // Fallback: take the largest decimal number found anywhere in the text
    final matches = RegExp(r'\d+[.,]\d{2}').allMatches(text);
    double largest = 0.0;
    for (final m in matches) {
      final val = double.tryParse(m.group(0)!.replaceAll(',', '.')) ?? 0.0;
      if (val > largest) largest = val;
    }
    return largest;
  }

  static DateTime? _extractDate(String text) {
    final patterns = [
      RegExp(r'(\d{1,2})[/\-](\d{1,2})[/\-](\d{2,4})'), // dd/mm/yyyy
      RegExp(r'(\d{4})[/\-](\d{1,2})[/\-](\d{1,2})'), // yyyy-mm-dd
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match == null) continue;
      try {
        if (match.group(1)!.length == 4) {
          return DateTime(
            int.parse(match.group(1)!),
            int.parse(match.group(2)!),
            int.parse(match.group(3)!),
          );
        } else {
          var year = int.parse(match.group(3)!);
          if (year < 100) year += 2000;
          return DateTime(
            year,
            int.parse(match.group(2)!),
            int.parse(match.group(1)!),
          );
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  static String _classifyCategory(String text) {
    final lower = text.toLowerCase();

    const rules = <String, List<String>>{
      'Food': ['restaurant', 'cafe', 'starbucks', 'mcdonald', 'kfc', 'pizza', 'food', 'coffee', 'bakery'],
      'Transport': ['uber', 'careem', 'taxi', 'fuel', 'petrol', 'gas station', 'parking', 'bus', 'metro'],
      'Shopping': ['mall', 'store', 'amazon', 'mart', 'shop', 'clothing', 'fashion'],
      'Bills': ['electricity', 'utility', 'internet', 'bill', 'water', 'phone', 'subscription'],
      'Entertainment': ['cinema', 'movie', 'netflix', 'game', 'concert', 'entertainment'],
    };

    for (final entry in rules.entries) {
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) return entry.key;
      }
    }
    return 'Other';
  }

  /// Call when the app shuts down to free native resources (optional).
  static void dispose() {
    _recognizer.close();
  }
}
