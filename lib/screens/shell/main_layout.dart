import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/app_top_bar.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onSelectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  String get _currentTitle {
    switch (_currentIndex) {
      case 0:
        return 'Головна панель';
      case 1:
        return 'Гараж';
      case 2:
        return 'Історія';
      case 3:
        return 'Профіль та Безпека';
      default:
        return 'AutoLog';
    }
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Цей розділ буде доступний у наступних лабораторних роботах',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          onNavigateToGarage: () => _onSelectTab(1),
          onNavigateToReminders: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Перехід до нагадувань'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      case 1:
        return _buildPlaceholder('Гараж автомобілів', Icons.warehouse_outlined);
      case 2:
        return _buildPlaceholder('Історія обслуговування', Icons.history_outlined);
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 840;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: isDesktop
              ? null
              : Drawer(
                  child: AppSidebar(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: _onSelectTab,
                    showBottomTip: _currentIndex == 0,
                  ),
                ),
          body: Row(
            children: [
              // Permanent Sidebar on Desktop / Web
              if (isDesktop)
                AppSidebar(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onSelectTab,
                  showBottomTip: _currentIndex == 0,
                ),

              // Main Application View
              Expanded(
                child: Column(
                  children: [
                    // Top Navigation Bar
                    AppTopBar(
                      title: _currentTitle,
                      isDashboard: _currentIndex == 0,
                      onOpenMenu: isDesktop ? null : () => _scaffoldKey.currentState?.openDrawer(),
                      onAddRecord: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Створення нового запису обслуговування...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),

                    // Scrollable Page Content
                    Expanded(
                      child: _buildCurrentPage(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
