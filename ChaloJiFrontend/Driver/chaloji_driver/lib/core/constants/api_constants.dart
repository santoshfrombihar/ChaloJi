class ApiConstants {
  static const String baseUrl = 'https://localhost:7127/api/v1';

  // ── Auth ─────────────────────────────────────────────
  static const String login    = '$baseUrl/Auth/login';
  static const String register = '$baseUrl/Auth/register';

  // ── Profile ──────────────────────────────────────────
  static const String getProfile    = '$baseUrl/UserProfile/profile';
  static const String createProfile = '$baseUrl/UserProfile/profile/create';
  static const String kycStatus     = '$baseUrl/UserProfile/kyc-status';

  // ── KYC ──────────────────────────────────────────────
  static const String updateAadhaar       = '$baseUrl/UserProfile/aadhaar-kyc';
  static const String verifyAadhaarOtp    = '$baseUrl/UserProfile/verify-aadhaar-otp';
  static const String updatePan           = '$baseUrl/UserProfile/pan-card';
  static const String updateVehicle       = '$baseUrl/UserProfile/vehicle-details';
  static const String updateLicense       = '$baseUrl/UserProfile/driver-license';
  static const String submitForVerification = '$baseUrl/UserProfile/submit-for-verification';
}