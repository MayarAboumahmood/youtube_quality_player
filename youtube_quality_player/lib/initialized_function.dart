library youtube_quality_player;
import 'package:media_kit/media_kit.dart';

/// Ensures that MediaKit is properly initialized.
///
/// This function should be called in the `main()` method of your application
/// before running the app. It is necessary for the proper functioning of
/// the features that depend on MediaKit.
///
/// Example:
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:your_package_name/your_package_name.dart';
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized
///   await ensureMediaKitInitialized(); // Call to ensure MediaKit is initialized
///
///   runApp(MyApp());
/// }
/// ```
///
void ensureMediaKitInitialized() {
  MediaKit.ensureInitialized();
}