import 'dart:convert';

import 'package:http/http.dart' as http;

const _configuredApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://169.58.165.98:8001/api/v1',
);

class CatalogApiClient {
  const CatalogApiClient({this.baseUrl = _configuredApiBaseUrl, this.client});

  final String baseUrl;
  final http.Client? client;

  String get _normalizedBaseUrl => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;

  Future<List<CatalogSubject>> fetchSubjects() async {
    final uri = Uri.parse('$_normalizedBaseUrl/catalog/subjects/');
    final response = await (client?.get(uri) ?? http.get(uri)).timeout(
      const Duration(seconds: 15),
    );
    if (response.statusCode != 200) {
      throw CatalogException(
        'The catalog server returned ${response.statusCode}.',
      );
    }
    final value = jsonDecode(utf8.decode(response.bodyBytes));
    if (value is! List<dynamic>) {
      throw const CatalogException('The catalog server returned invalid data.');
    }
    return value
        .map((item) => CatalogSubject.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CatalogSubject> fetchSubject(String slug) async {
    final uri = Uri.parse('$_normalizedBaseUrl/catalog/subjects/$slug/');
    final response = await (client?.get(uri) ?? http.get(uri)).timeout(
      const Duration(seconds: 15),
    );
    if (response.statusCode != 200) {
      throw CatalogException(
        'The catalog server returned ${response.statusCode}.',
      );
    }
    final value = jsonDecode(utf8.decode(response.bodyBytes));
    if (value is! Map<String, dynamic>) {
      throw const CatalogException('The catalog server returned invalid data.');
    }
    return CatalogSubject.fromJson(value);
  }
}

class CatalogException implements Exception {
  const CatalogException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CatalogSubject {
  const CatalogSubject({
    required this.slug,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.colorStart,
    required this.colorEnd,
    required this.coverImageUrl,
    required this.parts,
  });

  factory CatalogSubject.fromJson(Map<String, dynamic> json) {
    return CatalogSubject(
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      colorStart: json['color_start'] as String? ?? '#2563EB',
      colorEnd: json['color_end'] as String? ?? '#60A5FA',
      coverImageUrl: json['cover_image_url'] as String? ?? '',
      parts: (json['parts'] as List<dynamic>? ?? const [])
          .map(
            (item) => CatalogSubjectPart.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final String slug;
  final String name;
  final String subtitle;
  final String icon;
  final String colorStart;
  final String colorEnd;
  final String coverImageUrl;
  final List<CatalogSubjectPart> parts;
}

class CatalogSubjectPart {
  const CatalogSubjectPart({
    required this.id,
    required this.title,
    required this.description,
    required this.reviewBlocks,
  });

  factory CatalogSubjectPart.fromJson(Map<String, dynamic> json) {
    return CatalogSubjectPart(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      reviewBlocks: (json['review_blocks'] as List<dynamic>? ?? const [])
          .map(
            (item) => CatalogReviewBlock.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final int id;
  final String title;
  final String description;
  final List<CatalogReviewBlock> reviewBlocks;
}

class CatalogReviewBlock {
  const CatalogReviewBlock({
    required this.id,
    required this.title,
    required this.summary,
    required this.keyPoints,
    required this.recallPrompts,
    required this.estimatedMinutes,
  });

  factory CatalogReviewBlock.fromJson(Map<String, dynamic> json) {
    return CatalogReviewBlock(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      keyPoints: List<String>.from(
        json['key_points'] as List<dynamic>? ?? const [],
      ),
      recallPrompts: List<String>.from(
        json['recall_prompts'] as List<dynamic>? ?? const [],
      ),
      estimatedMinutes: json['estimated_minutes'] as int? ?? 50,
    );
  }

  final int id;
  final String title;
  final String summary;
  final List<String> keyPoints;
  final List<String> recallPrompts;
  final int estimatedMinutes;

  String memoryText({required String subjectName, required String partTitle}) {
    final buffer = StringBuffer()
      ..writeln('$subjectName — $partTitle')
      ..writeln()
      ..writeln(title)
      ..writeln()
      ..writeln(summary);
    if (keyPoints.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Key points');
      for (final point in keyPoints) {
        buffer.writeln('• $point');
      }
    }
    if (recallPrompts.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Active-recall prompts');
      for (var index = 0; index < recallPrompts.length; index++) {
        buffer.writeln('${index + 1}. ${recallPrompts[index]}');
      }
    }
    return buffer.toString().trim();
  }
}
