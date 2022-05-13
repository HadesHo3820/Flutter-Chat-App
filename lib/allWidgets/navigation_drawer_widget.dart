import 'package:flutter/material.dart';
import 'package:ichat_app/allModels/navigation_item.dart';
import 'package:ichat_app/allProviders/auth_provider.dart';
import 'package:ichat_app/allProviders/navigation_provider.dart';
import 'package:ichat_app/allScreens/change_account_info_page.dart';
import 'package:ichat_app/allScreens/home_page.dart';
import 'package:ichat_app/allScreens/login_page.dart';
import 'package:ichat_app/allScreens/settings_page.dart';
import 'package:ichat_app/utilities/helper_widgets.dart';
import 'package:provider/provider.dart';

class NavigationDrawer extends StatelessWidget {
  final padding = const EdgeInsets.symmetric(horizontal: 20);

  @override
  Widget build(BuildContext context) {
    final _authProvider = Provider.of<AuthProvider>(context, listen: false);
    const name = "Viet Huy";
    const email = "hoviethuy3820@gmail.com";
    const urlImage =
        "https://img.freepik.com/free-vector/cute-corgi-dog-sitting-cartoon-vector-icon-illustration-animal-nature-icon-concept-isolated-premium-vector-flat-cartoon-style_138676-4181.jpg?w=826";
    return Drawer(
      child: Material(
        color: Theme.of(context).colorScheme.primaryVariant,
        child: ListView(
          children: [
            buildHeader(
                urlImage: urlImage, name: name, email: email, onClicked: () {}),
            Container(
              padding: padding,
              child: Column(
                children: [
                  addVerticalSpace(12),
                  buildMenuItem(
                    context,
                    navigationItem: NavigationItem.home,
                    text: 'Home Page',
                    icon: Icons.home,
                  ),
                  addVerticalSpace(16),
                  buildMenuItem(context,
                      navigationItem: NavigationItem.settings,
                      text: 'Setting',
                      icon: Icons.settings),
                  addVerticalSpace(24),
                  const Divider(
                    color: Colors.white70,
                  ),
                  addVerticalSpace(24),
                  buildLogoutItem(context,
                      authProvider: _authProvider,
                      text: "Logout",
                      icon: Icons.logout)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLogoutItem(BuildContext context,
      {required AuthProvider authProvider,
      required String text,
      required IconData icon}) {
    final color = Colors.red;
    const hoverColor = Colors.white70;
    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        text,
        style: TextStyle(color: color),
      ),
      hoverColor: hoverColor,
      onTap: () {
        authProvider.handleSignOut();
        Provider.of<NavigationProvider>(context, listen: false)
            .setNavigationItem(NavigationItem.home);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()));
      },
    );
  }

  Widget buildMenuItem(BuildContext context,
      {required NavigationItem navigationItem,
      required String text,
      required IconData icon}) {
    final provider = Provider.of<NavigationProvider>(context, listen: false);
    final currentItem = provider.currentNavItem;
    final isSelected = navigationItem == currentItem;

    final color = isSelected ? Colors.orangeAccent : Colors.white;
    const hoverColor = Colors.white70;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        selected: isSelected,
        selectedTileColor: Colors.white24,
        leading: Icon(
          icon,
          color: color,
        ),
        title: Text(
          text,
          style: TextStyle(color: color),
        ),
        hoverColor: hoverColor,
        onTap: () => isSelected ? null : selectedItem(context, navigationItem),
      ),
    );
  }

  void selectedItem(BuildContext context, NavigationItem item) {
    final provider = Provider.of<NavigationProvider>(context, listen: false);
    provider.setNavigationItem(item);
    Navigator.of(context).pop();
    switch (item) {
      case NavigationItem.home:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()));
        break;
      case NavigationItem.settings:
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SettingsPage()));
        break;
      case NavigationItem.header:
        // TODO: Handle this case.
        break;
    }
  }

  Widget buildHeader(
          {required String urlImage,
          required String name,
          required String email,
          required VoidCallback onClicked}) =>
      InkWell(
        onTap: onClicked,
        child: Container(
          padding: padding.add(const EdgeInsets.symmetric(vertical: 40)),
          child: Row(
            children: [
              CircleAvatar(radius: 30, backgroundImage: NetworkImage(urlImage)),
              addHorizontalSpace(20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  addVerticalSpace(4),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              )
            ],
          ),
        ),
      );
}
