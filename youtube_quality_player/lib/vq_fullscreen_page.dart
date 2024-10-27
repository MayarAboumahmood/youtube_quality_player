import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';

class FullscreenVideoPlayer extends StatefulWidget {
  final VideoController videoController;
  final Color primaryColor;
  final Color secondaryColor;

  FullscreenVideoPlayer(
      {required this.videoController,
      required this.primaryColor,
      required this.secondaryColor});

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  bool showDirectionControls = false;

  TransformationController transformationController =
      TransformationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            buildVideoFullWidget(context),
            Positioned(
              top: 20,
              right: 60,
              child: IconButton(
                icon: Icon(Icons.zoom_in,
                    color: widget.primaryColor.withOpacity(0.5), size: 30),
                onPressed: () {
                  _zoomIn();
                },
              ),
            ),
            Positioned(
              top: 20,
              right: 90,
              child: IconButton(
                icon: Icon(
                  Icons.zoom_out,
                  color: widget.primaryColor.withOpacity(0.5),
                  size: 30,
                ),
                onPressed: () {
                  _zoomOut();
                },
              ),
            ),
            showDirectionControls ? buildMovementButtons() : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Stack buildMovementButtons() {
    return Stack(
      children: [
        Positioned(
          left: 16,
          top: 100,
          child: _MovementButton(
            icon: Icons.arrow_upward,
            onPressed: () => _moveVideo(0, 20),
            primaryColor: widget.primaryColor,
          ),
        ),
        Positioned(
          left: 16,
          bottom: 100,
          child: _MovementButton(
            icon: Icons.arrow_downward,
            onPressed: () => _moveVideo(0, -20),
            primaryColor: widget.primaryColor,
          ),
        ),
        Positioned(
          right: 16,
          top: 100,
          child: _MovementButton(
            icon: Icons.arrow_back,
            primaryColor: widget.primaryColor,
            onPressed: () => _moveVideo(20, 0),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 100,
          child: _MovementButton(
            icon: Icons.arrow_forward,
            onPressed: () => _moveVideo(-20, 0),
            primaryColor: widget.primaryColor,
          ),
        ),
      ],
    );
  }

  Center buildVideoFullWidget(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: MaterialVideoControlsTheme(
            normal: buildNormalMaterialVideoControlsThemeData(context),
            fullscreen: MaterialVideoControlsThemeData(),
            child: InteractiveViewer(
              transformationController: transformationController,
              minScale: 0.8,
              // maxScale: 4,
              boundaryMargin: const EdgeInsets.only(bottom: 0),
              clipBehavior: Clip.hardEdge,
              child: Video(
                  // width: 400,
                  // height: 200,
                  controller: widget.videoController),
            )),
      ),
    );
  }

  MaterialVideoControlsThemeData buildNormalMaterialVideoControlsThemeData(
      BuildContext context) {
    return MaterialVideoControlsThemeData(
      seekOnDoubleTap: true,
      seekOnDoubleTapEnabledWhileControlsVisible: true,
      padding: EdgeInsets.symmetric(vertical: 10),
      seekBarPositionColor: widget.primaryColor,
      seekBarThumbColor: widget.primaryColor,
      buttonBarButtonSize: 30.0,
      buttonBarButtonColor: Colors.white,
      primaryButtonBar: [
        MaterialPlayOrPauseButton(iconSize: 48.0),
      ],
      bottomButtonBar: [
        IconButton(
          onPressed: () => _exitFullscreen(),
          icon: const Icon(Icons.fullscreen_exit),
          iconSize: 30,
          color: Colors.white,
        ),
      ],
    );
  }

  void _zoomOut() {
    // Apply zoom-out by scaling the transformationController
    final currentScale = transformationController.value.getMaxScaleOnAxis();

    // Define the minimum scale allowed (original scale)
    final minScale = 1.0;

    // Only zoom out if the current scale is greater than the minimum scale
    if (currentScale > minScale) {
      final newScale = currentScale * 0.8; // Reduce scale by 20%

      // Ensure the new scale doesn't go below the minimum scale
      if (newScale >= minScale) {
        transformationController.value = transformationController.value.clone()
          ..scale(0.8);
      } else {
        // If the new scale is less than the minimum scale, set it to the minimum scale
        transformationController.value = transformationController.value.clone()
          ..scale(minScale / currentScale);
      }
    }
    _updateShowDirectionControls();
  }

  void _zoomIn() {
    // Apply zoom-in by scaling the transformationController
    transformationController.value = transformationController.value.clone()
      ..scale(1.2);
    _updateShowDirectionControls();
  }

  void _updateShowDirectionControls() {
    // Check the current scale and update the lessonVideoController's showDirectionControls
    final currentScale = transformationController.value.getMaxScaleOnAxis();
    setState(() {
      showDirectionControls = currentScale > 1.0;
    });
  }

  // Method to exit fullscreen and rotate the device back to portrait mode
  void _exitFullscreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).then((_) async {
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
    });
  }

  void _moveVideo(double dx, double dy) {
    // Apply translation by adjusting the transformation controller's matrix
    transformationController.value = Matrix4.identity()
      ..translate(dx, dy)
      ..multiply(transformationController.value);
  }
}

// Custom button widget for movement
class _MovementButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color primaryColor;

  const _MovementButton(
      {required this.icon,
      required this.onPressed,
      required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: primaryColor,
          ),
        ),
      ),
    );
  }
}
