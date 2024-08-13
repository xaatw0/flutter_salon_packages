import 'package:objectbox/objectbox.dart';

@Entity()
class UserEntity {
  @Id()
  int id = 0;

  String name;

  UserEntity({
    required this.name,
  });
}
