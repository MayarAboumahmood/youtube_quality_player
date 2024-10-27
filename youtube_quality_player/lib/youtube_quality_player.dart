library youtube_quality_player;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:media_kit/media_kit.dart' as mediKit;
import 'package:media_kit_video/media_kit_video.dart' as mediKitVideo;
import 'package:youtube_quality_player/video_settings_bottomsheet.dart';

import 'fullscreen_functions.dart';

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

  YQPlayer({
    super.key,
    required this.videoLink,
    this.primaryColor = Colors.green,
    this.secondaryColor = Colors.greenAccent,
  });

  @override
  _YQPlayerState createState() => _YQPlayerState();
}

class _YQPlayerState extends State<YQPlayer> {
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

  List<mediKit.VideoTrack> videosUrl = [];

  late mediKit.Player videoPlayer = mediKit.Player();

  late mediKitVideo.VideoController videoController;

  Future<void> fetchVideoQualities() async {
    setState(() {
      fetchingVideoQualitiesLoading = true;
    });
    try {
      var manifest =
          await youtubeExplode.videos.streamsClient.getManifest(videoId);

      if (manifest.videoOnly.isNotEmpty && manifest.audioOnly.isNotEmpty) {
        audioOnlyStreamInfo = manifest.audioOnly;
        assignVideoQualities(manifest.videoOnly);
        setState(() {
          selectedQuality = videoQualities[(videoQualities.length ~/ 2)];
        });
        initialiseVideoPlayer();
      }
      videoController = mediKitVideo.VideoController(videoPlayer);

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

  void assignVideoQualities(List<VideoStreamInfo> videoInfos) {
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

  void initialiseVideoPlayer() async {
    if (selectedQuality != null) {
      await videoPlayer
          .open(mediKit.Media(selectedQuality!.url.toString()))
          .then((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        videoPlayer.setAudioTrack(
            mediKit.AudioTrack.uri(getClosestAudioStream()!.url.toString()));
      });
    }
  }

  void changeVideoQuality(VideoStreamInfo newQuality) async {
    setState(() {
      selectedQuality = newQuality;
    });

    AudioOnlyStreamInfo? newAudio = getClosestAudioStream();
    Duration? cPosition = await videoPlayer.stream.position.first;
    await videoPlayer
        .open(mediKit.Media(selectedQuality!.url.toString(), start: cPosition))
        .then((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (newAudio != null) {
        await videoPlayer
            .setAudioTrack(mediKit.AudioTrack.uri(newAudio.url.toString()));
      }
    });

    setState(() {
      videoController = mediKitVideo.VideoController(videoPlayer);
    });
  }

  AudioOnlyStreamInfo? getClosestAudioStream() {
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
    return Scaffold(
      body: fetchingVideoQualitiesLoading
          ? Container(
              color: Colors.black,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 9 / 16,
              child: const Center(
                  child: CircularProgressIndicator(
                color: Colors.white,
              )))
          : mediKitVideo.MaterialVideoControlsTheme(
              normal: buildMaterialVideoControlsNormalThemeData(context),
              fullscreen: buildMaterialVideoControlsFullScreenThemeData(),
              child: mediKitVideo.Video(
                  controller: videoController, fit: BoxFit.contain)),
    );
  }

  mediKitVideo.MaterialVideoControlsThemeData
      buildMaterialVideoControlsFullScreenThemeData() {
    return const mediKitVideo.MaterialVideoControlsThemeData(
      // Modify theme options:
      displaySeekBar: false,
      automaticallyImplySkipNextButton: false,
      automaticallyImplySkipPreviousButton: false,
    );
  }

  mediKitVideo.MaterialVideoControlsThemeData
      buildMaterialVideoControlsNormalThemeData(BuildContext context) {
    return mediKitVideo.MaterialVideoControlsThemeData(
      padding: const EdgeInsets.symmetric(vertical: 10),
      // seekBarBufferColor: Colors.green,
      seekBarPositionColor: widget.secondaryColor!,
      seekBarThumbColor: widget.primaryColor!,
      // Modify theme options:
      buttonBarButtonSize: 24.0,
      buttonBarButtonColor: Colors.white,
      primaryButtonBar: [
        mediKitVideo.MaterialPlayOrPauseButton(iconSize: 48.0),
      ],
      bottomButtonBar: [
        IconButton(
          onPressed: () => customToggleFullscreen(context, videoController,
              widget.primaryColor!, widget.secondaryColor!),
          icon: (mediKitVideo.isFullscreen(context)
              ? const Icon(Icons.fullscreen_exit)
              : const Icon(Icons.fullscreen)),
          iconSize: 24,
          color: Colors.white,
        )
      ],

      topButtonBar: [
        const Spacer(),
        mediKitVideo.MaterialDesktopCustomButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return SettingsSheet(
                  videoQualities: videoQualities,
                  currentSpeed: currentSpeed,
                  onChangeQuality: (newSelected) {
                    changeVideoQuality(newSelected);
                  },
                  selectedQuality: selectedQuality,
                  primaryColor: widget.primaryColor!,
                  onChangeSpeed: (speed) {
                    setState(() {
                      currentSpeed = speed;
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
