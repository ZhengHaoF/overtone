import 'package:flutter/material.dart';

/// Root navigator key for [MaterialApp.router].
///
/// Widget-free layers (e.g. the desktop close prompt in `DesktopShell`) need to
/// show a Flutter dialog above whatever route is on screen. They reach the root
/// navigator through `overtoneNavigatorKey.currentContext` instead of plumbing a
/// `BuildContext` all the way down from the widget tree.
final GlobalKey<NavigatorState> overtoneNavigatorKey =
    GlobalKey<NavigatorState>();

/// App-level messenger so playback prompts can surface from every route,
/// including full-screen pages pushed above the shell (e.g. `/player`).
final GlobalKey<ScaffoldMessengerState> overtoneScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
