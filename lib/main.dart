import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'blend_mask.dart';
import 'camera_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<XFile> _images = [];
  XFile? _overlayImage = null;

  Future<void> _incrementCounter() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        // This call to setState tells the Flutter framework that something has
        // changed in this State, which causes it to rerun the build method below
        // so that the display can reflect the updated values. If we changed
        // _counter without calling setState(), then the build method would not be
        // called again, and so nothing would appear to happen.
        _images = images;
        _overlayImage = images[0];
      });
    }
  }

  Widget getImage(XFile file) {
    return kIsWeb ? Image.network(file.path) : Image.file(File(file.path));
  }

  @override
  Widget build(BuildContext context) {
// Ensure that plugin services are initialized so that `availableCameras()`
// can be called before `runApp()`
    WidgetsFlutterBinding.ensureInitialized();

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            icon: const Icon(Icons.add_a_photo_rounded),
          )
        ],
      ),
      body: Column(children: [
        Expanded(
            child: Stack(children: [
          FutureBuilder(
            future: availableCameras(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  return const Center(child: Text("no Camera found"));
                }
                final cameras = snapshot.data as List<CameraDescription>;
                final firstCamera = cameras.first;
                return CameraView(camera: firstCamera);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          BlendMask(
              blendMode: BlendMode.exclusion,
              opacity: 0.5,
              child: _overlayImage == null
                  ? Container()
                  : getImage(_overlayImage!))
        ])),
        Container(
          height: 100,
          color: Color.fromARGB(255, 0, 0, 0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _images.length,
            itemBuilder: (BuildContext context, int index) => InkWell(
                child: getImage(_images[index]),
                onTap: () => setState(() {
                      // This call to setState tells the Flutter framework that something has
                      // changed in this State, which causes it to rerun the build method below
                      // so that the display can reflect the updated values. If we changed
                      // _counter without calling setState(), then the build method would not be
                      // called again, and so nothing would appear to happen.
                      _overlayImage = _images[index];
                    })),
          ),
        )
      ]),
    );
  }
}
