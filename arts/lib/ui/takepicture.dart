import 'dart:convert';
import 'package:arts/model/vision_response.dart';
import 'package:arts/ui/singlepoiview.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:native_exif/native_exif.dart';
import '../api/poi_api.dart';
import '../api/recognition_api.dart';
import '../model/POI.dart';
import './styles.dart';

class TakePictureScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final CameraDescription camera;

  const TakePictureScreen({Key? key, required this.camera, required this.latitude, required this.longitude}) : super(key: key);

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  FlashMode flashMode = FlashMode.off;

  void initializeCamera() async {
    _controller = CameraController(
      enableAudio: false,
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose of the camera controller when the widget is disposed.
    _controller.dispose();
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
            FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the preview.
                  _controller.setFlashMode(flashMode);
                  final mediaSize = MediaQuery.of(context).size;
                  final scale = 1 / (_controller.value.aspectRatio * mediaSize.aspectRatio);
                  return ClipRect(
                    clipper: _MediaSizeClipper(mediaSize),
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: CameraPreview(_controller),
                    ),
                  );
                } else {
                  // Otherwise, display a loading indicator.
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            Positioned(
              bottom: 40.0,
              child: ElevatedButton(
                style: largeButtonStyle,
                child: const Icon(Icons.camera),
                onPressed: () async {
                  try {
                    // Ensure camera is initialized
                    await _initializeControllerFuture;

                    final image = await _controller.takePicture();

                    /* When we're done taking the picture, we let the ImageRecogntionScreen
                    widget do the rest of the work (calling Google Vision API). */
                    if (!mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ImageRecognitionScreen(
                          imagePath: image.path,
                          latitude: widget.latitude,
                          longitude: widget.longitude,
                        ),
                      ),
                    );
                  } catch (e) {
                    debugPrint("Could not take the picture! Exception message:\n ${e.toString()}");
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
          ]
      ),
    );
  }
}

class ImageRecognitionScreen extends StatelessWidget {
  final String imagePath;
  final double latitude;
  final double longitude;
  final double distanceThreshold = 500; // maximum allowed distance in meters

  const ImageRecognitionScreen(
    {super.key, required this.imagePath, required this.latitude, required this.longitude});

  Future<POI?> recognizePOI(String imagePath) async {
    /* Storing the device location into image's EXIF metadata to improve
    probability of success of the recognition step. */
    Exif? exif = await Exif.fromPath(imagePath);
    await exif.writeAttributes({
      'GPSLatitude': latitude.toString(),
      'GPSLatitudeRef': 'N',
      'GPSLongitude': longitude.toString(),
      'GPSLongitudeRef': 'E',
    });
    await exif.close();

    final String imageBase64 = base64Encode(await XFile(imagePath).readAsBytes());
    GoogleVisionResponse? visionResponse = await getVisionResults(imageBase64);
    if (visionResponse != null) {
      for (var webEntity in visionResponse.responses![0].webDetection!.webEntities!) {
        debugPrint("Searching for: ${webEntity.description!}");
        var searchResults = await getPOIListByName(webEntity.description!);
        if (searchResults != null && searchResults.isNotEmpty) {
          for (var result in searchResults) {
            if (webEntity.description!.toLowerCase() == result.name!.toLowerCase()
            || webEntity.description!.toLowerCase() == result.nameEn!.toLowerCase()) {
              debugPrint("Found a match! ---- ${result.name}");
              return result;
            }
          }
        }
      }
    }
    return null;
  }

  bool checkDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    double distanceInMeters = Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
    debugPrint("Distance between current location and POI is: $distanceInMeters meters.");
    if (distanceInMeters <= distanceThreshold) {
      debugPrint("Distance is OK!");
      return true;
    }
    else {
      debugPrint("You are too distant!");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: recognizePOI(imagePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              POI poi = snapshot.data!;
              bool isDistanceValid = checkDistance(latitude, longitude, poi.latitude!, poi.longitude!);
              if (isDistanceValid) {
                Future.microtask(() {
                  // Going back to TakePictureScreen
                  Navigator.pop(context);
                  // Replacing TakePicutreScreen with the recongized poi screen
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SinglePOIView(poi: snapshot.data!)));
                });
              }
              else {
                // POI is too distant. Showing an information message
                return TooDistantDialog(poi: snapshot.data!);
              }
            }
            else {
              // POI not recognized
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: Text(AppLocalizations.of(context)!.poiNotRecognized)),
                  ElevatedButton(
                      child: Text(AppLocalizations.of(context)!.tryAgain),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],
              );
            }
          }
          // Show a loading indicator during POI recognition
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Text(AppLocalizations.of(context)!.poiRecognitionLoading)),
              const Center(child: CircularProgressIndicator()),
            ],
          );
        }),
    );
  }
}

class TooDistantDialog extends StatelessWidget {
  final POI poi;
  const TooDistantDialog({Key? key, required this.poi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(AppLocalizations.of(context)!.tooDistantWarning, textAlign: TextAlign.center),
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.backToHomepage),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }),
          ElevatedButton(
              child: Text(AppLocalizations.of(context)!.continueAnyway),
              onPressed: () {
                Future.microtask(() {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SinglePOIView(poi: poi)));
                });
              }),
        ],
      ),
    );
  }
}

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }
  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}