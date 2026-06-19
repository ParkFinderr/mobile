import 'package:flutter/material.dart';

String greetingFromHour(BuildContext context) {
  final hour = DateTime.now().hour;
  if (hour < 10) {
    return 'Selamat Pagi';
  } else if (hour < 15) {
    return 'Selamat Siang';
  } else if (hour < 18) {
    return 'Selamat Sore';
  } else {
    return 'Selamat Malam';
  }
}
