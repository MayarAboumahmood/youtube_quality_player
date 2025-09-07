import 'package:flutter/material.dart';
import 'package:youtube_quality_player/initialized_function.dart';
import 'package:youtube_quality_player/youtube_quality_player.dart';

void main() {
  ensureYQPInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youtube Quality player example :)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Youtube Quality player example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.width * 9 / 16,
            width: MediaQuery.of(context).size.width,
            child: YQPlayer(
              shouldAutoPlay: false,
              primaryColor: Colors.blueGrey,
              secondaryColor: Colors.grey,
              locale: const Locale('ar'),
              //The default is English
              videoLink: 'https://youtu.be/hh70ArnzOcE?si=TcGr5GY5gtOyDIxk',
            ),
          ),
        ],
      ),
    );
  }
}
