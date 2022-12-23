import 'package:arts/ui/settings.dart';
import 'package:arts/utils/user_utils.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import './styles.dart';
import './profile.dart';
import './sidequest.dart';
import './collection.dart';
import './takepicture.dart';
import './tourlistscreen.dart';
import '../utils/maps.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation degOneTranslationAnimation,
      degTwoTranslationAnimation,
      degThreeTranslationAnimation;
  late Animation rotationAnimation;
  var menuOpenedIcon = const Icon(Icons.add, color: Colors.white);
  var menuClosedIcon = const Icon(Icons.remove, color: Colors.white);
  bool isMenuOpened = false;
  late Future<Position> _currentPositionFuture;

  late Future<bool?> _isLoggedFuture;

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void initState() {
    super.initState();

    _isLoggedFuture = UserUtils.isLogged();

    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
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

    _currentPositionFuture = _determinePosition();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          const Maps(),
          Positioned(
            top: 80.0,
            left: -25.0,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: FutureBuilder(
                      future: _isLoggedFuture,
                      builder: (context, snapshot) {
                        return ElevatedButton(
                            style: topButtonStyle,
                            child:
                            const Icon(Icons.person, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Profile()),
                              );
                            });
                      }),
                ),
                ElevatedButton(
                    style: topButtonStyle,
                    child:
                        const Icon(Icons.mark_chat_unread, color: Colors.white),
                    onPressed: () {
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
                          child:
                              const Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TakePictureScreen(camera: camera)),
                            );
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
          FutureBuilder(
            future: _currentPositionFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Positioned(
                    top: 0,
                    child: Container(
                        color: Colors.green,
                        width: MediaQuery.of(context).size.width,
                        height: 60,
                        child: Center(
                            child: Text(
                                textAlign: TextAlign.center,
                                "${AppLocalizations.of(context)!.deviceLocationAvailable}."))),
                  );
                } else {
                  return Positioned(
                      top: 0,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 60,
                          color: Colors.red,
                          child: Center(
                              child: Text(
                                  textAlign: TextAlign.center,
                                  "${AppLocalizations.of(context)!.deviceLocationNotAvailable}."))));
                }
              } else {
                return const Positioned(
                    top: 0, child: CircularProgressIndicator());
              }
            },
          )
        ],
      ),
    );
  }
}
