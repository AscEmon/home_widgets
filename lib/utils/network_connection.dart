import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '/utils/enum.dart';
import 'package:flutter/material.dart';

class NetworkConnection {
  static NetworkConnection? _instance;

  NetworkConnection._();

  static NetworkConnection get instance => _instance ??= NetworkConnection._();
  bool isInternet = true;

  Future<bool> hasInternetConnection() async {
    try {
      try {
        final response = await Dio().get(
          'https://www.google.com',
          options: Options(
            receiveTimeout: const Duration(seconds: 3),
          ),
        );
        return response.statusCode == 200;
      } catch (e) {
        // If the HTTP request fails, assume no internet
        return false;
      }
    } on PlatformException {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> internetAvailable() async {
    isInternet = await hasInternetConnection();
    debugPrint("isInternet1 :: $isInternet");

    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        isInternet = false;
        debugPrint("isInternet2 :: $isInternet");
      } else {
        isInternet = true;
        debugPrint("isInternet3 :: $isInternet");
      }
    });

    // Delay to sync the result value with the UI.
    await Future.delayed(const Duration(seconds: 1));
  }

  List<APIParams> apiStack = [];
}

// API parameters for calling the API when the internet is available
class APIParams {
  String url;
  Method method;
  Map<String, dynamic> variables;
  Function(Response<dynamic>) onSuccessFunction;

  APIParams({
    required this.url,
    required this.method,
    required this.variables,
    required this.onSuccessFunction,
  });
}


