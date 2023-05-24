import 'dart:async';
import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

enum AnimationType {
  fromTop,
  fromLeft,
  fromRight,
}

class SaveToHereTip extends StatefulWidget {
  SaveToHereTip({
    Key? key,
    this.iconColor = Colors.black,
    this.action,
    this.backgroundColor,
    this.actionHandler,
    this.description,
    this.displayTitle = true,
    this.animationDuration = const Duration(
      milliseconds: 2000,
    ),
    this.animationCurve = Curves.ease,
    this.animationType = AnimationType.fromRight,
    this.autoDismiss = true,
    this.toastDuration = const Duration(
      milliseconds: 5000,
    ),
    this.displayCloseButton = true,
    this.borderRadius = 20,
    this.displayIcon = true,
    this.enableIconAnimation = true,
    this.iconSize = 20,
  }) : super(key: key);

  ///Text widget displayed as a description in the toast
  final Text? description;

  ///THe action button displayed below description
  ///by default there's no action added
  final Text? action;

  ///indicates whether display or not the title
  ///
  final bool displayTitle;

  ///the Icon color
  ///this parameter is only available on the default constructor
  ///for the built-in themes the color  will be set automatically
  late Color iconColor;

  //background color of container
  final Color? backgroundColor;

  ///the icon size
  ///by default is 20
  ///this parameter is available in default constructor
  late double iconSize;

  ///the function invoked when clicking on the action button
  ///
  final Function? actionHandler;

  ///The duration of the animation by default it's 1.5 seconds
  ///
  final Duration animationDuration;

  ///the animation curve by default it's set to `Curves.ease`
  ///
  final Cubic animationCurve;

  ///The animation type applied on the toast
  ///```dart
  ///{
  ///fromTop,
  ///fromLeft,
  ///fromRight
  ///}
  ///```
  final AnimationType animationType;

  ///indicates whether the toast will be hidden automatically or not
  ///
  final bool autoDismiss;

  ///the duration of the toast if [autoDismiss] is true
  ///by default it's 3 seconds
  ///
  final Duration toastDuration;

  ///Display / Hide the close button icon
  ///by default it's true
  final bool displayCloseButton;

  ///define the border radius applied on the toast
  ///by default it's 20
  ///
  final double borderRadius;

  ///Define whether the icon will be  rendered or not
  ///
  final bool displayIcon;

  ///Define wether the animation on the icon will be rendered or not
  ///
  final bool enableIconAnimation;

  ///Display the created cherry toast
  ///[context] the context of the application
  ///
  void show(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: false,
        barrierColor: Colors.transparent,
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, _, __) => SafeArea(
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  child: this,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  _SaveToHereTipState createState() => _SaveToHereTipState();
}

class _SaveToHereTipState extends State<SaveToHereTip>
    with TickerProviderStateMixin {
  late Animation<Offset> offsetAnimation;
  late AnimationController slideController;
  late BoxDecoration toastDecoration;
  Timer? autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _initAnimation();

    if (widget.autoDismiss) {
      autoDismissTimer = Timer(widget.toastDuration, () {
        slideController.reverse();
        Timer(widget.animationDuration, () {
          Navigator.maybePop(context);
        });
      });
    }
  }

  @override
  void dispose() {
    autoDismissTimer?.cancel();
    slideController.dispose();
    super.dispose();
  }

  ///Initialize animation parameters [slideController] and [offsetAnimation]
  void _initAnimation() {
    slideController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    switch (widget.animationType) {
      case AnimationType.fromLeft:
        offsetAnimation = Tween<Offset>(
          begin: const Offset(-2, 0),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(
            parent: slideController,
            curve: widget.animationCurve,
          ),
        );
        break;
      case AnimationType.fromRight:
        offsetAnimation = Tween<Offset>(
          begin: const Offset(2, 0),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(
            parent: slideController,
            curve: widget.animationCurve,
          ),
        );
        break;
      case AnimationType.fromTop:
        offsetAnimation = Tween<Offset>(
          begin: const Offset(0, -2),
          end: const Offset(0, 0),
        ).animate(
          CurvedAnimation(
            parent: slideController,
            curve: widget.animationCurve,
          ),
        );
        break;
      default:
    }

    /// ! To support Flutter < 3.0.0
    /// This allows a value of type T or T?
    /// to be treated as a value of type T?.
    ///
    /// We use this so that APIs that have become
    /// non-nullable can still be used with `!` and `?`
    /// to support older versions of the API as well.
    T? ambiguate<T>(T? value) => value;

    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((_) {
      slideController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    toastDecoration = BoxDecoration(
      border: Border.all(color: ColorsTheme.of(context).purple100),
      color:
          widget.backgroundColor ?? ColorsTheme.of(context).primaryBackground,
      borderRadius: BorderRadius.circular(widget.borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 1,
          offset: const Offset(0, 1), // changes position of shadow
        ),
      ],
    );

    return _renderLayoutToast(context);
  }

  Widget _renderLayoutToast(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SlideTransition(
          position: offsetAnimation,
          child: Container(
            decoration: toastDecoration,
            margin: const EdgeInsets.symmetric(
              vertical: 50,
              horizontal: 20,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Save to here',
                    style: FontTheme.of(context).h4.primary(),
                  ),
                  SvgPicture.asset(
                    'assets/svg/down_arrow.svg',
                    colorFilter: filterFor(ColorsTheme.of(context).purpleMain),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// render the close button icon with a clickable  widget that
  /// will hide the toast
  ///
  InkWell _renderCloseButton(BuildContext context) {
    return InkWell(
      onTap: () {
        slideController.reverse();
        autoDismissTimer?.cancel();
        Timer(
          widget.animationDuration,
          () {
            Navigator.pop(context);
          },
        );
      },
      child: Icon(
        Icons.close_rounded,
        color: ColorsTheme.of(context).primaryText,
        size: 20,
      ),
    );
  }
}
