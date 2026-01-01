import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:tasknote/General/common_functions.dart';
import 'package:tasknote/Model/Group/m_group.dart';
import 'package:tasknote/Model/Note/m_note.dart';
import 'package:tasknote/Service/isar.dart';
import 'package:tasknote/View/General_Views/splash.dart';

class NoteController {
  // ----------------------------
  // ISAR DATABASE FUNCTIONS
  // ----------------------------
  final IsarService isarService = IsarService();
  final Logger logger = Logger();

  // Insert
  Future<String> addNote(Note note) async {
    final isar = await isarService.db;
    int addedNoteId = 0;
    String uid = "";
    await isar.writeTxn(() async {
      final existing = await isar.notes
          .where()
          .uidEqualTo(note.uid)
          .findFirst();

      if (existing != null) {
        note.id = existing.id; // keep local Isar id
      }

      addedNoteId = await isar.notes.put(note);
      Note? n = await isar.notes.get(addedNoteId);
      uid = n!.uid.toString();
    });
    CommonFunctions.logger.d("Note added id: $addedNoteId");
    return uid;
  }

  // Delete
  Future<void> deleteNote(int id) async {
    final isar = await isarService.db;

    await isar.writeTxn(() async {
      await isar.notes.delete(id);
    });
    CommonFunctions.logger.d("Note deleted id: $id");
  }

  // Update
  Future<void> updateNote({required Note eNote, required Note nNote}) async {
    final isar = await isarService.db;

    eNote.title = nNote.title;
    eNote.content = nNote.content;
    eNote.createdAt = nNote.createdAt;
    eNote.updatedAt = nNote.updatedAt;
    eNote.decorColor = nNote.decorColor;

    // 2. Save to Isar
    await isar.writeTxn(() async {
      await isar.notes.put(eNote);
    });

    CommonFunctions.logger.d("Note updated id: ${eNote.id}");
  }

  // Stream of List<Note> where calNote = false and grouped = false (NoteScreen)
  Stream<List<Note>> listenToNoteSchema(String sort) async* {
    final isar = await isarService.db;

    yield* isar.notes.where().watch(fireImmediately: true).map((_) {
      switch (sort) {
        // All in Ascending Order except : Last updated and Created
        case "Created":
          return isar.notes
              .filter()
              .calNoteEqualTo(false)
              .groupedEqualTo(false)
              .sortByCreatedAtDesc()
              .findAllSync();
        case "Last updated":
          return isar.notes
              .filter()
              .calNoteEqualTo(false)
              .groupedEqualTo(false)
              .sortByUpdatedAtDesc()
              .findAllSync();
        case "DecorColor":
          return isar.notes
              .filter()
              .calNoteEqualTo(false)
              .groupedEqualTo(false)
              .sortByDecorColor()
              .findAllSync();
        case "Alphabetically":
          return isar.notes
              .filter()
              .calNoteEqualTo(false)
              .groupedEqualTo(false)
              .sortByTitle()
              .findAllSync();
        default:
          return isar.notes
              .filter()
              .calNoteEqualTo(false)
              .groupedEqualTo(false)
              .sortByCreatedAt()
              .findAllSync();
      }
    });
  }

  // Stream of List<Note> where calNote = true (CalenderScreen)
  Stream<List<Note>> listenToCalNoteSchema(String sort) async* {
    final isar = await isarService.db;

    yield* isar.notes.where().watch(fireImmediately: true).map((_) {
      switch (sort) {
        // All in Ascending Order except Last updated
        case "Created":
          return isar.notes
              .filter()
              .calNoteEqualTo(true)
              .sortByCreatedAt()
              .findAllSync();
        case "Last updated":
          return isar.notes
              .filter()
              .calNoteEqualTo(true)
              .sortByUpdatedAtDesc()
              .findAllSync();
        case "DecorColor":
          return isar.notes
              .filter()
              .calNoteEqualTo(true)
              .sortByDecorColor()
              .findAllSync();
        case "Alphabetically":
          return isar.notes
              .filter()
              .calNoteEqualTo(true)
              .sortByTitle()
              .findAllSync();
        default:
          return isar.notes
              .filter()
              .calNoteEqualTo(true)
              .sortByCreatedAt()
              .findAllSync();
      }
    });
  }

  // Stream of List<Note> where grouped = true (GroupScreen)
  Stream<List<Note>> listenToGroupedNoteSchema() async* {
    final isar = await isarService.db;

    yield* isar.notes.where().watch(fireImmediately: true).map((_) {
      return isar.notes
          .filter()
          .calNoteEqualTo(false)
          .groupedEqualTo(true)
          .sortByUpdatedAtDesc()
          .findAllSync();
    });
  }

  // Multiple note select and delete
  Future<void> deleteMultipleNotes({required List<String> uidlist}) async {
    final isar = await isarService.db;

    for (var i in uidlist) {
      await isar.writeTxn(() async {
        // Note? n = await isar.notes.where().uidEqualTo(i).findFirst();
        await isar.notes.deleteByUid(i);
      });
      CommonFunctions.logger.d("Deleted note uid $i");
    }
  }

  // Multiple note select and make group
  Future<void> groupSelectedNotes({
    required List<String> uidList,
    required String gName,
  }) async {
    final isar = await isarService.db;

    await isar.writeTxn(() async {
      for (final uid in uidList) {
        final note = await isar.notes.getByUid(uid);
        if (note != null) {
          note.grouped = true;
          await isar.notes.put(note);
          CommonFunctions.logger.d(
            "Note having uid $uid added in group: $gName",
          );
        }
      }
    });
  }

  // Ungroup notes
  Future<void> unGroupNotes({
    required List<String> uidList,
    required String gName,
  }) async {
    final isar = await isarService.db;

    await isar.writeTxn(() async {
      for (final uid in uidList) {
        final note = await isar.notes.getByUid(uid);
        if (note != null) {
          note.grouped = false;
          await isar.notes.put(note);
          CommonFunctions.logger.d(
            "Note having uid $uid removed from group $gName",
          );
        }
      }
    });
  }

  // Add note inside group
  Future<void> addNoteToExistingGroup({
    required int groupId,
    required String noteUid,
  }) async {
    final isar = await isarService.db;
    Group? g = await groupController.getGroupById(groupId);

    if (g != null) {
      final List<String> idList = List<String>.from(g.notesUidsList ?? []);
      idList.add(noteUid);
      g.notesUidsList = idList;
      g.noteCount = idList.length;

      // Why this works
      // List.from() creates a growable List
      // You avoid mutating the original fixed-length list
      // You correctly reassign the updated list back to the model
      await isar.writeTxn(() async {
        await isar.groups.put(g);
      });

      CommonFunctions.logger.d(
        "Note having uid: $noteUid added in Group having id $groupId",
      );
    }
  }

  // Remove note from group
  Future<void> removeNoteFromGroup({
    required int groupId,
    required String noteUid,
  }) async {
    final isar = await isarService.db;
    Group? g = await groupController.getGroupById(groupId);

    if (g != null) {
      final List<String> idList = List<String>.from(g.notesUidsList ?? []);
      idList.remove(noteUid);
      g.notesUidsList = idList;
      g.noteCount = idList.length;

      // Why this works
      // List.from() creates a growable List
      // You avoid mutating the original fixed-length list
      // You correctly reassign the updated list back to the model
      await isar.writeTxn(() async {
        await isar.groups.put(g);
      });

      CommonFunctions.logger.d(
        "Note having uid: $noteUid removed from Group having id $groupId",
      );
    }
  }

  // Get total no. of notes
  Future<int> getTotalNoteCount() async {
    final isar = await isarService.db;
    return isar.notes.count();
  }

  // ----------------------------
  // FIREBASE FUNCTIONS
  // ----------------------------

  // Save notes to firebase 
  Future<bool> uploadNotesToFirebase({required String userId}) async {
    final isar = await isarService.db;

    // 1. Fetch current local notes from Isar
    List<Note> notesList = await isar.notes
        .where()
        .sortByUpdatedAtDesc()
        .findAll();

    // Create a set of local titles for O(1) lookup speed
    Set<String> localNoteTitles = notesList.map((n) => n.title).toSet();

    FirebaseFirestore db = FirebaseFirestore.instance;
    WriteBatch batch = db.batch();

    try {
      // 2. Fetch existing notes in Firebase for this specific user
      // This prevents deleting notes belonging to other users
      QuerySnapshot existingCloudNotes = await db
          .collection('Notes')
          .where('userId', isEqualTo: userId)
          .get();

      // 3. Identify and delete "Orphan" notes (exists in cloud but not locally)
      int deletedCount = 0;
      for (var doc in existingCloudNotes.docs) {
        if (!localNoteTitles.contains(doc.id)) {
          batch.delete(doc.reference);
          deletedCount++;
        }
      }

      // 4. Add/Update all current local notes to the batch
      for (var note in notesList) {
        // Using title as docId as per your setup
        DocumentReference docRef = db.collection('Notes').doc(note.title);
        batch.set(docRef, note.toMap(userId));
      }

      // 5. Commit all changes (deletes and updates) at once
      await batch.commit();

      logger.d(
        "Sync Complete: $deletedCount notes removed, ${notesList.length} notes updated/added.",
      );
      return true;
    } catch (e) {
      logger.e("Firebase Notes Sync Error: $e");
      return false;
    }
  }

  // Fetch notes from firebase and store in isar
  Future<bool> fetchAndSyncNotes({required String userId}) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final isar = await isarService.db;

    try {
      // 1. Fetch from Firebase
      QuerySnapshot querySnapshot = await db
          .collection('Notes')
          .where('userId', isEqualTo: userId)
          .get();

      // 2. Map Firebase docs to Note objects
      List<Note> firebaseNotes = querySnapshot.docs.map((doc) {
        return Note.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      // 3. Save to Isar inside a transaction
      if (firebaseNotes.isNotEmpty) {
        await isar.writeTxn(() async {
          for (final note in firebaseNotes) {
            final existing = await isar.notes
                .where()
                .uidEqualTo(note.uid)
                .findFirst();

            if (existing != null) {
              note.id = existing.id; // preserve local Isar id
            }

            await isar.notes.put(note);
          }
        });

        logger.d("Synced ${firebaseNotes.length} notes to local database.");
      }
      return true; // Download Completed
    } catch (e) {
      logger.d("Error syncing notes: $e");
      return false; // Download failed
    }
  }

  // ----------------------------
  // Utility FUNCTIONS
  // ----------------------------
  List<Note> getCalNotesForDay({
    required List<Note> sortedCalNoteList,
    required DateTime current,
  }) {
    return sortedCalNoteList.where((n) {
      final created = n.selectedD;
      return created!.year == current.year &&
          created.month == current.month &&
          created.day == current.day;
    }).toList();
  }

  String formatDate(DateTime dt) {
    // Wed, 8 December
    return DateFormat('EEE, d MMMM').format(dt);
  }
}
