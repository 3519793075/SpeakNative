import 'package:flutter/material.dart';

import 'app_context.dart';
import 'app_localizations.dart';
import 'pages/slang_page.dart';
import 'pages/translation_page.dart';

void main() {
  runApp(const SlangifyApp());
}

enum AppPage { translate, slang }

class SlangifyApp extends StatefulWidget {
  const SlangifyApp({super.key});

  @override
  State<SlangifyApp> createState() => _SlangifyAppState();
}

class _SlangifyAppState extends State<SlangifyApp> {
  AppPage _page = AppPage.translate;
  AppLocale _locale = AppLocale.zh;
  final AppClientContext _client = AppClientContext(
    userId: 'guest',
    sessionId: generateSessionId(),
    appVersion: const String.fromEnvironment('APP_VERSION', defaultValue: 'dev'),
    platform: currentPlatform(),
  );

  @override
  void initState() {
    super.initState();
    _locale = _resolveInitialLocale();
  }

  AppLocale _resolveInitialLocale() {
    final locales = WidgetsBinding.instance.platformDispatcher.locales;
    for (final locale in locales) {
      switch (locale.languageCode) {
        case 'zh':
          return AppLocale.zh;
        case 'en':
          return AppLocale.en;
        case 'ja':
          return AppLocale.ja;
      }
    }
    return AppLocale.zh;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: t(_locale, 'appTitle'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text('SpeakNative', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _NavButton(
                        label: t(_locale, 'navTranslate'),
                        selected: _page == AppPage.translate,
                        onPressed: () => setState(() => _page = AppPage.translate),
                      ),
                      const SizedBox(width: 8),
                      _NavButton(
                        label: t(_locale, 'navSlang'),
                        selected: _page == AppPage.slang,
                        onPressed: () => setState(() => _page = AppPage.slang),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  Text(t(_locale, 'uiLang')),
                  const SizedBox(width: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<AppLocale>(
                      value: _locale,
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() => _locale = val);
                      },
                      items: const [
                        DropdownMenuItem(value: AppLocale.zh, child: Text('中文')),
                        DropdownMenuItem(value: AppLocale.en, child: Text('English')),
                        DropdownMenuItem(value: AppLocale.ja, child: Text('日本語')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: _page == AppPage.translate
            ? TranslationPage(locale: _locale)
            : SlangPage(locale: _locale, client: _client),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
      ),
      child: Text(label),
    );
  }
}
