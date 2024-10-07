import 'package:objectbox/objectbox.dart';

@Entity()
class DocumentBox {
  @Id()
  int id = 0;

  String fileName;
  String memo;

  @Property(type: PropertyType.date)
  DateTime createDate;

  DocumentBox({
    required this.fileName,
    required this.memo,
    required this.createDate,
  });

  Future<DocumentBox> save(Store store) async {
    final id = store.box<DocumentBox>().putAsync(this);
    return store.box<DocumentBox>().get(await id)!;
  }

  factory DocumentBox.fromJson(Map<String, dynamic> json) {
    return DocumentBox(
      fileName: json['fileName'],
      memo: json['memo'],
      createDate: DateTime.parse(json['createDate']),
    )..id = json['id'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'memo': memo,
      'createDate': createDate.toIso8601String(),
    };
  }
}
