import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
// Import all models here
import 'package:tasknote/Model/Note/m_note.dart';
import 'package:tasknote/Model/Group/m_group.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();

      // PASS ALL SCHEMAS HERE
      return await Isar.open(
        [NoteSchema, GroupSchema], // <--- Both schemas together!
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  
}
