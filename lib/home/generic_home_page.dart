import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/home/admin_home.dart';
import 'package:tourism_recommendation_system/home/cupertino_home_scaffold.dart';
import 'package:tourism_recommendation_system/home/homepage.dart';
import 'package:tourism_recommendation_system/home/profile/profile_page.dart';
import 'package:tourism_recommendation_system/home/tab_items.dart';
import 'package:tourism_recommendation_system/models/user_model.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';
import 'package:tourism_recommendation_system/services/database.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  _MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  TabItem _currentTab = TabItem.home;

  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.home: GlobalKey<NavigatorState>(),
    TabItem.profile: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return {
      TabItem.home: (_) => auth.isCurrentUserAdmin ? AdminHome() : HomePage(),
      TabItem.profile: (context) => ChangeNotifierProvider<MyUser>(
            create: (_) => MyUser(
              email: auth.currentUser?.email,
              isAdmin: auth.currentUser == null ? false: auth.isCurrentUserAdmin,
              name: auth.currentUser?.displayName,
            ),
            child: ProfilePage(),
          ),
    };
  }

  void _select(TabItem tabItem) {
    if (tabItem == _currentTab) {
      // pop to first route
      navigatorKeys[tabItem]?.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[_currentTab]!.currentState!.maybePop(),
      child: CupertinoHomeScaffold(
        currentTab: _currentTab,
        onSelectTab: _select,
        widgetBuilders: widgetBuilders,
        navigatorKeys: navigatorKeys,
      ),
    );
  }
}
