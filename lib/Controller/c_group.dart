import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:tasknote/General/common_functions.dart';
import 'package:tasknote/General/stateless_widgets.dart';
import 'package:tasknote/Model/Group/m_group.dart';
import 'package:tasknote/Service/isar.dart';

class GroupNotesController {
  // ----------------------------
  // ISAR DATABASE FUNCTIONS
  // ----------------------------

  final Logger logger = Logger();
  final IsarService isarService = IsarService();

  // Insert (Checks Duplicate)
  Future<bool> checkAndAddGroup(Group group, BuildContext context) async {
    final isar = await isarService.db;

    // Checks if group with same name exists.
    if (await groupExists(group.gName)) {
      scaffoldMessenger(context, "A folder with this name already exists!");
      return false; // Not added
    }

    await isar.writeTxn(() async {
      // Prevent duplicate group
      final existing = await isar.groups
          .where()
          .uidEqualTo(group.uid)
          .findFirst();
      if (existing != null) {
        group.id = existing.id; // keep local Isar id
      }

      await isar.groups.put(group);
    });

    CommonFunctions.logger.d("${group.gName} group added");
    return true; // Added
  }

  // Delete
  Future<void> deleteGroup(int id) async {
    final isar = await isarService.db;

    await isar.writeTxn(() async {
      await isar.groups.delete(id);
    });
    CommonFunctions.logger.d("Group having id: $id deleted");
  }

  // Update (Checks Duplicate)
  Future<bool> checkAndUpdateGroup({
    required Group eGroup, // existing (from DB)
    required Group nGroup, // new data (from UI)
    required BuildContext context,
  }) async {
    final isar = await isarService.db;

    // 1. Check if the name has actually changed
    if (eGroup.gName != nGroup.gName) {
      // 2. Check if the NEW name is already taken by another group
      final duplicate = await isar.groups
          .filter()
          .gNameEqualTo(nGroup.gName)
          .findFirst();

      if (duplicate != null) {
        // Show error and exit the function early
        scaffoldMessenger(context, "A folder with this name already exists!");
        return false; // Not updated
      }
    }

    // 3. If we reach here, it's safe to update
    await isar.writeTxn(() async {
      // Assign new values
      eGroup.gName = nGroup.gName;
      eGroup.description = nGroup.description;
      eGroup.createdAt = nGroup.createdAt;
      eGroup.updatedAt = nGroup.updatedAt;
      eGroup.decorColor = nGroup.decorColor;
      eGroup.noteCount = nGroup.noteCount;
      eGroup.notesUidsList = nGroup.notesUidsList;

      await isar.groups.put(eGroup);
    });

    CommonFunctions.logger.d("Group having id: ${eGroup.id} updated");
    return true; // Updated
  }

  // Get group based on id
  Future<Group?> getGroupById(int id) async {
    final isar = await isarService.db;

    return await isar.groups.get(id);
  }

  // Stream of List<Group> (One time sort)
  Stream<List<Group>> listenToGroupSchema(String sort) async* {
    final isar = await isarService.db;

    yield* isar.groups.where().watch(fireImmediately: true).map((_) {
      // All in Ascending Order except Last updated
      // Fetches groups based on sort
      switch (sort) {
        case "Created":
          return isar.groups.where().sortByCreatedAt().findAllSync();
        case "Last updated":
          return isar.groups.where().sortByUpdatedAtDesc().findAllSync();
        case "DecorColor":
          return isar.groups.where().sortByDecorColor().findAllSync();
        case "Alphabetically":
          return isar.groups.where().sortByGName().findAllSync();
        default:
          return isar.groups.where().sortByCreatedAt().findAllSync();
      }
    });
  }

  // Sort Groups (Multiple time sort)
  List<Group> sortGroups(String sort, List<Group> originalList) {
    // Create a copy so the original list is not modified
    final list = List<Group>.from(originalList);

    switch (sort) {
      case "Created":
        // Newest first // Works perfectly
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case "Last updated":
        // Most recently updated first // Works perfectly
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;

      case "DecorColor":
        // Sort by color value (ascending) // Works perfectly
        list.sort((a, b) => a.decorColor!.compareTo(b.decorColor!));
        break;

      case "Alphabetically":
        // Sort by name A → Z (case-sensitive) // Works perfectly
        list.sort((a, b) => a.gName.compareTo(b.gName));
        break;

      default:
        // No sorting
        break;
    }

    return list;
  }

  // Get total no. of groups
  Future<int> getTotalGroupCount() async {
    final isar = await isarService.db;
    return isar.groups.count();
  }

  // Check if group exists
  Future<bool> groupExists(String gName) async {
    final isar = await isarService.db;

    // .findFirst() is faster than .findAll() for existence checks
    final group = await isar.groups.filter().gNameEqualTo(gName).findFirst();

    return group != null;
  }

  // ----------------------------
  // FIREBASE DATABASE FUNCTIONS
  // ----------------------------

  // Save Groups to firebase
  Future<bool> uploadGroupsToFirebase({required String userId}) async {
    final isar = await isarService.db;

    // 1. Fetch current local groups from Isar
    List<Group> groupsList = await isar.groups
        .where()
        .sortByUpdatedAtDesc()
        .findAll();

    // Create a set of local names for quick lookup
    Set<String> localGroupNames = groupsList.map((g) => g.gName).toSet();

    FirebaseFirestore db = FirebaseFirestore.instance;
    WriteBatch batch = db.batch();

    try {
      // 2. FETCH CLOUD STATE: Find what's currently in Firebase for this user
      // Note: This assumes your group document contains the 'userId' field
      QuerySnapshot existingGroups = await db
          .collection('Groups')
          .where('userId', isEqualTo: userId)
          .get();

      // 3. DELETE ORPHANS: If a cloud doc is NOT in our local list, delete it
      int deletedCount = 0;
      for (var doc in existingGroups.docs) {
        if (!localGroupNames.contains(doc.id)) {
          batch.delete(doc.reference);
          deletedCount++;
        }
      }

      // 4. UPLOAD/UPDATE: Add local groups to the batch
      for (var group in groupsList) {
        DocumentReference docRef = db.collection('Groups').doc(group.gName);
        batch.set(docRef, group.toMap(userId));
      }

      // 5. COMMIT: Execute all deletes and updates in one atomic transaction
      await batch.commit();

      logger.d(
        "Sync Complete: $deletedCount groups removed, ${groupsList.length} groups updated/added.",
      );
      return true;
    } catch (e) {
      logger.e("Firebase Sync Error: $e");
      return false;
    }
  }

  // Fetches groups from firebase and stores in isar
  Future<bool> fetchAndSyncGroups({required String userId}) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    final isar = await isarService.db;

    try {
      // 1. Fetch from Firebase
      QuerySnapshot querySnapshot = await db
          .collection('Groups')
          .where('userId', isEqualTo: userId)
          .get();

      // 2. Map Firebase docs to Group objects
      List<Group> firebaseGroups = querySnapshot.docs.map((doc) {
        return Group.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();

      // 3. Save to Isar inside a transaction
      if (firebaseGroups.isNotEmpty) {
        await isar.writeTxn(() async {
          // Prevent duplicate groups
          for (final group in firebaseGroups) {
            final existing = await isar.groups
                .where()
                .uidEqualTo(group.uid)
                .findFirst();

            if (existing != null) {
              group.id = existing.id; // preserve local Isar id
            }

            await isar.groups.put(group);
          }
        });
        logger.d("Synced ${firebaseGroups.length} groups to local database.");
      }

      return true; // Download Completed
    } catch (e) {
      logger.d("Error syncing groups: $e");
      return false; // Download failed
    }
  }
}
