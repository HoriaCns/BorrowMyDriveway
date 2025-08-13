import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

// Create an instance of GetIt for dependency injection.
final getIt = GetIt.instance;

/// Initializes the service locator and registers all Appwrite services as singletons.
/// This ensures a single instance of each service is used throughout the app,
/// which is efficient and prevents potential state issues.
void setupLocator() {
  // Register Appwrite Client as a singleton.
  // This is the core client for communicating with the Appwrite server.
  getIt.registerSingleton<Client>(
    Client()
      ..setEndpoint(dotenv.env['APPWRITE_ENDPOINT']!)
      ..setProject(dotenv.env['APPWRITE_PROJECT_ID']!)
      ..setSelfSigned(status: true), // Use this for development, disable for production.
  );

  // Register Appwrite Account service.
  // This service handles all user authentication tasks.
  getIt.registerSingleton<Account>(Account(getIt<Client>()));

  // Register Appwrite Databases service.
  // This service is used to interact with your Appwrite database collections.
  getIt.registerSingleton<Databases>(Databases(getIt<Client>()));

  // Register Appwrite Storage service.
  // This service manages file uploads, downloads, and previews.
  getIt.registerSingleton<Storage>(Storage(getIt<Client>()));
}
