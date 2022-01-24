import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/home/admin/admin_home.dart';
import 'package:tourism_recommendation_system/home/common/cupertino_home_scaffold.dart';
import 'package:tourism_recommendation_system/home/common/tab_items.dart';
import 'package:tourism_recommendation_system/home/homepage.dart';
import 'package:tourism_recommendation_system/home/profile/profile_page.dart';
import 'package:tourism_recommendation_system/home/wish_list_page.dart';
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
  bool isAdmin = false;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await setIsAdmin(context);
    });
    super.initState();
  }

  Future<void> setIsAdmin(BuildContext context) async {
    final db = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    if (auth.isCurrentUserAdmin == null) {
      final users = await db.usersStream().first;
      var myUser =
          users.where((user) => user.email == auth.currentUser!.email!).first;
      bool admin = myUser.isAdmin!;
      var places = myUser.savedPlacesIds;
      setState(() {
        auth.setCurrentUserAdmin(admin);
        auth.setMyUser(MyUser(
            email: auth.currentUser!.email,
            isAdmin: admin,
            name: auth.currentUser!.displayName,
            savedPlacesIds: places,
           ));
        isAdmin = admin;
      });
    } else {
      isAdmin = auth.isCurrentUserAdmin!;
    }
  }

  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.home: GlobalKey<NavigatorState>(),
    TabItem.saved: GlobalKey<NavigatorState>(),
    TabItem.profile: GlobalKey<NavigatorState>(),
  };
  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeysAdmin = {
    TabItem.home: GlobalKey<NavigatorState>(),
    TabItem.profile: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, WidgetBuilder> get widgetBuilders {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return {
      TabItem.home: (_) => isAdmin ? AdminHome() : HomePage(),
      if (!isAdmin) TabItem.saved: (_) => WishListPage(user: auth.myUser!),
      TabItem.profile: (context) => ChangeNotifierProvider<MyUser>(
            create: (_) => MyUser(
                email: auth.currentUser?.email,
                isAdmin: isAdmin,
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
    setIsAdmin(context);

    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[_currentTab]!.currentState!.maybePop(),
      child: CupertinoHomeScaffold(
        isAdmin: isAdmin,
        currentTab: _currentTab,
        onSelectTab: _select,
        widgetBuilders: widgetBuilders,
        navigatorKeys: isAdmin ? navigatorKeysAdmin : navigatorKeys,
      ),
    );
  }
}
