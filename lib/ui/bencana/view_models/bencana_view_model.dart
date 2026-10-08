import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iam_relawan/data/repositories/bencana_repository.dart';
import 'package:iam_relawan/data/repositories/bencana_repository_firebase_impl.dart';
import 'package:iam_relawan/data/repositories/bencana_repository_hybrid_impl.dart';
import 'package:iam_relawan/data/repositories/bencana_repository_impl.dart';
import 'package:iam_relawan/data/services/bencana_database_service.dart';
import 'package:iam_relawan/data/services/bencana_firestore_service.dart';
import 'package:iam_relawan/domain/models/bencana_list.dart';
import 'package:uuid/uuid.dart';

// Menginisiasi repositori yang digunakan
final bencanaRepositoryProvider = Provider<BencanaRepository>((ref) {
  // return BencanaRepositoryImpl(BencanaDatabaseService.instance); //nonaktif dulu SQL
  // return BencanaRepositoryFirebaseImpl(BencanaFirestoreService());
  return BencanaRepositoryHybridImpl(
    BencanaDatabaseService.instance,
    BencanaFirestoreService(),
  );
});

// Membuat viewmodel untuk mengambil data
class BencanaViewModel extends AsyncNotifier<List<BencanaList>> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _periodicTimer;

  // @override
  // //Method Read
  // Future<List<BencanaList>> build() async {
  //   final repository = ref.watch(bencanaRepositoryProvider);
  //   return repository.getAllBencana();
  // }

  @override
  Future<List<BencanaList>> build() async {
    final repository =
        ref.watch(bencanaRepositoryProvider) as BencanaRepositoryHybridImpl;

    // Pemicu sinkronisasi 2: sync saat aplikasi pertama kali dibuka
    unawaited(_runSync(repository));

    // Pemicu sinkronisasi 1: listener perubahan koneksi
    _connectivitySub ??= Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = !results.contains(ConnectivityResult.none);
      if (isOnline) unawaited(_runSync(repository));
    });

    // Pemicu sinkronisasi 3: timer periodik, jaring pengaman terakhir
    _periodicTimer ??= Timer.periodic(
      const Duration(minutes: 3),
      (_) => unawaited(_runSync(repository)),
    );

    ref.onDispose(() {
      _connectivitySub?.cancel();
      _periodicTimer?.cancel();
    });

    return repository.getAllBencana();
  }

  Future<void> _runSync(BencanaRepositoryHybridImpl repository) async {
    await repository.syncPush();
    await repository.syncPull();
    state = AsyncData(await repository.getAllBencana());
  }

  final _uuid = Uuid();

  Future<bool> tambahBencana({
    required String name,
    required String location,
    required String description,
    required String nameReporter,
    required String phoneNumber,
  }) async {
    try {
      final repository = ref.read(bencanaRepositoryProvider);
      final now = DateTime.now().toString();
      final uniqueId = _uuid.v4();
      await repository.tambahBencana(
        BencanaList(
          id: uniqueId,
          name: name,
          location: location,
          description: description,
          createdAt: now,
          updatedAt: now,
          nameReporter: nameReporter,
          phoneNumber: phoneNumber,
        ),
      );
      ref.invalidateSelf();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBencana(String id) async {
    try {
      final repository = ref.read(bencanaRepositoryProvider);
      await repository.deleteBencana(id);

      final currentList = state.value ?? [];
      state = AsyncData(currentList.where((b) => b.id != id).toList());

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBencana({
    required String id,
    required String createdAt,
    required String name,
    required String location,
    required String description,
    required String nameReporter,
    required String phoneNumber,
  }) async {
    try {
      final repository = ref.read(bencanaRepositoryProvider);
      final updated = BencanaList(
        id: id,
        name: name,
        location: location,
        description: description,
        createdAt: createdAt,
        updatedAt: DateTime.now().toString(),
        nameReporter: nameReporter,
        phoneNumber: phoneNumber,
      );
      await repository.updateBencana(updated);

      final currentList = state.value ?? [];
      state = AsyncData([
        for (final b in currentList)
          if (b.id == id) updated else b,
      ]);

      return true;
    } catch (e) {
      return false;
    }
  }
}

// Menyediakan viewmodel untuk UI
final bencanaViewModelProvider =
    AsyncNotifierProvider<BencanaViewModel, List<BencanaList>>(
      BencanaViewModel.new,
    );
