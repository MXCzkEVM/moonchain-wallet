// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show kMinFlingVelocity;
import 'package:flutter/scheduler.dart';

import 'package:flutter/cupertino.dart';
import 'package:mxc_ui/mxc_ui.dart';

// The scale of the child at the time that the CupertinoContextMenuExtended opens.
// This value was eyeballed from a physical device running iOS 13.1.2.
const double _kOpenScale = 1.15;

// The ratio for the borderRadius of the context menu preview image. This value
// was eyeballed by overlapping the CupertinoContextMenuExtended with a context menu
// from iOS 16.0 in the XCode iPhone simulator.
const double _previewBorderRadiusRatio = 12.0;

// The duration of the transition used when a modal popup is shown. Eyeballed
// from a physical device running iOS 13.1.2.
const Duration _kModalPopupTransitionDuration = Duration(milliseconds: 335);

// The duration it takes for the CupertinoContextMenuExtended to open.
// This value was eyeballed from the XCode simulator running iOS 16.0.
const Duration _previewLongPressTimeout = Duration(milliseconds: 800);

// The total length of the combined animations until the menu is fully open.
final int _animationDuration = _previewLongPressTimeout.inMilliseconds +
    _kModalPopupTransitionDuration.inMilliseconds;

// The final box shadow for the opening child widget.
// This value was eyeballed from the XCode simulator running iOS 16.0.
const List<BoxShadow> _endBoxShadow = <BoxShadow>[
  BoxShadow(
    color: Color(0x40000000),
    blurRadius: 10.0,
    spreadRadius: 0.5,
  ),
];

const Color _borderColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFA9A9AF),
  darkColor: Color(0xFF57585A),
);

typedef _DismissCallback = void Function(
  BuildContext context,
  double scale,
  double opacity,
);

/// A function that produces the preview when the CupertinoContextMenuExtended is open.
///
/// Called every time the animation value changes.
typedef ContextMenuPreviewBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

/// A function that builds the child and handles the transition between the
/// default child and the preview when the CupertinoContextMenuExtended is open.
typedef CupertinoContextMenuBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
);

// Given a GlobalKey, return the Rect of the corresponding RenderBox's
// paintBounds in global coordinates.
Rect _getRect(GlobalKey globalKey) {
  assert(globalKey.currentContext != null);
  final RenderBox renderBoxContainer =
      globalKey.currentContext!.findRenderObject()! as RenderBox;
  return Rect.fromPoints(
      renderBoxContainer.localToGlobal(
        renderBoxContainer.paintBounds.topLeft,
      ),
      renderBoxContainer
          .localToGlobal(renderBoxContainer.paintBounds.bottomRight));
}

// The context menu arranges itself slightly differently based on the location
// on the screen of [CupertinoContextMenuExtended.child] before the
// [CupertinoContextMenuExtended] opens.
enum _ContextMenuLocation {
  center,
  left,
  right,
}

/// A full-screen modal route that opens when the [child] is long-pressed.
///
/// When open, the [CupertinoContextMenuExtended] shows the child, or the widget returned
/// by [previewBuilder] if given, in a large full-screen [Overlay] with a list
/// of buttons specified by [actions]. The child/preview is placed in an
/// [Expanded] widget so that it will grow to fill the Overlay if its size is
/// unconstrained.
///
/// When closed, the CupertinoContextMenuExtended simply displays the child as if the
/// CupertinoContextMenuExtended were not there. Sizing and positioning is unaffected.
/// The menu can be closed like other [PopupRoute]s, such as by tapping the
/// background or by calling `Navigator.pop(context)`. Unlike PopupRoute, it can
/// also be closed by swiping downwards.
///
/// The [previewBuilder] parameter is most commonly used to display a slight
/// variation of [child]. See [previewBuilder] for an example of rounding the
/// child's corners and allowing its aspect ratio to expand, similar to the
/// Photos app on iOS.
///
/// {@tool dartpad}
/// This sample shows a very simple CupertinoContextMenuExtended for the Flutter logo.
/// Simply long press on it to open.
///
/// ** See code in examples/api/lib/cupertino/context_menu/cupertino_context_menu.0.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// This sample shows a similar CupertinoContextMenuExtended, this time using [builder]
/// to add a border radius to the widget.
///
/// ** See code in examples/api/lib/cupertino/context_menu/cupertino_context_menu.1.dart **
/// {@end-tool}
///
/// See also:
///
///  * <https://developer.apple.com/design/human-interface-guidelines/ios/controls/context-menus/>
class CupertinoContextMenuExtended extends StatefulWidget {
  /// Create a context menu.
  ///
  /// [actions] is required and cannot be null or empty.
  ///
  /// [child] is required and cannot be null.
  CupertinoContextMenuExtended({
    super.key,
    required this.actions,
    required Widget this.child,
    @Deprecated(
      'Use CupertinoContextMenuExtended.builder instead. '
      'This feature was deprecated after v3.4.0-34.1.pre.',
    )
        this.previewBuilder = _defaultPreviewBuilder,
  })  : assert(actions != null && actions.isNotEmpty),
        assert(child != null),
        builder =
            ((BuildContext context, Animation<double> animation) => child);

  /// Creates a context menu with a custom [builder] controlling the widget.
  ///
  /// Use instead of the default constructor when it is needed to have a more
  /// custom animation.
  ///
  /// [actions] is required and cannot be null or empty.
  ///
  /// [builder] is required.
  CupertinoContextMenuExtended.builder({
    super.key,
    required this.actions,
    required this.builder,
  })  : assert(actions != null && actions.isNotEmpty),
        child = null,
        previewBuilder = null;

  /// Exposes the default border radius for matching iOS 16.0 behavior. This
  /// value was eyeballed from the iOS simulator running iOS 16.0.
  ///
  /// {@tool snippet}
  ///
  /// Below is example code in order to match the default border radius for an
  /// iOS 16.0 open preview.
  ///
  /// ```dart
  /// CupertinoContextMenuExtended.builder(
  ///   actions: <Widget>[
  ///     CupertinoContextMenuAction(
  ///       child: const Text('Action one'),
  ///       onPressed: () {},
  ///     ),
  ///   ],
  ///   builder:(BuildContext context, Animation<double> animation) {
  ///     final Animation<BorderRadius?> borderRadiusAnimation = BorderRadiusTween(
  ///       begin: BorderRadius.circular(0.0),
  ///       end: BorderRadius.circular(CupertinoContextMenuExtended.kOpenBorderRadius),
  ///     ).animate(
  ///       CurvedAnimation(
  ///         parent: animation,
  ///         curve: Interval(
  ///           CupertinoContextMenuExtended.animationOpensAt,
  ///           1.0,
  ///         ),
  ///       ),
  ///     );
  ///
  ///     final Animation<Decoration> boxDecorationAnimation = DecorationTween(
  ///       begin: const BoxDecoration(
  ///        color: Color(0xFFFFFFFF),
  ///        boxShadow: <BoxShadow>[],
  ///       ),
  ///       end: const BoxDecoration(
  ///        color: Color(0xFFFFFFFF),
  ///        boxShadow: CupertinoContextMenuExtended.kEndBoxShadow,
  ///       ),
  ///      ).animate(
  ///        CurvedAnimation(
  ///         parent: animation,
  ///         curve: Interval(
  ///           0.0,
  ///           CupertinoContextMenuExtended.animationOpensAt,
  ///         ),
  ///       )
  ///     );
  ///
  ///     return Container(
  ///       decoration:
  ///         animation.value < CupertinoContextMenuExtended.animationOpensAt ? boxDecorationAnimation.value : null,
  ///       child: FittedBox(
  ///         fit: BoxFit.cover,
  ///         child: ClipRRect(
  ///           borderRadius: borderRadiusAnimation.value ?? BorderRadius.circular(0.0),
  ///           child: SizedBox(
  ///             height: 150,
  ///             width: 150,
  ///             child: Image.network('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
  ///           ),
  ///         ),
  ///       )
  ///     );
  ///   },
  /// )
  /// ```
  ///
  /// {@end-tool}
  static const double kOpenBorderRadius = _previewBorderRadiusRatio;

  /// Exposes the final box shadow of the opening animation of the child widget
  /// to match the default behavior of the native iOS widget. This value was
  /// eyeballed from the iOS simulator running iOS 16.0.
  static const List<BoxShadow> kEndBoxShadow = _endBoxShadow;

  /// The point at which the CupertinoContextMenuExtended begins to animate
  /// into the open position.
  ///
  /// A value between 0.0 and 1.0 corresponding to a point in [builder]'s
  /// animation. When passing in an animation to [builder] the range before
  /// [animationOpensAt] will correspond to the animation when the widget is
  /// pressed and held, and the range after is the animation as the menu is
  /// fully opening. For an example, see the documentation for [builder].
  static final double animationOpensAt =
      _previewLongPressTimeout.inMilliseconds / _animationDuration;

  /// A function that returns a widget to be used alternatively from [child].
  ///
  /// The widget returned by the function will be shown at all times: when the
  /// [CupertinoContextMenuExtended] is closed, when it is in the middle of opening,
  /// and when it is fully open. This will overwrite the default animation that
  /// matches the behavior of an iOS 16.0 context menu.
  ///
  /// This builder can be used instead of the child when either the intended
  /// child has a property that would conflict with the default animation, like
  /// a border radius or a shadow, or if simply a more custom animation is
  /// needed.
  ///
  /// In addition to the current [BuildContext], the function is also called
  /// with an [Animation]. The complete animation goes from 0 to 1 when
  /// the CupertinoContextMenuExtended opens, and from 1 to 0 when it closes, and it can
  /// be used to animate the widget in sync with this opening and closing.
  ///
  /// The animation works in two stages. The first happens on press and hold of
  /// the widget from 0 to [animationOpensAt], and the second stage for when the
  /// widget fully opens up to the menu, from [animationOpensAt] to 1.
  ///
  /// {@tool snippet}
  ///
  /// Below is an example of using [builder] to show an image tile setup to be
  /// opened in the default way to match a native iOS 16.0 app. The behavior
  /// will match what will happen if the simple child image was passed as just
  /// the [child] parameter, instead of [builder]. This can be manipulated to
  /// add more custamizability to the widget's animation.
  ///
  /// ```dart
  /// CupertinoContextMenuExtended.builder(
  ///   actions: <Widget>[
  ///     CupertinoContextMenuAction(
  ///       child: const Text('Action one'),
  ///       onPressed: () {},
  ///     ),
  ///   ],
  ///   builder:(BuildContext context, Animation<double> animation) {
  ///     final Animation<BorderRadius?> borderRadiusAnimation = BorderRadiusTween(
  ///       begin: BorderRadius.circular(0.0),
  ///       end: BorderRadius.circular(CupertinoContextMenuExtended.kOpenBorderRadius),
  ///     ).animate(
  ///       CurvedAnimation(
  ///         parent: animation,
  ///         curve: Interval(
  ///           CupertinoContextMenuExtended.animationOpensAt,
  ///           1.0,
  ///         ),
  ///       ),
  ///      );
  ///
  ///     final Animation<Decoration> boxDecorationAnimation = DecorationTween(
  ///       begin: const BoxDecoration(
  ///        color: Color(0xFFFFFFFF),
  ///        boxShadow: <BoxShadow>[],
  ///       ),
  ///       end: const BoxDecoration(
  ///        color: Color(0xFFFFFFFF),
  ///        boxShadow: CupertinoContextMenuExtended.kEndBoxShadow,
  ///       ),
  ///      ).animate(
  ///        CurvedAnimation(
  ///         parent: animation,
  ///         curve: Interval(
  ///           0.0,
  ///           CupertinoContextMenuExtended.animationOpensAt,
  ///         ),
  ///       ),
  ///     );
  ///
  ///     return Container(
  ///       decoration:
  ///         animation.value < CupertinoContextMenuExtended.animationOpensAt ? boxDecorationAnimation.value : null,
  ///       child: FittedBox(
  ///         fit: BoxFit.cover,
  ///         child: ClipRRect(
  ///           borderRadius: borderRadiusAnimation.value ?? BorderRadius.circular(0.0),
  ///           child: SizedBox(
  ///             height: 150,
  ///             width: 150,
  ///             child: Image.network('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
  ///           ),
  ///         ),
  ///       ),
  ///     );
  ///   },
  /// )
  /// ```
  ///
  /// {@end-tool}
  ///
  /// {@tool dartpad}
  /// Additionally below is an example of a real world use case for [builder].
  ///
  /// If a widget is passed to the [child] parameter with properties that
  /// conflict with the default animation, in this case the border radius,
  /// unwanted behaviors can arise. Here a boxed shadow will wrap the widget as
  /// it is expanded. To handle this, a more custom animation and widget can be
  /// passed to the builder, using values exposed by [CupertinoContextMenuExtended],
  /// like [CupertinoContextMenuExtended.kEndBoxShadow], to match the native iOS
  /// animation as close as desired.
  ///
  /// ** See code in examples/api/lib/cupertino/context_menu/cupertino_context_menu.1.dart **
  /// {@end-tool}
  final CupertinoContextMenuBuilder builder;

  /// The default preview builder if none is provided. It makes a rectangle
  /// around the child widget with rounded borders, matching the iOS 16 opened
  /// context menu eyeballed on the XCode iOS simulator.
  static Widget _defaultPreviewBuilder(
      BuildContext context, Animation<double> animation, Widget child) {
    return FittedBox(
      fit: BoxFit.cover,
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(_previewBorderRadiusRatio * animation.value),
        child: child,
      ),
    );
  }

  // TODO(mitchgoodwin): deprecate [child] with builder refactor https://github.com/flutter/flutter/issues/116306

  /// The widget that can be "opened" with the [CupertinoContextMenuExtended].
  ///
  /// When the [CupertinoContextMenuExtended] is long-pressed, the menu will open and
  /// this widget (or the widget returned by [previewBuilder], if provided) will
  /// be moved to the new route and placed inside of an [Expanded] widget. This
  /// allows the child to resize to fit in its place in the new route, if it
  /// doesn't size itself.
  ///
  /// When the [CupertinoContextMenuExtended] is "closed", this widget acts like a
  /// [Container], i.e. it does not constrain its child's size or affect its
  /// position.
  final Widget? child;

  /// The actions that are shown in the menu.
  ///
  /// These actions are typically [CupertinoContextMenuAction]s.
  ///
  /// This parameter cannot be null or empty.
  final List<Widget> actions;

  /// A function that returns an alternative widget to show when the
  /// [CupertinoContextMenuExtended] is open.
  ///
  /// If not specified, [child] will be shown.
  ///
  /// The preview is often used to show a slight variation of the [child]. For
  /// example, the child could be given rounded corners in the preview but have
  /// sharp corners when in the page.
  ///
  /// In addition to the current [BuildContext], the function is also called
  /// with an [Animation] and the [child]. The animation goes from 0 to 1 when
  /// the CupertinoContextMenuExtended opens, and from 1 to 0 when it closes, and it can
  /// be used to animate the preview in sync with this opening and closing. The
  /// child parameter provides access to the child displayed when the
  /// CupertinoContextMenuExtended is closed.
  ///
  /// {@tool snippet}
  ///
  /// Below is an example of using [previewBuilder] to show an image tile that's
  /// similar to each tile in the iOS iPhoto app's context menu. Several of
  /// these could be used in a GridView for a similar effect.
  ///
  /// When opened, the child animates to show its full aspect ratio and has
  /// rounded corners. The larger size of the open CupertinoContextMenuExtended allows
  /// the FittedBox to fit the entire image, even when it has a very tall or
  /// wide aspect ratio compared to the square of a GridView, so this animates
  /// into view as the CupertinoContextMenuExtended is opened. The preview is swapped in
  /// right when the open animation begins, which includes the rounded corners.
  ///
  /// ```dart
  /// CupertinoContextMenuExtended(
  ///   // The FittedBox in the preview here allows the image to animate its
  ///   // aspect ratio when the CupertinoContextMenuExtended is animating its preview
  ///   // widget open and closed.
  ///   // ignore: deprecated_member_use
  ///   previewBuilder: (BuildContext context, Animation<double> animation, Widget child) {
  ///     return FittedBox(
  ///       fit: BoxFit.cover,
  ///       // This ClipRRect rounds the corners of the image when the
  ///       // CupertinoContextMenuExtended is open, even though it's not rounded when
  ///       // it's closed. It uses the given animation to animate the corners
  ///       // in sync with the opening animation.
  ///       child: ClipRRect(
  ///         borderRadius: BorderRadius.circular(64.0 * animation.value),
  ///         child: Image.asset('assets/photo.jpg'),
  ///       ),
  ///     );
  ///   },
  ///   actions: <Widget>[
  ///     CupertinoContextMenuAction(
  ///       child: const Text('Action one'),
  ///       onPressed: () {},
  ///     ),
  ///   ],
  ///   child: FittedBox(
  ///     fit: BoxFit.cover,
  ///     child: Image.asset('assets/photo.jpg'),
  ///   ),
  /// )
  /// ```
  ///
  /// {@end-tool}
  @Deprecated(
    'Use CupertinoContextMenuExtended.builder instead. '
    'This feature was deprecated after v3.4.0-34.1.pre.',
  )
  final ContextMenuPreviewBuilder? previewBuilder;


  @override
  State<CupertinoContextMenuExtended> createState() =>
      _CupertinoContextMenuState();
}

class _CupertinoContextMenuState extends State<CupertinoContextMenuExtended>
    with TickerProviderStateMixin {
  final GlobalKey _childGlobalKey = GlobalKey();
  bool _childHidden = false;
  // Animates the child while it's opening.
  late AnimationController _openController;
  Rect? _decoyChildEndRect;
  OverlayEntry? _lastOverlayEntry;
  _ContextMenuRoute<void>? _route;
  final double _midpoint = CupertinoContextMenuExtended.animationOpensAt / 2;

  @override
  void initState() {
    super.initState();
    _openController = AnimationController(
      duration: _previewLongPressTimeout,
      vsync: this,
      upperBound: CupertinoContextMenuExtended.animationOpensAt,
    );
    _openController.addStatusListener(_onDecoyAnimationStatusChange);
  }

  // Determine the _ContextMenuLocation based on the location of the original
  // child in the screen.
  //
  // The location of the original child is used to determine how to horizontally
  // align the content of the open CupertinoContextMenuExtended. For example, if the
  // child is near the center of the screen, it will also appear in the center
  // of the screen when the menu is open, and the actions will be centered below
  // it.
  _ContextMenuLocation get _contextMenuLocation {
    final Rect childRect = _getRect(_childGlobalKey);
    final double screenWidth = MediaQuery.of(context).size.width;

    final double center = screenWidth / 2;
    final bool centerDividesChild =
        childRect.left < center && childRect.right > center;
    final double distanceFromCenter = (center - childRect.center.dx).abs();
    if (centerDividesChild && distanceFromCenter <= childRect.width / 4) {
      return _ContextMenuLocation.center;
    }

    if (childRect.center.dx > center) {
      return _ContextMenuLocation.right;
    }

    return _ContextMenuLocation.left;
  }

  // Push the new route and open the CupertinoContextMenuExtended overlay.
  void _openContextMenu() {
    setState(() {
      _childHidden = true;
    });

    _route = _ContextMenuRoute<void>(
      actions: widget.actions,
      barrierLabel: 'Dismiss',
      filter: ui.ImageFilter.blur(
        sigmaX: 5.0,
        sigmaY: 5.0,
      ),
      contextMenuLocation: _contextMenuLocation,
      previousChildRect: _decoyChildEndRect!,
      builder: (BuildContext context, Animation<double> animation) {
        if (widget.child == null) {
          final Animation<double> localAnimation = Tween<double>(
                  begin: CupertinoContextMenuExtended.animationOpensAt, end: 1)
              .animate(animation);
          return widget.builder(context, localAnimation);
        }
        return widget.previewBuilder!(context, animation, widget.child!);
      },
    );
    Navigator.of(context, rootNavigator: true).push<void>(_route!);
    _route!.animation!.addStatusListener(_routeAnimationStatusListener);
  }

  void _onDecoyAnimationStatusChange(AnimationStatus animationStatus) {
    switch (animationStatus) {
      case AnimationStatus.dismissed:
        if (_route == null) {
          setState(() {
            _childHidden = false;
          });
        }
        _lastOverlayEntry?.remove();
        _lastOverlayEntry = null;
        break;

      case AnimationStatus.completed:
        setState(() {
          _childHidden = true;
        });
        _openContextMenu();
        // Keep the decoy on the screen for one extra frame. We have to do this
        // because _ContextMenuRoute renders its first frame offscreen.
        // Otherwise there would be a visible flash when nothing is rendered for
        // one frame.
        SchedulerBinding.instance.addPostFrameCallback((Duration _) {
          _lastOverlayEntry?.remove();
          _lastOverlayEntry = null;
          _openController.reset();
        });
        break;

      case AnimationStatus.forward:
      case AnimationStatus.reverse:
        return;
    }
  }

  // Watch for when _ContextMenuRoute is closed and return to the state where
  // the CupertinoContextMenuExtended just behaves as a Container.
  void _routeAnimationStatusListener(AnimationStatus status) {
    if (status != AnimationStatus.dismissed) {
      return;
    }
    setState(() {
      _childHidden = false;
    });
    _route!.animation!.removeStatusListener(_routeAnimationStatusListener);
    _route = null;
  }

  void _onTap() {
    if (_openController.isAnimating && _openController.value < _midpoint) {
      _openController.reverse();
    }
  }

  void _onTapCancel() {
    if (_openController.isAnimating && _openController.value < _midpoint) {
      _openController.reverse();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_openController.isAnimating && _openController.value < _midpoint) {
      _openController.reverse();
    }
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _childHidden = true;
    });

    final Rect childRect = _getRect(_childGlobalKey);
    _decoyChildEndRect = Rect.fromCenter(
      center: childRect.center,
      width: childRect.width * _kOpenScale,
      height: childRect.height * _kOpenScale,
    );

    // Create a decoy child in an overlay directly on top of the original child.
    // TODO(justinmc): There is a known inconsistency with native here, due to
    // doing the bounce animation using a decoy in the top level Overlay. The
    // decoy will pop on top of the AppBar if the child is partially behind it,
    // such as a top item in a partially scrolled view. However, if we don't use
    // an overlay, then the decoy will appear behind its neighboring widget when
    // it expands. This may be solvable by adding a widget to Scaffold that's
    // underneath the AppBar.
    _lastOverlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return _DecoyChild(
          beginRect: childRect,
          controller: _openController,
          endRect: _decoyChildEndRect,
          builder: widget.builder,
          child: widget.child,
        );
      },
    );
    Overlay.of(context, rootOverlay: true, debugRequiredFor: widget)
        .insert(_lastOverlayEntry!);
    _openController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTapCancel: _onTapCancel,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTap: _onTap,
        child: TickerMode(
          enabled: !_childHidden,
          child: Visibility.maintain(
            key: _childGlobalKey,
            visible: !_childHidden,
            child: widget.builder(context, _openController),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _openController.dispose();
    super.dispose();
  }
}

// A floating copy of the CupertinoContextMenuExtended's child.
//
// When the child is pressed, but before the CupertinoContextMenuExtended opens, it does
// an animation where it slowly grows. This is implemented by hiding the
// original child and placing _DecoyChild on top of it in an Overlay. The use of
// an Overlay allows the _DecoyChild to appear on top of siblings of the
// original child.
class _DecoyChild extends StatefulWidget {
  const _DecoyChild({
    this.beginRect,
    required this.controller,
    this.endRect,
    this.child,
    this.builder,
  });

  final Rect? beginRect;
  final AnimationController controller;
  final Rect? endRect;
  final Widget? child;
  final CupertinoContextMenuBuilder? builder;

  @override
  _DecoyChildState createState() => _DecoyChildState();
}

class _DecoyChildState extends State<_DecoyChild>
    with TickerProviderStateMixin {
  late Animation<Rect?> _rect;
  late Animation<Decoration> _boxDecoration;

  @override
  void initState() {
    super.initState();

    const double beginPause = 1.0;
    const double openAnimationLength = 5.0;
    const double totalOpenAnimationLength = beginPause + openAnimationLength;
    final double endPause = ((totalOpenAnimationLength * _animationDuration) /
            _previewLongPressTimeout.inMilliseconds) -
        totalOpenAnimationLength;

    // The timing on the animation was eyeballed from the XCode iOS simulator
    // running iOS 16.0.
    // Because the animation no longer goes from 0.0 to 1.0, but to a number
    // depending on the ratio between the press animation time and the opening
    // animation time, a pause needs to be added to the end of the tween
    // sequence that completes that ratio. This is to allow the animation to
    // fully complete as expected without doing crazy math to the _kOpenScale
    // value. This change was necessary from the inclusion of the builder and
    // the complete animation value that it passes along.
    _rect = TweenSequence<Rect?>(<TweenSequenceItem<Rect?>>[
      TweenSequenceItem<Rect?>(
        tween: RectTween(
          begin: widget.beginRect,
          end: widget.beginRect,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: beginPause,
      ),
      TweenSequenceItem<Rect?>(
        tween: RectTween(
          begin: widget.beginRect,
          end: widget.endRect,
        ).chain(CurveTween(curve: Curves.easeOutSine)),
        weight: openAnimationLength,
      ),
      TweenSequenceItem<Rect?>(
        tween: RectTween(
          begin: widget.endRect,
          end: widget.endRect,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: endPause,
      ),
    ]).animate(widget.controller);

    _boxDecoration = DecorationTween(
      begin: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        boxShadow: <BoxShadow>[],
      ),
      end: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        boxShadow: _endBoxShadow,
      ),
    ).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Interval(0.0, CupertinoContextMenuExtended.animationOpensAt),
      ),
    );
  }

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return Positioned.fromRect(
      rect: _rect.value!,
      child: Container(
        decoration: _boxDecoration.value,
        child: widget.child,
      ),
    );
  }

  Widget _buildBuilder(BuildContext context, Widget? child) {
    return Positioned.fromRect(
      rect: _rect.value!,
      child: widget.builder!(context, widget.controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedBuilder(
          builder: widget.child != null ? _buildAnimation : _buildBuilder,
          animation: widget.controller,
        ),
      ],
    );
  }
}

// The open CupertinoContextMenuExtended modal.
class _ContextMenuRoute<T> extends PopupRoute<T> {
  // Build a _ContextMenuRoute.
  _ContextMenuRoute({
    required List<Widget> actions,
    required _ContextMenuLocation contextMenuLocation,
    this.barrierLabel,
    CupertinoContextMenuBuilder? builder,
    super.filter,
    required Rect previousChildRect,
    super.settings,
  })  : assert(actions != null && actions.isNotEmpty),
        assert(contextMenuLocation != null),
        _actions = actions,
        _builder = builder,
        _contextMenuLocation = contextMenuLocation,
        _previousChildRect = previousChildRect;

  // Barrier color for a Cupertino modal barrier.
  static const Color _kModalBarrierColor = Color(0x6604040F);

  final List<Widget> _actions;
  final CupertinoContextMenuBuilder? _builder;
  final GlobalKey _childGlobalKey = GlobalKey();
  final _ContextMenuLocation _contextMenuLocation;
  bool _externalOffstage = false;
  bool _internalOffstage = false;
  Orientation? _lastOrientation;
  // The Rect of the child at the moment that the CupertinoContextMenuExtended opens.
  final Rect _previousChildRect;
  double? _scale = 1.0;
  final GlobalKey _sheetGlobalKey = GlobalKey();

  static final CurveTween _curve = CurveTween(
    curve: Curves.easeOutBack,
  );
  static final CurveTween _curveReverse = CurveTween(
    curve: Curves.easeInBack,
  );
  static final RectTween _rectTween = RectTween();
  static final Animatable<Rect?> _rectAnimatable = _rectTween.chain(_curve);
  static final RectTween _rectTweenReverse = RectTween();
  static final Animatable<Rect?> _rectAnimatableReverse =
      _rectTweenReverse.chain(
    _curveReverse,
  );
  static final RectTween _sheetRectTween = RectTween();
  final Animatable<Rect?> _sheetRectAnimatable = _sheetRectTween.chain(
    _curve,
  );
  final Animatable<Rect?> _sheetRectAnimatableReverse = _sheetRectTween.chain(
    _curveReverse,
  );
  static final Tween<double> _sheetScaleTween = Tween<double>();
  static final Animatable<double> _sheetScaleAnimatable =
      _sheetScaleTween.chain(
    _curve,
  );
  static final Animatable<double> _sheetScaleAnimatableReverse =
      _sheetScaleTween.chain(
    _curveReverse,
  );
  final Tween<double> _opacityTween = Tween<double>(begin: 0.0, end: 1.0);
  late Animation<double> _sheetOpacity;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => _kModalBarrierColor;

  @override
  bool get barrierDismissible => true;

  @override
  bool get semanticsDismissible => false;

  @override
  Duration get transitionDuration => _kModalPopupTransitionDuration;

  // Getting the RenderBox doesn't include the scale from the Transform.scale,
  // so it's manually accounted for here.
  static Rect _getScaledRect(GlobalKey globalKey, double scale) {
    final Rect childRect = _getRect(globalKey);
    final Size sizeScaled = childRect.size * scale;
    final Offset offsetScaled = Offset(
      childRect.left + (childRect.size.width - sizeScaled.width) / 2,
      childRect.top + (childRect.size.height - sizeScaled.height) / 2,
    );
    return offsetScaled & sizeScaled;
  }

  // Get the alignment for the _ContextMenuSheet's Transform.scale based on the
  // contextMenuLocation.
  static AlignmentDirectional getSheetAlignment(
      _ContextMenuLocation contextMenuLocation) {
    switch (contextMenuLocation) {
      case _ContextMenuLocation.center:
        return AlignmentDirectional.topCenter;
      case _ContextMenuLocation.right:
        return AlignmentDirectional.topEnd;
      case _ContextMenuLocation.left:
        return AlignmentDirectional.topStart;
    }
  }

  // The place to start the sheetRect animation from.
  static Rect _getSheetRectBegin(
      Orientation? orientation,
      _ContextMenuLocation contextMenuLocation,
      Rect childRect,
      Rect sheetRect) {
    switch (contextMenuLocation) {
      case _ContextMenuLocation.center:
        final Offset target = orientation == Orientation.portrait
            ? childRect.bottomCenter
            : childRect.topCenter;
        final Offset centered = target - Offset(sheetRect.width / 2, 0.0);
        return centered & sheetRect.size;
      case _ContextMenuLocation.right:
        final Offset target = orientation == Orientation.portrait
            ? childRect.bottomRight
            : childRect.topRight;
        return (target - Offset(sheetRect.width, 0.0)) & sheetRect.size;
      case _ContextMenuLocation.left:
        final Offset target = orientation == Orientation.portrait
            ? childRect.bottomLeft
            : childRect.topLeft;
        return target & sheetRect.size;
    }
  }

  void _onDismiss(BuildContext context, double scale, double opacity) {
    _scale = scale;
    _opacityTween.end = opacity;
    _sheetOpacity = _opacityTween.animate(CurvedAnimation(
      parent: animation!,
      curve: const Interval(0.9, 1.0),
    ));
    Navigator.of(context).pop();
  }

  // Take measurements on the child and _ContextMenuSheet and update the
  // animation tweens to match.
  void _updateTweenRects() {
    final Rect childRect = _scale == null
        ? _getRect(_childGlobalKey)
        : _getScaledRect(_childGlobalKey, _scale!);
    _rectTween.begin = _previousChildRect;
    _rectTween.end = childRect;

    // When opening, the transition happens from the end of the child's bounce
    // animation to the final state. When closing, it goes from the final state
    // to the original position before the bounce.
    final Rect childRectOriginal = Rect.fromCenter(
      center: _previousChildRect.center,
      width: _previousChildRect.width / _kOpenScale,
      height: _previousChildRect.height / _kOpenScale,
    );

    final Rect sheetRect = _getRect(_sheetGlobalKey);
    final Rect sheetRectBegin = _getSheetRectBegin(
      _lastOrientation,
      _contextMenuLocation,
      childRectOriginal,
      sheetRect,
    );
    _sheetRectTween.begin = sheetRectBegin;
    _sheetRectTween.end = sheetRect;
    _sheetScaleTween.begin = 0.0;
    _sheetScaleTween.end = _scale;

    _rectTweenReverse.begin = childRectOriginal;
    _rectTweenReverse.end = childRect;
  }

  void _setOffstageInternally() {
    super.offstage = _externalOffstage || _internalOffstage;
    // It's necessary to call changedInternalState to get the backdrop to
    // update.
    changedInternalState();
  }

  @override
  bool didPop(T? result) {
    _updateTweenRects();
    return super.didPop(result);
  }

  @override
  set offstage(bool value) {
    _externalOffstage = value;
    _setOffstageInternally();
  }

  @override
  TickerFuture didPush() {
    _internalOffstage = true;
    _setOffstageInternally();

    // Render one frame offstage in the final position so that we can take
    // measurements of its layout and then animate to them.
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      _updateTweenRects();
      _internalOffstage = false;
      _setOffstageInternally();
    });
    return super.didPush();
  }

  @override
  Animation<double> createAnimation() {
    final Animation<double> animation = super.createAnimation();
    _sheetOpacity = _opacityTween.animate(CurvedAnimation(
      parent: animation,
      curve: Curves.linear,
    ));
    return animation;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    // This is usually used to build the "page", which is then passed to
    // buildTransitions as child, the idea being that buildTransitions will
    // animate the entire page into the scene. In the case of _ContextMenuRoute,
    // two individual pieces of the page are animated into the scene in
    // buildTransitions, and a SizedBox.shrink() is returned here.
    return const SizedBox.shrink();
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        _lastOrientation = orientation;

        // While the animation is running, render everything in a Stack so that
        // they're movable.
        if (!animation.isCompleted) {
          final bool reverse = animation.status == AnimationStatus.reverse;
          final Rect rect = reverse
              ? _rectAnimatableReverse.evaluate(animation)!
              : _rectAnimatable.evaluate(animation)!;
          final Rect sheetRect = reverse
              ? _sheetRectAnimatableReverse.evaluate(animation)!
              : _sheetRectAnimatable.evaluate(animation)!;
          final double sheetScale = reverse
              ? _sheetScaleAnimatableReverse.evaluate(animation)
              : _sheetScaleAnimatable.evaluate(animation);
          return Stack(
            children: <Widget>[
              Positioned.fromRect(
                rect: sheetRect,
                child: FadeTransition(
                  opacity: _sheetOpacity,
                  child: Transform.scale(
                    alignment: getSheetAlignment(_contextMenuLocation),
                    scale: sheetScale,
                    child: _ContextMenuSheet(
                      key: _sheetGlobalKey,
                      actions: _actions,
                      contextMenuLocation: _contextMenuLocation,
                      orientation: orientation,
                    ),
                  ),
                ),
              ),
              Positioned.fromRect(
                key: _childGlobalKey,
                rect: rect,
                child: _builder!(context, animation),
              ),
            ],
          );
        }

        // When the animation is done, just render everything in a static layout
        // in the final position.
        return _ContextMenuRouteStatic(
          actions: _actions,
          childGlobalKey: _childGlobalKey,
          contextMenuLocation: _contextMenuLocation,
          onDismiss: _onDismiss,
          orientation: orientation,
          sheetGlobalKey: _sheetGlobalKey,
          child: _builder!(context, animation),
        );
      },
    );
  }
}

// The final state of the _ContextMenuRoute after animating in and before
// animating out.
class _ContextMenuRouteStatic extends StatefulWidget {
  const _ContextMenuRouteStatic({
    this.actions,
    required this.child,
    this.childGlobalKey,
    required this.contextMenuLocation,
    this.onDismiss,
    required this.orientation,
    this.sheetGlobalKey,
  })  : assert(contextMenuLocation != null),
        assert(orientation != null);

  final List<Widget>? actions;
  final Widget child;
  final GlobalKey? childGlobalKey;
  final _ContextMenuLocation contextMenuLocation;
  final _DismissCallback? onDismiss;
  final Orientation orientation;
  final GlobalKey? sheetGlobalKey;

  @override
  _ContextMenuRouteStaticState createState() => _ContextMenuRouteStaticState();
}

class _ContextMenuRouteStaticState extends State<_ContextMenuRouteStatic>
    with TickerProviderStateMixin {
  // The child is scaled down as it is dragged down until it hits this minimum
  // value.
  static const double _kMinScale = 0.8;
  // The CupertinoContextMenuSheet disappears at this scale.
  static const double _kSheetScaleThreshold = 0.9;
  static const double _kPadding = 20.0;
  static const double _kDamping = 400.0;
  static const Duration _kMoveControllerDuration = Duration(milliseconds: 600);

  late Offset _dragOffset;
  double _lastScale = 1.0;
  late AnimationController _moveController;
  late AnimationController _sheetController;
  late Animation<Offset> _moveAnimation;
  late Animation<double> _sheetScaleAnimation;
  late Animation<double> _sheetOpacityAnimation;

  // The scale of the child changes as a function of the distance it is dragged.
  static double _getScale(
      Orientation orientation, double maxDragDistance, double dy) {
    final double dyDirectional = dy <= 0.0 ? dy : -dy;
    return math.max(
      _kMinScale,
      (maxDragDistance + dyDirectional) / maxDragDistance,
    );
  }

  void _onPanStart(DragStartDetails details) {
    _moveController.value = 1.0;
    _setDragOffset(Offset.zero);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _setDragOffset(_dragOffset + details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    // If flung, animate a bit before handling the potential dismiss.
    if (details.velocity.pixelsPerSecond.dy.abs() >= kMinFlingVelocity) {
      final bool flingIsAway = details.velocity.pixelsPerSecond.dy > 0;
      final double finalPosition =
          flingIsAway ? _moveAnimation.value.dy + 100.0 : 0.0;

      if (flingIsAway && _sheetController.status != AnimationStatus.forward) {
        _sheetController.forward();
      } else if (!flingIsAway &&
          _sheetController.status != AnimationStatus.reverse) {
        _sheetController.reverse();
      }

      _moveAnimation = Tween<Offset>(
        begin: Offset(0.0, _moveAnimation.value.dy),
        end: Offset(0.0, finalPosition),
      ).animate(_moveController);
      _moveController.reset();
      _moveController.duration = const Duration(
        milliseconds: 64,
      );
      _moveController.forward();
      _moveController.addStatusListener(_flingStatusListener);
      return;
    }

    // Dismiss if the drag is enough to scale down all the way.
    if (_lastScale == _kMinScale) {
      widget.onDismiss!(context, _lastScale, _sheetOpacityAnimation.value);
      return;
    }

    // Otherwise animate back home.
    _moveController.addListener(_moveListener);
    _moveController.reverse();
  }

  void _moveListener() {
    // When the scale passes the threshold, animate the sheet back in.
    if (_lastScale > _kSheetScaleThreshold) {
      _moveController.removeListener(_moveListener);
      if (_sheetController.status != AnimationStatus.dismissed) {
        _sheetController.reverse();
      }
    }
  }

  void _flingStatusListener(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }

    // Reset the duration back to its original value.
    _moveController.duration = _kMoveControllerDuration;

    _moveController.removeStatusListener(_flingStatusListener);
    // If it was a fling back to the start, it has reset itself, and it should
    // not be dismissed.
    if (_moveAnimation.value.dy == 0.0) {
      return;
    }
    widget.onDismiss!(context, _lastScale, _sheetOpacityAnimation.value);
  }

  Alignment _getChildAlignment(
      Orientation orientation, _ContextMenuLocation contextMenuLocation) {
    switch (contextMenuLocation) {
      case _ContextMenuLocation.center:
        return orientation == Orientation.portrait
            ? Alignment.bottomCenter
            : Alignment.topRight;
      case _ContextMenuLocation.right:
        return orientation == Orientation.portrait
            ? Alignment.bottomCenter
            : Alignment.topLeft;
      case _ContextMenuLocation.left:
        return orientation == Orientation.portrait
            ? Alignment.bottomCenter
            : Alignment.topRight;
    }
  }

  void _setDragOffset(Offset dragOffset) {
    // Allow horizontal and negative vertical movement, but damp it.
    final double endX = _kPadding * dragOffset.dx / _kDamping;
    final double endY = dragOffset.dy >= 0.0
        ? dragOffset.dy
        : _kPadding * dragOffset.dy / _kDamping;
    setState(() {
      _dragOffset = dragOffset;
      _moveAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(
          clampDouble(endX, -_kPadding, _kPadding),
          endY,
        ),
      ).animate(
        CurvedAnimation(
          parent: _moveController,
          curve: Curves.elasticIn,
        ),
      );

      // Fade the _ContextMenuSheet out or in, if needed.
      if (_lastScale <= _kSheetScaleThreshold &&
          _sheetController.status != AnimationStatus.forward &&
          _sheetScaleAnimation.value != 0.0) {
        _sheetController.forward();
      } else if (_lastScale > _kSheetScaleThreshold &&
          _sheetController.status != AnimationStatus.reverse &&
          _sheetScaleAnimation.value != 1.0) {
        _sheetController.reverse();
      }
    });
  }

  // The order and alignment of the _ContextMenuSheet and the child depend on
  // both the orientation of the screen as well as the position on the screen of
  // the original child.
  List<Widget> _getChildren(
    Orientation orientation,
    _ContextMenuLocation contextMenuLocation,
  ) {
    final Expanded child = Expanded(
      child: Align(
        alignment: _getChildAlignment(
          widget.orientation,
          widget.contextMenuLocation,
        ),
        child: AnimatedBuilder(
          animation: _moveController,
          builder: _buildChildAnimation,
          child: widget.child,
        ),
      ),
    );
    const SizedBox spacer = SizedBox(
      width: _kPadding,
      height: _kPadding,
    );
    final Expanded sheet = Expanded(
      child: AnimatedBuilder(
        animation: _sheetController,
        builder: _buildSheetAnimation,
        child: _ContextMenuSheet(
          key: widget.sheetGlobalKey,
          actions: widget.actions!,
          contextMenuLocation: widget.contextMenuLocation,
          orientation: widget.orientation,
        ),
      ),
    );

    switch (contextMenuLocation) {
      case _ContextMenuLocation.center:
        return <Widget>[child, spacer, sheet];
      case _ContextMenuLocation.right:
        return orientation == Orientation.portrait
            ? <Widget>[child, spacer, sheet]
            : <Widget>[sheet, spacer, child];
      case _ContextMenuLocation.left:
        return <Widget>[child, spacer, sheet];
    }
  }

  // Build the animation for the _ContextMenuSheet.
  Widget _buildSheetAnimation(BuildContext context, Widget? child) {
    return Transform.scale(
      alignment:
          _ContextMenuRoute.getSheetAlignment(widget.contextMenuLocation),
      scale: _sheetScaleAnimation.value,
      child: FadeTransition(
        opacity: _sheetOpacityAnimation,
        child: child,
      ),
    );
  }

  // Build the animation for the child.
  Widget _buildChildAnimation(BuildContext context, Widget? child) {
    _lastScale = _getScale(
      widget.orientation,
      MediaQuery.of(context).size.height,
      _moveAnimation.value.dy,
    );
    return Transform.scale(
      key: widget.childGlobalKey,
      scale: _lastScale,
      child: child,
    );
  }

  // Build the animation for the overall draggable dismissible content.
  Widget _buildAnimation(BuildContext context, Widget? child) {
    return Transform.translate(
      offset: _moveAnimation.value,
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      duration: _kMoveControllerDuration,
      value: 1.0,
      vsync: this,
    );
    _sheetController = AnimationController(
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sheetScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _sheetController,
        curve: Curves.linear,
        reverseCurve: Curves.easeInBack,
      ),
    );
    _sheetOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_sheetController);
    _setDragOffset(Offset.zero);
  }

  @override
  void dispose() {
    _moveController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = _getChildren(
      widget.orientation,
      widget.contextMenuLocation,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(_kPadding),
        child: Align(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onPanEnd: _onPanEnd,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            child: AnimatedBuilder(
              animation: _moveController,
              builder: _buildAnimation,
              child: widget.orientation == Orientation.portrait
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// The menu that displays when CupertinoContextMenuExtended is open. It consists of a
// list of actions that are typically CupertinoContextMenuActions.
class _ContextMenuSheet extends StatelessWidget {
  _ContextMenuSheet({
    super.key,
    required this.actions,
    required _ContextMenuLocation contextMenuLocation,
    required Orientation orientation,
  })  : assert(actions != null && actions.isNotEmpty),
        assert(contextMenuLocation != null),
        assert(orientation != null),
        _contextMenuLocation = contextMenuLocation,
        _orientation = orientation;

  final List<Widget> actions;
  final _ContextMenuLocation _contextMenuLocation;
  final Orientation _orientation;

  // Get the children, whose order depends on orientation and
  // contextMenuLocation.
  List<Widget> getChildren(BuildContext context) {
    final Widget menu = Flexible(
      fit: FlexFit.tight,
      flex: 2,
      child: IntrinsicHeight(
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(13.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              actions.first,
              for (Widget action in actions.skip(1))
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                      color: actions.indexOf(action) == 1
                          ? CupertinoDynamicColor.resolve(_borderColor, context)
                          : ColorsTheme.of(context).textPrimary,
                      width: 1,
                    )),
                  ),
                  position: DecorationPosition.foreground,
                  child: action,
                ),
            ],
          ),
        ),
      ),
    );

    switch (_contextMenuLocation) {
      case _ContextMenuLocation.center:
        return _orientation == Orientation.portrait
            ? <Widget>[
                const Spacer(),
                menu,
                const Spacer(),
              ]
            : <Widget>[
                menu,
                const Spacer(),
              ];
      case _ContextMenuLocation.right:
        return <Widget>[
          const Spacer(),
          menu,
        ];
      case _ContextMenuLocation.left:
        return <Widget>[
          menu,
          const Spacer(),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: getChildren(context),
    );
  }
}
