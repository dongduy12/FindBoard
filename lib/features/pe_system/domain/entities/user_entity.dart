class UserEntity {
  final int? id;
  final String? email;

  UserEntity({required this.id, required this.email});
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as int?,
      email: json['email'] as String?,
    );
  }
}