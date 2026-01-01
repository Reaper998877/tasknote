// Original path is assets/audio/oversimplified.mp3 , but The AudioPlayer library automatically prepends "assets/", so it finds: "assets/" + "audio/oversimplified.mp3"
// That's why "assets/" is not written in the path.
import 'package:flutter/material.dart';

final String defaultColor = "FF000000"; // Black

final List<String> viewOptions = ["Small Grid", "Large Grid", "List", "Title"];
final List<IconData> viewOptionsIcons = [
  Icons.grid_on,
  Icons.grid_view,
  Icons.list,
  Icons.menu,
];
final List<String> sortOptions = ["Created", "Last updated", "DecorColor", "Alphabetically"];


final RegExp titlePattern = RegExp(
  r'[a-zA-Z0-9_\-\s.,]',
); // letters, numbers, space, _-.,
