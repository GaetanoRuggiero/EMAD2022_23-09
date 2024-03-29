import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:arts/api/sidequest_api.dart';
import 'package:arts/exception/exceptions.dart';
import 'package:arts/utils/user_utils.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:native_exif/native_exif.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import './styles.dart';
import '../api/poi_api.dart';
import '../api/recognition_api.dart';
import '../api/user_api.dart';
import '../model/POI.dart';
import '../model/google_vision_response.dart';
import '../model/sidequest.dart';
import '../model/user.dart';
import '../ui/singlepoiview.dart';
import '../utils/user_provider.dart';

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
  bool _cameraPermissionGranted = true;
  FlashMode flashMode = FlashMode.off;
  StreamSubscription<NativeDeviceOrientation>? _stream;
  NativeDeviceOrientation? _currentDeviceOrientation = NativeDeviceOrientation.portraitUp;

  void initializeCamera() async {
    _controller = CameraController(
      enableAudio: false,
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.max,
    );


    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cameraPermissionGranted = true;
      });
    }).catchError((error) {
      if (error is CameraException) {
        switch (error.code) {
          case 'CameraAccessDenied':
            setState(() {
              _cameraPermissionGranted = false;
            });
            break;
          default:
            break;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
      _stream = NativeDeviceOrientationCommunicator()
          .onOrientationChanged(useSensor: true)
          .asBroadcastStream()
          .listen((event) {
        _currentDeviceOrientation = event;
      });
    initializeCamera();
  }

  @override
  void dispose() {
    // Dispose of the camera controller when the widget is disposed.
    _controller.dispose();
    if (_stream != null) {
      _stream?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraPermissionGranted) {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.no_photography_rounded, size: 40),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(AppLocalizations.of(context)!.cameraPermissionsError, textAlign: TextAlign.center),
            ),
            ElevatedButton(onPressed: () async {
              var status = await Permission.camera.request();
              debugPrint(status.toString());
              if (status == PermissionStatus.denied) {
                debugPrint("Camera permission denied.");
              } else if (status == PermissionStatus.permanentlyDenied) {
                debugPrint("Camera permission permanently denied.");
                if (!mounted) {
                  return;
                }
                showDialog(context: context, builder: (context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.cameraPermissionDialogTitle),
                    content: Text(AppLocalizations.of(context)!.cameraPermissionDialogContent),
                    actions: [
                      TextButton(
                          child: Text(AppLocalizations.of(context)!.noThanks),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                      TextButton(
                          child: Text(AppLocalizations.of(context)!.allowPermission),
                          onPressed: () {
                            Navigator.of(context).pop();
                            openAppSettings();
                          })
                    ],
                  );
                });
              } else if (status == PermissionStatus.granted) {
                initializeCamera();
              }
            }, child: Text(AppLocalizations.of(context)!.allowPermission))
          ],
        ));
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        shadowColor: Colors.transparent
      ),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            _controller.setFlashMode(flashMode);
            final mediaSize = MediaQuery.of(context).size;
            final scale = 1 / (_controller.value.aspectRatio * mediaSize.aspectRatio);
            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: ClipRect(
                    clipper: _MediaSizeClipper(mediaSize),
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
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
                                orientation: _currentDeviceOrientation!,
                                latitude: widget.latitude,
                                longitude: widget.longitude,
                              ),
                            ),
                          );
                        } catch (e) {
                          debugPrint("Could not take the picture! Exception message:\n ${e.toString()}");
                        }
                      })
                ),
                /*Positioned(
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
                      },
                      child: flashMode == FlashMode.off ?
                      const Icon(Icons.flash_off_outlined)
                      : const Icon(Icons.flash_on_outlined)
                  ),
                )*/
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class ImageRecognitionScreen extends StatelessWidget {
  final String imagePath;
  final double latitude;
  final double longitude;
  final NativeDeviceOrientation orientation;

  const ImageRecognitionScreen(
    {super.key, required this.imagePath, required this.orientation, required this.latitude, required this.longitude});

  Future<Map<POI, double>> recognizePOI(String imagePath, bool developerMode) async {
    final img.Image? capturedImage = img.decodeImage(await XFile(imagePath).readAsBytes());
    final img.Image rotatedImage;

    if (orientation == NativeDeviceOrientation.portraitDown) {
      debugPrint("Portait Down");
      rotatedImage = img.copyRotate(capturedImage!, 180);
    } else if (orientation == NativeDeviceOrientation.landscapeLeft) {
      debugPrint("Landscape left");
      rotatedImage = img.copyRotate(capturedImage!, 270);
    } else if (orientation == NativeDeviceOrientation.landscapeRight) {
      debugPrint("LandscapeRight");
      rotatedImage = img.copyRotate(capturedImage!, 90);
    } else {
      debugPrint("Portrait");
      rotatedImage = capturedImage!;
    }
    await File(imagePath).writeAsBytes(img.encodeJpg(rotatedImage));
    
    Map<POI, double> candidates = {};
    double acceptableScore = 0.4;
    /* Storing the device location into image's EXIF metadata to improve
    probability of success of the recognition step. */
    if (!developerMode) {
      Exif? exif = await Exif.fromPath(imagePath);
      await exif.writeAttributes({
        'GPSLatitude': latitude.toString(),
        'GPSLatitudeRef': 'N',
        'GPSLongitude': longitude.toString(),
        'GPSLongitudeRef': 'E',
      });
      await exif.close();
    }

    final String imageBase64 = base64Encode(await XFile(imagePath).readAsBytes());
    try {
      GoogleVisionResponse visionResponse = await getVisionResults(imageBase64);
      String? bestGuessLabel = visionResponse.responses?[0].webDetection?.bestGuessLabels?[0].label;
      for (var webEntity in visionResponse.responses![0].webDetection!.webEntities!) {
        debugPrint("[ImageRecognitionScreen] Searching for: ${webEntity.description!}");
        var searchResults = await getPOIListByName(webEntity.description!);
        if (searchResults.isNotEmpty) {
          for (var result in searchResults) {
            if (webEntity.description!.toLowerCase() ==
                result.name!.toLowerCase()
                || webEntity.description!.toLowerCase() ==
                    result.nameEn!.toLowerCase()) {
              if (webEntity.score! < acceptableScore) {
                debugPrint("[ImageRecognitionScreen] Not considering - ${result.nameEn}, score is too low: ${webEntity.score}");
                continue;
              }
              debugPrint("[ImageRecognitionScreen] Found a match! - ${result.nameEn} with score: ${webEntity.score}");
              candidates.update(result,
                (value) {
                  if (value < webEntity.score!) {
                    return webEntity.score!;
                  } else {
                    return (value + 0.5);
                  }
                },
                ifAbsent: () {
                double score = webEntity.score!;
                  if (bestGuessLabel != null && bestGuessLabel.isNotEmpty) {
                    if (bestGuessLabel.toLowerCase() == result.name!.toLowerCase()
                      || bestGuessLabel.toLowerCase() == result.nameEn!.toLowerCase()) {
                      score = score + 0.5;
                      debugPrint("[ImageRecognitionScreen] bestGuessLabel: $bestGuessLabel");
                    }
                  }
                  return score;
                });
            }
          }
        }
      }
    } on ConnectionErrorException catch(e) {
      debugPrint(e.cause);
    }
    return candidates;
  }

  double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    double distanceInMeters = Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
    debugPrint("[ImageRecognitionScreen] Distance between current location and POI is: $distanceInMeters meters.");
    return distanceInMeters;
  }

  bool checkPhotoThreshold(double distance, double threshold) {
    if (distance <= threshold) {
      debugPrint("[ImageRecognitionScreen] Distance is OK!");
      return true;
    } else {
      debugPrint("[ImageRecognitionScreen] You are too distant!");
      return false;
    }
  }

  Future<Sidequest?> checkCompletedSidequest(POI recognizedPOI) async {
    List<Sidequest> availableSidequests = await getAvailableSidequest();
    for (var sidequest in availableSidequests) {
      if (sidequest.poi == recognizedPOI) {
        return sidequest;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return FutureBuilder(
            future: recognizePOI(imagePath, userProvider.isDeveloperModeOn),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  Map<POI, double> candidates = snapshot.data!;
                  POI bestCandidate = candidates.keys.first;

                  double minDistance = calculateDistance(latitude, longitude, bestCandidate.latitude!, bestCandidate.longitude!);
                  for (int i = 1; i < candidates.length; i++) {
                    double distance = calculateDistance(latitude, longitude, candidates.keys.elementAt(i).latitude!,  candidates.keys.elementAt(i).longitude!);
                    if (minDistance > distance) {
                      double currentScore = candidates[bestCandidate]!;
                      double newScore = candidates[candidates.keys.elementAt(i)]!;
                      if (currentScore > (newScore + 0.3)) {
                        continue;
                      }
                      minDistance = distance;
                      bestCandidate =  candidates.keys.elementAt(i);
                    }

                  }

                  double distanceThreshold = POI.getMaxPhotoThreshold(bestCandidate.size!);
                  if (userProvider.isDeveloperModeOn) {
                    distanceThreshold = 99999999999999999.9;
                  }

                  bool isDistanceValid = checkPhotoThreshold(minDistance, distanceThreshold);

                  if (isDistanceValid) {
                    debugPrint("[ImageRecognitionScreen] Best candidate: ${bestCandidate.nameEn} with score: ${candidates[bestCandidate]}");
                    Sidequest? completedSidequest;
                    Future.delayed(Duration.zero, () async {
                      String? email = await UserUtils.readEmail();
                      String? token = await UserUtils.readToken();
                      if (email != null && token != null) {
                        String lastVisited = DateTime.now().toLocal().toString();
                        userProvider.visited.update(bestCandidate, (value) => lastVisited, ifAbsent: () => lastVisited);
                        try {
                          updateVisitedPOI(email, token, bestCandidate.id!, lastVisited);
                          completedSidequest = await checkCompletedSidequest(bestCandidate);
                          if (completedSidequest != null) {
                            Coupon? coupon = await giveSidequestCoupon(email, token, completedSidequest!.reward!.id!);
                            if (coupon == null) {
                              debugPrint("\n[ Sidequest already Completed ]\n- Reward place: ${completedSidequest!.reward!.placeEvent}\n- POI to recognize: ${completedSidequest!.poi!.nameEn}");
                              completedSidequest = null;
                            } else {
                              debugPrint("\n[ Sidequest Completed ]\n- Reward place: ${completedSidequest!.reward!.placeEvent}\n- POI to recognize: ${completedSidequest!.poi!.nameEn}");
                            }
                          }
                        } on ConnectionErrorException catch(e) {
                          debugPrint(e.cause);
                        }
                      }
                      Future.microtask(() {
                        // Going back to TakePictureScreen
                        Navigator.pop(context);
                        // Replacing TakePictureScreen with the recognized poi screen
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => SinglePOIView(poi: bestCandidate, sidequest: completedSidequest)));
                      });
                    });
                  }
                  else {
                    // POI is too distant. Showing an information message
                    return TooDistantDialog(poi: bestCandidate);
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: Text("${AppLocalizations.of(context)!.poiRecognitionLoading}...")),
                  ),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            });
        },
      ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(AppLocalizations.of(context)!.tooDistantWarning, textAlign: TextAlign.center),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(300, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
              )
            ),
            child: Text(AppLocalizations.of(context)!.backToHomepage),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(300, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30)
              )
            ),
            child: Text(AppLocalizations.of(context)!.continueAnyway),
            onPressed: () {
              Future.microtask(() {
                Navigator.pop(context);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SinglePOIView(poi: poi, sidequest: null)));
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