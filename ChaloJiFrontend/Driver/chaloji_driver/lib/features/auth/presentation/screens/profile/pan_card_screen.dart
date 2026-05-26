import 'package:flutter/material.dart';
import 'package:chaloji_driver/core/theme/app_theme.dart';

class PanCardScreen extends StatefulWidget {
  const PanCardScreen({super.key});

  @override
  State<PanCardScreen> createState() => _PanCardScreenState();
}

class _PanCardScreenState extends State<PanCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _panImageUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _panController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.accentColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  // Backend: PUT /api/v1/UserProfile/pan-card
  // Body: { panNumber, panImageUrl, nameOnPan, dateOfBirth }
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      _showSnackBar('Please select date of birth', isError: true);
      return;
    }
    setState(() => _isLoading = true);

    // TODO: API call
    // await profileService.updatePanCard(
    //   panNumber: _panController.text,
    //   nameOnPan: _nameController.text,
    //   dateOfBirth: _dateOfBirth,
    //   panImageUrl: _panImageUrl,
    // );

    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    _showSnackBar('PAN Card details saved!');
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
        title: const Text('PAN Card Details',
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
              // PAN Number
              _buildLabel('PAN Card Number'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _panController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 10,
                style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2),
                decoration: _inputDecoration(
                    'ABCDE1234F', Icons.badge_rounded,
                    counterText: ''),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'PAN number is required';
                  if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(v)) {
                    return 'Invalid PAN format. Example: ABCDE1234F';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Name on PAN
              _buildLabel('Name on PAN Card'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: AppTheme.primaryColor),
                decoration: _inputDecoration(
                    'As printed on PAN card', Icons.person_outline_rounded),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
                  if (v.trim().length < 3) return 'Enter valid name';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date of Birth
              _buildLabel('Date of Birth'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppTheme.textMutedColor, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _dateOfBirth != null
                            ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                            : 'Select date of birth',
                        style: TextStyle(
                          color: _dateOfBirth != null
                              ? AppTheme.primaryColor
                              : AppTheme.textMutedColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // PAN Image Upload
              _buildLabel('PAN Card Photo'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // TODO: image_picker se upload
                },
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _panImageUrl != null
                          ? AppTheme.accentColor.withOpacity(0.5)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _panImageUrl != null
                            ? Icons.check_circle_rounded
                            : Icons.cloud_upload_outlined,
                        color: _panImageUrl != null
                            ? AppTheme.accentColor
                            : AppTheme.textMutedColor,
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _panImageUrl != null
                            ? 'Image uploaded ✓'
                            : 'Tap to upload PAN card photo',
                        style: TextStyle(
                          fontSize: 13,
                          color: _panImageUrl != null
                              ? AppTheme.accentColor
                              : AppTheme.textMutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
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
                      : const Text('Submit PAN Details',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor));
  }

  InputDecoration _inputDecoration(String hint, IconData icon,
      {String? counterText}) {
    return InputDecoration(
      hintText: hint,
      counterText: counterText,
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
        borderSide:
            const BorderSide(color: AppTheme.accentColor, width: 2),
      ),
    );
  }
}