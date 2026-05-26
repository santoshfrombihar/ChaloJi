import 'package:flutter/material.dart';
import 'package:chaloji_driver/core/theme/app_theme.dart';

class DriverLicenseScreen extends StatefulWidget {
  const DriverLicenseScreen({super.key});

  @override
  State<DriverLicenseScreen> createState() => _DriverLicenseScreenState();
}

class _DriverLicenseScreenState extends State<DriverLicenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licenseNumberController = TextEditingController();
  final _issuingAuthorityController = TextEditingController();

  String _selectedLicenseClass = 'LMV';
  DateTime? _issueDate;
  DateTime? _expiryDate;
  String? _frontImageUrl;
  String? _backImageUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _licenseNumberController.dispose();
    _issuingAuthorityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      {required bool isPast, required Function(DateTime) onSelected}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isPast ? now.subtract(const Duration(days: 365)) : now.add(const Duration(days: 365)),
      firstDate: isPast ? DateTime(2000) : now,
      lastDate: isPast ? now : DateTime(2040),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.accentColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => onSelected(picked));
  }

  // Backend: PUT /api/v1/UserProfile/driver-license
  // Body: { licenseNumber, licenseClass, issueDate, expiryDate, issuingAuthority, licenseFrontImageUrl, licenseBackImageUrl }
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_expiryDate == null) {
      _showSnackBar('Please select license expiry date', isError: true);
      return;
    }
    setState(() => _isLoading = true);

    // TODO: API call
    // await profileService.updateDriverLicense(
    //   licenseNumber: _licenseNumberController.text,
    //   licenseClass: _selectedLicenseClass,
    //   issueDate: _issueDate,
    //   expiryDate: _expiryDate!,
    //   issuingAuthority: _issuingAuthorityController.text,
    //   licenseFrontImageUrl: _frontImageUrl,
    //   licenseBackImageUrl: _backImageUrl,
    // );

    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    _showSnackBar('Driving license saved successfully!');
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
        title: const Text('Driving License',
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
              // License Number
              _buildLabel('License Number'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _licenseNumberController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5),
                decoration: _inputDeco(
                    'BR0120230012345', Icons.badge_rounded),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'License number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // License Class
              _buildLabel('License Class'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLicenseClass,
                decoration:
                    _inputDeco('Select class', Icons.category_outlined),
                items: ['LMV', 'MCWG', 'Transport', 'LMV-TR', 'HMV']
                    .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c,
                            style: const TextStyle(
                                color: AppTheme.primaryColor))))
                    .toList(),
                onChanged: (v) => setState(() => _selectedLicenseClass = v!),
              ),
              const SizedBox(height: 16),

              // Issue Date
              _buildLabel('Issue Date'),
              const SizedBox(height: 8),
              _buildDatePicker(
                label: _issueDate != null
                    ? '${_issueDate!.day}/${_issueDate!.month}/${_issueDate!.year}'
                    : 'Select issue date',
                onTap: () => _selectDate(
                    isPast: true, onSelected: (d) => _issueDate = d),
              ),
              const SizedBox(height: 16),

              // Expiry Date
              _buildLabel('Expiry Date *'),
              const SizedBox(height: 8),
              _buildDatePicker(
                label: _expiryDate != null
                    ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                    : 'Select expiry date',
                onTap: () => _selectDate(
                    isPast: false, onSelected: (d) => _expiryDate = d),
                isRequired: true,
              ),
              const SizedBox(height: 16),

              // Issuing Authority
              _buildLabel('Issuing Authority (RTO)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _issuingAuthorityController,
                style: const TextStyle(color: AppTheme.primaryColor),
                decoration: _inputDeco(
                    'e.g., RTO Muzaffarpur', Icons.account_balance_outlined),
              ),
              const SizedBox(height: 24),

              // Upload images
              _buildLabel('License Photos'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildImageCard(
                      'Front Side',
                      Icons.credit_card_rounded,
                      _frontImageUrl,
                      () {
                        // TODO: image_picker
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildImageCard(
                      'Back Side',
                      Icons.flip_rounded,
                      _backImageUrl,
                      () {
                        // TODO: image_picker
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit button
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
                      : const Text('Submit License Details',
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

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor)),
      );

  Widget _buildDatePicker(
      {required String label,
      required VoidCallback onTap,
      bool isRequired = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isRequired && _expiryDate == null
                  ? Colors.transparent
                  : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: AppTheme.textMutedColor, size: 18),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textMutedColor)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textMutedColor, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(
      String label, IconData icon, String? imageUrl, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: imageUrl != null
                ? AppTheme.accentColor.withOpacity(0.5)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              imageUrl != null ? Icons.check_circle_rounded : icon,
              color: imageUrl != null
                  ? AppTheme.accentColor
                  : AppTheme.textMutedColor,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              imageUrl != null ? 'Uploaded ✓' : label,
              style: TextStyle(
                  fontSize: 12,
                  color: imageUrl != null
                      ? AppTheme.accentColor
                      : AppTheme.textMutedColor),
            ),
            if (imageUrl == null)
              const Text('Tap to upload',
                  style: TextStyle(
                      fontSize: 10, color: AppTheme.textMutedColor)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
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