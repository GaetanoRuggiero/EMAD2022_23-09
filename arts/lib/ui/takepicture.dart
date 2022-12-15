import 'dart:convert';
import 'package:arts/model/vision_response.dart';
import 'package:arts/ui/singlepoiview.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../api/poi_api.dart';
import '../api/recognition_api.dart';
import '../model/POI.dart';
import './styles.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({Key? key, required this.camera}) : super(key: key);

  final CameraDescription camera;

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  FlashMode flashMode = FlashMode.off;


  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  void initializeCamera() async {
    _controller = CameraController(
      enableAudio: false,
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    await _controller.setFlashMode(flashMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home_rounded))
        ],
        title: Text(AppLocalizations.of(context)!.poiRecognitionTitleBar),
      ),
      body: Stack(
        alignment: Alignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the Future is complete, display the preview.
                    return CameraPreview(_controller);
                  } else {
                    // Otherwise, display a loading indicator.
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Positioned(
              bottom: 40.0,
              child: ElevatedButton(
                  style: largeButtonStyle,
                  child:
                  const Icon(Icons.camera_alt),
                  onPressed: () async {
                    try {
                      await _initializeControllerFuture;
                      //await _controller.setFlashMode(flashMode);
                      // Attempt to take a picture and then get the location
                      // where the image file is saved.
                      final image = await _controller.takePicture();
                      //final imageBase64 = base64Encode(await image.readAsBytes());

                      //final response = await googleVision(imageBase64);

                      // If the picture was taken, display it on a new screen.
                      if (!mounted) return;
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => ImageRecognitionScreen(
                            // Pass the automatically generated path to
                            // the DisplayPictureScreen widget.
                            imagePath: image.path,
                            //poiVision: PointOfInterest.fromJson(jsonDecode(response.body)),
                          ),
                        ),
                      );
                    } catch (e) {
                      // If an error occurs, log the error to the console.
                      debugPrint(e.toString());
                    }
                  }),
            ),
            Positioned(
              bottom: 45.0,
              left: MediaQuery.of(context).size.width / 2 + 60.0,
              child: ElevatedButton(
                style: smallButtonStyle,
                onPressed: () {
                  setState(() {
                    if (flashMode == FlashMode.off) {
                      _controller.setFlashMode(FlashMode.always);
                      flashMode = FlashMode.always;
                    } else {
                      _controller.setFlashMode(FlashMode.off);
                      flashMode = FlashMode.off;
                    }
                  });
                }, child: flashMode == FlashMode.off ? const Icon(Icons.flash_off_outlined) : const Icon(Icons.flash_on_outlined)
              ),
            )
          ]),
    );
  }
}

// A widget that displays the picture taken by the user.

class ImageRecognitionScreen extends StatelessWidget {
  final String imagePath;

  const ImageRecognitionScreen(
      {super.key, required this.imagePath});

  Future<POI?> recognizePOI(String imagePath) async {
    final String imageBase64 = base64Encode(await XFile(imagePath).readAsBytes());
    GoogleVisionResponse? vision = await getVisionResults(imageBase64);
    if (vision != null) {
      for (var result in vision.responses!) {
        for (var label in result.webDetection!.webEntities!) {
          debugPrint("Searching for label: ${label.description!}");
          var searchResults = await getPOIListByName(label.description!);
          if (searchResults != null && searchResults.isNotEmpty) {
            for (var search in searchResults) {
              if (label.description!.toLowerCase() == search.name!.toLowerCase()) {
                debugPrint("Found a match! ---- ${search.name}");
                return search;
              }
            }
          }
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: recognizePOI(imagePath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    Future.microtask(() => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SinglePOIView(poi: snapshot.data!))
                    ));
                  }
                  else {
                    return const Center(child: Text("Opera non riconosciuta!"));
                  }
                  return Container();
                }
                else {
                  return const Center(child: CircularProgressIndicator());
                }
              })
          ]),
      );
  }
}