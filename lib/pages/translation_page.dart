import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

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
];

const Map<String, List<LocalizedOption>> _stylesByLanguage = {
  '中文': [
    LocalizedOption('普通话', {
      AppLocale.zh: '普通话（标准中文）',
      AppLocale.en: 'Standard Chinese',
      AppLocale.ja: '標準中国語',
    }),
    LocalizedOption('北京话', {
      AppLocale.zh: '北京话',
      AppLocale.en: 'Beijing Mandarin',
      AppLocale.ja: '北京語',
    }),
    LocalizedOption('东北话', {
      AppLocale.zh: '东北话',
      AppLocale.en: 'Northeast Mandarin',
      AppLocale.ja: '東北語',
    }),
    LocalizedOption('上海话', {
      AppLocale.zh: '上海话',
      AppLocale.en: 'Shanghainese',
      AppLocale.ja: '上海語',
    }),
    LocalizedOption('广东话', {
      AppLocale.zh: '广东话（粤语）',
      AppLocale.en: 'Cantonese',
      AppLocale.ja: '広東語',
    }),
    LocalizedOption('客家话', {
      AppLocale.zh: '客家话',
      AppLocale.en: 'Hakka',
      AppLocale.ja: '客家語',
    }),
    LocalizedOption('四川话', {
      AppLocale.zh: '四川话',
      AppLocale.en: 'Sichuanese',
      AppLocale.ja: '四川語',
    }),
  ],
  'English': [
    LocalizedOption('皇室贵族英语', {
      AppLocale.zh: '皇室贵族英语 (RP)',
      AppLocale.en: 'Received Pronunciation (RP)',
      AppLocale.ja: 'RP',
    }),
    LocalizedOption('伦敦东区贫民英语', {
      AppLocale.zh: '伦敦东区贫民英语 (Cockney)',
      AppLocale.en: 'Cockney',
      AppLocale.ja: 'コックニー',
    }),
    LocalizedOption('利物浦蓝领英语', {
      AppLocale.zh: '利物浦蓝领英语 (Scouse)',
      AppLocale.en: 'Scouse',
      AppLocale.ja: 'スカウス',
    }),
    LocalizedOption('纽卡斯尔工薪英语', {
      AppLocale.zh: '纽卡斯尔工薪英语 (Geordie)',
      AppLocale.en: 'Geordie',
      AppLocale.ja: 'ジョーディー',
    }),
    LocalizedOption('苏格兰高地英语', {
      AppLocale.zh: '苏格兰高地英语 (Scottish Brogue)',
      AppLocale.en: 'Scottish Brogue',
      AppLocale.ja: 'スコティッシュブローグ',
    }),
    LocalizedOption('爱尔兰乡间英语', {
      AppLocale.zh: '爱尔兰乡间英语 (Irish Brogue)',
      AppLocale.en: 'Irish Brogue',
      AppLocale.ja: 'アイリッシュブローグ',
    }),
    LocalizedOption('英国叛逆青年英语', {
      AppLocale.zh: '英国叛逆青年英语 (Chav Speak)',
      AppLocale.en: 'Chav Speak',
      AppLocale.ja: 'チャヴスラング',
    }),
    LocalizedOption('常春藤精英英语', {
      AppLocale.zh: '常春藤精英英语 (Mid-Atlantic)',
      AppLocale.en: 'Mid-Atlantic',
      AppLocale.ja: 'ミッドアトランティック',
    }),
    LocalizedOption('非裔街头英语', {
      AppLocale.zh: '非裔街头英语 (AAVE/Ebonics)',
      AppLocale.en: 'AAVE / Ebonics',
      AppLocale.ja: 'AAVE',
    }),
    LocalizedOption('南方红脖子英语', {
      AppLocale.zh: '南方红脖子英语 (Redneck/Southern Drawl)',
      AppLocale.en: 'Southern Drawl',
      AppLocale.ja: 'サザンドロール',
    }),
    LocalizedOption('加州山谷女孩英语', {
      AppLocale.zh: '加州山谷女孩英语 (Valley Girl)',
      AppLocale.en: 'Valley Girl',
      AppLocale.ja: 'バレーガール',
    }),
    LocalizedOption('纽约蓝领工薪英语', {
      AppLocale.zh: '纽约蓝领工薪英语 (New York Accent)',
      AppLocale.en: 'New York Accent',
      AppLocale.ja: 'ニューヨーク訛り',
    }),
    LocalizedOption('德州牛仔英语', {
      AppLocale.zh: '德州牛仔英语 (Texan English)',
      AppLocale.en: 'Texan English',
      AppLocale.ja: 'テキサス訛り',
    }),
    LocalizedOption('波士顿码头英语', {
      AppLocale.zh: '波士顿码头英语 (Boston Accent)',
      AppLocale.en: 'Boston Accent',
      AppLocale.ja: 'ボストン訛り',
    }),
    LocalizedOption('澳洲懒散土澳英语', {
      AppLocale.zh: '澳洲懒散土澳英语 (Strine)',
      AppLocale.en: 'Strine',
      AppLocale.ja: 'オージー訛り',
    }),
    LocalizedOption('新加坡式混合英语', {
      AppLocale.zh: '新加坡式混合英语 (Singlish)',
      AppLocale.en: 'Singlish',
      AppLocale.ja: 'シングリッシュ',
    }),
    LocalizedOption('印度式英语', {
      AppLocale.zh: '印度式英语 (Hinglish)',
      AppLocale.en: 'Hinglish',
      AppLocale.ja: 'ヒングリッシュ',
    }),
    LocalizedOption('牙买加雷鬼英语', {
      AppLocale.zh: '牙买加雷鬼英语 (Patois)',
      AppLocale.en: 'Patois',
      AppLocale.ja: 'パトワ',
    }),
    LocalizedOption('尼日利亚皮钦英语', {
      AppLocale.zh: '尼日利亚皮钦英语 (Pidgin)',
      AppLocale.en: 'Pidgin',
      AppLocale.ja: 'ピジン',
    }),
    LocalizedOption('加勒比海盗式英语', {
      AppLocale.zh: '加勒比海盗式英语 (West Country Dialect)',
      AppLocale.en: 'West Country Dialect',
      AppLocale.ja: 'ウェストカントリー方言',
    }),
  ],
  'Japanese': [
    LocalizedOption('关西腔', {
      AppLocale.zh: '关西腔 (Kansai-ben)',
      AppLocale.en: 'Kansai-ben',
      AppLocale.ja: '関西弁',
    }),
    LocalizedOption('京都腔', {
      AppLocale.zh: '京都腔 (Kyoto-ben/Kyo-kotoba)',
      AppLocale.en: 'Kyoto-ben',
      AppLocale.ja: '京言葉',
    }),
    LocalizedOption('博多腔', {
      AppLocale.zh: '博多腔 (Hakata-ben)',
      AppLocale.en: 'Hakata-ben',
      AppLocale.ja: '博多弁',
    }),
    LocalizedOption('广岛腔', {
      AppLocale.zh: '广岛腔 (Hiroshima-ben)',
      AppLocale.en: 'Hiroshima-ben',
      AppLocale.ja: '広島弁',
    }),
    LocalizedOption('东北腔', {
      AppLocale.zh: '东北腔 (Tohoku-ben/Zuzu-ben)',
      AppLocale.en: 'Tohoku-ben',
      AppLocale.ja: '東北弁',
    }),
    LocalizedOption('名古屋腔', {
      AppLocale.zh: '名古屋腔 (Nagoya-ben)',
      AppLocale.en: 'Nagoya-ben',
      AppLocale.ja: '名古屋弁',
    }),
    LocalizedOption('萨摩腔', {
      AppLocale.zh: '萨摩腔 (Satsuma-ben)',
      AppLocale.en: 'Satsuma-ben',
      AppLocale.ja: '薩摩弁',
    }),
    LocalizedOption('冲绳腔', {
      AppLocale.zh: '冲绳腔 (Uchinaa-guchi)',
      AppLocale.en: 'Uchinaa-guchi',
      AppLocale.ja: 'ウチナーグチ',
    }),
    LocalizedOption('皇室贵族语', {
      AppLocale.zh: '皇室贵族语 (Gokou-kotoba)',
      AppLocale.en: 'Gokou-kotoba',
      AppLocale.ja: '御公家言葉',
    }),
    LocalizedOption('江户下町庶民语', {
      AppLocale.zh: '江户下町庶民语 (Edomae-kotoba)',
      AppLocale.en: 'Edomae-kotoba',
      AppLocale.ja: '江戸前言葉',
    }),
    LocalizedOption('极道黑帮用语', {
      AppLocale.zh: '极道黑帮用语 (Gokudo-yogo)',
      AppLocale.en: 'Gokudo-yogo',
      AppLocale.ja: '極道用語',
    }),
    LocalizedOption('职场公文敬语', {
      AppLocale.zh: '职场公文敬语 (Keigo/Business Japanese)',
      AppLocale.en: 'Keigo / Business Japanese',
      AppLocale.ja: '敬語',
    }),
    LocalizedOption('大小姐语气', {
      AppLocale.zh: '大小姐语气 (Ojou-sama kotoba)',
      AppLocale.en: 'Ojou-sama kotoba',
      AppLocale.ja: 'お嬢様言葉',
    }),
    LocalizedOption('热血少年漫语气', {
      AppLocale.zh: '热血少年漫语气 (Shonen-manga style)',
      AppLocale.en: 'Shonen-manga style',
      AppLocale.ja: '少年漫画口調',
    }),
    LocalizedOption('傲娇语气', {
      AppLocale.zh: '傲娇语气 (Tsundere tone)',
      AppLocale.en: 'Tsundere tone',
      AppLocale.ja: 'ツンデレ口調',
    }),
    LocalizedOption('大叔/顽固老头语', {
      AppLocale.zh: '大叔/顽固老头语 (Oyaji-kotoba)',
      AppLocale.en: 'Oyaji-kotoba',
      AppLocale.ja: '親父言葉',
    }),
    LocalizedOption('辣妹语', {
      AppLocale.zh: '辣妹语 (Gyaru-go)',
      AppLocale.en: 'Gyaru-go',
      AppLocale.ja: 'ギャル語',
    }),
    LocalizedOption('执事/管家语', {
      AppLocale.zh: '执事/管家语 (Shitsuji-kotoba)',
      AppLocale.en: 'Shitsuji-kotoba',
      AppLocale.ja: '執事言葉',
    }),
    LocalizedOption('死宅用语', {
      AppLocale.zh: '死宅用语 (Otaku-yogo)',
      AppLocale.en: 'Otaku-yogo',
      AppLocale.ja: 'オタク用語',
    }),
    LocalizedOption('网络隐语', {
      AppLocale.zh: '网络隐语 (Net-slang/2channel style)',
      AppLocale.en: 'Net-slang / 2channel style',
      AppLocale.ja: 'ネットスラング',
    }),
    LocalizedOption('男大姐/跨性别语气', {
      AppLocale.zh: '男大姐/跨性别语气 (Onee-kotoba)',
      AppLocale.en: 'Onee-kotoba',
      AppLocale.ja: 'オネエ言葉',
    }),
    LocalizedOption('中日混杂语', {
      AppLocale.zh: '中日混杂语 (Kyowa-go/Co-prosperous Japanese)',
      AppLocale.en: 'Kyowa-go',
      AppLocale.ja: '興亜語',
    }),
  ],
};

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

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key, required this.locale});

  final AppLocale locale;

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final TextEditingController _controller = TextEditingController();
  late final TextEditingController _styleController;
  static const String _customStyleValue = '__custom__';
  String _selectedLang = _translateLanguages.first.value;
  String _selectedStyle = _stylesByLanguage[_translateLanguages.first.value]!.first.value;
  String _styleQuery = '';
  String _sourceLang = 'zh';
  bool _sourceLangAuto = true;
  String _degree = _degrees.first.code;
  String _tone = _tones[1].code;
  String _result = '';
  String _analysis = '';
  String _analysisError = '';
  bool _analyze = true;
  bool _isLoading = false;

  // Filter styles based on selected language
  List<LocalizedOption> get _filteredStyles {
    return _stylesByLanguage[_selectedLang] ?? [];
  }

  List<LocalizedOption> get _styleSuggestions {
    if (_selectedStyle != _customStyleValue) return [];
    final query = _styleQuery.trim();
    if (query.isEmpty) return [];
    return _filteredStyles.where((option) => _matchesQuery(query, option)).toList();
  }

  String get _effectiveStyle {
    if (_selectedStyle == _customStyleValue) {
      return _styleQuery.trim();
    }
    return _selectedStyle;
  }

  bool _matchesQuery(String query, LocalizedOption option) {
    final normalizedQuery = query.toLowerCase();
    if (option.value.toLowerCase().contains(normalizedQuery)) {
      return true;
    }
    for (final label in option.labels.values) {
      if (label.toLowerCase().contains(normalizedQuery)) {
        return true;
      }
    }
    return false;
  }

  // final String _apiUrl = 'http://10.1.151.23:8080/translate';
  final String _apiUrl = 'http://127.0.0.1:8080/translate';
  @override
  void initState() {
    super.initState();
    _sourceLang = localeCode(widget.locale);
    _styleController = TextEditingController(
      text: _filteredStyles.isNotEmpty ? _filteredStyles.first.label(widget.locale) : '',
    );
    if (_filteredStyles.isNotEmpty) {
      _selectedStyle = _filteredStyles.first.value;
    }
  }

  @override
  void didUpdateWidget(covariant TranslationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale && _sourceLangAuto) {
      setState(() {
        _sourceLang = localeCode(widget.locale);
      });
    }
    if (oldWidget.locale != widget.locale) {
      if (_selectedStyle == _customStyleValue) {
        return;
      }
      final match = _filteredStyles.where((opt) => opt.value == _selectedStyle).toList();
      if (match.isNotEmpty) {
        _styleController.text = match.first.label(widget.locale);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _styleController.dispose();
    super.dispose();
  }

  Future<void> _handleTranslate() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = '';
      _analysis = '';
      _analysisError = '';
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': _controller.text,
          'source_lang': _sourceLang,
          'target_lang': _selectedLang,
          'target_style': _effectiveStyle,
          'degree': _degree,
          'tone': _tone,
          'analyze': _analyze,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['status'] == 'error') {
          setState(() {
            _result = (data['message'] ?? '').toString();
          });
          return;
        }
        setState(() {
          _result = (data['translation'] ?? '').toString();
          final analysis = data['analysis'];
          if (analysis is String) {
            _analysis = analysis;
          } else if (analysis != null) {
            _analysis = const JsonEncoder.withIndent('  ').convert(analysis);
            _analysis = '```\n$_analysis\n```';
          } else {
            _analysis = '';
          }
          _analysisError = (data['analysis_error'] ?? '').toString();
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
          Text(
            t(widget.locale, 'introText'),
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
          const SizedBox(height: 12),
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
                      final styles = _stylesByLanguage[_selectedLang] ?? [];
                      if (styles.isNotEmpty) {
                        _selectedStyle = styles.first.value;
                        _styleController.text = styles.first.label(widget.locale);
                      }
                      _styleQuery = '';
                    });
                  },
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedStyle,
                      decoration: InputDecoration(labelText: t(widget.locale, 'style')),
                      items: [
                        DropdownMenuItem(
                          value: _customStyleValue,
                          child: Text(t(widget.locale, 'customStyle')),
                        ),
                        ..._filteredStyles.map((opt) => DropdownMenuItem(
                              value: opt.value,
                              child: Text(opt.label(widget.locale)),
                            )),
                      ],
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() {
                          _selectedStyle = val;
                          if (val == _customStyleValue) {
                            _styleController.text = _styleQuery;
                          } else {
                            final match = _filteredStyles.where((opt) => opt.value == val).toList();
                            _styleController.text =
                                match.isNotEmpty ? match.first.label(widget.locale) : '';
                            _styleQuery = '';
                          }
                        });
                      },
                    ),
                    if (_selectedStyle == _customStyleValue) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _styleController,
                        decoration: InputDecoration(
                          labelText: t(widget.locale, 'customStyle'),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _styleQuery = val;
                          });
                        },
                      ),
                    ],
                    if (_styleSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _styleSuggestions.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: Colors.grey.shade200,
                          ),
                          itemBuilder: (context, index) {
                            final option = _styleSuggestions[index];
                            return ListTile(
                              dense: true,
                              title: Text(option.label(widget.locale)),
                              onTap: () {
                                setState(() {
                                  _selectedStyle = option.value;
                                  _styleController.text = option.label(widget.locale);
                                  _styleQuery = '';
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ],
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
          const SizedBox(height: 12),
          Row(
            children: [
              Text(t(widget.locale, 'analysisToggle')),
              const Spacer(),
              Switch(
                value: _analyze,
                onChanged: (val) => setState(() => _analyze = val),
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
          if (_analysis.isNotEmpty || _analysisError.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t(widget.locale, 'analysisTitle'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_analysis.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    MarkdownBody(
                      data: _analysis,
                      styleSheet: MarkdownStyleSheet.fromTheme(context).copyWith(
                        p: const TextStyle(height: 1.5),
                        blockSpacing: 12,
                        h1: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        h2: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        h3: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        strong: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  if (_analysisError.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _analysisError,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
