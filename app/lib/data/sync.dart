import 'dart:convert';

import 'package:http/http.dart' as http;

import 'collector.dart';
import 'models.dart';
import 'survey.dart';

class SyncClient {
  static const origin = 'https://app.puretrovey.net';
  static const syncPath = '/api/sync';
  static const recordsPath = '/api/records';

  static String get syncUrl {
    const env = String.fromEnvironment('SYNC_URL', defaultValue: '');
    if (env.isNotEmpty) return env;
    return '$origin$syncPath';
  }

  static String get recordsUrl => '$origin$recordsPath';

  static Future<void> send(SurveyResponse row, Settings settings) async {
    final flat = flattenAnswers(row.answers);
    final body = <String, dynamic>{
      'clientId': row.clientId,
      'surveyId': surveyId,
      'collectorName': Collector.fullName,
      'collectorId': Collector.id,
      'locale': settings.locale,
      'createdAt': row.createdAt,
      'submittedAt': row.submittedAt ?? DateTime.now().toUtc().toIso8601String(),
      'hasPhoto': row.photoB64 != null && row.photoB64!.isNotEmpty,
      ...flat,
    };

    final res = await http
        .post(
          Uri.parse(syncUrl),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! Map || decoded['ok'] != true || decoded['kv'] != true) {
      throw Exception('cloud ${decoded is Map ? decoded['error'] : res.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> list() async {
    final res = await http.get(Uri.parse(recordsUrl)).timeout(const Duration(seconds: 20));
    final decoded = jsonDecode(res.body);
    if (decoded is! Map || decoded['ok'] != true || decoded['records'] is! List) {
      return const [];
    }
    return (decoded['records'] as List)
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  static Future<Map<String, dynamic>> probe() async {
    final res = await http.get(Uri.parse(syncUrl)).timeout(const Duration(seconds: 15));
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'ok': false, 'error': res.body};
  }
}

SurveyResponse responseFromCloud(Map<String, dynamic> json) {
  final answers = emptyAnswers();
  answers.forEach((key, _) {
    if (!json.containsKey(key)) return;
    answers[key] = json[key];
  });
  for (final key in ['markets', 'informationSources']) {
    final value = answers[key];
    if (value is String) {
      answers[key] = value.split('|').where((part) => part.trim().isNotEmpty).toList();
    }
  }
  final created = '${json['createdAt'] ?? json['storedAt'] ?? DateTime.now().toUtc().toIso8601String()}';
  return SurveyResponse(
    clientId: '${json['clientId']}',
    status: ResponseStatus.synced,
    answers: answers,
    createdAt: created,
    updatedAt: '${json['storedAt'] ?? created}',
    submittedAt: json['submittedAt'] as String?,
    syncedAt: json['storedAt'] as String? ?? created,
  );
}
