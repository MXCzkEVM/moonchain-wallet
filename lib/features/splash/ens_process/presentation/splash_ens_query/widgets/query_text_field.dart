import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

class QueryTextfield extends StatefulWidget {
  const QueryTextfield({
    Key? key,
    required this.controller,
    this.onChanged,
    this.errorText,
  }) : super(key: key);

  final TextEditingController controller;
  final void Function(String)? onChanged;
  final String? errorText;

  @override
  State<QueryTextfield> createState() => _QueryTextfieldState();
}

class _QueryTextfieldState extends State<QueryTextfield> {
  final FocusNode _focusNode = FocusNode();
  double _leftPosition = 0;
  bool _focused = false;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      Size textSize = Formatter.boundingTextSize(widget.controller.text,
          FontTheme.of(context, listen: false).body1.white());
      setState(() => _leftPosition = textSize.width);
    });

    _focusNode.addListener(_focusNodeListener);
  }

  void _focusNodeListener() {
    if (_focusNode.hasFocus != _focused) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  Future<void> dispose() async {
    widget.controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FlutterI18n.translate(context, 'username'),
          style: FontTheme.of(context).caption2.white(),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(
                color:
                    _focused ? Colors.white : Colors.white.withOpacity(0.32)),
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      style: FontTheme.of(context).body1.white(),
                      decoration: const InputDecoration(
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      onChanged: (v) => widget.onChanged!(v),
                    ),
                  ),
                  if (widget.controller.text.isNotEmpty)
                    InkWell(
                      child: SvgPicture.asset('assets/svg/ic_clear.svg'),
                      onTap: () => widget.controller.clear(),
                    ),
                ],
              ),
              Positioned(
                top: 14,
                left: _leftPosition,
                child: Text(
                  '.mxc',
                  style: FontTheme.of(context).body1().copyWith(
                        color: Colors.white.withOpacity(0.32),
                      ),
                ),
              ),
            ],
          ),
        ),
        if (widget.errorText != null && widget.errorText!.isNotEmpty)
          ErrorTip(widget.errorText!),
      ],
    );
  }
}
