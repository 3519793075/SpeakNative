import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../app_localizations.dart';

class LocalizedOption {
  const LocalizedOption(this.value, this.labels);

  final String value;
  final Map<AppLocale, String> labels;

  String label(AppLocale locale) => labels[locale] ?? value;
}

const List<LocalizedOption> _translateLanguages = [
  LocalizedOption('English', {
    AppLocale.zh: '英语',
    AppLocale.en: 'English',
    AppLocale.ja: '英語',
  }),
  LocalizedOption('中文', {
    AppLocale.zh: '中文',
    AppLocale.en: 'Chinese',
    AppLocale.ja: '中国語',
  }),
  LocalizedOption('Japanese', {
    AppLocale.zh: '日语',
    AppLocale.en: 'Japanese',
    AppLocale.ja: '日本語',
  }),
  LocalizedOption('Cantonese', {
    AppLocale.zh: '粤语',
    AppLocale.en: 'Cantonese',
    AppLocale.ja: '広東語',
  }),
];

const List<LocalizedOption> _translateStyles = [
  LocalizedOption('New York Street', {
    AppLocale.zh: '纽约街头',
    AppLocale.en: 'New York Street',
    AppLocale.ja: 'NY ストリート',
  }),
  LocalizedOption('London Mate', {
    AppLocale.zh: '伦敦口吻',
    AppLocale.en: 'London Mate',
    AppLocale.ja: 'ロンドン口調',
  }),
  LocalizedOption('北京', {
    AppLocale.zh: '北京话',
    AppLocale.en: 'Beijing',
    AppLocale.ja: '北京語',
  }),
  LocalizedOption('东北', {
    AppLocale.zh: '东北话',
    AppLocale.en: 'Northeast',
    AppLocale.ja: '東北語',
  }),
  LocalizedOption('精神小伙', {
    AppLocale.zh: '精神小伙',
    AppLocale.en: 'Vibe Bro',
    AppLocale.ja: 'イケてる兄貴',
  }),
];

class CodeOption {
  const CodeOption(this.code, this.labels);

  final String code;
  final Map<AppLocale, String> labels;

  String label(AppLocale locale) => labels[locale] ?? code;
}

const List<CodeOption> _sourceLanguages = [
  CodeOption('zh', {
    AppLocale.zh: '中文',
    AppLocale.en: 'Chinese',
    AppLocale.ja: '中国語',
  }),
  CodeOption('en', {
    AppLocale.zh: '英文',
    AppLocale.en: 'English',
    AppLocale.ja: '英語',
  }),
  CodeOption('ja', {
    AppLocale.zh: '日文',
    AppLocale.en: 'Japanese',
    AppLocale.ja: '日本語',
  }),
];

const List<CodeOption> _degrees = [
  CodeOption('low', {
    AppLocale.zh: '低',
    AppLocale.en: 'Low',
    AppLocale.ja: '弱め',
  }),
  CodeOption('medium', {
    AppLocale.zh: '中',
    AppLocale.en: 'Medium',
    AppLocale.ja: '普通',
  }),
  CodeOption('high', {
    AppLocale.zh: '高',
    AppLocale.en: 'High',
    AppLocale.ja: '強め',
  }),
];

const List<CodeOption> _tones = [
  CodeOption('happy', {
    AppLocale.zh: '开心',
    AppLocale.en: 'Happy',
    AppLocale.ja: '喜び',
  }),
  CodeOption('neutral', {
    AppLocale.zh: '平淡',
    AppLocale.en: 'Neutral',
    AppLocale.ja: '平静',
  }),
  CodeOption('sad', {
    AppLocale.zh: '伤心',
    AppLocale.en: 'Sad',
    AppLocale.ja: '悲しみ',
  }),
  CodeOption('angry', {
    AppLocale.zh: '愤怒',
    AppLocale.en: 'Angry',
    AppLocale.ja: '怒り',
  }),
];

// Mapping of target languages to compatible speaking styles
const Map<String, List<String>> _compatibleStylesByLanguage = {
  'English': ['New York Street', 'London Mate'], // English can have NY street or London mate styles
  '中文': ['北京', '东北', '精神小伙'], // Chinese can have Beijing, Northeast, or Vibe Bro styles
  'Japanese': [], // Japanese doesn't have region-specific slang equivalents in the current list
  'Cantonese': ['New York Street', 'London Mate'], // Cantonese can have NY street or London mate styles
};

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key, required this.locale});

  final AppLocale locale;

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final TextEditingController _controller = TextEditingController();
  String _selectedLang = _translateLanguages.first.value;
  String _selectedStyle = _translateStyles.first.value;
  String _sourceLang = 'zh';
  bool _sourceLangAuto = true;
  String _degree = _degrees.first.code;
  String _tone = _tones[1].code;
  String _result = '';
  bool _isLoading = false;

  // Get filtered styles based on selected language
  List<LocalizedOption> get _filteredStyles {
    final compatibleStyles = _compatibleStylesByLanguage[_selectedLang] ?? [];
    if (compatibleStyles.isEmpty) {
      // If no compatible styles, return all styles
      return _translateStyles;
    }
    return _translateStyles.where((style) => compatibleStyles.contains(style.value)).toList();
  }

  final String _apiUrl = 'http://10.1.151.23:8080/translate';

  @override
  void initState() {
    super.initState();
    _sourceLang = localeCode(widget.locale);
  }

  @override
  void didUpdateWidget(covariant TranslationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale && _sourceLangAuto) {
      setState(() {
        _sourceLang = localeCode(widget.locale);
      });
    }
  }

  Future<void> _handleTranslate() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': _controller.text,
          'source_lang': _sourceLang,
          'target_lang': _selectedLang,
          'target_style': _selectedStyle,
          'degree': _degree,
          'tone': _tone,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _result = (data['translation'] ?? '').toString();
        });
      } else {
        setState(() {
          _result = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _result = '${t(widget.locale, 'error')}: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _sourceLang,
            decoration: InputDecoration(labelText: t(widget.locale, 'sourceLang')),
            items: _sourceLanguages
                .map((opt) => DropdownMenuItem(
                      value: opt.code,
                      child: Text(opt.label(widget.locale)),
                    ))
                .toList(),
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _sourceLang = val;
                _sourceLangAuto = false;
              });
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: t(widget.locale, 'inputHint'),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedLang,
                  decoration: InputDecoration(labelText: t(widget.locale, 'targetLang')),
                  items: _translateLanguages
                      .map((opt) => DropdownMenuItem(
                            value: opt.value,
                            child: Text(opt.label(widget.locale)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() {
                      _selectedLang = val;
                      // Reset style to first compatible option when language changes
                      final compatibleStyles = _compatibleStylesByLanguage[_selectedLang] ?? [];
                      if (compatibleStyles.isNotEmpty) {
                        _selectedStyle = compatibleStyles.first;
                      } else {
                        // If no compatible styles, keep current or use first available
                        _selectedStyle = _translateStyles.first.value;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStyle,
                  decoration: InputDecoration(labelText: t(widget.locale, 'style')),
                  items: _filteredStyles
                      .map((opt) => DropdownMenuItem(
                            value: opt.value,
                            child: Text(opt.label(widget.locale)),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedStyle = val ?? _selectedStyle),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _degree,
                  decoration: InputDecoration(labelText: t(widget.locale, 'degree')),
                  items: _degrees
                      .map((opt) => DropdownMenuItem(
                            value: opt.code,
                            child: Text(opt.label(widget.locale)),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _degree = val ?? _degree),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _tone,
                  decoration: InputDecoration(labelText: t(widget.locale, 'tone')),
                  items: _tones
                      .map((opt) => DropdownMenuItem(
                            value: opt.code,
                            child: Text(opt.label(widget.locale)),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _tone = val ?? _tone),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleTranslate,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(t(widget.locale, 'translate'), style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 30),
          if (_result.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _result,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: t(widget.locale, 'copy'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _result));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t(widget.locale, 'copied'))),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
