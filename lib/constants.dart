import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A class to hold all Appwrite related constants loaded from the .env file.
/// This provides a single, reliable source for configuration values.
class AppwriteConstants {
  static final String endpoint = dotenv.env['APPWRITE_ENDPOINT']!;
  static final String projectId = dotenv.env['APPWRITE_PROJECT_ID']!;
  static final String databaseId = dotenv.env['APPWRITE_DATABASE_ID']!;
  static final String drivewaysCollectionId = dotenv.env['APPWRITE_DRIVEWAYS_COLLECTION_ID']!;
  static final String storageBucketId = dotenv.env['APPWRITE_STORAGE_BUCKET_ID']!;
}
