import 'dart:convert';

import 'package:home_widgets/constant/app_url.dart';
import 'package:home_widgets/utils/enum.dart';

import '../../../utils/network_request_builder.dart';
import '../model/hadith_model.dart';
import 'dashboard_interface.dart';

class DashboardRepository implements IDashboardRepository {
  @override
  Future<HadithModel?> getDailyHadith() async {
    HadithModel? hadith;

    final apiKey = 'SqD712P3E82xnwOAEOkGd5JZH8s9wRR24TqNFzjk';
    final builder = NetworkRequestBuilder()
        .setUrl(AppUrl.dailyHadith.url)
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
                date: DateTime.now(),
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
