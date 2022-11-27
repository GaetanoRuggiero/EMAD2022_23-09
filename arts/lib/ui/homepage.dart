import 'package:flutter/material.dart';
import './styles.dart';
import './sidequest.dart';
import '../utils/maps.dart';

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

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void initState() {
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

    super.initState();
    animationController.addListener(() {
      setState(() {});
    });
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
                  child: ElevatedButton(
                      style: topButtonStyle,
                      child: const Icon(Icons.person,
                          color: Colors.white),
                      onPressed: () {
                        debugPrint('Profilo');
                      }),
                ),
                ElevatedButton(
                    style: topButtonStyle,
                    child:
                        const Icon(Icons.mark_chat_unread, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SideQuest()),
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
                            debugPrint('Collezione');
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
                            debugPrint('Riconoscimento opera');
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
                            debugPrint('Lista Itinerari');
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
        ],
      ),
    );
  }
}
