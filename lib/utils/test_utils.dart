import 'package:mongo_dart/mongo_dart.dart' as mongo;

class TestUtils {
  static mongo.ObjectId extractObjectId(String rawId) {
    if (rawId.startsWith('ObjectId("') && rawId.endsWith('")')) {
      return mongo.ObjectId.parse(rawId.substring(10, rawId.length - 2));
    }
    return mongo.ObjectId.parse(rawId);
  }

  static bool isValidTestData({
    required String? testName,
    required DateTime? date,
    required String testValue,
    required String result,
  }) {
    return testName != null &&
        date != null &&
        double.tryParse(testValue) != null &&
        result.isNotEmpty;
  }
}
