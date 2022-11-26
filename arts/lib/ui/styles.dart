import 'package:flutter/material.dart';

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