class DriverProfileResponse {
  final String id;
  final String userId;
  final String kycStatus;
  final bool isVerified;
  final bool isOnline;
  final DateTime createdAt;
  final String? rejectionReason;
  final AadhaarKycResponse? aadhaarKyc;

  DriverProfileResponse({
    required this.id,
    required this.userId,
    required this.kycStatus,
    required this.isVerified,
    required this.isOnline,
    required this.createdAt,
    this.rejectionReason,
    this.aadhaarKyc,
  });

  factory DriverProfileResponse.fromJson(Map<String, dynamic> json) {
    return DriverProfileResponse(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      kycStatus: json['kycStatus'] ?? 'Pending',
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      rejectionReason: json['rejectionReason'],
      aadhaarKyc: json['aadhaarKyc'] != null 
          ? AadhaarKycResponse.fromJson(json['aadhaarKyc']) 
          : null,
    );
  }
}

class AadhaarKycResponse {
  final String id;
  final String aadhaarNumber;
  final bool isVerified;

  AadhaarKycResponse({
    required this.id,
    required this.aadhaarNumber,
    required this.isVerified,
  });

  factory AadhaarKycResponse.fromJson(Map<String, dynamic> json) {
    return AadhaarKycResponse(
      id: json['id'] ?? '',
      aadhaarNumber: json['aadhaarNumber'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }
}