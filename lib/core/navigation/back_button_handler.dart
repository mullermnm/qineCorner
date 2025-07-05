import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A widget that handles back button presses globally across the app.
/// It prevents the app from exiting when the back button is pressed,
/// instead navigating back in the app's navigation stack.
class BackButtonHandler extends StatelessWidget {
  final Widget child;
  
  const BackButtonHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Get the current context and router
        final router = GoRouter.of(context);
        
        // Check if we can pop the current route
        if (router.canPop()) {
          router.pop();
          return false; // Prevent default back button behavior
        }
        
        // If we're at the root route, show a confirmation dialog
        final bool? shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App?'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        
        // If user confirms exit, allow the app to exit
        return shouldPop ?? false;
      },
      child: child,
    );
  }
}
