import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum TabItem { home,saved, profile}

class TabItemData {
  const TabItemData({required this.title, required this.icon});

  final String title;
  final IconData icon;

  static const Map<TabItem, TabItemData> allTabs = {
    TabItem.home: TabItemData(title: 'Attractions', icon: Icons.home),
    TabItem.saved: TabItemData(title: 'Wish List', icon: CupertinoIcons.heart_solid),
    TabItem.profile: TabItemData(title: 'Profile', icon: Icons.account_circle),
  };
}