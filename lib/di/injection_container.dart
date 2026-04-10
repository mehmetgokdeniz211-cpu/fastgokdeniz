import 'package:get_it/get_it.dart';
import '../data/repositories/message_repository.dart';
import '../data/repositories/qr_repository.dart';
import '../data/services/message_service.dart';
import '../data/services/qr_service.dart';
import '../data/services/qr_scanner_service.dart';
import '../data/services/database_service.dart';
import '../domain/generate_qr_use_case.dart';
import '../domain/send_message_use_case.dart';
import '../presentation/providers/message_provider.dart';
import '../presentation/providers/qr_provider.dart';
import '../presentation/providers/qr_scanner_provider.dart';
import '../presentation/providers/user_profile_provider.dart';
import '../presentation/providers/scan_history_provider.dart';
import '../presentation/providers/authentication_provider.dart';
import '../core/services/caching_service.dart';
import '../core/services/search_filter_service.dart';
import '../core/services/sharing_service.dart';
import '../core/services/camera_service.dart';
import '../core/services/export_import_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core Services
  final databaseService = DatabaseService();
  await databaseService.initialize();
  getIt.registerSingleton<DatabaseService>(databaseService);
  
  final cacheService = CachingService();
  cacheService.initialize();
  getIt.registerSingleton<CachingService>(cacheService);
  
  getIt.registerSingleton<SearchFilterService>(SearchFilterService());
  getIt.registerSingleton<SharingService>(SharingService());
  getIt.registerSingleton<ExportImportService>(ExportImportService());
  
  final cameraService = CameraService();
  cameraService.initialize();
  getIt.registerSingleton<CameraService>(cameraService);

  // Legacy Services
  getIt.registerLazySingleton<MessageService>(() => MessageService());
  getIt.registerLazySingleton<QRService>(() => QRService());
  getIt.registerLazySingleton<QRScannerService>(() => QRScannerService());

  // Repositories
  getIt.registerLazySingleton<MessageRepository>(
    () => MessageRepository(getIt<MessageService>()),
  );
  getIt.registerLazySingleton<QRRepository>(
    () => QRRepository(getIt<QRService>()),
  );

  // Use Cases
  getIt.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(getIt<MessageRepository>()),
  );
  getIt.registerLazySingleton<GenerateQRUseCase>(
    () => GenerateQRUseCase(getIt<QRRepository>()),
  );

  // Providers
  getIt.registerFactory<MessageProvider>(
    () => MessageProvider(getIt<SendMessageUseCase>()),
  );
  getIt.registerFactory<QRProvider>(
    () => QRProvider(getIt<GenerateQRUseCase>()),
  );
  getIt.registerFactory<QRScannerProvider>(
    () => QRScannerProvider(getIt<QRScannerService>()),
  );
  getIt.registerFactory<UserProfileProvider>(
    () => UserProfileProvider(),
  );
  getIt.registerFactory<ScanHistoryProvider>(
    () => ScanHistoryProvider(),
  );
  getIt.registerFactory<AuthenticationProvider>(
    () => AuthenticationProvider(),
  );
}