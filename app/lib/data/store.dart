import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'collector.dart';
import 'i18n.dart';
import 'install.dart';
import 'models.dart';
import 'survey.dart';
import 'sync.dart';

class TroveyStore extends ChangeNotifier {
  TroveyStore();

  late Box<String> _responses;
  late Box<String> _settingsBox;
  late Box<String> _meta;
  Settings settings = Settings();
  List<SurveyResponse> records = [];
  bool online = true;
  String lastSyncAt = '';
  StreamSubscription<List<ConnectivityResult>>? _sub;

  String get locale => settings.locale;
  String t(String key) => tr(locale, key);
  int get queueCount =>
      records.where((r) => r.status == ResponseStatus.queued || r.status == ResponseStatus.failed).length;

  SurveyResponse? get openDraft {
    final drafts = records.where((r) => r.status == ResponseStatus.draft).toList();
    return drafts.isEmpty ? null : drafts.first;
  }

  Future<void> init() async {
    await Hive.initFlutter();
    _responses = await Hive.openBox<String>('tickets-v3');
    _settingsBox = await Hive.openBox<String>('settings');
    _meta = await Hive.openBox<String>('meta');
    _loadSettings();
    settings
      ..collectorName = Collector.fullName
      ..collectorId = Collector.id;
    _loadRecords();
    lastSyncAt = _meta.get('lastSyncAt') ?? '';
    final status = await Connectivity().checkConnectivity();
    online = !status.contains(ConnectivityResult.none);
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      online = !results.contains(ConnectivityResult.none);
      notifyListeners();
      if (online) unawaited(_hydrate());
    });
    if (online) {
      unawaited(_hydrate());
    }
    if (kIsWeb) {
      InstallBridge.onDrain(() => unawaited(_hydrate()));
      unawaited(InstallBridge.requestPermissions());
    }
    notifyListeners();
  }

  void _loadSettings() {
    final raw = _settingsBox.get('profile');
    if (raw != null) {
      settings = Settings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
  }

  void _loadRecords() {
    records = _responses.values
        .map((raw) => SurveyResponse.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> saveSettings(Settings next) async {
    settings = next;
    await _settingsBox.put('profile', jsonEncode(next.toJson()));
    notifyListeners();
  }

  Future<SurveyResponse> put(SurveyResponse row) async {
    await _responses.put(row.clientId, jsonEncode(row.toJson()));
    _loadRecords();
    notifyListeners();
    return row;
  }

  SurveyResponse? getById(String id) {
    final raw = _responses.get(id);
    if (raw == null) return null;
    return SurveyResponse.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _responses.delete(id);
    _loadRecords();
    notifyListeners();
  }

  Future<SurveyResponse> createDraft() async {
    final now = DateTime.now().toUtc().toIso8601String();
    final row = SurveyResponse(
      clientId: const Uuid().v4(),
      status: ResponseStatus.draft,
      answers: emptyAnswers(),
      createdAt: now,
      updatedAt: now,
    );
    return put(row);
  }

  Future<SurveyResponse> saveDraft(SurveyResponse row) {
    row
      ..status = ResponseStatus.draft
      ..updatedAt = DateTime.now().toUtc().toIso8601String();
    return put(row);
  }

  Future<SurveyResponse> enqueue(SurveyResponse row) async {
    row
      ..status = ResponseStatus.queued
      ..submittedAt ??= DateTime.now().toUtc().toIso8601String()
      ..updatedAt = DateTime.now().toUtc().toIso8601String()
      ..lastError = null;
    await put(row);
    unawaited(drainQueue());
    return row;
  }

  Future<void> _hydrate() async {
    await pullCloud();
    await drainQueue();
  }

  Future<void> pullCloud() async {
    if (!online) return;
    try {
      final remote = await SyncClient.list();
      for (final row in remote) {
        final id = '${row['clientId'] ?? ''}';
        if (id.isEmpty) continue;
        final existing = getById(id);
        if (existing != null &&
            (existing.status == ResponseStatus.draft ||
                existing.status == ResponseStatus.queued ||
                existing.status == ResponseStatus.syncing ||
                existing.status == ResponseStatus.failed)) {
          continue;
        }
        await _responses.put(id, jsonEncode(responseFromCloud(row).toJson()));
      }
      _loadRecords();
      notifyListeners();
    } catch (_) {
      /* keep local copy */
    }
  }

  Future<void> drainQueue() async {
    if (!online) return;
    final pending = records
        .where((r) => r.status == ResponseStatus.queued || r.status == ResponseStatus.failed)
        .toList();
    for (final row in pending) {
      await sendOne(row.clientId);
    }
  }

  String exportCsv() {
    const headers = [
      'clientId',
      'status',
      'surveyId',
      'collectorName',
      'collectorId',
      'locale',
      'createdAt',
      'submittedAt',
      'siteCountry',
      'siteCity',
      'interviewPlace',
      'lat',
      'lng',
      'ageRange',
      'yearsTrading',
      'markets',
      'style',
      'hoursPerWeek',
      'platform',
      'usesStop',
      'biggestChallenge',
      'resultBand',
    ];
    final lines = <String>[headers.join(',')];
    for (final row in records) {
      final flat = flattenAnswers(row.answers);
      final map = <String, String>{
        'clientId': row.clientId,
        'status': row.status.name,
        'surveyId': surveyId,
        'collectorName': Collector.fullName,
        'collectorId': Collector.id,
        'locale': settings.locale,
        'createdAt': row.createdAt,
        'submittedAt': row.submittedAt ?? '',
        ...flat,
      };
      lines.add(headers.map((h) => _csv(map[h] ?? '')).join(','));
    }
    return lines.join('\n');
  }

  String _csv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<void> sendOne(String clientId) async {
    final row = getById(clientId);
    if (row == null) return;
    if (row.status == ResponseStatus.draft || row.status == ResponseStatus.synced) return;

    row
      ..status = ResponseStatus.syncing
      ..attempts += 1
      ..updatedAt = DateTime.now().toUtc().toIso8601String();
    await put(row);

    try {
      await SyncClient.send(row, settings);
      final now = DateTime.now().toUtc().toIso8601String();
      row
        ..status = ResponseStatus.synced
        ..syncedAt = now
        ..lastError = null
        ..updatedAt = now;
      await put(row);
      lastSyncAt = now;
      await _meta.put('lastSyncAt', now);
      if (kIsWeb) {
        unawaited(InstallBridge.notifySync(t('syncNotifyTitle'), t('syncNotifyBody')));
      }
    } catch (error) {
      row
        ..status = ResponseStatus.failed
        ..lastError = error.toString()
        ..updatedAt = DateTime.now().toUtc().toIso8601String();
      await put(row);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
