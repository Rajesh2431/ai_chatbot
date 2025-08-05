class UserProfile {
  final String name;
  final String age;
  final String email;
  final String phone;
  final String gender;
  final String hobbies;
  final String location;
  final String relationshipStatus;
  final String emergencyContact;
  final String? avatarPath;

  UserProfile({
    required this.name,
    this.age = '',
    this.email = '',
    this.phone = '',
    this.gender = '',
    this.hobbies = '',
    this.location = '',
    this.relationshipStatus = '',
    this.emergencyContact = '',
    this.avatarPath,
  });

  factory UserProfile.fromMap(Map<String, String?> map) {
    return UserProfile(
      name: map['name'] ?? '',
      age: map['age'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? '',
      hobbies: map['hobbies'] ?? '',
      location: map['location'] ?? '',
      relationshipStatus: map['relationshipStatus'] ?? '',
      emergencyContact: map['emergencyContact'] ?? '',
      avatarPath: map['avatarPath'],
    );
  }

  Map<String, String?> toMap() {
    return {
      'name': name,
      'age': age,
      'email': email,
      'phone': phone,
      'gender': gender,
      'hobbies': hobbies,
      'location': location,
      'relationshipStatus': relationshipStatus,
      'emergencyContact': emergencyContact,
      'avatarPath': avatarPath,
    };
  }

  UserProfile copyWith({
    String? name,
    String? age,
    String? email,
    String? phone,
    String? gender,
    String? hobbies,
    String? location,
    String? relationshipStatus,
    String? emergencyContact,
    String? avatarPath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      hobbies: hobbies ?? this.hobbies,
      location: location ?? this.location,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  bool get isComplete {
    return name.isNotEmpty && 
           age.isNotEmpty && 
           email.isNotEmpty && 
           phone.isNotEmpty && 
           gender.isNotEmpty;
  }

  String get displayName {
    return name.isNotEmpty ? name : 'User';
  }
}