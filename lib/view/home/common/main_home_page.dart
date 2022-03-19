import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourism_recommendation_system/controller/main_home_page_controller.dart';
import 'package:tourism_recommendation_system/view/home/admin/admin_home.dart';
import 'package:tourism_recommendation_system/view/home/common/cupertino_home_scaffold.dart';
import 'package:tourism_recommendation_system/view/home/common/tab_items.dart';
import 'package:tourism_recommendation_system/view/home/standard_user/homepage.dart';
import 'package:tourism_recommendation_system/view/home/profile/profile_page.dart';
import 'package:tourism_recommendation_system/model/user.dart';
import 'package:tourism_recommendation_system/view/home/standard_user/wish_list_page.dart';
import 'package:tourism_recommendation_system/view_model/user_view_model.dart';
import 'package:tourism_recommendation_system/services/auth_base.dart';
import 'package:tourism_recommendation_system/services/database.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  _MainHomePageState createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final MainHomePageController controller = MainHomePageController();
  TabItem _currentTab = TabItem.home;
  bool? isAdmin;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await setIsAdmin(context);
    });
    super.initState();
  }

  setIsAdmin(BuildContext context) async {
    final db = Provider.of<Database>(context, listen: false);
    final auth = Provider.of<AuthBase>(context, listen: false);
    bool isAdmin = await controller.setIsAdmin(db, auth);
    setState(() {
      this.isAdmin = isAdmin;
    });
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
      TabItem.home: (_) => isAdmin! ? AdminHome() : HomePage(),
      if (!isAdmin!) TabItem.saved: (_) => WishListPage(user: auth.myUser!),
      TabItem.profile: (context) => ChangeNotifierProvider<MyUserViewModel>(
            create: (_) => MyUserViewModel(
              myUser: MyUser(
                email: auth.currentUser?.email,
                isAdmin: isAdmin,
                name: auth.currentUser?.displayName,
              ),
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
    return isAdmin == null
        ? Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : WillPopScope(
            onWillPop: () async =>
                !await navigatorKeys[_currentTab]!.currentState!.maybePop(),
            child: CupertinoHomeScaffold(
              isAdmin: isAdmin!,
              currentTab: _currentTab,
              onSelectTab: _select,
              widgetBuilders: widgetBuilders,
              navigatorKeys: isAdmin! ? navigatorKeysAdmin : navigatorKeys,
            ),
          );
  }
}
