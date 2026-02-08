import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../routing/app_router.dart';
import '../../routing/route_names.dart';
import 'admin_drawer.dart';
import 'admin_nav_items.dart';
import 'back_navigation_guard.dart';

class AdminScaffold extends StatefulWidget {
  final String title;
  final String currentRoute;
  final Widget body;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final bool showDrawer;
  final bool showTopNav;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.currentRoute,
    required this.body,
    this.actions,
    this.bottom,
    this.floatingActionButton,
    this.showDrawer = true,
    this.showTopNav = true,
  });

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<bool> _handleWillPop() async {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
      return false;
    }

    return handleBackNavigation(
      context,
      title: 'Exit Admin App',
      message: 'Do you want to close the admin app?',
    );
  }

  PreferredSizeWidget? _buildBottomBar() {
    final List<Widget> sections = [];

    if (widget.showTopNav) {
      sections.add(const Divider(height: 1));
      sections.add(_AdminTopNav(currentRoute: widget.currentRoute));
    }

    if (widget.bottom != null) {
      sections.add(widget.bottom!);
    }

    if (sections.isEmpty) return null;

    final double height =
        (widget.showTopNav ? 50 : 0) +
        (widget.bottom?.preferredSize.height ?? 0) +
        1;

    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: Container(
        color: AppColors.surface,
        child: Column(mainAxisSize: MainAxisSize.min, children: sections),
      ),
    );
  }

  Widget? _buildLeading() {
    final canPop = Navigator.of(context).canPop();

    if (canPop) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    if (!widget.showDrawer) return null;

    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      tooltip: 'Menu',
    );
  }

  List<Widget> _buildActions() {
    return [
      TextButton.icon(
        onPressed: () =>
            AppRouter.pushAndRemoveUntil(context, RouteNames.dashboard),
        icon: const Icon(Icons.home_outlined),
        label: const Text('Home'),
      ),
      if (widget.actions != null) ...widget.actions!,
      const SizedBox(width: 4),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: widget.showDrawer
            ? AdminDrawer(currentRoute: widget.currentRoute)
            : null,
        appBar: AppBar(
          title: Text(widget.title),
          automaticallyImplyLeading: false,
          leading: _buildLeading(),
          actions: _buildActions(),
          bottom: _buildBottomBar(),
        ),
        body: widget.body,
        floatingActionButton: widget.floatingActionButton,
      ),
    );
  }
}

class _AdminTopNav extends StatelessWidget {
  final String currentRoute;

  const _AdminTopNav({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: adminNavItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = adminNavItems[index];
          final isSelected = currentRoute == item.route;

          return ChoiceChip(
            selected: isSelected,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 18),
                const SizedBox(width: 6),
                Text(item.label),
              ],
            ),
            onSelected: (_) {
              if (isSelected) return;
              AppRouter.pushAndRemoveUntil(context, item.route);
            },
          );
        },
      ),
    );
  }
}
