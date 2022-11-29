import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

bool isSwitched = false;


class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  final Container iconArrow = Container(
    child: IconButton(
      onPressed: (){},
      icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
    ),
  );

  final Color iconColor = const Color(0xffE68532);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Impostazioni"),
        actions: <Widget>[
          IconButton(onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
              icon: const Icon(Icons.home_rounded)),
        ],
      ),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text("Lingua e tema",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )
                    ),

                    const SizedBox(height: 10),

                    SettingsTile(
                        cont: iconArrow,
                        icon: Ionicons.language,
                        title: "Lingua"),

                    const SizedBox(height: 10),

                    SettingsTile(
                      icon: Ionicons.color_palette_outline,
                      title: "Tema scuro",
                      cont: Container(
                        child: Switch(
                          activeColor: Colors.grey,
                          value: isSwitched,
                          onChanged: (value) {
                            setState(() {
                              isSwitched = !isSwitched;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text("Account",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )
                    ),

                    const SizedBox(height: 10),

                    SettingsTile(
                        cont: iconArrow,
                        icon: Icons.account_circle,
                        title: "Info account"
                    ),

                    const SizedBox(height: 10),

                    SettingsTile(
                        cont: iconArrow,
                        icon: Ionicons.log_out_outline,
                        title: "Logout"
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text("Info",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                    ),

                    const SizedBox(height: 10),

                    SettingsTile(
                        cont: iconArrow,
                        icon: Ionicons.information_circle_sharp,
                        title: "Info e riconoscimenti"
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class SettingsTile extends StatelessWidget {

  final IconData icon;
  final String title;
  final Container cont;

  const SettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.cont
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.transparent,
          ),
          child: Icon(icon, color: const Color(0xffE68532)),
        ),

        const SizedBox(width: 10),

        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),

        const Spacer(),

        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: cont,
        ),

      ],
    );
  }
}
