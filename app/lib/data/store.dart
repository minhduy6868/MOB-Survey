import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import 'i18n.dart';
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
    _responses = await Hive.openBox<String>('responses');
    _settingsBox = await Hive.openBox<String>('settings');
    _meta = await Hive.openBox<String>('meta');
    _loadSettings();
    _loadRecords();
    lastSyncAt = _meta.get('lastSyncAt') ?? '';
    final status = await Connectivity().checkConnectivity();
    online = !status.contains(ConnectivityResult.none);
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      online = !results.contains(ConnectivityResult.none);
      notifyListeners();
      if (online) unawaited(drainQueue());
    });
    if (online) unawaited(drainQueue());
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

  Future<void> drainQueue() async {
    if (!online) return;
    final pending = records
        .where((r) => r.status == ResponseStatus.queued || r.status == ResponseStatus.failed)
        .toList();
    for (final row in pending) {
      await sendOne(row.clientId);
    }
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
