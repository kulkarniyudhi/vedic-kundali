import 'package:material_ui/material_ui.dart';
import '../services/localization_service.dart';
import '../theme/app_theme.dart';
import 'cities/city_search_screen.dart';
import 'gunmilan/gunmilan_input_screen.dart';
import 'kundali/kundali_input_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Widget> get _screens => const [
    KundaliInputScreen(),
    GunMilanInputScreen(),
    CitySearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() => _currentIndex = idx);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome, color: AppTheme.deepVermilion),
            label: AppStrings.tabKundali,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline),
            selectedIcon: const Icon(Icons.favorite, color: AppTheme.deepVermilion),
            label: AppStrings.tabGunMilan,
          ),
          NavigationDestination(
            icon: const Icon(Icons.location_city_outlined),
            selectedIcon: const Icon(Icons.location_city, color: AppTheme.deepVermilion),
            label: AppStrings.tabCitySearch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings, color: AppTheme.deepVermilion),
            label: AppStrings.tabSettings,
          ),
        ],
      ),
    );
  }
}
