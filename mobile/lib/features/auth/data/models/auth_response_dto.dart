class AuthResponseDto {
  final int userId;
  final String fullName;
  final String email;
  final String token;
  final String role;
  final bool isSetupCompleted;

  AuthResponseDto({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.token,
    required this.role,
    required this.isSetupCompleted,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      userId: json['userID'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      role: json['role'] ?? '',
      isSetupCompleted: json['isSetupCompleted'] ?? false,
    );
  }
}
