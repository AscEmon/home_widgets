class HadithModel {
  final int id;
  final String title;
  final String narrator;
  final String text;
  final String reference;
  final String chapter;
  final int bookNumber;
  final int hadithNumber;
  final DateTime date;

  HadithModel({
    required this.id,
    required this.title,
    required this.narrator,
    required this.text,
    required this.reference,
    required this.chapter,
    required this.bookNumber,
    required this.hadithNumber,
    required this.date,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      narrator: json['narrator'] ?? '',
      text: json['text'] ?? '',
      reference: json['reference'] ?? '',
      chapter: json['chapter'] ?? '',
      bookNumber: json['book_number'] ?? 0,
      hadithNumber: json['hadith_number'] ?? 0,
      date: json['date'] ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'narrator': narrator,
      'text': text,
      'reference': reference,
      'chapter': chapter,
      'book_number': bookNumber,
      'hadith_number': hadithNumber,
    };
  }
}

class HadithResponse {
  final bool success;
  final List<HadithModel> data;
  final String message;

  HadithResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory HadithResponse.fromJson(Map<String, dynamic> json) {
    return HadithResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List?)
              ?.map((e) => HadithModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message'] ?? '',
    );
  }
}

class DailyHadith {
  final int id;
  final String text;
  final String narrator;
  final String reference;
  final DateTime date;

  DailyHadith({
    required this.id,
    required this.text,
    required this.narrator,
    required this.reference,
    required this.date,
  });

  factory DailyHadith.fromJson(Map<String, dynamic> json) {
    return DailyHadith(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      narrator: json['narrator'] ?? '',
      reference: json['reference'] ?? '',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'narrator': narrator,
      'reference': reference,
      'date': date.toIso8601String(),
    };
  }
}
