import 'strings/strings_en.dart';
import 'strings/strings_ja.dart';
import 'strings/strings_zh.dart';

enum AppLocale { zh, en, ja }

String t(AppLocale locale, String key) {
  return _strings[locale]?[key] ?? key;
}

const Map<AppLocale, Map<String, String>> _strings = {
  AppLocale.zh: zhStrings,
  AppLocale.en: enStrings,
  AppLocale.ja: jaStrings,
};

String localeCode(AppLocale locale) {
  switch (locale) {
    case AppLocale.zh:
      return 'zh';
    case AppLocale.en:
      return 'en';
    case AppLocale.ja:
      return 'ja';
  }
}
