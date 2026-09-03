import 'collector.dart';

enum ResponseStatus { draft, queued, syncing, synced, failed }

class GpsValue {
  const GpsValue({
    required this.lat,
    required this.lng,
    required this.accuracy,
    required this.at,
  });

  final double lat;
  final double lng;
  final double accuracy;
  final String at;

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'accuracy': accuracy,
        'at': at,
      };

  factory GpsValue.fromJson(Map<String, dynamic> json) => GpsValue(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        accuracy: (json['accuracy'] as num).toDouble(),
        at: json['at'] as String,
      );
}

class SurveyResponse {
  SurveyResponse({
    required this.clientId,
    required this.status,
    required this.answers,
    required this.createdAt,
    required this.updatedAt,
    this.photoB64,
    this.submittedAt,
    this.syncedAt,
    this.lastError,
    this.attempts = 0,
  });

  final String clientId;
  ResponseStatus status;
  Map<String, dynamic> answers;
  String? photoB64;
  String createdAt;
  String updatedAt;
  String? submittedAt;
  String? syncedAt;
  String? lastError;
  int attempts;

  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        'status': status.name,
        'answers': answers,
        'photoB64': photoB64,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'submittedAt': submittedAt,
        'syncedAt': syncedAt,
        'lastError': lastError,
        'attempts': attempts,
      };

  factory SurveyResponse.fromJson(Map<String, dynamic> json) => SurveyResponse(
        clientId: json['clientId'] as String,
        status: ResponseStatus.values.byName(json['status'] as String),
        answers: Map<String, dynamic>.from(json['answers'] as Map),
        photoB64: json['photoB64'] as String?,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
        submittedAt: json['submittedAt'] as String?,
        syncedAt: json['syncedAt'] as String?,
        lastError: json['lastError'] as String?,
        attempts: json['attempts'] as int? ?? 0,
      );
}

class Settings {
  Settings({
    this.collectorName = Collector.fullName,
    this.collectorId = Collector.id,
    this.locale = 'vi',
    this.theme = 'paper',
  });

  String collectorName;
  String collectorId;
  String locale;
  String theme;

  bool get isNight => theme == 'night';

  Map<String, dynamic> toJson() => {
        'collectorName': Collector.fullName,
        'collectorId': Collector.id,
        'locale': locale,
        'theme': theme,
      };

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        collectorName: Collector.fullName,
        collectorId: Collector.id,
        locale: json['locale'] as String? ?? 'vi',
        theme: json['theme'] as String? ?? 'paper',
      );
}

enum FieldType { text, long, single, dropdown, multi, number, yesno, photo, gps, phone }

class FieldOption {
  const FieldOption(this.value, this.vi, this.en);
  final String value;
  final String vi;
  final String en;
  String label(String locale) => locale == 'en' ? en : vi;
}

class FieldDef {
  const FieldDef({
    required this.id,
    required this.type,
    this.required = false,
    this.options = const [],
  });

  final String id;
  final FieldType type;
  final bool required;
  final List<FieldOption> options;
}

class SectionDef {
  const SectionDef({
    required this.id,
    required this.vi,
    required this.en,
    this.hintVi,
    this.hintEn,
    required this.fields,
  });

  final String id;
  final String vi;
  final String en;
  final String? hintVi;
  final String? hintEn;
  final List<FieldDef> fields;

  String title(String locale) => locale == 'en' ? en : vi;
  String? hint(String locale) => locale == 'en' ? hintEn : hintVi;
}
