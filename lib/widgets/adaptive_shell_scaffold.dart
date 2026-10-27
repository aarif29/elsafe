import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Presentation for the existing five destinations, independent of services.
class AdaptiveShellScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final int unreadCount;
  final Widget body;
  final Widget? drawer;
  final Widget? floatingActionButton;

  const AdaptiveShellScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.unreadCount = 0,
    this.drawer,
    this.floatingActionButton,
  });

  static const _labels = [
    'Dashboard',
    'Daftar',
    'Peta',
    'Notifikasi',
    'Profil',
  ];
  static const _icons = [
    Icons.dashboard,
    Icons.list,
    Icons.map,
    Icons.notifications_outlined,
    Icons.person,
  ];

  Widget _icon(int index) {
    if (index != 3 || unreadCount <= 0) return Icon(_icons[index]);
    return Badge(
      label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
      child: Icon(_icons[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 1024;
        return Scaffold(
          drawer: drawer,
          body: Row(
            children: [
              if (desktop)
                SafeArea(
                  child: SizedBox(
                    width: 224,
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: (constraints.maxHeight -
                                  MediaQuery.paddingOf(context).vertical)
                              .clamp(0, double.infinity),
                        ),
                        child: IntrinsicHeight(
                          child: NavigationRail(
                            extended: true,
                            minExtendedWidth: 224,
                            backgroundColor: context.surfaceColor,
                            selectedIndex: selectedIndex,
                            onDestinationSelected: onDestinationSelected,
                            destinations: [
                              for (var i = 0; i < _labels.length; i++)
                                NavigationRailDestination(
                                  icon: _icon(i),
                                  label: Text(_labels[i]),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (desktop)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: context.borderColor,
                ),
              // Always last in this Row, so resizing retains the screen subtree.
              Expanded(child: body),
            ],
          ),
          bottomNavigationBar:
              desktop
                  ? null
                  : BottomNavigationBar(
                    currentIndex: selectedIndex,
                    onTap: onDestinationSelected,
                    type: BottomNavigationBarType.fixed,
                    selectedFontSize: 12,
                    unselectedFontSize: 12,
                    items: [
                      for (var i = 0; i < _labels.length; i++)
                        BottomNavigationBarItem(
                          icon: _icon(i),
                          label: _labels[i],
                        ),
                    ],
                  ),
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}
