import 'package:objectbox/objectbox.dart'; // needed before generate
import '../../objectbox.g.dart'; // auto generated file

@Entity()
class CannotBuildEntity {
  @Id()
  int id = 0;

  @Transient()
  Store? store;

  CannotBuildEntity();
}
