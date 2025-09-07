/// Bottom sheet widget for video settings (quality, speed, etc.).
library;

import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter/material.dart';

class SettingsSheet extends StatelessWidget {
  final List<VideoStreamInfo> videoQualities;
  final Function(VideoStreamInfo) onChangeQuality;
  final Function(double) onChangeSpeed;
  final double currentSpeed;
  final VideoStreamInfo? selectedQuality;
  final Color primaryColor;
  final Locale locale;

  const SettingsSheet({
    super.key,
    required this.videoQualities,
    required this.onChangeQuality,
    required this.onChangeSpeed,
    required this.currentSpeed,
    required this.primaryColor,
    this.selectedQuality,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildQualityChangeListTile(context),
          _buildChangeSpeedListTile(context),
        ],
      ),
    );
  }

  ListTile _buildChangeSpeedListTile(BuildContext context) {
    final text = locale.languageCode == 'ar' ? 'سرعة الفيديو' : 'Video Speed';

    return ListTile(
      trailing:
          Text('x$currentSpeed', style: Theme.of(context).textTheme.bodyMedium),
      title: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      leading: Icon(Icons.speed_sharp,
          size: MediaQuery.of(context).size.width * .08),
      onTap: () {
        Navigator.pop(context);
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SpeedSelectionSheet(
              currentSpeed: currentSpeed,
              onChangeSpeed: onChangeSpeed,
            );
          },
        );
      },
    );
  }

  ListTile _buildQualityChangeListTile(BuildContext context) {
    final text = locale.languageCode == 'ar' ? 'جودة الفيديو' : 'Video Quality';

    return ListTile(
      trailing: Text('${selectedQuality?.videoResolution.height ?? ''}',
          style: Theme.of(context).textTheme.bodyMedium),
      leading: Icon(Icons.hd_outlined,
          size: MediaQuery.of(context).size.width * .08),
      title: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      onTap: () {
        Navigator.pop(context);
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return QualitySelectionSheet(
              videoQualities: videoQualities,
              onChangeQuality: onChangeQuality,
              selectedQuality: selectedQuality,
              primaryColor: primaryColor,
            );
          },
        );
      },
    );
  }
}

class QualitySelectionSheet extends StatelessWidget {
  final List<VideoStreamInfo> videoQualities;
  final Function(VideoStreamInfo) onChangeQuality;
  final VideoStreamInfo? selectedQuality;
  final Color primaryColor;

  const QualitySelectionSheet({
    super.key,
    required this.videoQualities,
    required this.onChangeQuality,
    this.selectedQuality,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: videoQualities.map((quality) {
          return GestureDetector(
            onTap: () {
              onChangeQuality(quality);
              Navigator.pop(context);
            },
            child: Container(
              color: selectedQuality == quality
                  ? primaryColor.withValues(alpha: 0.3)
                  : Colors.transparent,
              child: ListTile(
                title: Text('${quality.videoResolution.height}p',
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SpeedSelectionSheet extends StatelessWidget {
  final List<double> speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  final Function(double) onChangeSpeed;
  final double currentSpeed;

  SpeedSelectionSheet(
      {super.key, required this.onChangeSpeed, required this.currentSpeed});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: speeds.map((speed) {
          return GestureDetector(
            onTap: () {
              onChangeSpeed(speed);
              Navigator.pop(context);
            },
            child: Container(
              color: currentSpeed == speed
                  ? Colors.blue.withValues(alpha: 0.3)
                  : Colors.transparent,
              child: ListTile(
                title: Text('x$speed',
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
