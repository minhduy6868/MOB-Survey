import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../data/i18n.dart';
import '../data/models.dart';
import '../data/survey.dart';
import '../theme/tokens.dart';
import 'chrome.dart';

class FieldBlock extends StatelessWidget {
  const FieldBlock({
    super.key,
    required this.field,
    required this.answers,
    required this.locale,
    required this.error,
    required this.onChanged,
    this.photoB64,
    this.onPhoto,
  });

  final FieldDef field;
  final Map<String, dynamic> answers;
  final String locale;
  final bool error;
  final ValueChanged<dynamic> onChanged;
  final String? photoB64;
  final ValueChanged<String?>? onPhoto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TroveySpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldLabel(field.id, locale) + (field.required ? ' *' : ''),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: TroveySpace.sm),
          _control(context),
          if (error)
            Padding(
              padding: const EdgeInsets.only(top: TroveySpace.sm),
              child: Text(
                tr(locale, 'required'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _control(BuildContext context) {
    switch (field.type) {
      case FieldType.text:
        return _text(false);
      case FieldType.long:
        return _text(true);
      case FieldType.phone:
        return TextFormField(
          initialValue: '${answers[field.id] ?? ''}',
          keyboardType: TextInputType.phone,
          onChanged: onChanged,
        );
      case FieldType.number:
        return TextFormField(
          initialValue: '${answers[field.id] ?? ''}',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          onChanged: onChanged,
        );
      case FieldType.dropdown:
        final current = '${answers[field.id] ?? ''}';
        return DropdownMenu<String>(
          initialSelection: current.isEmpty ? null : current,
          hintText: tr(locale, 'chooseCountry'),
          enableFilter: true,
          requestFocusOnTap: true,
          expandedInsets: EdgeInsets.zero,
          dropdownMenuEntries: field.options
              .map((opt) => DropdownMenuEntry<String>(value: opt.value, label: opt.label(locale)))
              .toList(),
          onSelected: (value) {
            if (value != null) onChanged(value);
          },
        );
      case FieldType.single:
        return Wrap(
          spacing: TroveySpace.sm,
          runSpacing: TroveySpace.sm,
          children: field.options.map((opt) {
            final selected = answers[field.id] == opt.value;
            return ChoiceChip(
              label: Text(opt.label(locale)),
              selected: selected,
              onSelected: (_) => onChanged(opt.value),
            );
          }).toList(),
        );
      case FieldType.multi:
        final selected = List<String>.from(answers[field.id] as List? ?? const []);
        return Wrap(
          spacing: TroveySpace.sm,
          runSpacing: TroveySpace.sm,
          children: field.options.map((opt) {
            final on = selected.contains(opt.value);
            return FilterChip(
              label: Text(opt.label(locale)),
              selected: on,
              onSelected: (next) {
                final copy = [...selected];
                if (next) {
                  copy.add(opt.value);
                } else {
                  copy.remove(opt.value);
                }
                onChanged(copy);
              },
            );
          }).toList(),
        );
      case FieldType.yesno:
        return ChoicePair(
          yesLabel: tr(locale, 'yes'),
          noLabel: tr(locale, 'no'),
          value: answers[field.id]?.toString(),
          onChanged: onChanged,
        );
      case FieldType.gps:
        return _GpsField(answers: answers, locale: locale, onChanged: onChanged);
      case FieldType.photo:
        return _PhotoField(
          locale: locale,
          photoB64: photoB64,
          onPhoto: onPhoto ?? (_) {},
        );
    }
  }

  Widget _text(bool long) {
    return TextFormField(
      initialValue: '${answers[field.id] ?? ''}',
      minLines: long ? 3 : 1,
      maxLines: long ? 6 : 1,
      onChanged: onChanged,
    );
  }
}

class _GpsField extends StatelessWidget {
  const _GpsField({
    required this.answers,
    required this.locale,
    required this.onChanged,
  });

  final Map<String, dynamic> answers;
  final String locale;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    final gps = answers['gps'];
    String summary = '';
    if (gps is Map && gps['lat'] != null) {
      summary = '${gps['lat']} , ${gps['lng']}  ±${gps['accuracy']}m';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (summary.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: TroveySpace.sm),
            child: Text(
              summary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).extension<AppColors>()?.success ?? Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        Wrap(
          spacing: TroveySpace.sm,
          runSpacing: TroveySpace.sm,
          children: [
            GhostButton(
              label: tr(locale, 'captureGps'),
              onPressed: () async {
                final permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.denied ||
                    permission == LocationPermission.deniedForever) {
                  onChanged(null);
                  return;
                }
                final pos = await Geolocator.getCurrentPosition();
                onChanged({
                  'lat': pos.latitude,
                  'lng': pos.longitude,
                  'accuracy': pos.accuracy,
                  'at': DateTime.now().toUtc().toIso8601String(),
                });
              },
            ),
            GhostButton(
              label: tr(locale, 'skipGps'),
              onPressed: () => onChanged(null),
            ),
          ],
        ),
        if (gps == null)
          Padding(
            padding: const EdgeInsets.only(top: TroveySpace.sm),
            child: TextFormField(
              initialValue: '${answers['gpsSkipped'] ?? ''}',
              decoration: InputDecoration(hintText: tr(locale, 'skipReason')),
              onChanged: (v) => answers['gpsSkipped'] = v,
            ),
          ),
      ],
    );
  }
}

class _PhotoField extends StatelessWidget {
  const _PhotoField({
    required this.locale,
    required this.photoB64,
    required this.onPhoto,
  });

  final String locale;
  final String? photoB64;
  final ValueChanged<String?> onPhoto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (photoB64 != null && photoB64!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: TroveySpace.sm),
            child: Image.memory(base64Decode(photoB64!), height: 120, fit: BoxFit.cover),
          ),
        Wrap(
          spacing: TroveySpace.sm,
          children: [
            GhostButton(
              label: tr(locale, 'takePhoto'),
              onPressed: () async {
                final file = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1280,
                  imageQuality: 70,
                );
                if (file == null) return;
                final bytes = await file.readAsBytes();
                onPhoto(base64Encode(bytes));
              },
            ),
            if (photoB64 != null)
              GhostButton(label: tr(locale, 'removePhoto'), onPressed: () => onPhoto(null)),
          ],
        ),
      ],
    );
  }
}
