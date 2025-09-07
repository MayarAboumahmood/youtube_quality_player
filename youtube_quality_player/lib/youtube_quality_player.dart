/// Youtube Quality Player
///
/// A Flutter package that allows you to play YouTube videos with quality selection,
/// fullscreen support, and customizable controls.
library;

export 'package:youtube_quality_player/youtube_quality_player.dart';
export '/initialized_function.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:media_kit/media_kit.dart' as media_kit;
import 'package:media_kit_video/media_kit_video.dart' as media_kit_video;
import 'package:youtube_quality_player/src/video_settings_bottomsheet.dart';

import 'src/fullscreen_functions.dart';

/// A widget that plays YouTube videos with selectable quality options.
class YQPlayer extends StatefulWidget {
  /// The YouTube video link to be played.
  ///
  /// This is a required parameter that specifies the URL of the YouTube video.
  final String videoLink;

  /// The primary color used as the main theme color.
  ///
  /// This color will be used for primary UI elements. If not specified, a default
  /// color will be applied.
  final Color? primaryColor;

  /// The secondary color used as the secondary theme color.
  ///
  /// This color will be used for secondary UI elements. If not specified, a default
  /// color will be applied.
  final Color? secondaryColor;

  /// The locale to be used for localization.
  ///
  /// Pass a `Locale` object (e.g., `Locale('en')` for English or `Locale('ar')` for Arabic).
  /// If not specified, it defaults English.
  final Locale locale;

  /// if set true then the video will automatically play when initial, false will not, default true
  final bool shouldAutoPlay;

  /// control the size of the play icon size to prevent it's placed where it should not.
  final double playIconSize;

  const YQPlayer({
    super.key,
    required this.videoLink,
    this.primaryColor = Colors.green,
    this.secondaryColor = Colors.greenAccent,
    this.locale = const Locale('en'), // Default to English
    this.shouldAutoPlay = true, // Default to English
    this.playIconSize = 48, // Default to English
  });

  @override
  YQPlayerState createState() => YQPlayerState();
}

class YQPlayerState extends State<YQPlayer> {
  @override
  void initState() {
    super.initState();
    videoLink = widget.videoLink; // example video
    videoId = VideoId(videoLink);
    fetchVideoQualities();
  }

  @override
  void dispose() {
    videoPlayer.stop();
    videoPlayer.dispose();
    super.dispose();
  }

  late List<VideoStreamInfo> videoQualities = [];
  double currentSpeed = 1.0;
  VideoStreamInfo? selectedQuality;
  late VideoId videoId;
  late String videoLink;
  YoutubeExplode youtubeExplode = YoutubeExplode();
  bool fetchingVideoQualitiesLoading = true;
  late List<AudioOnlyStreamInfo> audioOnlyStreamInfo = [];

  List<media_kit.VideoTrack> videosUrl = [];

  late media_kit.Player videoPlayer = media_kit.Player();

  late media_kit_video.VideoController videoController;

  Future<void> fetchVideoQualities() async {
    setState(() {
      fetchingVideoQualitiesLoading = true;
    });
    try {
      var manifest =
          await youtubeExplode.videos.streamsClient.getManifest(videoId);

      if (manifest.videoOnly.isNotEmpty && manifest.audioOnly.isNotEmpty) {
        audioOnlyStreamInfo = manifest.audioOnly;
        _assignVideoQualities(manifest.videoOnly);
        setState(() {
          selectedQuality = videoQualities[(videoQualities.length ~/ 2)];
        });
        _initialiseVideoPlayer();
      }
      videoController = media_kit_video.VideoController(videoPlayer);

      setState(() {
        fetchingVideoQualitiesLoading = false;
      });
    } catch (e) {
      setState(() {
        fetchingVideoQualitiesLoading = false;
      });
      debugPrint('Error fetching video/audio: $e');
    }
  }

  void _assignVideoQualities(List<VideoStreamInfo> videoInfos) {
    for (VideoStreamInfo i in videoInfos) {
      if (i.codec.toString().contains('mp4')) {
        bool shouldAdd = true;
        for (VideoStreamInfo j in videoQualities) {
          if (j.videoResolution.height == i.videoResolution.height) {
            shouldAdd = false;
          }
        }
        if (shouldAdd) {
          setState(() {
            videoQualities.add(i);
          });
        }
      }
    }
  }

  bool videoInitializationFailed = false;

  void _initialiseVideoPlayer() async {
    try {
      if (selectedQuality != null) {
        await videoPlayer
            .open(media_kit.Media(selectedQuality!.url.toString()),
                play: widget.shouldAutoPlay)
            .then((_) async {
          await Future.delayed(const Duration(milliseconds: 500));
          videoPlayer.setAudioTrack(media_kit.AudioTrack.uri(
              _getClosestAudioStream()!.url.toString()));
          // videoController = media_kit_video.VideoController(videoPlayer);
        });
      }
    } catch (_) {
      videoInitializationFailed = false;
    }
  }

  void _changeVideoQuality(VideoStreamInfo newQuality) async {
    setState(() {
      selectedQuality = newQuality;
    });

    AudioOnlyStreamInfo? newAudio = _getClosestAudioStream();
    Duration? cPosition = await videoPlayer.stream.position.first;
    await videoPlayer
        .open(
            media_kit.Media(selectedQuality!.url.toString(), start: cPosition))
        .then((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (newAudio != null) {
        await videoPlayer
            .setAudioTrack(media_kit.AudioTrack.uri(newAudio.url.toString()));
      }
    });

    setState(() {
      videoController = media_kit_video.VideoController(videoPlayer);
    });
  }

  AudioOnlyStreamInfo? _getClosestAudioStream() {
    if (audioOnlyStreamInfo.isEmpty || selectedQuality == null) {
      return null;
    }

    AudioOnlyStreamInfo? closestAudio;

    int videoHeight = selectedQuality!.videoResolution.height;
    if (videoHeight <= 360) {
      closestAudio = audioOnlyStreamInfo.firstWhere(
        (audio) => audio.bitrate.bitsPerSecond <= 128000,
        orElse: () => audioOnlyStreamInfo[0],
      );
    } else if (videoHeight > 360 && videoHeight <= 720) {
      closestAudio = audioOnlyStreamInfo.firstWhere(
        (audio) =>
            audio.bitrate.bitsPerSecond > 128000 &&
            audio.bitrate.bitsPerSecond <= 256000,
        orElse: () => audioOnlyStreamInfo[(audioOnlyStreamInfo.length ~/ 2)],
      );
    } else {
      closestAudio = audioOnlyStreamInfo.withHighestBitrate();
    }

    return closestAudio;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          videoPlayer.stop();
        }
      },
      child: Scaffold(
        body: fetchingVideoQualitiesLoading
            ? Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 9 / 16,
                child: const Center(
                    child: CircularProgressIndicator(
                  color: Colors.white,
                )))
            : videoInitializationFailed
                ? Container(
                    color: Colors.black,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 9 / 16,
                    child: Center(
                      child: Text(
                        widget.locale.languageCode == 'ar'
                            ? 'لم يتم تحميل الفيديو. يُرجى المحاولة لاحقًا.'
                            : 'Video failed to load. Please try again later.',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : media_kit_video.MaterialVideoControlsTheme(
                    normal: _buildMaterialVideoControlsNormalThemeData(context),
                    fullscreen:
                        _buildMaterialVideoControlsFullScreenThemeData(),
                    child: media_kit_video.Video(
                        controller: videoController, fit: BoxFit.contain)),
      ),
    );
  }

  media_kit_video.MaterialVideoControlsThemeData
      _buildMaterialVideoControlsFullScreenThemeData() {
    return const media_kit_video.MaterialVideoControlsThemeData(
      // Modify theme options:
      displaySeekBar: false,
      automaticallyImplySkipNextButton: false,
      automaticallyImplySkipPreviousButton: false,
    );
  }

  media_kit_video.MaterialVideoControlsThemeData
      _buildMaterialVideoControlsNormalThemeData(BuildContext context) {
    FullscreenHelper fullscreenHelper = FullscreenHelper();

    return media_kit_video.MaterialVideoControlsThemeData(
      padding: const EdgeInsets.symmetric(vertical: 10),
      // seekBarBufferColor: Colors.green,
      seekBarPositionColor: widget.secondaryColor!,
      seekBarThumbColor: widget.primaryColor!,
      // Modify theme options:
      buttonBarButtonSize: 24.0,

      buttonBarButtonColor: Colors.white,
      primaryButtonBar: [
        media_kit_video.MaterialPlayOrPauseButton(
            iconSize: widget.playIconSize),
      ],
      bottomButtonBar: [
        IconButton(
          onPressed: () => fullscreenHelper.customToggleFullscreen(
              context,
              videoController,
              widget.primaryColor!,
              widget.secondaryColor!,
              widget.playIconSize),
          icon: (media_kit_video.isFullscreen(context)
              ? const Icon(Icons.fullscreen_exit)
              : const Icon(Icons.fullscreen)),
          iconSize: 24,
          color: Colors.white,
        )
      ],

      topButtonBar: [
        const Spacer(),
        media_kit_video.MaterialDesktopCustomButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return SettingsSheet(
                  locale: widget.locale,
                  videoQualities: videoQualities,
                  currentSpeed: currentSpeed,
                  onChangeQuality: (newSelected) {
                    _changeVideoQuality(newSelected);
                  },
                  selectedQuality: selectedQuality,
                  primaryColor: widget.primaryColor!,
                  onChangeSpeed: (speed) {
                    setState(() {
                      currentSpeed = speed;
                      videoPlayer.setRate(currentSpeed);
                    });
                  },
                );
              },
            );
          },
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }
}
