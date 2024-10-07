import 'package:objectbox/objectbox.dart';

import '../../../objectbox.g.dart'; // auto generate file
import 'document_entity.dart';

@Entity()
class DocumentEmbeddingEntity {
  @Id()
  int id = 0;

  @HnswIndex(dimensions: 1024)
  @Property(type: PropertyType.floatVector)
  List<double> vector;
  String message;

  final document = ToOne<DocumentEntity>();

  DocumentEmbeddingEntity({
    required this.vector,
    required this.message,
  });

  Future<DocumentEmbeddingEntity> save(Store store) async {
    final id = store.box<DocumentEmbeddingEntity>().putAsync(this);
    return store.box<DocumentEmbeddingEntity>().get(await id)!;
  }

  static Future<List<DocumentEmbeddingEntity>> findRelatedInformation(
    Store store,
    List<double> vector, {
    int count = 5,
  }) {
    final query = store.box<DocumentEmbeddingEntity>().query(
        DocumentEmbeddingEntity_.vector.nearestNeighborsF32(vector, count));

    return query.build().findAsync();
  }
}
