import 'package:objectbox/objectbox.dart';

@Entity()
class TestBox {
  @Id()
  int id = 0;

  String name;

  TestBox({
    required this.name,
  });

  static Future<List<TestBox>> list(Store store) {
    return store.box<TestBox>().getAllAsync();
  }

  Future<TestBox> save(Store store) async {
    final id = store.box<TestBox>().putAsync(this);
    return store.box<TestBox>().get(await id)!;
  }
}
