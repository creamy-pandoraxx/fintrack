class AppUser {
  const AppUser({
    required this.id,
    required this.firebaseUid,
    required this.email,
    this.name,
    this.photoUrl,
  });

  final String id;
  final String firebaseUid;
  final String email;
  final String? name;
  final String? photoUrl;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      firebaseUid: json['firebaseUid'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }
}
