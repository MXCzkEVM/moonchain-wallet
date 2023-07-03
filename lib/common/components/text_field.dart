import 'package:datadashwallet/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mxc_ui/mxc_ui.dart';

class MxcTextfield extends StatefulWidget {
  const MxcTextfield({
    Key? key,
    required this.controller,
    this.onChanged,
    this.errorText,
    this.label,
    this.maxLines = 1,
    this.hintText,
  }) : super(key: key);

  final TextEditingController controller;
  final void Function(String)? onChanged;
  final String? errorText;
  final String? label;
  final int? maxLines;
  final String? hintText;

  @override
  State<MxcTextfield> createState() => _MxcTextfieldState();
}

class _MxcTextfieldState extends State<MxcTextfield> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();

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
        if (widget.label != null)
          Text(
            FlutterI18n.translate(context, widget.label!),
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
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  maxLines: widget.maxLines,
                  controller: widget.controller,
                  focusNode: _focusNode,
                  style: FontTheme.of(context).body1.white(),
                  decoration: InputDecoration(
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: widget.hintText,
                  ),
                  onChanged: (v) =>
                      widget.onChanged != null ? widget.onChanged!(v) : null,
                ),
              ),
              if (widget.controller.text.isNotEmpty)
                InkWell(
                  child: SvgPicture.asset('assets/svg/ic_clear.svg'),
                  onTap: () => widget.controller.clear(),
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
