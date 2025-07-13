import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomReactiveButton extends StatelessWidget {
  final Stream<bool> stream;
  final VoidCallback onPressed;
  final String buttonText;
  final bool showLoading;
  final double height;
  final double loadingSize;

  const CustomReactiveButton({
    Key? key,
    required this.stream,
    required this.onPressed,
    required this.buttonText,
    this.showLoading = true,
    this.height = 48,
    this.loadingSize = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: stream,
      initialData: false,
      builder: (context, snapshot) {
        final isLoading = snapshot.data ?? false;

        return SizedBox(
          width: double.infinity,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: isLoading && showLoading
                ? SizedBox(
                    height: loadingSize,
                    width: loadingSize,
                    child: Lottie.asset(
                      'assets/json/loading.json', // Replace with JsonAssets.loading2
                      fit: BoxFit.contain,
                    ),
                  )
                : Text(buttonText),
          ),
        );
      },
    );
  }
}
