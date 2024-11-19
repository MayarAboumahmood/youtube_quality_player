# youtube_quality_player

`youtube_quality_player` is a Flutter widget that enables easy YouTube video playback with adjustable quality settings. This package is ideal for applications that require YouTube video integration with enhanced user control over video quality and fullscreen options.

## Features
- Play YouTube videos directly within your Flutter app.
- Choose video quality settings to optimize playback experience.
- Fullscreen mode and customizable primary and secondary colors for a seamless UI.

## Getting Started

To start using `youtube_quality_player`, ensure you have a Flutter environment set up. Then, add `youtube_quality_player` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  youtube_quality_player: ^0.0.1


## Usage
import 'package:flutter/material.dart';
import 'package:youtube_quality_player/youtube_quality_player.dart';

void main() {
  ensureYQPInitialized();
  runApp(MyApp());
}

import 'package:youtube_quality_player/youtube_quality_player.dart';
import 'package:flutter/material.dart';

YQPlayer(
  videoLink: 'https://youtube.com/watch?v=example',
  primaryColor: Colors.blue,
  secondaryColor: Colors.redAccent,
);


