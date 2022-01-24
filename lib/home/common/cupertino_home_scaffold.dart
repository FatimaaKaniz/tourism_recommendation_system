import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tourism_recommendation_system/home/common/tab_items.dart';

class CupertinoHomeScaffold extends StatelessWidget {
  const CupertinoHomeScaffold({
    required this.currentTab,
    required this.onSelectTab,
    required this.widgetBuilders,
    required this.navigatorKeys,
    required this.isAdmin,
  }) : super();

  final TabItem currentTab;
  final bool isAdmin;
  final ValueChanged<TabItem> onSelectTab;
  final Map<TabItem, WidgetBuilder> widgetBuilders;
  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: Colors.grey.shade200,
        items: [
          _buildItem(TabItem.home),
          if (!isAdmin) _buildItem(TabItem.saved),
          _buildItem(TabItem.profile),
        ],
        onTap: (index) => onSelectTab(TabItem.values[index]),
      ),
      tabBuilder: (context, index) {
        if (isAdmin && index == 1) {
          index = 2;
        }
        final item = TabItem.values[index];
        return CupertinoTabView(
          navigatorKey: navigatorKeys[item],
          builder: (context) => widgetBuilders[item]!(context),
        );
      },
    );
  }

  BottomNavigationBarItem _buildItem(TabItem tabItem) {
    final itemData = TabItemData.allTabs[tabItem];
    final color = currentTab == tabItem ? Colors.teal : Colors.grey;
    return BottomNavigationBarItem(
      icon: Icon(
        itemData?.icon,
        color: color,
      ),
      label: itemData?.title,
    );
  }
}
