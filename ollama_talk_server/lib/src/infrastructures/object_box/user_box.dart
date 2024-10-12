import 'package:objectbox/objectbox.dart';

@Entity()
class UserBox {
  @Id()
  int id = 0;

  String name;

  UserBox({
    required this.name,
  });

  Future<int> save(Store store) {
    return store.box<UserBox>().putAsync(this);
  }
}
