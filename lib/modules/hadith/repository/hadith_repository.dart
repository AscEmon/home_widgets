import 'dart:convert';

import '/constant/app_url.dart';
import '/utils/enum.dart';
import '/utils/network_request_builder.dart';
import '../model/hadith_model.dart';
import 'hadith_interface.dart';

class HadithRepository implements IHadithRepository {
  @override
  Future<List<HadithModel>> getHadithList({
    required int page,
    required int limit,
  }) async {
    List<HadithModel> hadithList = [];

    // Use API key in headers
    final apiKey = 'SqD712P3E82xnwOAEOkGd5JZH8s9wRR24TqNFzjk';
    final builder = NetworkRequestBuilder()
        .setUrl('${AppUrl.hadithApi.url}?page=$page&limit=$limit')
        .setMethod(Method.GET)
        .setExtraHeaders({
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-Key': apiKey,
        })
        .setOnSuccess((response) {
          final jsonData = json.decode(response.toString());
          print('Hadith list response: $jsonData');

          // Parse the response based on the new API format
          if (jsonData['collection'] != null &&
              jsonData['collection'] is List) {
            // This is the collection metadata format
            final englishCollection = jsonData['collection'].firstWhere(
              (c) => c['lang'] == 'en',
              orElse: () => jsonData['collection'][0],
            );

            // Create a single hadith model from collection data
            hadithList.add(
              HadithModel(
                id: 0,
                title: englishCollection['title'] ?? 'Sahih al-Bukhari',
                narrator: '',
                text: englishCollection['shortIntro'] ?? '',
                reference: 'Bukhari',
                chapter: '',
                bookNumber: 0,
                hadithNumber: 0,
              ),
            );
          } else if (jsonData['data'] != null && jsonData['data'] is List) {
            hadithList =
                (jsonData['data'] as List)
                    .map((item) => HadithModel.fromJson(item))
                    .toList();
          } else if (jsonData['hadiths'] != null &&
              jsonData['hadiths'] is List) {
            // Handle new API format
            hadithList = [];
            for (var item in jsonData['hadiths']) {
              // Extract English hadith
              if (item['hadith'] != null && item['hadith'] is List) {
                final englishHadith = item['hadith'].firstWhere(
                  (h) => h['lang'] == 'en',
                  orElse: () => item['hadith'][0],
                );

                if (englishHadith != null) {
                  // Extract narrator from the body text
                  String narratorText = '';
                  String bodyText = '';

                  if (englishHadith['body'] != null) {
                    final bodyHtml = englishHadith['body'] as String;
                    final narratorMatch = RegExp(
                      r'Narrated ([^:]+):',
                    ).firstMatch(bodyHtml);

                    if (narratorMatch != null) {
                      narratorText = narratorMatch.group(1) ?? '';
                    }

                    // Clean HTML tags from body
                    bodyText =
                        bodyHtml
                            .replaceAll(RegExp(r'<[^>]*>'), '')
                            .replaceAll('Narrated $narratorText:', '')
                            .trim();
                  }

                  hadithList.add(
                    HadithModel(
                      id: englishHadith['urn'] ?? 0,
                      title: englishHadith['chapterTitle'] ?? '',
                      narrator: narratorText,
                      text: bodyText,
                      reference: 'Bukhari: ${item['hadithNumber'] ?? ''}',
                      chapter: englishHadith['chapterTitle'] ?? '',
                      bookNumber: int.parse(
                        item['bookNumber']?.toString() ?? '0',
                      ),
                      hadithNumber: int.parse(
                        item['hadithNumber']?.toString() ?? '0',
                      ),
                    ),
                  );
                }
              }
            }
          }
        })
        .setOnFailed((error) {
          // Handle error
          print('Error fetching hadith list: $error');
        });

    await builder.executeNetworkRequest();

    return hadithList;
  }

  @override
  Future<HadithModel?> getHadithDetail({required int hadithId}) async {
    HadithModel? hadith;

    final apiKey = 'SqD712P3E82xnwOAEOkGd5JZH8s9wRR24TqNFzjk';
    final builder = NetworkRequestBuilder()
        .setUrl('${AppUrl.hadithDetail.url}/$hadithId')
        .setMethod(Method.GET)
        .setExtraHeaders({
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-Key': apiKey,
        })
        .setOnSuccess((response) {
          final jsonData = json.decode(response.toString());
          print('Hadith detail response: $jsonData');

          // Handle new API format
          if (jsonData['data'] != null) {
            hadith = HadithModel.fromJson(jsonData['data']);
          } else if (jsonData['hadith'] != null && jsonData['hadith'] is List) {
            // Extract English hadith
            final englishHadith = jsonData['hadith'].firstWhere(
              (h) => h['lang'] == 'en',
              orElse: () => jsonData['hadith'][0],
            );

            if (englishHadith != null) {
              // Extract narrator from the body text
              String narratorText = '';
              String bodyText = '';

              if (englishHadith['body'] != null) {
                final bodyHtml = englishHadith['body'] as String;
                final narratorMatch = RegExp(
                  r'Narrated ([^:]+):',
                ).firstMatch(bodyHtml);

                if (narratorMatch != null) {
                  narratorText = narratorMatch.group(1) ?? '';
                }

                // Clean HTML tags from body
                bodyText =
                    bodyHtml
                        .replaceAll(RegExp(r'<[^>]*>'), '')
                        .replaceAll('Narrated $narratorText:', '')
                        .trim();
              }

              hadith = HadithModel(
                id: englishHadith['urn'] ?? 0,
                title: englishHadith['chapterTitle'] ?? '',
                narrator: narratorText,
                text: bodyText,
                reference: 'Bukhari: ${jsonData['hadithNumber'] ?? ''}',
                chapter: englishHadith['chapterTitle'] ?? '',
                bookNumber: int.parse(
                  jsonData['bookNumber']?.toString() ?? '0',
                ),
                hadithNumber: int.parse(
                  jsonData['hadithNumber']?.toString() ?? '0',
                ),
              );
            }
          }
        })
        .setOnFailed((error) {
          // Handle error
          print('Error fetching hadith detail: $error');
        });

    await builder.executeNetworkRequest();

    return hadith;
  }

  @override
  Future<HadithModel?> getDailyHadith() async {
    HadithModel? hadith;

    final apiKey = 'SqD712P3E82xnwOAEOkGd5JZH8s9wRR24TqNFzjk';
    final builder = NetworkRequestBuilder()
        .setUrl('${AppUrl.dailyHadith.url}')
        .setMethod(Method.GET)
        .setExtraHeaders({
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-Key': apiKey,
        })
        .setOnSuccess((response) {
          final jsonData = json.decode(response.toString());

          // Extract English hadith data from the new API response format
          if (jsonData['hadith'] != null &&
              jsonData['hadith'] is List &&
              jsonData['hadith'].isNotEmpty) {
            final englishHadith = jsonData['hadith'].firstWhere(
              (h) => h['lang'] == 'en',
              orElse: () => jsonData['hadith'][0],
            );

            if (englishHadith != null) {
              // Extract narrator from the body text
              String narratorText = '';
              String bodyText = '';

              if (englishHadith['body'] != null) {
                final bodyHtml = englishHadith['body'] as String;
                final narratorMatch = RegExp(
                  r'Narrated ([^:]+):',
                ).firstMatch(bodyHtml);

                if (narratorMatch != null) {
                  narratorText = narratorMatch.group(1) ?? '';
                }

                // Clean HTML tags from body
                bodyText =
                    bodyHtml
                        .replaceAll(RegExp(r'<[^>]*>'), '')
                        .replaceAll('Narrated $narratorText:', '')
                        .trim();
              }

              hadith = HadithModel(
                id: englishHadith['urn'] ?? 0,
                title: englishHadith['chapterTitle'] ?? '',
                narrator: narratorText,
                text: bodyText,
                reference: 'Bukhari: ${jsonData['hadithNumber'] ?? ''}',
                chapter: englishHadith['chapterTitle'] ?? '',
                bookNumber: int.parse(jsonData['bookNumber'] ?? '0'),
                hadithNumber: int.parse(jsonData['hadithNumber'] ?? '0'),
              );
            }
          }
        })
        .setOnFailed((error) {
          // Handle error
          print('Error fetching hadith: $error');
        });

    await builder.executeNetworkRequest();

    return hadith;
  }
}
