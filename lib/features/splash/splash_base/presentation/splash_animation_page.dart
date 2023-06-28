import 'package:datadashwallet/common/common.dart';
import 'package:datadashwallet/core/src/routing/route.dart';
import 'package:datadashwallet/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashAnimationPage extends StatefulWidget {
  const SplashAnimationPage({super.key});

  @override
  State<SplashAnimationPage> createState() => _SplashAnimationPageState();
}

class _SplashAnimationPageState extends State<SplashAnimationPage>
    with TickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _controller!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Do something when the animation is completed
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                SplashSetupWalletPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MxcPage(useSplashBackground: true, children: [
      Center(
        child: LottieBuilder.asset(
          "assets/lottie/data_dash_splash_screen.json",
          controller: _controller,
          onLoaded: (p0) {
            _controller!.forward();
          },
          filterQuality: FilterQuality.high,
          frameRate: FrameRate.max,
          repeat: false,
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
        ),
      )
    ]);
  }
}
