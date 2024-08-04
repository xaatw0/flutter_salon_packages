import 'package:objectbox/objectbox.dart';
import 'package:ollama_talk/ollama_talk.dart';

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
