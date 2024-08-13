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
}
