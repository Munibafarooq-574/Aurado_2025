import 'package:flutter/material.dart';

/// Converts a hex string like "#B1E5CC" or "B1E5CC" to a Flutter Color.
Color fromHex(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff'); // full opacity
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
