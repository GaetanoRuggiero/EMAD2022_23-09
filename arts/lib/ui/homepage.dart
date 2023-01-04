import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import './collection.dart';
import './login.dart';
import './maps.dart';
import './profile.dart';
import './settings.dart';
import './sidequest.dart';
import './styles.dart';
import './takepicture.dart';
import './tourlistscreen.dart';
import '../main.dart';
import '../utils/blinking_text.dart';
import '../utils/user_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation degOneTranslationAnimation, degTwoTranslationAnimation, degThreeTranslationAnimation;
  late Animation rotationAnimation;
  var menuOpenedIcon = const Icon(Icons.add, color: Colors.white);
  var menuClosedIcon = const Icon(Icons.remove, color: Colors.white);
  bool isMenuOpened = false;

  bool _isLogged = false;

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  late Position? _currentPosition;
  late Future<Position?>? _currentPositionFuture;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 5,
  );
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  bool locationServiceToggle = false;

  Future<bool> _handlePermission() async {
    LocationPermission permission;
    bool locationService;

    locationService = await _geolocatorPlatform.isLocationServiceEnabled();
    // Test if location services are enabled.
    if (!locationService) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      if (locationServiceToggle) {
        showLocationDisabledDialog();
      }
      locationServiceToggle = true;
      debugPrint("Location services are disabled.");
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        showPermissionDeniedDialog();
        debugPrint("Location permission were denied.");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      showPermissionDeniedDialog();
      debugPrint("Location services denied forever.");
      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    debugPrint("Location permissions are granted.");
    return true;
  }

  Future<Position?> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return null;
    }

    return await _geolocatorPlatform.getCurrentPosition();
  }

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  void _openLocationSettings() async {
    final opened = await _geolocatorPlatform.openLocationSettings();

    if (opened) {
      debugPrint("Opened Location Settings");
    } else {
      debugPrint("Error opening Location Settings");
    }
  }

  void _openAppSettings() async {
    final opened = await _geolocatorPlatform.openAppSettings();

    if (opened) {
      debugPrint("Opened Application Settings");
    } else {
      debugPrint("Error opening Location Settings");
    }
  }

  void showLocationDisabledDialog() {
    showDialog(barrierDismissible: false, context: context, builder: (context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.locationOffDialogTitle),
        content: Text(AppLocalizations.of(context)!.locationOffDialogContent),
        actions: [
          TextButton(
              child: Text(AppLocalizations.of(context)!.noThanks),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          TextButton(
              child: Text(AppLocalizations.of(context)!.turnOnLocation),
              onPressed: () {
                Navigator.of(context).pop();
                _openLocationSettings();
              })
        ],
      );
    });
  }

  void showPermissionDeniedDialog() {
    showDialog(barrierDismissible: false, context: context, builder: (context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.locationPermissionDialogTitle),
        content: Text(AppLocalizations.of(context)!.locationPermissionDialogContent),
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
                _openAppSettings();
              })
        ],
      );
    });
  }

  @override
  void initState() {
    super.initState();

    UserUtils.isLogged().then((value) {
      if (value != null) {
        setState(() {
          _isLogged = value;
        });
      }
      return;
    });

    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0),
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.4), weight: 55.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.4, end: 1.0), weight: 45.0),
    ]).animate(animationController);
    degThreeTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.75), weight: 35.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.75, end: 1.0), weight: 65.0),
    ]).animate(animationController);
    rotationAnimation = Tween<double>(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));

    animationController.addListener(() {
      setState(() {});
    });

    // Initializing device's location
    _currentPosition = null;
    _currentPositionFuture = _getCurrentPosition();

    _serviceStatusStreamSubscription = _geolocatorPlatform.getServiceStatusStream()
      .handleError((error) {
        _serviceStatusStreamSubscription?.cancel();
        _serviceStatusStreamSubscription = null;
      }).listen((serviceStatus) {
        if (serviceStatus == ServiceStatus.enabled) {
          debugPrint("Location service enabled");
        } else {
          if (_positionStreamSubscription != null) {
            _positionStreamSubscription?.cancel();
            _positionStreamSubscription = null;
          }
          debugPrint("Location service disabled");
        }
        /* Location state changed (either enabled or disabled). We reset current
        * device location to ensure both location and service are enabled.*/
        setState(() {
          locationServiceToggle = true;
          _currentPosition = null;
          _currentPositionFuture = _getCurrentPosition();
        });
      });

    _positionStreamSubscription = _geolocatorPlatform.getPositionStream(locationSettings: locationSettings)
      .handleError((error) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      })
      .listen((Position? position) {
        if (position != null) {
          _currentPosition = position;
        }
        debugPrint(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
      });
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
    }
    if (_serviceStatusStreamSubscription != null) {
      _serviceStatusStreamSubscription?.cancel();
      _serviceStatusStreamSubscription = null;
    }
  }

  void showLoginDialog() {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.notLoggedDialogTitle),
        content: Text(AppLocalizations.of(context)!.notLoggedDialogContent),
        actions: [
          TextButton(
              child: Text(AppLocalizations.of(context)!.noThanks),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          TextButton(
              child: Text(AppLocalizations.of(context)!.redirectLog),
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
              })
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            FutureBuilder(
              future: _currentPositionFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    _currentPosition = snapshot.data!;
                    return Maps(latitude: snapshot.data!.latitude, longitude: snapshot.data!.longitude);
                  }
                  else {
                    return Center(child: Text(AppLocalizations.of(context)!.deviceLocationNotAvailable));
                  }
                }
                else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
            Positioned(
              top: 80.0,
              left: -25.0,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: _isLogged
                      ? ElevatedButton(
                          style: topButtonStyle,
                          child:
                          const Icon(Icons.person, color: Colors.white),
                          onPressed: () {
                            if (!_isLogged) {
                              showLoginDialog();
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Profile()),
                            );
                          }
                        )
                      : ElevatedButton(
                          style: topButtonStyle,
                          child:
                          const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen()),
                            );
                          }
                        )
                  ),
                  ElevatedButton(
                    style: topButtonStyle,
                    child: const Icon(Icons.mark_chat_unread, color: Colors.white),
                    onPressed: () {
                      if (!_isLogged) {
                        showLoginDialog();
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SideQuest()),
                      );
                    }),
                ],
              ),
            ),
            Positioned(
              bottom: 30.0,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  IgnorePointer(
                    child: Container(
                      color: Colors.transparent,
                      height: 150.0,
                      width: 250.0,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(getRadiansFromDegree(340),
                        degOneTranslationAnimation.value * 90),
                    child: Transform(
                        transform: Matrix4.rotationZ(
                            getRadiansFromDegree(rotationAnimation.value))
                          ..scale(degOneTranslationAnimation.value),
                        alignment: Alignment.center,
                        child: ElevatedButton(
                            style: smallButtonStyle,
                            child: const Icon(Icons.auto_stories,
                                color: Colors.white),
                            onPressed: () {
                              if (!_isLogged) {
                                showLoginDialog();
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CollectionScreen()),
                              );
                            })),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(getRadiansFromDegree(270),
                        degTwoTranslationAnimation.value * 80),
                    child: Transform(
                      transform: Matrix4.rotationZ(
                          getRadiansFromDegree(rotationAnimation.value))
                        ..scale(degTwoTranslationAnimation.value),
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: smallButtonStyle,
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white),
                        onPressed: () {
                          if (_currentPosition == null) {
                            setState(() {
                              _currentPositionFuture = _getCurrentPosition();
                            });
                          }
                          else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TakePictureScreen(camera: camera, latitude: _currentPosition!.latitude, longitude: _currentPosition!.longitude)),
                            );
                          }
                        })),
                  ),
                  Transform.translate(
                    offset: Offset.fromDirection(getRadiansFromDegree(200),
                        degThreeTranslationAnimation.value * 90),
                    child: Transform(
                        transform: Matrix4.rotationZ(
                            getRadiansFromDegree(rotationAnimation.value))
                          ..scale(degThreeTranslationAnimation.value),
                        alignment: Alignment.center,
                        child: ElevatedButton(
                            style: smallButtonStyle,
                            child: const Icon(Icons.location_on,
                                color: Colors.white),
                            onPressed: () {
                              if (!_isLogged) {
                                showLoginDialog();
                                return;
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const TourListScreen()));
                            })),
                  ),
                  Transform(
                    transform: Matrix4.rotationZ(
                        getRadiansFromDegree(rotationAnimation.value)),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: largeButtonStyle,
                      child: isMenuOpened ? menuClosedIcon : menuOpenedIcon,
                      onPressed: () {
                        if (animationController.isCompleted) {
                          isMenuOpened = !isMenuOpened;
                          animationController.reverse();
                        } else if (animationController.isDismissed) {
                          isMenuOpened = !isMenuOpened;
                          animationController.forward();
                        }
                      }),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: FutureBuilder(future: _currentPositionFuture, builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    return Container(
                      color: Colors.green,
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: Center(
                        child: Text(textAlign: TextAlign.center, AppLocalizations.of(context)!.deviceLocationAvailable)
                      )
                  );
                  }
                  else {
                    return Container(
                      color: Colors.red,
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: Center(
                        child: Text(textAlign: TextAlign.center, "${AppLocalizations.of(context)!.deviceLocationNotAvailable}.")
                      )
                    );
                  }
                }
                else {
                  return Container(
                    color: Colors.green,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Center(
                        child: BlinkText("${AppLocalizations.of(context)!.fetchingGPSCoordinates}...")
                    )
                  );
                }
              }),
            )
          ],
        ),
      ),
    );
  }
}