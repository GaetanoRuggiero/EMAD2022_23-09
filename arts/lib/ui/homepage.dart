import 'dart:async';

import 'package:arts/api/poi_api.dart';
import 'package:arts/exception/exceptions.dart';
import 'package:arts/utils/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../utils/settings_model.dart';
import './collection.dart';
import './login.dart';
import './profile.dart';
import './settings.dart';
import './sidequestscreen.dart';
import './styles.dart';
import './takepicture.dart';
import './tourlistscreen.dart';
import '../main.dart';
import '../model/POI.dart';
import '../utils/location_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late GoogleMapController _mapController;
  late String _darkMapStyle;
  late String _lightMapStyle;
  bool _isMapDark = false;
  List<Marker> _markers = [];
  late AnimationController animationController;
  late AnimationController glowingAnimationController;
  late AnimationController switchThemeAnimationController;
  late Animation<double> switchThemeAnimation;
  late Animation glowingAnimation;
  late Animation degOneTranslationAnimation, degTwoTranslationAnimation, degThreeTranslationAnimation;
  late Animation rotationAnimation;
  late Animation<double> menuOpacityAnimation;
  bool isMenuOpened = false;

  Position? _currentPosition;
  Future<Position?>? _currentPositionFuture;
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

    locationService = await LocationUtils.geolocatorPlatform.isLocationServiceEnabled();
    // Test if location services are enabled.
    if (!locationService) {
      if (locationServiceToggle) {
        if (!mounted) return false;
        LocationUtils.showLocationDisabledDialog(context);
      }
      locationServiceToggle = true;
      return false;
    }

    permission = await LocationUtils.geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await LocationUtils.geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        if (!mounted) return false;
        LocationUtils.showPermissionDeniedDialog(context);
        debugPrint("Location permission were denied.");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      if (!mounted) return false;
      LocationUtils.showPermissionDeniedDialog(context);
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

    Position? position = await LocationUtils.geolocatorPlatform.getLastKnownPosition();
    if (position != null) {
      _drawInRangeMarkers(position.latitude, position.longitude, 4);
      return position;
    }

    if (glowingAnimationController.isDismissed) {
      glowingAnimationController.repeat(reverse: true);
    }
    try {
      position = await LocationUtils.geolocatorPlatform.getCurrentPosition();
      _drawInRangeMarkers(position.latitude, position.longitude, 4);
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    if (glowingAnimationController.isAnimating) {
      glowingAnimationController.reset();
    }
    return position;
  }

  Future<void> _drawInRangeMarkers(double latitude, double longitude, double rangeKm) async {
    BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), "assets/markers/marker_tovisit.png");
    try {
      List<POI> inRangeList = await getPOIByRange(latitude, longitude, rangeKm);
      List<Marker> markers = [];
      for (int i = 0; i < inRangeList.length; i++) {
        markers.add(Marker(
          markerId: MarkerId(i.toString()),
          position: LatLng(inRangeList[i].latitude!, inRangeList[i].longitude!),
          icon: markerIcon,
            onTap: () {
              showDialog(barrierColor: const Color(0x01000000),
                context: context,
                builder: (_) {
                  return SimpleDialog(
                    backgroundColor: Colors.grey,
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.topCenter,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                    ),
                    elevation: 2.0,
                    contentPadding: EdgeInsets.zero,
                    insetPadding: const EdgeInsets.fromLTRB(24, 115, 24, 24),
                    children: [
                      SizedBox(
                          width: 200,
                          height: 150,
                          child: Image.asset(inRangeList[i].imageURL!, fit: BoxFit.fitWidth)
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 28.0),
                                ),
                                Text(inRangeList[i].name!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            )
                          )
                        ],
                      ),
                    ],
                  );
                }
              );
            }
        ));
      }
      setState(() {
        _markers = markers;
      });
    } on ConnectionErrorException catch (e) {
      debugPrint(e.cause);
    }
  }

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  Future _loadMapStyles() async {
    _darkMapStyle  = await rootBundle.loadString('assets/map_styles/dark.json');
    _lightMapStyle = await rootBundle.loadString('assets/map_styles/light.json');
  }

  _changeMapTheme() async {
    if (_isMapDark) {
      _mapController.setMapStyle(_lightMapStyle);
    } else {
      _mapController.setMapStyle(_darkMapStyle);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    switchThemeAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    switchThemeAnimation = Tween<double>(begin: 0.0, end: MediaQuery.of(context).size.longestSide * 2)
        .animate(CurvedAnimation(parent: switchThemeAnimationController, curve: Curves.easeInOut));
    switchThemeAnimationController.addStatusListener((status) {
       if (status == AnimationStatus.completed) {
         switchThemeAnimationController.reset();
         setState(() {
           _isMapDark = !_isMapDark;
         });
       }
    });
    switchThemeAnimationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMapStyles();

    // Initializing device's location
    Future.delayed(Duration.zero, () async {
      _currentPosition = await _getCurrentPosition();
      setState(() {
        _currentPositionFuture = Future.value(_currentPosition);
      });
    });

    glowingAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    glowingAnimation = Tween(begin: 1.0, end: 5.0).animate(glowingAnimationController);
    glowingAnimationController.addListener(() {
      setState(() {});
    });

    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
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
    menuOpacityAnimation = Tween<double>(begin: 0.0, end: 0.6).animate(animationController);
    animationController.addListener(() {
      setState(() {});
    });

    _serviceStatusStreamSubscription = LocationUtils.geolocatorPlatform.getServiceStatusStream()
      .handleError((error) {
        _serviceStatusStreamSubscription?.cancel();
        _serviceStatusStreamSubscription = null;
      }).listen((serviceStatus) {
        if (serviceStatus == ServiceStatus.disabled) {
          if (_positionStreamSubscription != null) {
            _positionStreamSubscription?.cancel();
            _positionStreamSubscription = null;
          }
          setState(() {
            _currentPosition = null;
            _currentPositionFuture = Future.value(_currentPosition);
          });
        } else {
          setState(() {
            _currentPositionFuture = _getCurrentPosition().then((position) {
              setState(() {
                _currentPosition = position;
              });
              return position;
            });
          });
        }

        locationServiceToggle = true;
      });

    _positionStreamSubscription = LocationUtils.geolocatorPlatform.getPositionStream(locationSettings: locationSettings)
      .handleError((error) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      })
      .listen((Position? position) {
        if (position != null) {
          _currentPosition = position;
          _mapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 18.0
              )
          ));
        }
        debugPrint(position == null ? 'Unknown' : 'Homepage: Location updated successfully.');
      });
  }

  @override
  void dispose() {
    _mapController.dispose();
    switchThemeAnimationController.dispose();
    glowingAnimationController.dispose();
    animationController.dispose();
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
    }
    if (_serviceStatusStreamSubscription != null) {
      _serviceStatusStreamSubscription?.cancel();
      _serviceStatusStreamSubscription = null;
    }
    super.dispose();
  }

  void showLoginDialog() {
    showDialog(context: context, builder: (context) {
      return TopIconDialog(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(AppLocalizations.of(context)!.notLoggedDialogTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(AppLocalizations.of(context)!.notLoggedDialogContent, textAlign: TextAlign.center),
        ),
        icon: Icon(Icons.info, size: 65, color: Theme.of(context).textTheme.bodyLarge!.color),
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
        ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer2<UserProvider, SettingsModel>(
          builder: (context, userProvider, settingsModel, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  color: _isMapDark ? const Color(0xff242f3e) : Theme.of(context).scaffoldBackgroundColor,
                  child: _currentPosition != null
                  ? GoogleMap(
                    markers: Set.from(_markers),
                    mapToolbarEnabled: false,
                    zoomControlsEnabled: false,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    onMapCreated: (controller) {
                      _mapController = controller;

                      final theme = settingsModel.themeMode;
                      if (theme == ThemeMode.dark) {
                        _isMapDark = true;
                        _mapController.setMapStyle(_darkMapStyle);
                      } else {
                        _isMapDark = false;
                        _mapController.setMapStyle(_lightMapStyle);
                      }
                    },
                    initialCameraPosition: CameraPosition(
                        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        zoom: 18.0
                    ),
                  )
                  : FutureBuilder(
                    future: _currentPositionFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && !snapshot.hasData) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_off, size: 80),
                              Text("${AppLocalizations.of(context)!.deviceLocationNotAvailable}.",
                                style: TextStyle(color: _isMapDark ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color),),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                                  ),
                                  onPressed: () {
                                    _handlePermission();
                                  },
                                  child: Text(AppLocalizations.of(context)!.turnOnLocation)
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                OverflowBox(
                  maxHeight: MediaQuery.of(context).size.longestSide * 2,
                  maxWidth: MediaQuery.of(context).size.longestSide * 2,
                  child: Container(
                    width: switchThemeAnimation.value,
                    height: switchThemeAnimation.value,
                    decoration: BoxDecoration(
                      color: _isMapDark ? Colors.white : const Color(0xff242f3e),
                      shape: BoxShape.circle
                    ),
                  ),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade700, width: 0.3),
                        boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 1, spreadRadius: 1)]
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        if (switchThemeAnimationController.isDismissed) {
                          switchThemeAnimationController.forward();
                        }
                        Future.delayed(const Duration(milliseconds: 300), () async {
                          _changeMapTheme();
                        });
                      },
                      icon: _isMapDark ? const Icon(Icons.sunny, color: Colors.orangeAccent) : const Icon(Icons.dark_mode, color: Colors.black),
                    ),
                  ),
                ),
                Positioned(
                  top: 64,
                  right: 15,
                  child: FutureBuilder(future: _currentPositionFuture, builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        _currentPosition = snapshot.data!;
                        return Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade700, width: 0.3),
                              boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 1, spreadRadius: 1)]
                          ),
                          child: Tooltip(
                              showDuration: const Duration(seconds: 3),
                              message: AppLocalizations.of(context)!.deviceLocationAvailable,
                              triggerMode: TooltipTriggerMode.tap,
                              child: const Icon(Icons.location_pin, color: Colors.green, size: 25),
                              onTriggered: () {
                                if (_currentPosition != null) {
                                  _mapController.animateCamera(CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                          zoom: 18.0
                                      )
                                  ));
                                }
                              },
                          ),
                        );
                      }
                      else {
                        return Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade700, width: 0.3),
                              boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 1, spreadRadius: 1)]
                          ),
                          child: Tooltip(
                              showDuration: const Duration(seconds: 3),
                              message: AppLocalizations.of(context)!.deviceLocationNotAvailable,
                              triggerMode: TooltipTriggerMode.tap,
                              child: const Icon(Icons.location_off, color: Colors.red, size: 25)
                          ),
                        );
                      }
                    }
                    else {
                      return Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade700, width: 0.3),
                            boxShadow: [BoxShadow(
                              color: Colors.grey.shade400,
                              offset: Offset.zero,
                              blurRadius: glowingAnimation.value,
                              spreadRadius: glowingAnimation.value
                            )]
                        ),
                        child: Tooltip(
                            showDuration: const Duration(seconds: 3),
                            message: AppLocalizations.of(context)!.fetchingGPSCoordinates,
                            triggerMode: TooltipTriggerMode.tap,
                            child: Icon(Icons.location_on, color: Colors.blue.shade800, size: 25)
                        ),
                      );
                    }
                  }),
                ),
                Positioned(
                  top: 80.0,
                  left: -25.0,
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: userProvider.isLogged
                              ? ElevatedButton(
                              style: topButtonStyle,
                              child:
                              const Icon(Icons.person, color: Colors.white),
                              onPressed: () {
                                if (!userProvider.isLogged) {
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
                            if (!userProvider.isLogged) {
                              showLoginDialog();
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SidequestScreen()),
                            );
                          }),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (animationController.isCompleted && isMenuOpened) {
                      setState(() {
                        isMenuOpened = false;
                      });
                      animationController.reverse();
                    }
                  },
                  child: IgnorePointer(
                    ignoring: !isMenuOpened,
                    child: Container(
                      color: Colors.black.withOpacity(menuOpacityAnimation.value),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 35.0,
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
                                  if (!userProvider.isLogged) {
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
                                    if (glowingAnimationController.isDismissed) {
                                      glowingAnimationController.repeat(reverse: true);
                                    }
                                    Future.delayed(Duration.zero, () async {
                                      Position? position = await _getCurrentPosition();
                                      if (position != null) {
                                        setState(() {
                                          _currentPositionFuture = Future.value(position);
                                          _currentPosition = position;
                                        });
                                      }
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
                                  if (!userProvider.isLogged) {
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
                            child: isMenuOpened
                            ? const Icon(Icons.remove, color: Colors.white)
                            : const Icon(Icons.add, color: Colors.white),
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
              ],
            );
          }
        ),
      ),
    );
  }
}