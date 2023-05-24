import 'package:flutter/widgets.dart';

ColorFilter filterFor(Color color) => ColorFilter.mode(
      color,
      BlendMode.srcIn,
    );
