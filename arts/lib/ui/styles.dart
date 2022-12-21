import 'package:flutter/material.dart';

const Color darkOrange = Color(0xffE68532);
const Color lightOrange = Color(0xFFEB9E5C);

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

final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColorLight: Colors.blue.shade300,
    appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xff113197),
        actionsIconTheme: IconThemeData(color: Color(0xffE68532)),
        iconTheme: IconThemeData(color: Color(0xffE68532))
    ),
  backgroundColor: Colors.white,
  iconTheme: const IconThemeData(color: Color(0xffE68532)),
  colorScheme: const ColorScheme.dark().copyWith(secondary: const Color(0xff89E649)),
  cardColor: Colors.white54,
  dividerColor: Colors.white54
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
  appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff113197),
      actionsIconTheme: IconThemeData(color: Color(0xffE68532)),
      iconTheme: IconThemeData(color: Color(0xffE68532))
  ),
  backgroundColor: const Color(0xff242F72),
  iconTheme: const IconThemeData(color: Color(0xffE68532)),
  colorScheme: const ColorScheme.light().copyWith(secondary: const Color(0xff89E649)),
  cardColor: const Color(0xff414C9C),
  dividerColor:  const Color(0xff414C9C)
);