import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_localizations.dart';
import '../app_context.dart';

class FilterOption {
  const FilterOption(this.code, this.labels);

  final String code;
  final Map<AppLocale, String> labels;

  String label(AppLocale locale) => labels[locale] ?? code;
}

const List<FilterOption> _slangLangs = [
  FilterOption('zh', {
    AppLocale.zh: '中文',
    AppLocale.en: 'Chinese',
    AppLocale.ja: '中国語',
  }),
  FilterOption('en', {
    AppLocale.zh: '英文',
    AppLocale.en: 'English',
    AppLocale.ja: '英語',
  }),
  FilterOption('ja', {
    AppLocale.zh: '日文',
    AppLocale.en: 'Japanese',
    AppLocale.ja: '日本語',
  }),
];

const Map<String, List<FilterOption>> _slangDialectsByLang = {
  'zh': [
    FilterOption('standard', {
      AppLocale.zh: '普通话',
      AppLocale.en: 'Standard Chinese',
      AppLocale.ja: '標準中国語',
    }),
    FilterOption('cantonese', {
      AppLocale.zh: '粤语',
      AppLocale.en: 'Cantonese',
      AppLocale.ja: '広東語',
    }),
    FilterOption('beijing', {
      AppLocale.zh: '北京话',
      AppLocale.en: 'Beijing',
      AppLocale.ja: '北京語',
    }),
    FilterOption('northeast', {
      AppLocale.zh: '东北话',
      AppLocale.en: 'Northeast',
      AppLocale.ja: '東北語',
    }),
    FilterOption('sichuan', {
      AppLocale.zh: '四川话',
      AppLocale.en: 'Sichuan',
      AppLocale.ja: '四川語',
    }),
  ],
  'en': [
    FilterOption('standard', {
      AppLocale.zh: '美国英文',
      AppLocale.en: 'American English',
      AppLocale.ja: 'アメリカ英語',
    }),
    FilterOption('ny_street', {
      AppLocale.zh: '纽约街头',
      AppLocale.en: 'New York Street',
      AppLocale.ja: 'NY ストリート',
    }),
    FilterOption('london', {
      AppLocale.zh: '伦敦口吻',
      AppLocale.en: 'London Mate',
      AppLocale.ja: 'ロンドン口調',
    }),
    FilterOption('gangster', {
      AppLocale.zh: '黑帮',
      AppLocale.en: 'Gangster',
      AppLocale.ja: 'ギャング',
    }),
  ],
  'ja': [
    FilterOption('standard', {
      AppLocale.zh: '标准日语',
      AppLocale.en: 'Standard Japanese',
      AppLocale.ja: '標準語',
    }),
    FilterOption('tokyo', {
      AppLocale.zh: '东京',
      AppLocale.en: 'Tokyo',
      AppLocale.ja: '東京',
    }),
    FilterOption('kansai', {
      AppLocale.zh: '关西话',
      AppLocale.en: 'Kansai',
      AppLocale.ja: '関西弁',
    }),
  ],
};

class SlangItem {
  SlangItem({
    required this.term,
    required this.dialect,
    required this.meaningZh,
    required this.meaningEn,
    required this.meaningJa,
    required this.exampleZh,
    required this.exampleEn,
    required this.exampleJa,
  });

  final String term;
  final String dialect;
  final String meaningZh;
  final String meaningEn;
  final String meaningJa;
  final String exampleZh;
  final String exampleEn;
  final String exampleJa;

  String meaningForLocale(AppLocale locale) {
    switch (locale) {
      case AppLocale.zh:
        return meaningZh;
      case AppLocale.en:
        return meaningEn;
      case AppLocale.ja:
        return meaningJa;
    }
  }

  String exampleForLocale(AppLocale locale) {
    switch (locale) {
      case AppLocale.zh:
        return exampleZh;
      case AppLocale.en:
        return exampleEn;
      case AppLocale.ja:
        return exampleJa;
    }
  }

  factory SlangItem.fromJson(Map<String, dynamic> json) {
    return SlangItem(
      term: (json['term'] ?? '').toString(),
      dialect: (json['dialect'] ?? '').toString(),
      meaningZh: (json['meaning_zh'] ?? '').toString(),
      meaningEn: (json['meaning_en'] ?? '').toString(),
      meaningJa: (json['meaning_ja'] ?? '').toString(),
      exampleZh: (json['example_zh'] ?? '').toString(),
      exampleEn: (json['example_en'] ?? '').toString(),
      exampleJa: (json['example_ja'] ?? '').toString(),
    );
  }
}

class SlangResponse {
  SlangResponse({
    required this.items,
    required this.total,
  });

  final List<SlangItem> items;
  final int total;

  factory SlangResponse.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems.map((item) => SlangItem.fromJson(item as Map<String, dynamic>)).toList()
        : <SlangItem>[];
    final total = (json['total'] ?? items.length).toString();
    return SlangResponse(items: items, total: int.tryParse(total) ?? items.length);
  }
}

class SlangPage extends StatefulWidget {
  const SlangPage({super.key, required this.locale, required this.client});

  final AppLocale locale;
  final AppClientContext client;

  @override
  State<SlangPage> createState() => _SlangPageState();
}

class _SlangPageState extends State<SlangPage> {
  // final String _apiUrl = 'http://10.1.151.23:8080/slang';
  final String _apiUrl = 'http://127.0.0.1:8080/slang';
  final int _pageSize = 20;

  String _selectedLang = _slangLangs.first.code;
  int _page = 1;
  int _total = 0;
  bool _isLoading = false;
  String _error = '';
  List<SlangItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadSlang();
  }

  Future<void> _loadSlang() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'source_lang': _selectedLang,
          'dialect': 'standard',
          'page': _page,
          'page_size': _pageSize,
          'user_id': widget.client.userId,
          'session_id': widget.client.sessionId,
          'client_lang': localeCode(widget.locale),
          'app_version': widget.client.appVersion,
          'platform': widget.client.platform,
          'source_text_len': 0,
          'request_id': generateRequestId(),
          'lang': _selectedLang,
          'style': 'standard',
        }),
      );

      if (response.statusCode == 200) {
        final data = SlangResponse.fromJson(jsonDecode(response.body));
        setState(() {
          _items = data.items;
          _total = data.total;
        });
      } else {
        setState(() {
          _error = _errorFromResponse(response);
        });
      }
    } catch (e) {
      setState(() {
        _error = '${t(widget.locale, 'error')}: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _errorFromResponse(http.Response response) {
    if (response.body.isNotEmpty) {
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['detail'] != null) {
          return data['detail'].toString();
        }
      } catch (_) {}
    }
    return 'Error: ${response.statusCode}';
  }

  void _updateLang(String? code) {
    if (code == null) return;
    setState(() {
      _selectedLang = code;
      _page = 1;
    });
    _loadSlang();
  }

  void _prevPage() {
    if (_page <= 1) return;
    setState(() => _page -= 1);
    _loadSlang();
  }

  void _nextPage() {
    final totalPages = _total == 0 ? 0 : ((_total + _pageSize - 1) ~/ _pageSize);
    if (totalPages != 0 && _page >= totalPages) return;
    setState(() => _page += 1);
    _loadSlang();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = _total == 0 ? 0 : ((_total + _pageSize - 1) ~/ _pageSize);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedLang,
                  decoration: InputDecoration(labelText: t(widget.locale, 'filterLang')),
                  items: _slangLangs
                      .map((opt) => DropdownMenuItem(
                            value: opt.code,
                            child: Text(opt.label(widget.locale)),
                          ))
                      .toList(),
                  onChanged: _updateLang,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? Center(child: Text(t(widget.locale, 'loading')))
                : _error.isNotEmpty
                    ? Center(child: Text(_error))
                    : _items.isEmpty
                        ? Center(child: Text(t(widget.locale, 'empty')))
                        : ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              final meaning = item.meaningForLocale(widget.locale);
                              final example = item.exampleForLocale(widget.locale);
                              return Card(
                                elevation: 0,
                                color: Colors.deepPurple.withOpacity(0.04),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.deepPurple.withOpacity(0.15),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.term,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (item.dialect.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          item.dialect,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                      if (meaning.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(meaning),
                                      ],
                                      if (example.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          example,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _page <= 1 || _isLoading ? null : _prevPage,
                child: Text(t(widget.locale, 'prev')),
              ),
              const SizedBox(width: 12),
              Text(
                totalPages == 0
                    ? '${t(widget.locale, 'page')} $_page'
                    : '${t(widget.locale, 'page')} $_page / $totalPages',
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: _isLoading ? null : _nextPage,
                child: Text(t(widget.locale, 'next')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
