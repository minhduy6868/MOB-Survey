import 'models.dart';
import 'survey.dart';

class CountRow {
  const CountRow(this.key, this.count);
  final String key;
  final int count;
}

class SurveyStats {
  SurveyStats({
    required this.total,
    required this.markets,
    required this.styles,
    required this.ages,
    required this.stops,
  });

  final int total;
  final List<CountRow> markets;
  final List<CountRow> styles;
  final List<CountRow> ages;
  final Map<String, int> stops;

  factory SurveyStats.from(List<SurveyResponse> records) {
    final submitted = records.where((r) => r.status != ResponseStatus.draft).toList();
    final markets = <String, int>{};
    final styles = <String, int>{};
    final ages = <String, int>{};
    final stops = <String, int>{'yes': 0, 'no': 0};

    for (final row in submitted) {
      final m = row.answers['markets'];
      if (m is List) {
        for (final item in m) {
          markets['$item'] = (markets['$item'] ?? 0) + 1;
        }
      }
      final style = '${row.answers['style'] ?? ''}';
      if (style.isNotEmpty) styles[style] = (styles[style] ?? 0) + 1;
      final age = '${row.answers['ageRange'] ?? ''}';
      if (age.isNotEmpty) ages[age] = (ages[age] ?? 0) + 1;
      final stop = '${row.answers['usesStop'] ?? ''}';
      if (stops.containsKey(stop)) stops[stop] = (stops[stop] ?? 0) + 1;
    }

    List<CountRow> sort(Map<String, int> map) {
      final rows = map.entries.map((e) => CountRow(e.key, e.value)).toList()
        ..sort((a, b) => b.count.compareTo(a.count));
      return rows;
    }

    return SurveyStats(
      total: submitted.length,
      markets: sort(markets),
      styles: sort(styles),
      ages: sort(ages),
      stops: stops,
    );
  }
}

String optionLabel(String fieldId, String value, String locale) {
  for (final section in sections) {
    for (final field in section.fields) {
      if (field.id != fieldId) continue;
      for (final opt in field.options) {
        if (opt.value == value) return opt.label(locale);
      }
    }
  }
  return value;
}
