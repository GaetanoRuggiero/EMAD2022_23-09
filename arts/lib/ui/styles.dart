import 'package:flutter/material.dart';

const Color darkOrange = Color(0xffE68532);
const Color lightOrange = Color(0xFFEB9E5C);
const Color darkBlue =  Color(0xff113197);

final ButtonStyle largeButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFFE68532),
  minimumSize: const Size(60, 60),
  elevation: 4.0,
  shape: const CircleBorder(
    side: BorderSide(width: 2.5, color: Color(0x40000000)),
  ),
);

final ButtonStyle smallButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: const Color(0xFFEB9E5C),
  elevation: 4.0,
  minimumSize: const Size(50, 50),
  shape: const CircleBorder(
    side: BorderSide(width: 2.5, color: Color(0x40000000)),
  ),
);

final ButtonStyle topButtonStyle = ElevatedButton.styleFrom(
    shadowColor: Colors.transparent,
    backgroundColor: Colors.black38,
    minimumSize: const Size(80, 50),
    padding: const EdgeInsets.only(left: 20.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))
);

final ThemeData lightTheme = ThemeData(
  fontFamily: 'JosefinSans',
  appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 1.0,
      backgroundColor: Colors.transparent,
      shadowColor: Color(0x33000000),
      actionsIconTheme: IconThemeData(color: darkOrange),
      iconTheme: IconThemeData(color: darkOrange),
      titleTextStyle: TextStyle(color: darkBlue, fontSize: 18, fontFamily: 'JosefinSans', fontWeight: FontWeight.bold)
  ),
  tabBarTheme: const TabBarTheme(
    labelColor: darkBlue,
    indicator: UnderlineTabIndicator(borderSide: BorderSide(color: darkBlue, width: 2.0))
  ),
  iconTheme: const IconThemeData(color: darkOrange, shadows: [], size: 28),
  dividerColor: Colors.black26,
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0)
    ),
  ),
  colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: Colors.orange
  ).copyWith(
    primary: darkOrange,
    secondary: darkOrange,
    tertiary: darkBlue,
    error: Colors.red,
    onTertiary: Colors.white
  ),
  textTheme: const TextTheme().copyWith(
    bodyLarge: const TextStyle(color: darkBlue),
    bodyMedium: const TextStyle(color: darkBlue),
    titleLarge: const TextStyle(color: darkBlue),
    titleMedium: const TextStyle(color: darkBlue),
    titleSmall: const TextStyle(color: Colors.blueGrey),
  ),
  radioTheme: RadioThemeData(fillColor: MaterialStateProperty.resolveWith((states) => darkOrange)),
  inputDecorationTheme: const InputDecorationTheme().copyWith(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
    contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
    suffixIconColor: lightOrange,
    prefixIconColor: lightOrange,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
    unselectedItemColor: Colors.blueGrey,
    unselectedLabelStyle: const TextStyle(color: Colors.blueGrey)
  ),
);

final ThemeData darkTheme = ThemeData(
  fontFamily: 'JosefinSans',
  appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 1.0,
      backgroundColor: Colors.transparent,
      shadowColor: Color(0x33FFFFFF),
      actionsIconTheme: IconThemeData(color: darkOrange),
      iconTheme: IconThemeData(color: darkOrange),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'JosefinSans', fontWeight: FontWeight.bold)
  ),
  tabBarTheme: const TabBarTheme(
      labelColor: Colors.white,
      indicator: UnderlineTabIndicator(borderSide: BorderSide(color: Colors.orangeAccent, width: 2.0))
  ),
  iconTheme: const IconThemeData(color: darkOrange, shadows: [], size: 28),
  dividerColor: Colors.white70,
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0)
    ),
  ),
  colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: Colors.orange
  ).copyWith(
      primary: darkOrange,
      secondary: darkOrange,
      tertiary: lightOrange,
      error: Colors.red,
      onTertiary: Colors.grey.shade800
  ),
  textTheme: const TextTheme().copyWith(
    bodyLarge: const TextStyle(color: Colors.white),
    bodyMedium: const TextStyle(color: Colors.white),
    titleLarge: const TextStyle(color: Colors.white),
    titleMedium: const TextStyle(color: Colors.white),
    titleSmall: const TextStyle(color: Colors.white54),
  ),
  radioTheme: RadioThemeData(fillColor: MaterialStateProperty.resolveWith((states) => darkOrange)),
  inputDecorationTheme: const InputDecorationTheme().copyWith(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
    contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
    suffixIconColor: lightOrange,
    prefixIconColor: lightOrange,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
      unselectedItemColor: Colors.white54,
      unselectedLabelStyle: const TextStyle(color: Colors.white54)
  ),
);

class TopIconDialog extends StatelessWidget {
  const TopIconDialog({Key? key, required this.title, required this.content, required this.icon, required this.actions}) : super(key: key);
  final Widget title;
  final Widget content;
  final Widget icon;
  final List<Widget> actions;

  Widget dialogContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 0.0,right: 0.0),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 18.0,
            ),
            margin: const EdgeInsets.only(top: 13.0,right: 8.0),
            decoration: BoxDecoration(
                color: Theme.of(context).dialogBackgroundColor,
                borderRadius: BorderRadius.circular(30.0)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20.0),
                title,
                content,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: actions,
                )
              ],
            ),
          ),
          Positioned(
            top: -15.0,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              radius: 33.0,
              child: icon,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}
