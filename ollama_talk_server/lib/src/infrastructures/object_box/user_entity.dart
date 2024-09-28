import 'package:objectbox/objectbox.dart';

@Entity()
class UserEntity {
  @Id()
  int id = 0;

  String name;

  UserEntity({
    required this.name,
  });

  Future<int> save(Store store) {
    return store.box<UserEntity>().putAsync(this);
  }
}
