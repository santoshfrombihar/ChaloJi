import 'package:flutter/material.dart';
import 'package:chaloji_driver/core/theme/app_theme.dart';
import 'package:chaloji_driver/features/auth/data/services/profile_service.dart';

class AadhaarKycScreen extends StatefulWidget {
  const AadhaarKycScreen({super.key});

  @override
  State<AadhaarKycScreen> createState() => _AadhaarKycScreenState();
}

class _AadhaarKycScreenState extends State<AadhaarKycScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aadhaarController = TextEditingController();
  final _otpController = TextEditingController();
  final _profileService = ProfileService();

  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _frontImageUrl;
  String? _backImageUrl;

  @override
  void dispose() {
    _aadhaarController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ── Step 1: Save Aadhaar + Send OTP ──────────────────
  // PUT /api/v1/UserProfile/aadhaar-kyc
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _profileService.updateAadhaarKyc(
      aadhaarNumber: _aadhaarController.text.trim(),
      aadhaarFrontImageUrl: _frontImageUrl,
      aadhaarBackImageUrl: _backImageUrl,
    );

    setState(() => _isLoading = false);

    if (result.success) {
      setState(() => _isOtpSent = true);
      _showSnackBar('OTP sent to Aadhaar linked mobile number');
    } else {
      _showSnackBar(result.message, isError: true);
    }
  }

  // ── Step 2: Verify OTP ────────────────────────────────
  // POST /api/v1/UserProfile/verify-aadhaar-otp
  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      _showSnackBar('Please enter valid 6-digit OTP', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final result = await _profileService.verifyAadhaarOtp(
      otpCode: _otpController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result.success) {
      _showSnackBar('Aadhaar verified successfully!');
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context, true); // true = verified
    } else {
      _showSnackBar(result.message, isError: true);
    }
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Aadhaar KYC',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoBanner(
                'Your Aadhaar is encrypted and never shared with third parties.',
                Icons.security_rounded,
              ),
              const SizedBox(height: 24),

              // Step 1
              _buildStepTitle('Step 1', 'Enter Aadhaar Number'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _aadhaarController,
                keyboardType: TextInputType.number,
                maxLength: 12,
                enabled: !_isOtpSent,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
                decoration: _inputDeco(
                  'XXXX XXXX XXXX',
                  Icons.fingerprint_rounded,
                  counterText: '',
                ),
                validator: (v) {
                  if (v == null || v.trim().length != 12) {
                    return 'Enter valid 12-digit Aadhaar number';
                  }
                  if (!RegExp(r'^\d{12}$').hasMatch(v.trim())) {
                    return 'Only numbers allowed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Step 2 — Images
              _buildStepTitle('Step 2', 'Upload Aadhaar Images'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildImageCard(
                      label: 'Front Side',
                      icon: Icons.credit_card_rounded,
                      imageUrl: _frontImageUrl,
                      onTap: () {
                        // TODO: image_picker connect karenge
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildImageCard(
                      label: 'Back Side',
                      icon: Icons.flip_rounded,
                      imageUrl: _backImageUrl,
                      onTap: () {
                        // TODO: image_picker connect karenge
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Step 3 — OTP (sirf tab dikhao jab OTP send ho gaya ho)
              if (_isOtpSent) ...[
                _buildStepTitle('Step 3', 'Enter OTP'),
                const SizedBox(height: 12),
                _buildInfoBanner(
                  'OTP sent to mobile number linked with your Aadhaar.',
                  Icons.phone_android_rounded,
                  color: const Color(0xFF3B82F6),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 4,
                    fontSize: 18,
                  ),
                  decoration: _inputDeco(
                    '_ _ _ _ _ _',
                    Icons.lock_outline_rounded,
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.length != 6) {
                      return 'Enter valid 6-digit OTP';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(color: AppTheme.accentColor),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_isOtpSent ? _verifyOtp : _sendOtp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isOtpSent
                              ? 'Verify OTP'
                              : 'Send OTP to Aadhaar Mobile',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepTitle(String step, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            step,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.accentColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner(
    String text,
    IconData icon, {
    Color color = const Color(0xFF10B981),
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard({
    required String label,
    required IconData icon,
    required String? imageUrl,
    required VoidCallback onTap,
  }) {
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
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              imageUrl != null ? 'Uploaded ✓' : label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: imageUrl != null
                    ? AppTheme.accentColor
                    : AppTheme.textMutedColor,
              ),
            ),
            if (imageUrl == null)
              const Text(
                'Tap to upload',
                style: TextStyle(fontSize: 10, color: AppTheme.textMutedColor),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(
    String hint,
    IconData icon, {
    String? counterText,
  }) {
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
        borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    );
  }
}
