class UserVo {
  final String id;
  final String email;
  final String? fullName;
  final String? nickname;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserVo({
    required this.id,
    required this.email,
    this.fullName,
    this.nickname,
    this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
  });

  /// Supabase auth.user() + profiles 테이블 조인 데이터로부터 생성
  factory UserVo.fromJson(Map<String, dynamic> json) {
    return UserVo(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Supabase profiles 테이블에 저장할 데이터로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 닉네임 설정 여부 확인
  bool get hasNickname => nickname != null && nickname!.isNotEmpty;

  /// copyWith 메서드 (상태 업데이트용)
  UserVo copyWith({
    String? id,
    String? email,
    String? fullName,
    String? nickname,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserVo(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserVo(id: $id, email: $email, nickname: $nickname, hasNickname: $hasNickname)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserVo &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.nickname == nickname &&
        other.avatarUrl == avatarUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      fullName,
      nickname,
      avatarUrl,
      createdAt,
      updatedAt,
    );
  }
}