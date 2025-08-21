import 'package:ai_movie_suggestion/app/app.dart';
import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/presentation/send_notifcations/service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await NotificationService.initialize();
  await initAppModule();
  debugDisableShadows = false; // Helps with rendering
  debugPrintRebuildDirtyWidgets = false;
  runApp(MyApp());
}
