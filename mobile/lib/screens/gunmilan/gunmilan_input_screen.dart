import 'package:material_ui/material_ui.dart';
import '../../models/astrology_models.dart';
import '../../services/api/gunmilan_api.dart';
import '../../services/localization_service.dart';
import '../../theme/app_theme.dart';
import '../cities/city_search_screen.dart';
import 'gunmilan_result_screen.dart';

class GunMilanInputScreen extends StatefulWidget {
  const GunMilanInputScreen({super.key});

  @override
  State<GunMilanInputScreen> createState() => _GunMilanInputScreenState();
}

class _GunMilanInputScreenState extends State<GunMilanInputScreen> {
  final _formKey = GlobalKey<FormState>();

  // Boy form controllers
  final _boyNameController = TextEditingController();
  final _boyDateController = TextEditingController();
  final _boyTimeController = TextEditingController();
  final _boyPlaceController = TextEditingController();
  final _boyLatController = TextEditingController();
  final _boyLngController = TextEditingController();

  // Girl form controllers
  final _girlNameController = TextEditingController();
  final _girlDateController = TextEditingController();
  final _girlTimeController = TextEditingController();
  final _girlPlaceController = TextEditingController();
  final _girlLatController = TextEditingController();
  final _girlLngController = TextEditingController();

  String _selectedAyanamsha = 'lahiri';
  bool _isLoading = false;

  @override
  void dispose() {
    _boyNameController.dispose();
    _boyDateController.dispose();
    _boyTimeController.dispose();
    _boyPlaceController.dispose();
    _boyLatController.dispose();
    _boyLngController.dispose();

    _girlNameController.dispose();
    _girlDateController.dispose();
    _girlTimeController.dispose();
    _girlPlaceController.dispose();
    _girlLatController.dispose();
    _girlLngController.dispose();
    super.dispose();
  }

  void _fillSamplePair() {
    final isEnglish = LocalizationService.isEnglish(context);
    setState(() {
      _boyNameController.text = isEnglish ? 'Aniket Joshi' : 'अनिकेत जोशी';
      _boyDateController.text = '06-09-2000';
      _boyTimeController.text = '19:30:00';
      _boyPlaceController.text = 'Shirpur, Maharashtra';
      _boyLatController.text = '21.35';
      _boyLngController.text = '74.88';

      _girlNameController.text = isEnglish ? 'Priya Kulkarni' : 'प्रिया कुलकर्णी';
      _girlDateController.text = '12-10-2001';
      _girlTimeController.text = '10:15:00';
      _girlPlaceController.text = 'Pune, Maharashtra';
      _girlLatController.text = '18.52';
      _girlLngController.text = '73.85';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.samplePairLoaded)),
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final d = picked.day.toString().padLeft(2, '0');
      final m = picked.month.toString().padLeft(2, '0');
      controller.text = '$d-$m-${picked.year}';
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      controller.text = '$h:$m:00';
    }
  }

  Future<void> _selectCity(
    TextEditingController placeCtrl,
    TextEditingController latCtrl,
    TextEditingController lngCtrl,
  ) async {
    final CityItem? selected = await CitySearchScreen.pickCity(context);
    if (selected != null) {
      setState(() {
        placeCtrl.text = selected.display;
        latCtrl.text = selected.lat.toString();
        lngCtrl.text = selected.lng.toString();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final boyLat = double.parse(_boyLatController.text.trim());
      final boyLng = double.parse(_boyLngController.text.trim());
      final girlLat = double.parse(_girlLatController.text.trim());
      final girlLng = double.parse(_girlLngController.text.trim());

      final gunMilan = await GunMilanApi.calculateGunMilan(
        boy: {
          'name': _boyNameController.text.trim(),
          'date': _boyDateController.text.trim(),
          'time': _boyTimeController.text.trim(),
          'lat': boyLat,
          'lng': boyLng,
          'place': _boyPlaceController.text.trim(),
        },
        girl: {
          'name': _girlNameController.text.trim(),
          'date': _girlDateController.text.trim(),
          'time': _girlTimeController.text.trim(),
          'lat': girlLat,
          'lng': girlLng,
          'place': _girlPlaceController.text.trim(),
        },
        ayanamsha: _selectedAyanamsha,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GunMilanResultScreen(data: gunMilan),
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
              Text(AppStrings.gunMilanErrorTitle),
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
        title: Text(AppStrings.gunMilanTitle),
        actions: [
          TextButton.icon(
            onPressed: _fillSamplePair,
            icon: const Icon(Icons.auto_fix_high, size: 18, color: AppTheme.primarySaffron),
            label: Text(
              AppStrings.samplePair,
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
              // BOY'S PROFILE
              _buildPersonCard(
                title: AppStrings.boyBirthDetails,
                headerColor: const Color(0xFF1A365D),
                nameCtrl: _boyNameController,
                dateCtrl: _boyDateController,
                timeCtrl: _boyTimeController,
                placeCtrl: _boyPlaceController,
                latCtrl: _boyLatController,
                lngCtrl: _boyLngController,
              ),
              const SizedBox(height: 16),

              // GIRL'S PROFILE
              _buildPersonCard(
                title: AppStrings.girlBirthDetails,
                headerColor: const Color(0xFF701A45),
                nameCtrl: _girlNameController,
                dateCtrl: _girlDateController,
                timeCtrl: _girlTimeController,
                placeCtrl: _girlPlaceController,
                latCtrl: _girlLatController,
                lngCtrl: _girlLngController,
              ),
              const SizedBox(height: 16),

              // Ayanamsha selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedAyanamsha,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: AppStrings.ayanamshaSystem,
                      prefixIcon: const Icon(Icons.brightness_auto_outlined),
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
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.favorite_outline),
                label: Text(_isLoading ? AppStrings.checkingCompatibility : AppStrings.checkCompatibility),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonCard({
    required String title,
    required Color headerColor,
    required TextEditingController nameCtrl,
    required TextEditingController dateCtrl,
    required TextEditingController timeCtrl,
    required TextEditingController placeCtrl,
    required TextEditingController latCtrl,
    required TextEditingController lngCtrl,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 6,
                  backgroundColor: headerColor,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: headerColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: AppStrings.fullNameLabel,
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: dateCtrl,
                    readOnly: true,
                    onTap: () => _pickDate(dateCtrl),
                    decoration: InputDecoration(
                      labelText: AppStrings.birthDate,
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                    validator: (v) => v == null || v.isEmpty ? AppStrings.requiredField : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: timeCtrl,
                    readOnly: true,
                    onTap: () => _pickTime(timeCtrl),
                    decoration: InputDecoration(
                      labelText: AppStrings.birthTime,
                      prefixIcon: const Icon(Icons.access_time_outlined),
                    ),
                    validator: (v) => v == null || v.isEmpty ? AppStrings.requiredField : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: placeCtrl,
              readOnly: true,
              onTap: () => _selectCity(placeCtrl, latCtrl, lngCtrl),
              decoration: InputDecoration(
                labelText: AppStrings.birthPlace,
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: const Icon(Icons.search, color: AppTheme.primarySaffron),
              ),
              validator: (v) => v == null || v.isEmpty ? AppStrings.requiredField : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: latCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: AppStrings.latitude),
                    validator: (v) => v == null || v.isEmpty ? AppStrings.requiredField : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: lngCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: AppStrings.longitude),
                    validator: (v) => v == null || v.isEmpty ? AppStrings.requiredField : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
