import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../data/survey.dart';
import '../theme/tokens.dart';
import '../widgets/chrome.dart';
import '../widgets/fields.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({
    super.key,
    required this.store,
    this.resumeId,
    required this.onDone,
  });

  final TroveyStore store;
  final String? resumeId;
  final void Function(String id) onDone;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scroll = ScrollController();
  SurveyResponse? _row;
  Map<String, String> _errors = {};
  bool _busy = false;
  int _step = 0;
  Timer? _debounce;

  TroveyStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final existing = widget.resumeId == null ? null : store.getById(widget.resumeId!);
    final row = existing ?? await store.createDraft();
    setState(() => _row = row);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _touch(void Function() mutate) {
    mutate();
    _row!.updatedAt = DateTime.now().toUtc().toIso8601String();
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_row != null) store.saveDraft(_row!);
    });
  }

  Map<String, String> _validateStep() {
    final errors = <String, String>{};
    for (final field in sections[_step].fields) {
      if (!field.required) continue;
      final value = _row!.answers[field.id];
      if (field.type == FieldType.multi) {
        if (value is! List || value.isEmpty) errors[field.id] = 'required';
      } else if (field.type == FieldType.number) {
        if (value == null || value.toString().isEmpty || double.tryParse(value.toString()) == null) {
          errors[field.id] = 'required';
        }
      } else if (value == null || value.toString().isEmpty) {
        errors[field.id] = 'required';
      }
    }
    return errors;
  }

  Future<void> _next() async {
    final errors = _validateStep();
    setState(() => _errors = errors);
    if (errors.isNotEmpty) {
      if (_scroll.hasClients) {
        _scroll.animateTo(0, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
      }
      return;
    }
    if (_step < sections.length - 1) {
      setState(() => _step += 1);
      return;
    }
    if (_busy) return;
    setState(() => _busy = true);
    final id = _row!.clientId;
    await store.enqueue(_row!);
    if (!mounted) return;
    widget.onDone(id);
  }

  @override
  Widget build(BuildContext context) {
    final row = _row;
    if (row == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final section = sections[_step];

    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(TroveySpace.md, TroveySpace.md, TroveySpace.md, TroveySpace.lg),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < sections.length; i++) ...[
                        if (i > 0) const SizedBox(width: TroveySpace.sm),
                        FilterChip(
                          selected: i == _step,
                          label: Text('${i + 1}  ${sections[i].title(store.locale)}'),
                          onSelected: i <= _step
                              ? (_) => setState(() {
                                    _step = i;
                                    _errors = {};
                                  })
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: TroveySpace.md),
                HorizonBar(step: _step, total: sections.length),
                const SizedBox(height: TroveySpace.sm),
                Text(
                  store.t('draftSaved'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.extension<AppColors>()?.success ?? theme.colorScheme.primary,
                  ),
                ),
                if (_errors.isNotEmpty) ...[
                  const SizedBox(height: TroveySpace.md),
                  FieldErrorSummary(message: store.t('errorSummary')),
                ],
                const SizedBox(height: TroveySpace.md),
                if (_step == 0) ...[
                  Text(store.t('topicTitle'), style: theme.textTheme.titleLarge),
                  const SizedBox(height: TroveySpace.sm),
                  Text(
                    store.t('topicBody'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: TroveySpace.lg),
                ],
                Text(section.title(store.locale), style: theme.textTheme.headlineSmall),
                if (section.hint(store.locale) != null)
                  Padding(
                    padding: const EdgeInsets.only(top: TroveySpace.sm, bottom: TroveySpace.md),
                    child: Text(
                      section.hint(store.locale)!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: TroveySpace.md),
                ...section.fields.map(
                  (field) => FieldBlock(
                    field: field,
                    answers: row.answers,
                    locale: store.locale,
                    error: _errors.containsKey(field.id),
                    photoB64: row.photoB64,
                    onPhoto: (b64) => _touch(() => row.photoB64 = b64),
                    onChanged: (value) => _touch(() {
                      row.answers[field.id] = value;
                      _errors.remove(field.id);
                    }),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: theme.colorScheme.surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(TroveySpace.md, TroveySpace.sm, TroveySpace.md, TroveySpace.md),
                child: Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: GhostButton(
                          label: store.t('back'),
                          onPressed: () => setState(() {
                            _step -= 1;
                            _errors = {};
                          }),
                        ),
                      )
                    else
                      Expanded(
                        child: GhostButton(
                          label: store.t('saveDraft'),
                          onPressed: () async {
                            await store.saveDraft(row);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(store.t('draftSaved'))),
                              );
                            }
                          },
                        ),
                      ),
                    const SizedBox(width: TroveySpace.sm),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: _step == sections.length - 1
                            ? (_busy ? store.t('submitting') : store.t('seeResults'))
                            : store.t('next'),
                        busy: _busy,
                        onPressed: _next,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
