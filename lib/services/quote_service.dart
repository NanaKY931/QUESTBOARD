import 'dart:convert';
import 'package:http/http.dart' as http;

class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['quote'] ?? 'A smooth sea never made a skilled sailor.',
      author: json['author'] ?? 'Unknown',
    );
  }
}

class QuoteService {
  static const String _url = 'https://dummyjson.com/quotes/random';

  Future<Quote?> fetchQuoteOfTheDay() async {
    try {
      final response = await http.get(Uri.parse(_url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Quote.fromJson(data);
      }
    } catch (e) {
      // Silent catch to prevent crashing if offline
    }
    return null;
  }
}
