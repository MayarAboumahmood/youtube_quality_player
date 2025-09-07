import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:youtube_quality_player/src/vq_fullscreen_page.dart';

class FullscreenHelper {
  Future<void> customToggleFullscreen(
    BuildContext context,
    VideoController videoController,
    Color primaryColor,
    Color secondaryColor,
    double playIconSize,
  ) async {
    if (isFullscreen(context)) {
      return exitFullscreen(context);
    } else {
      return _enterFullscreen(
          context, videoController, primaryColor, secondaryColor, playIconSize);
    }
  }

  void _enterFullscreen(BuildContext context, VideoController videoController,
      Color primaryColor, Color secondaryColor, double playIconSize) async {
// Set the device to landscape mode

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
// Push the fullscreen route
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayer(
          videoController: videoController,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          playIconSize: playIconSize,
        ),
      ),
    )
        .then((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });
  }
}
