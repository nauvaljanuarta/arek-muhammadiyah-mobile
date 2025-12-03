import 'package:flutter_dotenv/flutter_dotenv.dart';

class Connection {
  static String baseUrl = dotenv.env['BASE_URL_PROD']!;
}
