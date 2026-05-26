import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chaloji_driver/core/constants/api_constants.dart';
import 'package:chaloji_driver/core/storage/token_storage.dart';

class ProfileService {
  // ── Auth Headers ─────────────────────────────────────
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Generic error handler ─────────────────────────────
  String _parseError(http.Response response) {
    try {
      final json = jsonDecode(response.body);
      return json['message'] ?? 'Something went wrong';
    } catch (_) {
      return 'Server error: ${response.statusCode}';
    }
  }

  // ════════════════════════════════════════════════════
  // 1. GET Profile
  // GET /api/v1/UserProfile/profile
  // ════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> getDriverProfile() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getProfile),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'];
      }
      return null;
    } catch (e) {
      print('getDriverProfile error: $e');
      return null;
    }
  }

  // ════════════════════════════════════════════════════
  // 2. Create Profile
  // POST /api/v1/UserProfile/profile/create
  // ════════════════════════════════════════════════════
  Future<bool> createDriverProfile() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.createProfile),
        headers: await _getHeaders(),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('createDriverProfile error: $e');
      return false;
    }
  }

  // ════════════════════════════════════════════════════
  // 3. GET KYC Status
  // GET /api/v1/UserProfile/kyc-status
  // ════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> getKycStatus() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.kycStatus),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'];
      }
      return null;
    } catch (e) {
      print('getKycStatus error: $e');
      return null;
    }
  }

  // ════════════════════════════════════════════════════
  // 4. Update Aadhaar KYC
  // PUT /api/v1/UserProfile/aadhaar-kyc
  // Body: { aadhaarNumber, aadhaarFrontImageUrl, aadhaarBackImageUrl }
  // ════════════════════════════════════════════════════
  Future<({bool success, String message})> updateAadhaarKyc({
    required String aadhaarNumber,
    String? aadhaarFrontImageUrl,
    String? aadhaarBackImageUrl,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConstants.updateAadhaar),
        headers: await _getHeaders(),
        body: jsonEncode({
          'aadhaarNumber': aadhaarNumber,
          'aadhaarFrontImageUrl': aadhaarFrontImageUrl,
          'aadhaarBackImageUrl': aadhaarBackImageUrl,
        }),
      );
      if (response.statusCode == 200) {
        return (success: true, message: 'Aadhaar updated successfully');
      }
      return (success: false, message: _parseError(response));
    } catch (e) {
      return (success: false, message: 'Network error: $e');
    }
  }

  // ════════════════════════════════════════════════════
  // 5. Verify Aadhaar OTP
  // POST /api/v1/UserProfile/verify-aadhaar-otp
  // Body: { "otpCode": "123456" }
  // ════════════════════════════════════════════════════
  Future<({bool success, String message})> verifyAadhaarOtp({
    required String otpCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyAadhaarOtp),
        headers: await _getHeaders(),
        body: jsonEncode({'otpCode': otpCode}),
      );
      if (response.statusCode == 200) {
        return (success: true, message: 'OTP verified successfully');
      }
      return (success: false, message: _parseError(response));
    } catch (e) {
      return (success: false, message: 'Network error: $e');
    }
  }

  // ════════════════════════════════════════════════════
  // 6. Update PAN Card
  // PUT /api/v1/UserProfile/pan-card
  // Body: { panNumber, panImageUrl, nameOnPan, dateOfBirth }
  // ════════════════════════════════════════════════════
  Future<({bool success, String message})> updatePanCard({
    required String panNumber,
    required String nameOnPan,
    required DateTime dateOfBirth,
    String? panImageUrl,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConstants.updatePan),
        headers: await _getHeaders(),
        body: jsonEncode({
          'panNumber': panNumber,
          'nameOnPan': nameOnPan,
          'dateOfBirth': dateOfBirth.toIso8601String(),
          'panImageUrl': panImageUrl,
        }),
      );
      if (response.statusCode == 200) {
        return (success: true, message: 'PAN Card updated successfully');
      }
      return (success: false, message: _parseError(response));
    } catch (e) {
      return (success: false, message: 'Network error: $e');
    }
  }

  // ════════════════════════════════════════════════════
  // 7. Update Vehicle Details
  // PUT /api/v1/UserProfile/vehicle-details
  // ════════════════════════════════════════════════════
  Future<({bool success, String message})> updateVehicleDetails({
    required String vehicleNumber,
    required int vehicleType, // Auto=0, Bike=1, Car=2, Van=3
    required String vehicleName,
    String? vehicleModel,
    String? vehicleColor,
    String? rcNumber,
    DateTime? rcExpiryDate,
    String? rcImageUrl,
    required String insurancePolicyNumber,
    String? insuranceCompanyName,
    DateTime? insuranceExpiryDate,
    String? insuranceImageUrl,
    String? fitnessCertificateNumber,
    DateTime? fitnessExpiryDate,
    String? permitNumber,
    DateTime? permitExpiryDate,
    String? vehicleFrontImageUrl,
    String? vehicleSideImageUrl,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConstants.updateVehicle),
        headers: await _getHeaders(),
        body: jsonEncode({
          'vehicleNumber': vehicleNumber,
          'vehicleType': vehicleType,
          'vehicleName': vehicleName,
          'vehicleModel': vehicleModel,
          'vehicleColor': vehicleColor,
          'rcNumber': rcNumber,
          'rcExpiryDate': rcExpiryDate?.toIso8601String(),
          'rcImageUrl': rcImageUrl,
          'insurancePolicyNumber': insurancePolicyNumber,
          'insuranceCompanyName': insuranceCompanyName,
          'insuranceExpiryDate': insuranceExpiryDate?.toIso8601String(),
          'insuranceImageUrl': insuranceImageUrl,
          'fitnessCertificateNumber': fitnessCertificateNumber,
          'fitnessExpiryDate': fitnessExpiryDate?.toIso8601String(),
          'permitNumber': permitNumber,
          'permitExpiryDate': permitExpiryDate?.toIso8601String(),
          'vehicleFrontImageUrl': vehicleFrontImageUrl,
          'vehicleSideImageUrl': vehicleSideImageUrl,
        }),
      );
      if (response.statusCode == 200) {
        return (success: true, message: 'Vehicle details updated successfully');
      }
      return (success: false, message: _parseError(response));
    } catch (e) {
      return (success: false, message: 'Network error: $e');
    }
  }

  // ════════════════════════════════════════════════════
  // 8. Update Driver License
  // PUT /api/v1/UserProfile/driver-license
  // ════════════════════════════════════════════════════
  Future<({bool success, String message})> updateDriverLicense({
    required String licenseNumber,
    String? licenseClass,
    DateTime? issueDate,
    required DateTime expiryDate,
    String? issuingAuthority,
    String? licenseFrontImageUrl,
    String? licenseBackImageUrl,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConstants.updateLicense),
        headers: await _getHeaders(),
        body: jsonEncode({
          'licenseNumber': licenseNumber,
          'licenseClass': licenseClass,
          'issueDate': issueDate?.toIso8601String(),
          'expiryDate': expiryDate.toIso8601String(),
          'issuingAuthority': issuingAuthority,
          'licenseFrontImageUrl': licenseFrontImageUrl,
          'licenseBackImageUrl': licenseBackImageUrl,
        }),
      );
      if (response.statusCode == 200) {
        return (success: true, message: 'Driver license updated successfully');
      }
      return (success: false, message: _parseError(response));
    } catch (e) {
      return (success: false, message: 'Network error: $e');
    }
  }

  // ════════════════════════════════════════════════════
  // 9. Submit for Verification
  // POST /api/v1/UserProfile/submit-for-verification
  // ════════════════════════════════════════════════════
  Future<({bool success, String message})> submitForVerification() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.submitForVerification),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return (success: true, message: 'Submitted for verification!');
      }
      return (success: false, message: _parseError(response));
    } catch (e) {
      return (success: false, message: 'Network error: $e');
    }
  }
}