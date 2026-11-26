import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../../models/astrology_models.dart';
import '../../services/api/city_api.dart';
import '../../services/localization_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';

class CitySearchScreen extends StatefulWidget {
  final bool isPicker;
  final String? initialQuery;

  const CitySearchScreen({
    super.key,
    this.isPicker = false,
    this.initialQuery,
  });

  /// Opens the city search screen as a full modal / page and returns the selected [CityItem].
  static Future<CityItem?> pickCity(BuildContext context, {String? initialQuery}) {
    return Navigator.push<CityItem>(
      context,
      MaterialPageRoute(
        builder: (context) => CitySearchScreen(
          isPicker: true,
          initialQuery: initialQuery,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  List<CityItem> _filteredCities = sampleIndianCities;
  String _activeQuickFilter = '';
  Timer? _debounceTimer;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _searchFocusNode = FocusNode();
    _searchController.addListener(_onSearchChanged);

    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _filterCities(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final text = _searchController.text;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      _filterCities(text);
    });
  }

  Future<void> _filterCities(String rawQuery) async {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _filteredCities = sampleIndianCities;
        _isSearching = false;
      });
      return;
    }

    if (query.length >= 2) {
      if (mounted) setState(() => _isSearching = true);
      try {
        final apiResults = await CityApi.searchCities(query, limit: 30);
        if (!mounted) return;
        setState(() {
          _isSearching = false;
          if (apiResults.isNotEmpty) {
            _filteredCities = apiResults;
          } else {
            _filteredCities = sampleIndianCities.where((c) {
              final matchesName = c.name.toLowerCase().contains(query);
              final matchesMarathi = (c.marathiName ?? '').toLowerCase().contains(query);
              final matchesDistrict = c.district.toLowerCase().contains(query);
              final matchesState = c.state.toLowerCase().contains(query);
              final matchesDisplay = c.display.toLowerCase().contains(query);
              return matchesName || matchesMarathi || matchesDistrict || matchesState || matchesDisplay;
            }).toList();
          }
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _isSearching = false;
          _filteredCities = sampleIndianCities.where((c) {
            final matchesName = c.name.toLowerCase().contains(query);
            final matchesMarathi = (c.marathiName ?? '').toLowerCase().contains(query);
            final matchesDistrict = c.district.toLowerCase().contains(query);
            final matchesState = c.state.toLowerCase().contains(query);
            final matchesDisplay = c.display.toLowerCase().contains(query);
            return matchesName || matchesMarathi || matchesDistrict || matchesState || matchesDisplay;
          }).toList();
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _filteredCities = sampleIndianCities.where((c) {
          final matchesName = c.name.toLowerCase().contains(query);
          final matchesMarathi = (c.marathiName ?? '').toLowerCase().contains(query);
          return matchesName || matchesMarathi;
        }).toList();
      });
    }
  }

  void _selectQuickFilter(String label, String queryValue) {
    setState(() {
      _activeQuickFilter = label;
      _searchController.text = queryValue;
    });
  }

  void _selectCity(CityItem city) {
    if (widget.isPicker) {
      Navigator.pop(context, city);
    } else {
      final displayName = LocalizationService.isMarathi(context) && city.marathiName != null
          ? city.marathiName!
          : city.name;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.citySelected(displayName, city.lat, city.lng)),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _buildQuickChip(String label, String query) {
    final isSelected = (_activeQuickFilter == label) ||
        (query.isEmpty && _searchController.text.isEmpty && _activeQuickFilter.isEmpty);

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _selectQuickFilter(label, query),
        selectedColor: AppTheme.primarySaffron.withValues(alpha: 0.18),
        checkmarkColor: AppTheme.deepVermilion,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.deepVermilion : AppTheme.darkWood,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPicker ? AppStrings.selectCityTitle : AppStrings.searchCityTitle),
        leading: widget.isPicker
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: AppStrings.back,
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: widget.isPicker,
              decoration: InputDecoration(
                hintText: AppStrings.searchCityHint,
                prefixIcon: const Icon(Icons.search, color: AppTheme.primarySaffron),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _activeQuickFilter = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          if (_isSearching)
            const LinearProgressIndicator(
              minHeight: 2,
              color: AppTheme.primarySaffron,
              backgroundColor: Colors.transparent,
            )
          else
            const SizedBox(height: 2),

          // Quick Filter Chips
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildQuickChip(AppStrings.all, ''),
                _buildQuickChip('शिरपूर (Shirpur)', 'Shirpur'),
                _buildQuickChip('पुणे (Pune)', 'Pune'),
                _buildQuickChip('मुंबई (Mumbai)', 'Mumbai'),
                _buildQuickChip('नाशिक (Nashik)', 'Nashik'),
                _buildQuickChip('नागपूर (Nagpur)', 'Nagpur'),
                _buildQuickChip('संभाजीनगर', 'Sambhajinagar'),
                _buildQuickChip('धुळे (Dhule)', 'Dhule'),
                _buildQuickChip('जळगाव (Jalgaon)', 'Jalgaon'),
                _buildQuickChip('ठाणे (Thane)', 'Thane'),
                _buildQuickChip('कोल्हापूर (Kolhapur)', 'Kolhapur'),
                _buildQuickChip('दिल्ली (Delhi)', 'Delhi'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Count and Database Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.citiesCount(_filteredCities.length),
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ),
                StatusBadge(text: AppStrings.localDbBadge, isSuccess: true),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // City Results List
          Expanded(
            child: _filteredCities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off_outlined, size: 52, color: AppTheme.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.noCitiesFound,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkWood),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.checkSpellingHint,
                          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _activeQuickFilter = '');
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(AppStrings.showAllCities),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredCities.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final city = _filteredCities[idx];
                      final cityName = LocalizationService.isMarathi(context) && city.marathiName != null
                          ? city.marathiName!
                          : city.name;

                      return Card(
                        elevation: 1,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _selectCity(city),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppTheme.chipBackground,
                                  child: Icon(Icons.location_pin, color: AppTheme.deepVermilion, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cityName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${city.district}, ${city.state}',
                                        style: const TextStyle(fontSize: 13, color: AppTheme.darkWood),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        AppStrings.latLngDisplay(city.lat, city.lng),
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                if (widget.isPicker)
                                  FilledButton.tonal(
                                    onPressed: () => _selectCity(city),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: Text(AppStrings.selectBtn),
                                  )
                                else
                                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textMuted),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
