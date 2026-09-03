import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';
import 'survey.dart';

class SyncClient {
  static const defaultUrl = String.fromEnvironment(
    'SYNC_URL',
    defaultValue: '/api/sync',
  );

  static Future<void> send(SurveyResponse row, Settings settings) async {
    final flat = flattenAnswers(row.answers);
    final body = <String, dynamic>{
      'clientId': row.clientId,
      'surveyId': surveyId,
      'collectorName': settings.collectorName,
      'collectorId': settings.collectorId,
      'locale': settings.locale,
      'createdAt': row.createdAt,
      'submittedAt': row.submittedAt ?? DateTime.now().toUtc().toIso8601String(),
      'hasPhoto': row.photoB64 != null && row.photoB64!.isNotEmpty,
      ...flat,
    };

    final uri = Uri.parse(defaultUrl);
    final res = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}');
    }
  }
}
