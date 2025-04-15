import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  const connectionString =
      'mongodb://admin:1234@ac-uru0tue-shard-00-00.pl66lr6.mongodb.net:27017,ac-uru0tue-shard-00-01.pl66lr6.mongodb.net:27017,ac-uru0tue-shard-00-02.pl66lr6.mongodb.net:27017/?replicaSet=atlas-4lamuj-shard-0&ssl=true&authSource=admin&retryWrites=true&w=majority&appName=flutterProject';

  try {
    var db = Db(connectionString);
    await db.open();
    print('✅ Successfully connected to MongoDB');
    await db.close();
  } catch (e, stackTrace) {
    print('❌ Failed to connect: $e');
    print(stackTrace);
  }
}
