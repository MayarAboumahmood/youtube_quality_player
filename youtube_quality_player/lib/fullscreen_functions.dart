import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:youtube_quality_player/vq_fullscreen_page.dart';

Future<void> customToggleFullscreen(
    BuildContext context,
    VideoController videoController,
    Color primaryColor,
    Color secondaryColor) async {
  if (isFullscreen(context)) {
    return exitFullscreen(context);
  } else {
    return _enterFullscreen(
        context, videoController, primaryColor, secondaryColor);
  }
}

void _enterFullscreen(BuildContext context, VideoController videoController,
    Color primaryColor, Color secondaryColor) async {
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
