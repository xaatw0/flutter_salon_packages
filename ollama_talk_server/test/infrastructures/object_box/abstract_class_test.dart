import 'package:objectbox/objectbox.dart';

class AbstractTestClass {
  AbstractTestClass(this.id);
  int id;
}

@Entity()
class TestClass extends AbstractTestClass {
  TestClass(this.id) : super(id);

  @Id()
  int id;
}
