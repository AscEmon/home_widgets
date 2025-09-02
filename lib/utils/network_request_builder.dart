import 'dart:io';
import 'package:dio/dio.dart';
import '../data_provider/api_client.dart';
import 'enum.dart';
import '/utils/extension.dart';
import 'mixin/loader_show_hide_mixin.dart';

class NetworkRequestBuilder with LoaderShowHideMixin {
  final ApiClient _apiClient = ApiClient();

  late String _url;
  late Method _method;
  Map<String, dynamic>? _params;
  // ignore: prefer_function_declarations_over_variables
  final Function(bool isLoading) _onLoading = (isLoading) => true;
  late Function(Response response) _onSuccess;
  late Function(Object errorMessage) onFailed;
  bool _showLoader = false;
  bool _isFormData = false;
  Map<String, String>? _extraHeaders;
  Options? _options;
  void Function(int, int)? _onReceiveProgress;
  String? _savePath;
  List<File>? _files;
  String? _fileKeyName;

  NetworkRequestBuilder setUrl(String url) {
    _url = url;
    return this;
  }

  NetworkRequestBuilder setMethod(Method method) {
    _method = method;
    return this;
  }

  NetworkRequestBuilder setParams(Map<String, dynamic> params) {
    _params = params;
    return this;
  }

  NetworkRequestBuilder setOnSuccess(Function(Response response) onSuccess) {
    _onSuccess = onSuccess;
    return this;
  }

  NetworkRequestBuilder setOnFailed(Function(Object errorMessage) onFailed) {
    this.onFailed = onFailed;
    return this;
  }

  NetworkRequestBuilder setShowLoader(bool showLoader) {
    _showLoader = showLoader;
    return this;
  }

  NetworkRequestBuilder setFormData(bool fromData) {
    _isFormData = fromData;
    return this;
  }

  NetworkRequestBuilder setExtraHeaders(Map<String, String>? extraHeaders) {
    _extraHeaders = extraHeaders;
    return this;
  }

  NetworkRequestBuilder setOptions(Options? options) {
    _options = options;
    return this;
  }

  NetworkRequestBuilder setOnReceiveProgress(
      void Function(int, int)? onReceiveProgress) {
    _onReceiveProgress = onReceiveProgress;
    return this;
  }

  NetworkRequestBuilder setSavePath(String? savePath) {
    _savePath = savePath;
    return this;
  }

  NetworkRequestBuilder setFiles(List<File>? files) {
    _files = files;
    return this;
  }

  NetworkRequestBuilder setFileKeyName(String? fileKeyName) {
    _fileKeyName = fileKeyName;
    return this;
  }

  Future<void> executeNetworkRequest() async {
    if (_showLoader) {
      showLoaderView();
    }
    _onLoading(true);

    await _apiClient
        .request(
      method: _method,
      url: _url,
      params: _params,
      extraHeaders: _extraHeaders,
      options: _options,
      onReceiveProgress: _onReceiveProgress,
      savePath: _savePath,
      files: _files,
      isFormData: _isFormData,
      fileKeyName: _fileKeyName,
      onSuccessFunction: (Response response) async {
        if (_showLoader) {
          hideLoader();
        }
        await _onSuccess(response);
        _onLoading(false);
      },
    )
        .catchError((Object e) {
      "E $e".log();
      if (_showLoader) {
        hideLoader();
      }
      onFailed(e);
      _onLoading(false);
    });
  }
}

