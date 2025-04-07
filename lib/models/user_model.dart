class UserProfile {
  final String id;
  final String name;
  final String phone;
  final String gender;
  final int age;
  final String location;
  final String imageUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.age,
    required this.location,
    required this.imageUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'],
      name: json['name'],
      phone: json['phone'],
      gender: json['gender'],
      age: json['age'],
      location: json['location'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'gender': gender,
      'age': age,
      'location': location,
      'imageUrl': imageUrl,
    };
  }
}
