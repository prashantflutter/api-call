import 'package:dio/dio.dart';

class BaseAPI {
  // static var base = "http://biometriccloudapi.com:8181/";
  static var baseCourse = "https://learno.org/api/";
  static var CourseUrl = "http://learno.org/course/";
  static var base = "https://ehubt.io";
  static var baseImage = "http://demoby.arityinfoway.com/";
  static var api = base + "/api/";

  static BaseOptions options = BaseOptions(
    baseUrl: api,
    followRedirects: false,
    validateStatus: (status) => true,
    responseType: ResponseType.plain,
    connectTimeout: Duration(seconds: 20),
    receiveTimeout: Duration(seconds: 20),
  );

  static Dio dio = new Dio(options);
}
