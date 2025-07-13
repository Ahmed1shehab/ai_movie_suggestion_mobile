import 'package:flutter/material.dart';
import 'package:ai_movie_suggestion/presentation/common/state_renderer/state_renderer.dart';

class SuccessTestPage extends StatelessWidget {
  const SuccessTestPage({super.key});

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => StateRenderer(
        stateRendererType: StateRendererType.popSuccessState,
        title: "Success",
        message: "Email verified successfully!",
        retryActionFunction: () {
          Navigator.of(context).pop(); // Close dialog
          // Optional: Navigate after success
          Navigator.of(context).pushReplacementNamed("/login"); // or your route
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Success Dialog")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showSuccessDialog(context),
          child: const Text("Show Success Dialog"),
        ),
      ),
    );
  }
}
