import 'package:objectbox/objectbox.dart';

import '../../../objectbox.g.dart'; // auto generate file
import 'document_box.dart';

@Entity()
class DocumentEmbeddingBox {
  @Id()
  int id = 0;

  @HnswIndex(dimensions: 1024)
  @Property(type: PropertyType.floatVector)
  List<double> vector;
  String message;

  final document = ToOne<DocumentBox>();

  DocumentEmbeddingBox({
    required this.vector,
    required this.message,
  });

  Future<DocumentEmbeddingBox> save(Store store) async {
    final id = store.box<DocumentEmbeddingBox>().putAsync(this);
    return store.box<DocumentEmbeddingBox>().get(await id)!;
  }

  static Future<List<DocumentEmbeddingBox>> findRelatedInformation(
    Store store,
    List<double> vector, {
    int count = 5,
  }) {
    final query = store.box<DocumentEmbeddingBox>().query(
        DocumentEmbeddingEntity_.vector.nearestNeighborsF32(vector, count));

    return query.build().findAsync();
  }
}
