import 'package:objectbox/objectbox.dart';

import '../../../objectbox.g.dart'; // auto generate file
import '../../../ollama_talk_server.dart';
import 'document_box.dart';

@Entity()
class DocumentMessageBox {
  @Id()
  int id = 0;

  DocumentMessageBox({
    required this.message,
  });

  String message;

  Future<DocumentMessageBox> save(Store store) async {
    return store
        .box<DocumentMessageBox>()
        .putAsync(this)
        .then((id) => store.box<DocumentMessageBox>().get(id)!);
  }
}
