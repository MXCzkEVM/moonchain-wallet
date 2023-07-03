import 'package:datadashwallet/features/home/apps/entities/bookmark.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppsTabPageState with EquatableMixin {
  List<Bookmark> bookmarks = [];
  List<int> pages = [];
  int pageIndex = 0;

  @override
  List<Object?> get props => [
        bookmarks,
        pages,
        pageIndex,
      ];
}
