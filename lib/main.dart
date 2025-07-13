import 'package:ai_movie_suggestion/app/app.dart';
import 'package:ai_movie_suggestion/app/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initAppModule();

  runApp(MyApp());
}
