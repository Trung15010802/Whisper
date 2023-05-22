class AppUser {
  String uid;
  String? displayName;
  String? email;
  String avatarUrl;
  AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    this.avatarUrl =
        'https://i.pinimg.com/originals/c6/e5/65/c6e56503cfdd87da299f72dc416023d4.jpg',
  });
}
