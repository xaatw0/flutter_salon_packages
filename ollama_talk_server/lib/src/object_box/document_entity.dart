import 'package:objectbox/objectbox.dart';

@Entity()
class DocumentEntity {
  @Id()
  int id = 0;

  String fileName;
  String memo;

  @Property(type: PropertyType.date)
  DateTime createDate;

  DocumentEntity({
    required this.fileName,
    required this.memo,
    required this.createDate,
  });

  factory DocumentEntity.fromJson(Map<String, dynamic> json) {
    return DocumentEntity(
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
