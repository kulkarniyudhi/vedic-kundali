import 'package:material_ui/material_ui.dart';
import '../../models/astrology_models.dart';
import '../../services/api/kundali_api.dart';
import '../../services/localization_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_card.dart';
import '../cities/city_search_screen.dart';
import 'experiment_result_router.dart';

class KundaliInputScreen extends StatefulWidget {
  const KundaliInputScreen({super.key});

  @override
  State<KundaliInputScreen> createState() => _KundaliInputScreenState();
}

class _KundaliInputScreenState extends State<KundaliInputScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _placeController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  String _selectedAyanamsha = 'lahiri';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _placeController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _fillSample() {
    setState(() {
      _nameController.text = 'अनिकेत जोशी';
      _dateController.text = '06-09-2000';
      _timeController.text = '19:30:00';
      _placeController.text = 'Shirpur, Dhule, Maharashtra';
      _latController.text = '21.35';
      _lngController.text = '74.88';
      _selectedAyanamsha = 'lahiri';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('नमुना जन्म तपशील भरले आहेत'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 9, 6),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primarySaffron,
              onPrimary: Colors.white,
              onSurface: AppTheme.darkWood,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();
      setState(() {
        _dateController.text = '$day-$month-$year';
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 30),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primarySaffron,
              onPrimary: Colors.white,
              onSurface: AppTheme.darkWood,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final min = picked.minute.toString().padLeft(2, '0');
      setState(() {
        _timeController.text = '$hour:$min:00';
      });
    }
  }

  Future<void> _selectCity() async {
    final CityItem? selected = await CitySearchScreen.pickCity(context);
    if (selected != null) {
      setState(() {
        _placeController.text = selected.display;
        _latController.text = selected.lat.toString();
        _lngController.text = selected.lng.toString();
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final double lat = double.parse(_latController.text.trim());
      final double lng = double.parse(_lngController.text.trim());

      final kundali = await KundaliApi.calculateKundali(
        name: _nameController.text.trim(),
        date: _dateController.text.trim(),
        time: _timeController.text.trim(),
        lat: lat,
        lng: lng,
        place: _placeController.text.trim(),
        ayanamsha: _selectedAyanamsha,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExperimentResultRouter(kundali: kundali),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: AppTheme.dangerRed),
              const SizedBox(width: 8),
              Text(AppStrings.error),
            ],
          ),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppStrings.ok),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.kundaliInputTitle),
        actions: [
          TextButton.icon(
            onPressed: _fillSample,
            icon: const Icon(Icons.auto_fix_high, size: 18, color: AppTheme.primarySaffron),
            label: Text(
              AppStrings.sampleButton,
              style: const TextStyle(color: AppTheme.primarySaffron, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VedicSectionHeader(
                        title: AppStrings.birthDetailsSection,
                        subtitle: AppStrings.birthDetailsSubtitle,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: AppStrings.personName,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              onTap: _selectDate,
                              decoration: InputDecoration(
                                labelText: AppStrings.birthDate,
                                hintText: 'DD-MM-YYYY',
                                prefixIcon: const Icon(Icons.calendar_today_outlined),
                              ),
                              validator: (val) => val == null || val.isEmpty ? AppStrings.requiredField : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _timeController,
                              readOnly: true,
                              onTap: _selectTime,
                              decoration: InputDecoration(
                                labelText: AppStrings.birthTime,
                                hintText: 'HH:MM:SS',
                                prefixIcon: const Icon(Icons.access_time_outlined),
                              ),
                              validator: (val) => val == null || val.isEmpty ? AppStrings.requiredField : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _placeController,
                        readOnly: true,
                        onTap: _selectCity,
                        decoration: InputDecoration(
                          labelText: AppStrings.birthPlace,
                          prefixIcon: const Icon(Icons.location_city_outlined),
                          suffixIcon: const Icon(Icons.search, color: AppTheme.primarySaffron),
                        ),
                        validator: (val) => val == null || val.isEmpty ? AppStrings.requiredField : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: AppStrings.latitude,
                                prefixIcon: const Icon(Icons.explore_outlined),
                              ),
                              validator: (val) => val == null || val.isEmpty ? AppStrings.requiredField : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lngController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: AppStrings.longitude,
                                prefixIcon: const Icon(Icons.explore_outlined),
                              ),
                              validator: (val) => val == null || val.isEmpty ? AppStrings.requiredField : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAyanamsha,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: AppStrings.ayanamshaSystem,
                          prefixIcon: const Icon(Icons.brightness_medium_outlined),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'lahiri',
                            child: Text(
                              AppStrings.lahiriAyanamsha,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'kp',
                            child: Text(
                              AppStrings.kpAyanamsha,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedAyanamsha = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isLoading ? AppStrings.calculating : AppStrings.calculateKundali),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
