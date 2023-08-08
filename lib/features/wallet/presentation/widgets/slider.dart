import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:mxc_ui/mxc_ui.dart';

class WalletSlider extends StatefulWidget {
  const WalletSlider({Key? key}) : super(key: key);

  @override
  State<WalletSlider> createState() => _WalletSliderState();
}

class _WalletSliderState extends State<WalletSlider> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Column(
            children: [
              Expanded(
                flex: 35,
                child: ImageSlider(
                  onPageChanged: (index) => setState(() => _index = index),
                ),
              ),
              Expanded(
                flex: 1,
                child: SliderIndicator(
                  index: _index,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ImageSlider extends StatefulWidget {
  const ImageSlider({
    Key? key,
    this.onPageChanged,
  }) : super(key: key);

  final Function(int)? onPageChanged;

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: PageView(
        onPageChanged: widget.onPageChanged,
        children: List.generate(
            7,
            (index) =>
                getSliderImage(ImagesTheme.of(context).sliderPlaceHolder)),
      ),
    );
  }
}

Widget getSliderImage(ImageProvider img) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10.0),
    decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        image: DecorationImage(image: img, fit: BoxFit.fill)),
  );
}

class SliderIndicator extends StatelessWidget {
  const SliderIndicator({
    Key? key,
    this.index = 0,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            7,
            (i) => SliderIndicatorItem(
              indicate: index == i,
            ),
          )),
    );
  }
}

class SliderIndicatorItem extends StatelessWidget {
  final bool indicate;
  const SliderIndicatorItem({Key? key, required this.indicate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: 25,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: (indicate)
              ? ColorsTheme.of(context).chipBgActive
              : ColorsTheme.of(context).iconGrey4),
    );
  }
}
