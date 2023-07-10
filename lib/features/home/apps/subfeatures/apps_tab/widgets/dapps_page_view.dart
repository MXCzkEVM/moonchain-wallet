import 'package:datadashwallet/features/home/apps/apps.dart';
import 'package:datadashwallet/features/home/apps/entities/bookmark.dart';
import 'package:datadashwallet/features/home/apps/entities/dapp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'bookmark_icon.dart';

class DAppsPageView extends StatefulWidget {
  const DAppsPageView({
    Key? key,
    this.child,
    required this.bookmarks,
    this.onLayoutChange,
    this.onLongPress,
    this.onRemoveTap,
    this.isEditMode = false,
  }) : super(key: key);

  final Widget? child;
  final List<Bookmark> bookmarks;
  final Function(int rowCount)? onLayoutChange;
  final VoidCallback? onLongPress;
  final Function(Bookmark)? onRemoveTap;
  final bool isEditMode;

  @override
  State<DAppsPageView> createState() => _DAppsPageViewState();
}

class _DAppsPageViewState extends State<DAppsPageView> {
  final GlobalKey _pageViewKey = GlobalKey();
  double _pageHeight = 0;
  double? _contentHeight;
  Size? _oldSize;
  int _rowCount = 0;

  void postFrameCallback(_) async {
    var context = _pageViewKey.currentContext;
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted || context == null) return;

    var newSize = context.size!;
    if (_oldSize == newSize) {
      if (widget.onLayoutChange != null) widget.onLayoutChange!(_rowCount);
      return;
    }

    _oldSize = newSize;
    _contentHeight = newSize.height;
    _rowCount = ((_pageHeight - (_contentHeight ?? 0)) / 80).floor();

    setState(() {});
    if (widget.onLayoutChange != null) widget.onLayoutChange!(_rowCount);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _pageHeight = MediaQuery.of(context).size.height - 160;
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          SizedBox(
            key: _pageViewKey,
            child: widget.child,
          ),
          if (widget.bookmarks.isNotEmpty &&
              _contentHeight != null &&
              _rowCount > 0) ...[
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
              ),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.bookmarks.length < _rowCount * 4
                  ? widget.bookmarks.length
                  : _rowCount * 4,
              itemBuilder: (context, index) => BookmarkIcon(
                onTap: widget.isEditMode
                    ? null
                    : () => openAppPage(
                        context,
                        DApp(
                            name: widget.bookmarks[index].title,
                            url: widget.bookmarks[index].url)),
                onLongPress: widget.onLongPress,
                onRemoveTap: widget.onRemoveTap != null
                    ? () => widget.onRemoveTap!(widget.bookmarks[index])
                    : null,
                title: widget.bookmarks[index].title,
                url: widget.bookmarks[index].url,
                isEditMode: widget.isEditMode,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
