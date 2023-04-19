@JS()
library browser;

import 'package:js/js.dart';

// Calls invoke JavaScript `JSON.stringify(obj)`.
@JS('alert')
external void alert(String message);
