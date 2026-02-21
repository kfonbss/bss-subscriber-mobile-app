import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:flutter/material.dart';

class RetryWidget extends StatelessWidget {
  const RetryWidget({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });
  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/filler.png',
                height: constraints.maxHeight * 0.5,
              ),
              Text(errorMessage),
              const SizedBox(height: 16),
              SizedBox(
                width: constraints.maxWidth - 40.h,
                child: ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
