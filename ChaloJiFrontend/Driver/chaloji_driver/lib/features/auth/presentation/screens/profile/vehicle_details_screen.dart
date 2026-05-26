import 'package:flutter/material.dart';
import 'package:chaloji_driver/core/theme/app_theme.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  final _vehicleNameController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _rcNumberController = TextEditingController();
  final _insurancePolicyController = TextEditingController();
  final _insuranceCompanyController = TextEditingController();
  final _fitnessCertController = TextEditingController();
  final _permitNumberController = TextEditingController();

  String _selectedVehicleType = 'Auto';
  DateTime? _rcExpiryDate;
  DateTime? _insuranceExpiryDate;
  DateTime? _fitnessExpiryDate;
  DateTime? _permitExpiryDate;
  bool _isLoading = false;

  // Image placeholders
  String? _rcImageUrl;
  String? _insuranceImageUrl;
  String? _vehicleFrontImageUrl;
  String? _vehicleSideImageUrl;

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _vehicleNameController.dispose();
    _vehicleModelController.dispose();
    _vehicleColorController.dispose();
    _rcNumberController.dispose();
    _insurancePolicyController.dispose();
    _insuranceCompanyController.dispose();
    _fitnessCertController.dispose();
    _permitNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(Function(DateTime) onSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.accentColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => onSelected(picked));
  }

  // Backend: PUT /api/v1/UserProfile/vehicle-details
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // TODO: API call
    // await profileService.updateVehicleDetail(
    //   vehicleNumber: _vehicleNumberController.text,
    //   vehicleType: _selectedVehicleType == 'Auto' ? 0 : _selectedVehicleType == 'Bike' ? 1 : 2,
    //   vehicleName: _vehicleNameController.text,
    //   vehicleModel: _vehicleModelController.text,
    //   vehicleColor: _vehicleColorController.text,
    //   rcNumber: _rcNumberController.text,
    //   rcExpiryDate: _rcExpiryDate,
    //   insurancePolicyNumber: _insurancePolicyController.text,
    //   insuranceCompanyName: _insuranceCompanyController.text,
    //   insuranceExpiryDate: _insuranceExpiryDate,
    //   ...
    // );

    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    _showSnackBar('Vehicle details saved successfully!');
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) Navigator.pop(context);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Vehicle Details',
            style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Basic Info ──────────────────────────
              _sectionHeader('Basic Information', Icons.directions_car_rounded),
              const SizedBox(height: 12),

              // Vehicle Type
              _buildLabel('Vehicle Type'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                decoration: _inputDecoration('Select type', Icons.category_outlined),
                items: ['Auto', 'Bike', 'Car', 'Van']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedVehicleType = v!),
              ),
              const SizedBox(height: 16),

              _buildTextField(_vehicleNumberController, 'Vehicle Number',
                  'BR01AB1234', Icons.pin_outlined,
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Vehicle number required' : null),
              const SizedBox(height: 16),

              _buildTextField(_vehicleNameController, 'Vehicle Name',
                  'Bajaj RE / Piaggio Ape', Icons.directions_car_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Vehicle name required' : null),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_vehicleModelController,
                        'Model Year', '2022', Icons.calendar_today_outlined,
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(_vehicleColorController,
                        'Color', 'Yellow', Icons.color_lens_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── RC Details ──────────────────────────
              _sectionHeader('RC Certificate', Icons.article_rounded),
              const SizedBox(height: 12),

              _buildTextField(_rcNumberController, 'RC Number',
                  'Registration number', Icons.numbers_rounded),
              const SizedBox(height: 12),
              _buildDatePicker('RC Expiry Date', _rcExpiryDate,
                  () => _selectDate((d) => _rcExpiryDate = d)),
              const SizedBox(height: 12),
              _buildImageUpload('RC Certificate Photo', _rcImageUrl, () {}),
              const SizedBox(height: 24),

              // ── Insurance ───────────────────────────
              _sectionHeader('Insurance', Icons.health_and_safety_rounded),
              const SizedBox(height: 12),

              _buildTextField(_insurancePolicyController, 'Policy Number',
                  'Insurance policy number', Icons.policy_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Policy number required' : null),
              const SizedBox(height: 12),
              _buildTextField(_insuranceCompanyController, 'Insurance Company',
                  'e.g., New India Assurance', Icons.business_outlined),
              const SizedBox(height: 12),
              _buildDatePicker('Insurance Expiry Date', _insuranceExpiryDate,
                  () => _selectDate((d) => _insuranceExpiryDate = d)),
              const SizedBox(height: 12),
              _buildImageUpload(
                  'Insurance Document Photo', _insuranceImageUrl, () {}),
              const SizedBox(height: 24),

              // ── Fitness ─────────────────────────────
              _sectionHeader('Fitness Certificate', Icons.verified_rounded),
              const SizedBox(height: 12),

              _buildTextField(_fitnessCertController, 'Fitness Certificate No.',
                  'Certificate number', Icons.numbers_rounded),
              const SizedBox(height: 12),
              _buildDatePicker('Fitness Expiry Date', _fitnessExpiryDate,
                  () => _selectDate((d) => _fitnessExpiryDate = d)),
              const SizedBox(height: 24),

              // ── Permit ──────────────────────────────
              _sectionHeader('Permit', Icons.approval_rounded),
              const SizedBox(height: 12),

              _buildTextField(_permitNumberController, 'Permit Number',
                  'Permit number', Icons.numbers_rounded),
              const SizedBox(height: 12),
              _buildDatePicker('Permit Expiry Date', _permitExpiryDate,
                  () => _selectDate((d) => _permitExpiryDate = d)),
              const SizedBox(height: 24),

              // ── Vehicle Photos ──────────────────────
              _sectionHeader('Vehicle Photos', Icons.photo_camera_rounded),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildImageUploadCard(
                        'Front View', _vehicleFrontImageUrl, () {}),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildImageUploadCard(
                        'Side View', _vehicleSideImageUrl, () {}),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Save Vehicle Details',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentColor, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor)),
      ],
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor)),
      );

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      style: const TextStyle(color: AppTheme.primaryColor),
      decoration: _inputDecoration(hint, icon, label: label),
    );
  }

  Widget _buildDatePicker(
      String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: AppTheme.textMutedColor, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null
                    ? '$label: ${date.day}/${date.month}/${date.year}'
                    : label,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      date != null ? AppTheme.primaryColor : AppTheme.textMutedColor,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textMutedColor, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUpload(
      String label, String? imageUrl, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: imageUrl != null
                ? AppTheme.accentColor.withOpacity(0.4)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(
              imageUrl != null
                  ? Icons.check_circle_rounded
                  : Icons.upload_file_rounded,
              color: imageUrl != null
                  ? AppTheme.accentColor
                  : AppTheme.textMutedColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              imageUrl != null ? '$label uploaded ✓' : 'Upload $label',
              style: TextStyle(
                fontSize: 13,
                color: imageUrl != null
                    ? AppTheme.accentColor
                    : AppTheme.textMutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadCard(
      String label, String? imageUrl, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: imageUrl != null
                ? AppTheme.accentColor.withOpacity(0.4)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              imageUrl != null
                  ? Icons.check_circle_rounded
                  : Icons.photo_camera_outlined,
              color: imageUrl != null
                  ? AppTheme.accentColor
                  : AppTheme.textMutedColor,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              imageUrl != null ? 'Uploaded ✓' : label,
              style: TextStyle(
                fontSize: 12,
                color: imageUrl != null
                    ? AppTheme.accentColor
                    : AppTheme.textMutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, {String? label}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppTheme.textMutedColor, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
      ),
    );
  }
}