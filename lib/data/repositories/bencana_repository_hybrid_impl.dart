import 'dart:async';
import 'package:iam_relawan/data/repositories/bencana_repository.dart';
import 'package:iam_relawan/data/services/bencana_database_service.dart';
import 'package:iam_relawan/data/services/bencana_firestore_service.dart';
import 'package:iam_relawan/domain/models/bencana_list.dart';

class BencanaRepositoryHybridImpl implements BencanaRepository {
  BencanaRepositoryHybridImpl(this._localService, this._remoteService);

  final BencanaDatabaseService _localService;
  final BencanaFirestoreService _remoteService;

  // Konversi
  Map<String, dynamic> _toMap(BencanaList b) => {
    'id': b.id,
    'name': b.name,
    'location': b.location,
    'description': b.description,
    'createdAt': b.createdAt,
    'updatedAt': b.updatedAt,
    'nameReporter': b.nameReporter,
    'phoneNumber': b.phoneNumber,
    'isSynced': b.isSynced ? 1 : 0,
    'isDeleted': b.isDeleted ? 1 : 0,
  };

  BencanaList _fromMap(Map<String, dynamic> row) => BencanaList(
    id: row['id'] as String,
    name: row['name'] as String,
    location: row['location'] as String,
    description: row['description'] as String,
    createdAt: row['createdAt'] as String,
    updatedAt: row['updatedAt'] as String,
    nameReporter: row['nameReporter'] as String,
    phoneNumber: row['phoneNumber'] as String,
    isSynced: (row['isSynced'] as int) == 1,
    isDeleted: (row['isDeleted'] as int) == 1,
  );

  // Method Read
  @override
  Future<List<BencanaList>> getAllBencana() async {
    final rows = await _localService.getAllBencana();
    return rows.map(_fromMap).toList();
  }

  // Method create
  @override
  Future<void> tambahBencana(BencanaList bencana) async {
    bencana.isSynced = false;
    await _localService.insertBencana(_toMap(bencana));
    unawaited(syncPush()); //tambahkan, untuk mengupdate remote
  }

  // Method update
  @override
  Future<void> updateBencana(BencanaList bencana) async {
    bencana.isSynced = false;
    await _localService.updateBencana(bencana.id!, _toMap(bencana));
    unawaited(syncPush()); //tambahkan, untuk mengupdate remote
  }

  // Method delete
  @override
  Future<void> deleteBencana(String id) async {
    await _localService.deleteBencana(id);
    unawaited(syncPush()); //tambahkan, untuk mengupdate remote
  }

  // Method push, menulis data sinkronisasi dari lokal ke remote
  Future<void> syncPush() async {
    final unsyncedRows = await _localService.getUnsyncedBencana();

    for (final row in unsyncedRows) {
      final bencana = _fromMap(row);
      try {
        if (bencana.isDeleted) {
          await _remoteService.deleteBencana(bencana.id!);
          await _localService.hardDeleteBencana(bencana.id!);
        } else {
          bencana.isSynced = true;
          await _remoteService.setBencana(bencana.id!, _toMap(bencana));
          await _localService.updateBencana(bencana.id!, _toMap(bencana));
        }
      } catch (e) {
        continue;
      }
    }
  }

  // Method pull, membaca data sinkronisasi dari remote ke local
  Future<void> syncPull() async {
    final remoteRows = await _remoteService.getAllBencana();
    final localRows = await _localService.getAllBencana();
    final localById = {for (final r in localRows) r['id'] as String: r};

    for (final remoteRow in remoteRows) {
      final remoteId = remoteRow['id'] as String;
      final localRow = localById[remoteId];

      try {
        if (localRow == null) {
          await _localService.insertBencana({
            ...remoteRow, 'isSynced': 1, 'isDeleted': 0,
          });
          continue;
        }

        final remoteUpdatedAt = DateTime.parse(
          remoteRow['updatedAt'] as String,
        );
        final localUpdatedAt = DateTime.parse(localRow['updatedAt'] as String);
        final localIsSynced = (localRow['isSynced'] as int) == 1;

        if (remoteUpdatedAt.isAfter(localUpdatedAt) && localIsSynced) {
          await _localService.updateBencana(remoteId, {
            ...remoteRow,
            'isSynced': 1,
          });
        }
      } catch (e) {
        continue;
      }
    }
  }
}
