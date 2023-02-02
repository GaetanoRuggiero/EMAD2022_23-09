import 'package:arts/ui/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> with SingleTickerProviderStateMixin{

  double _opacityImage = 1;
  double _opacityText = 0;

  Color textColor() {
    Color color = Theme.of(context).colorScheme.background;
    if (color == const Color(0xfffffbff)) {
      return darkBlue;
    }
    else {
      return Colors.white;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1),() {
      setState(() {
        _opacityImage = 0;
        _opacityText = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(AppLocalizations.of(context)!.infoAndRecognitions),
          actions: [
            IconButton(
                icon: const Icon(Icons.home_rounded),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
            )
          ]
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: double.infinity,
              child: AnimatedOpacity(opacity: _opacityImage,
                  duration: const Duration(seconds: 1),
                  child: Image.asset("assets/icon/icon_big.png")),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(opacity: 0.2, image: AssetImage("assets/icon/icon_big.png"))),
              alignment: Alignment.center,
              width: double.infinity,
              height: double.infinity,
              child: AnimatedOpacity(
                opacity: _opacityText,
                duration: const Duration(seconds: 1),
                child: Container(
                  padding: const  EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  width: 600,
                  child: RichText(text: TextSpan(
                      style: TextStyle(fontSize: 17, fontFamily: "JosefinSans", color: textColor()),
                      children: [
                        TextSpan(text: AppLocalizations.of(context)!.appNameLowerCase,
                            style: TextStyle(fontSize: 25, fontFamily: "DaVinci", color: Theme.of(context).iconTheme.color)),
                        TextSpan(text: " ${AppLocalizations.of(context)!.bornAsAProject}"),
                        TextSpan(text:" ${AppLocalizations.of(context)!.emad} ",
                            style: const TextStyle(shadows: <Shadow>[
                              Shadow(
                                offset: Offset(0.3, 0.3),
                                blurRadius: 5.0,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ],)),
                        TextSpan(text:"${AppLocalizations.of(context)!.unisa}.\n\n"),
                        TextSpan(text: "${AppLocalizations.of(context)!.developedBy}: \n"
                            " • ${AppLocalizations.of(context)!.aA}\n"
                            " • ${AppLocalizations.of(context)!.gR}\n"
                            " • ${AppLocalizations.of(context)!.mS}\n"),
                        TextSpan(text: "\n ${AppLocalizations.of(context)!.weThank}:\n"),
                        TextSpan(text: "- ${AppLocalizations.of(context)!.wikipedia}", style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16)),
                        TextSpan(text: ": ${AppLocalizations.of(context)!.thanksToWikipedia};\n"),
                        TextSpan(text: "- ${AppLocalizations.of(context)!.unsplash}", style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16)),
                        TextSpan(text: ": ${AppLocalizations.of(context)!.thanksToUnsplash};\n"),
                        TextSpan(text: "- ${AppLocalizations.of(context)!.johnsonMartin}", style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16)),
                        TextSpan(text: ": ${AppLocalizations.of(context)!.thanksToJohnson}"),
                        TextSpan(text: " ${AppLocalizations.of(context)!.link}", style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blue,),
                            recognizer: TapGestureRecognizer()..onTap = () {
                              Uri url = Uri.parse("https://skfb.ly/AIU9");
                              launchUrl(url);
                            }
                        ),
                        const TextSpan(text: "."),
                      ]
                  )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}