import 'package:ai_movie_suggestion/app/di.dart';
import 'package:ai_movie_suggestion/presentation/resources/routes_manager.dart';
import 'package:flutter/material.dart';

class SomeTriggeringView extends StatefulWidget {
  @override
  _SomeTriggeringViewState createState() => _SomeTriggeringViewState();
}

class _SomeTriggeringViewState extends State<SomeTriggeringView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initMovieDetailsModule();
      Navigator.pushReplacementNamed(
        context,
        Routes.movieDetailsRoute,
        arguments: 717770,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
