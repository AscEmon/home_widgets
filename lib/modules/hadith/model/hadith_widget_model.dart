import 'dart:convert';

class HadithWidgetModel {
  final int id;
  final String narrator;
  final String text;
  final String reference;
  final DateTime updatedAt;

  HadithWidgetModel({
    required this.id,
    required this.narrator,
    required this.text,
    required this.reference,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'narrator': narrator,
      'text': text,
      'reference': reference,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HadithWidgetModel.fromJson(Map<String, dynamic> json) {
    return HadithWidgetModel(
      id: json['id'] as int,
      narrator: json['narrator'] as String,
      text: json['text'] as String,
      reference: json['reference'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static String encode(HadithWidgetModel hadith) => json.encode(hadith.toJson());

  static HadithWidgetModel? decode(String? hadithJson) {
    if (hadithJson == null || hadithJson.isEmpty) return null;
    try {
      return HadithWidgetModel.fromJson(json.decode(hadithJson));
    } catch (e) {
      return null;
    }
  }
}
