import 'package:flutter/material.dart';

import 'data/store.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';
import 'screens/home_screen.dart';
import 'screens/results_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/tokens.dart';
import 'widgets/chrome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = TroveyStore();
  await store.init();
  runApp(TroveyApp(store: store));
}

class TroveyApp extends StatelessWidget {
  const TroveyApp({super.key, required this.store});
  final TroveyStore store;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return MaterialApp(
          title: 'Trovey',
          debugShowCheckedModeBanner: false,
          theme: TroveyTheme.paper(),
          darkTheme: TroveyTheme.night(),
          themeMode: store.settings.isNight ? ThemeMode.dark : ThemeMode.light,
          home: Shell(store: store),
        );
      },
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key, required this.store});
  final TroveyStore store;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;
  String? _formId;
  String? _detailId;
  String? _highlightId;

  TroveyStore get store => widget.store;

  bool get _inFlow => _tab == 3 || _tab == 4;

  void _open(String route, {String? id}) {
    setState(() {
      if (route == 'form') {
        _tab = 3;
        _formId = id;
        _detailId = null;
      } else if (route == 'detail' && id != null) {
        _tab = 4;
        _detailId = id;
      } else if (route == 'results') {
        _tab = 1;
        _detailId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        store: store,
        title: _title(),
        leading: _inFlow
            ? IconButton(
                tooltip: store.t('back'),
                onPressed: () => setState(() {
                  _tab = _tab == 4 ? 1 : 0;
                  _formId = null;
                  _detailId = null;
                }),
                icon: const Icon(Icons.arrow_back),
              )
            : null,
      ),
      body: SafeArea(child: PageWidth(child: _body())),
      bottomNavigationBar: _inFlow
          ? null
          : NavigationBar(
              selectedIndex: _tab > 2 ? 0 : _tab,
              onDestinationSelected: (i) => setState(() {
                _tab = i;
                _detailId = null;
                _formId = null;
              }),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: store.t('home'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.bar_chart_outlined),
                  selectedIcon: const Icon(Icons.bar_chart),
                  label: store.t('results'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: store.t('settings'),
                ),
              ],
            ),
    );
  }

  String _title() {
    return switch (_tab) {
      1 => store.t('results'),
      2 => store.t('settings'),
      3 => store.t('newInterview'),
      4 => store.t('results'),
      _ => 'Trovey',
    };
  }

  Widget _body() {
    switch (_tab) {
      case 1:
        return ResultsScreen(
          store: store,
          highlightId: _highlightId,
          onNew: () => _open('form'),
          onOpen: (id) => _open('detail', id: id),
        );
      case 2:
        return SettingsScreen(store: store);
      case 3:
        return FormScreen(
          store: store,
          resumeId: _formId,
          onDone: (id) => setState(() {
            _highlightId = id;
            _tab = 1;
            _formId = null;
          }),
        );
      case 4:
        return DetailScreen(
          store: store,
          id: _detailId!,
          onBack: () => setState(() => _tab = 1),
          onEdit: () => _open('form', id: _detailId),
        );
      default:
        return HomeScreen(store: store, onOpen: _open);
    }
  }
}
