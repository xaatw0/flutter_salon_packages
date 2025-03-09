import 'command.dart';

abstract interface class ISplitData
    implements ICommand<String, Stream<String>> {
  @override
  Stream<String> execute(String data);
}
