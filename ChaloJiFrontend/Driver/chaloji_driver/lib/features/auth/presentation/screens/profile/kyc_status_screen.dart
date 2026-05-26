import 'package:flutter/material.dart';
import 'package:chaloji_driver/core/theme/app_theme.dart';
import 'aadhaar_kyc_screen.dart';
import 'pan_card_screen.dart';
import 'vehicle_details_screen.dart';
import 'driver_license_screen.dart';

class KycStatusScreen extends StatelessWidget {
  // Yeh data aapko Profile Repository/Provider se milega
  final Map<String, dynamic> kycStatus; 

  const KycStatusScreen({super.key, required this.kycStatus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('KYC Verification', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete Your Profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please upload valid documents to verify your driver account and start receiving ride requests.',
              style: TextStyle(fontSize: 14, color: AppTheme.textMutedColor),
            ),
            const SizedBox(height: 24),

            // 1. Aadhaar Card Row
            _buildDocStatusCard(
              context: context,
              title: 'Aadhaar Verification',
              subtitle: 'Verify using UIDAI OTP',
              isVerified: kycStatus['aadhaarVerified'] ?? false,
              icon: Icons.fingerprint_rounded,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AadhaarKycScreen())),
            ),

            // 2. PAN Card Row
            _buildDocStatusCard(
              context: context,
              title: 'PAN Card Details',
              subtitle: '10-digit Alphanumeric PAN verification',
              isVerified: kycStatus['panVerified'] ?? false,
              icon: Icons.credit_card_rounded,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PanCardScreen())),
            ),

            // 3. Vehicle Details Row
            _buildDocStatusCard(
              context: context,
              title: 'Vehicle Information',
              subtitle: 'RC, Insurance & Permit details',
              isVerified: kycStatus['vehicleVerified'] ?? false,
              icon: Icons.directions_car_rounded,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleDetailsScreen())),
            ),

            // 4. Driver License Row
            _buildDocStatusCard(
              context: context,
              title: 'Driving License',
              subtitle: 'Upload valid DL front & back copy',
              isVerified: kycStatus['licenseVerified'] ?? false,
              icon: Icons.badge_rounded,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DriverLicenseScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocStatusCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isVerified,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: isVerified ? null : onTap, // Verified hone ke baad edit lock kar sakte hain
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isVerified ? const Color(0xFF10B981).withOpacity(0.1) : AppTheme.primaryColor.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isVerified ? const Color(0xFF10B981) : AppTheme.primaryColor, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.primaryColor)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMutedColor)),
        trailing: isVerified
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Verified', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
                ],
              )
            : const Icon(Icons.chevron_right_rounded, color: AppTheme.textMutedColor),
      ),
    );
  }
}