
class AppUser {
  AppUser({
    this.id,
    this.name = '',
  });

  final String? id;
  final String name;

    factory AppUser.fromDoc(String id, Map<String, dynamic> doc) => AppUser(
        id: id,
        name: doc['name'],
      );
}