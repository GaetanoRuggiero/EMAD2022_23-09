import 'dart:math';
import 'dart:ui';

import 'package:arts/model/sidequest.dart';
import 'package:arts/ui/styles.dart';
import 'package:arts/utils/user_provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../model/POI.dart';
import '../model/reward.dart';

class SinglePOIView extends StatefulWidget {
  const SinglePOIView({super.key, required this.poi, required this.sidequest});
  final POI poi;
  final Sidequest? sidequest;

  @override
  State<SinglePOIView> createState() => _SinglePOIViewState();
}

class _SinglePOIViewState extends State<SinglePOIView> with TickerProviderStateMixin {
  late Animation<double> _scrollDownOpacity, _imageOpacity, _blueOpacity, _textLeftPosition;
  late AnimationController _scrollDownAnimationController, _opacityController;
  bool _isScrollDownVisible = true;
  bool _sidequestDialogShown = false;


  @override
  void initState() {
    super.initState();

    _opacityController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _imageOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_opacityController);
    _blueOpacity = Tween<double>(begin: 0.0, end: 0.4).animate(_opacityController);
    _textLeftPosition = Tween<double>(begin: -300, end: 30).animate(_opacityController);
    _opacityController.forward();
    _opacityController.addListener(() {
      setState(() {});
    });

    _scrollDownAnimationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _scrollDownOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_scrollDownAnimationController);
    _scrollDownAnimationController.forward();
    _scrollDownAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isScrollDownVisible) {
        _scrollDownAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed && _isScrollDownVisible) {
        _scrollDownAnimationController.forward();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollDownAnimationController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sidequest != null && !_sidequestDialogShown) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        showDialog(
          barrierColor: const Color(0x22000000),
            context: context,
            builder: (context) =>
                SidequestCompletedDialog(reward: widget.sidequest!.reward!));

      });
      _sidequestDialogShown = true;
    }
    return Scaffold(
      body: Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        Locale currentLocale = Localizations.localeOf(context);
        String name = widget.poi.name!;
      if (currentLocale.languageCode == "en") {
        name = widget.poi.nameEn!;
      }
        String? lastVisited;
        String? dateVisited, hourVisited;
        if (userProvider.visited[widget.poi] != null) {
          lastVisited = lastVisited = userProvider.visited[widget.poi]!;
          if (currentLocale.languageCode == "en") {
            dateVisited = DateFormat('yyyy LLLL dd', currentLocale.toLanguageTag()).format(DateTime.parse(lastVisited));
            hourVisited = DateFormat('h:mm a', currentLocale.toLanguageTag()).format(DateTime.parse(lastVisited));
          } else {
            dateVisited = DateFormat('dd LLLL yyyy', currentLocale.toLanguageTag()).format(DateTime.parse(lastVisited));
            hourVisited = DateFormat('HH:mm', currentLocale.toLanguageTag()).format(DateTime.parse(lastVisited));
          }
        }
        return Stack(
          children: [
            AnimatedOpacity(
                opacity: _imageOpacity.value,
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                child: SizedBox(
                  height: double.infinity,
                  child: Image.asset(widget.poi.imageURL!, fit: BoxFit.cover, alignment: Alignment.center),
                )),
            lastVisited == null ?
            AnimatedOpacity(
              opacity: _scrollDownOpacity.value,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: Center(
                child: Icon(
                    Icons.question_mark,
                    color: Colors.orangeAccent,
                    shadows: const [],
                    size: MediaQuery.of(context).size.width - 60),
              ),
            ) : Container(),
            AnimatedOpacity(
              opacity: _blueOpacity.value,
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                        radius: 3,
                        center: Alignment.topCenter,
                        colors: [
                          Colors.black,
                          Colors.blue.shade700,
                        ]
                    )
                ),
              ),
            ),
            Positioned(
              top: 80,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 80,
                child: SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(
                          height: lastVisited != null ? MediaQuery.of(context).size.height - 80 : 300,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedPositioned(
                                  top: 0,
                                  left: _textLeftPosition.value,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width - 100,
                                        padding: const EdgeInsets.all(10),
                                        child: Text(name,
                                            style: const TextStyle(
                                                shadows: [
                                                  BoxShadow(color: Colors.black, offset: Offset(0.25, 1), blurRadius: 5)
                                                ],
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      ),
                                      lastVisited != null
                                          ? Container(
                                          padding: const EdgeInsets.all(10.0),
                                          child: RichText(
                                              text: TextSpan(
                                                  style: const TextStyle(fontFamily: 'JosefinSans'),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                        text: "${AppLocalizations.of(context)!.lastVisited}\n",
                                                        style: const TextStyle(color: Colors.white)
                                                    ),
                                                    TextSpan(
                                                        text: "$dateVisited ",
                                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                                    ),
                                                    TextSpan(
                                                        text: "${AppLocalizations.of(context)!.hourVisited} ",
                                                        style: const TextStyle(color: Colors.white)
                                                    ),
                                                    TextSpan(
                                                        text: hourVisited,
                                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                                    ),
                                                  ]))
                                      )
                                          : Container(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(AppLocalizations.of(context)!.notVisitedYet, style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic))
                                      ),
                                      lastVisited != null && widget.poi.modelName != null ?
                                      ElevatedButton.icon(
                                          icon: const Icon(FontAwesomeIcons.unity, color: Colors.white),
                                          style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                                          label: Text(AppLocalizations.of(context)!.view3dModel, style: const TextStyle(color: Colors.white)),
                                          onPressed: () {}
                                      ) : Container(),
                                    ],
                                  )),
                              lastVisited != null ? Positioned(
                                bottom: 0,
                                child: VisibilityDetector(
                                  key: const Key('scroll-down-widget'),
                                  onVisibilityChanged: (visibilityInfo) {
                                    double visiblePercentage = visibilityInfo.visibleFraction * 100;
                                    if (visiblePercentage < 1.0) {
                                      if (_scrollDownAnimationController.isAnimating) {
                                        _isScrollDownVisible = false;
                                        _scrollDownAnimationController.reset();
                                      }
                                    } else {
                                      if (!_scrollDownAnimationController.isAnimating) {
                                        _isScrollDownVisible = true;
                                        _scrollDownAnimationController.forward();
                                      }
                                    }
                                  },
                                  child: AnimatedOpacity(
                                    opacity: _scrollDownOpacity.value,
                                    duration: const Duration(seconds: 1),
                                    child: Column(
                                      children: [
                                        Text(AppLocalizations.of(context)!.scrollForDetails, style: const TextStyle(color: Colors.white)),
                                        const Icon(Icons.expand_more, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ),
                              ) : const SizedBox(width: 600, height: 400),
                            ],
                          ),
                        ),
                        lastVisited != null ?
                        Expanded(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height - 80
                            ),
                            child: DetailedPOIScreen(poi: widget.poi))) : const Text("")
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
            )
          ],
        );
      },
    ));
  }
}

class DetailedPOIScreen extends StatelessWidget {
  const DetailedPOIScreen({Key? key, required this.poi}) : super(key: key);
  final POI poi;

  @override
  Widget build(BuildContext context) {
    String history = poi.history!;
    String trivia = poi.trivia!;
    if (Localizations.localeOf(context).languageCode == "en") {
      history = poi.historyEn!;
      trivia = poi.triviaEn!;
    }
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5.0,
          sigmaY: 5.0
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 10, 5),
                  child: Icon(FontAwesomeIcons.buildingColumns, size: 30, color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 0, 20),
                  child: Text(AppLocalizations.of(context)!.history, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(history, style: const TextStyle(fontSize: 18, color: Colors.white)),
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 10, 5),
                  child: Icon(FontAwesomeIcons.question, size: 30, color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 20, 0, 20),
                  child: Text(AppLocalizations.of(context)!.trivia, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(trivia, style: const TextStyle(fontSize: 18, color: Colors.white)),
            )
          ]
        ),
      ),
    );
  }
}

class SidequestCompletedDialog extends StatefulWidget {
  const SidequestCompletedDialog({Key? key, required this.reward})
      : super(key: key);
  final Reward reward;

  @override
  State<SidequestCompletedDialog> createState() => _SidequestCompletedDialogState();
}

class _SidequestCompletedDialogState extends State<SidequestCompletedDialog> {

  late ConfettiController _controllerTopLeft;
  late ConfettiController _controllerTopRight;

  @override
  void initState() {
    super.initState();
    _controllerTopLeft = ConfettiController(duration: const Duration(seconds: 2));
    _controllerTopRight = ConfettiController(duration: const Duration(seconds: 2));
    _controllerTopLeft.play();
    _controllerTopRight.play();
  }

  List<Color> getListColors() {
    List<Color> colorList = [];
    for (int i = 0; i<100; i++) {
      colorList.add(Color((Random().nextDouble() * 0xFFFFFFFF).toInt()));
    }
    return colorList;
  }

  @override
  void dispose() {
    _controllerTopLeft.dispose();
    _controllerTopRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [

        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),

        Positioned(
          top: -50,
          left: 0,
          child: ConfettiWidget(
            confettiController: _controllerTopLeft,
            maxBlastForce: 20, // set a lower max blast force
            minBlastForce: 5, // set a lower min blast force
            emissionFrequency: 1.0,
            colors: getListColors(),
            shouldLoop: false,
            numberOfParticles: 20, // a lot of particles at once
            gravity: 0.4,
            blastDirectionality: BlastDirectionality.explosive,
            minimumSize: const Size(10, 10),
            particleDrag: 0.02,
            maximumSize: const Size(11, 11),
          ),
        ),

        Positioned(
          top: -50,
          right: 0,
          child: ConfettiWidget(
            confettiController: _controllerTopRight,
            maxBlastForce: 40, // set a lower max blast force
            minBlastForce: 3, // set a lower min blast force
            emissionFrequency: 1.0,
            colors: getListColors(),
            shouldLoop: false,
            numberOfParticles: 20, // a lot of particles at once
            gravity: 0.4,
            blastDirectionality: BlastDirectionality.explosive,
            minimumSize: const Size(10, 10),
            particleDrag: 0.02,
            maximumSize: const Size(11, 11),
          ),
        ),

        TopIconDialog(
          icon: Container(
            width: 55,
            height: 55,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              shape: BoxShape.circle
            ),
            child: Image.asset('assets/icon/party.png', fit: BoxFit.cover)),
          title: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text("${AppLocalizations.of(context)!.missionCompleted}!", textAlign: TextAlign.center, style: const TextStyle(color: darkOrange, fontSize: 18)),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
                "${AppLocalizations.of(context)!.youHaveReceived} 1 ${widget.reward.type} ${AppLocalizations.of(context)!.sideQuestGoToLower} ${widget.reward.placeEvent}!", textAlign: TextAlign.center),
          ),
          actions: [
            TextButton(
              child: const Text("Okay"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      ],
    );
  }
}