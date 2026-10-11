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

// Ubah repositori yang digunakan
final bencanaRepositoryProvider = Provider<BencanaRepository>((ref) {
  // return BencanaRepositoryImpl(BencanaDatabaseService.instance); //nonaktif dulu SQL
  // return BencanaRepositoryFirebaseImpl(BencanaFirestoreService()); //nonaktif dulu Firebase
  return BencanaRepositoryHybridImpl(BencanaDatabaseService.instance, BencanaFirestoreService());
});

class BencanaViewModel extends AsyncNotifier<List<BencanaList>> {
  final _uuid = Uuid();
  Timer? _periodicTimer; // tambahkan variabel timer
  bool _isSyncing = false; // tambahkan variabel syncing
  StreamSubscription<List<ConnectivityResult>>?
  _connectivitySub; // tambahkan variabel pemantau koneksi jaringan (jangan lupa registrasikan dulu pada pubspec)

  @override
  Future<List<BencanaList>> build() async {
    final repository = ref.watch(bencanaRepositoryProvider);
    // Tambahkan pengecekan kondisi, jalankan sinkronisasi jika hanya repository yang digunakan adalah BencanaRepositoryHybridImpl
    if (repository is BencanaRepositoryHybridImpl) {
      // Trigger 2: sinkronisasi saat provider pertama kali dibuka
      unawaited(_runSync(repository));

      // Trigger 1: sinkronisasi saat terjadi perubahan koneksi
      _connectivitySub ??= Connectivity().onConnectivityChanged.listen((
        reslut,
      ) {
        final isOnline = !reslut.contains(ConnectivityResult.none);
        if (isOnline) unawaited(_runSync(repository));
      });

      // Trigger 3: sinkronisasi secara berkala dalam rentang waktu tertentu (misal setiap 3 menit sekali)
      _periodicTimer ??= Timer.periodic(
        const Duration(minutes: 3),
        (_) => unawaited(_runSync(repository)),
      );

      ref.onDispose(() {
        _connectivitySub?.cancel();
        _periodicTimer?.cancel();
      });
    }

    return repository.getAllBencana();
  }

  // Tambahkan method _runSync
  Future<void> _runSync(BencanaRepositoryHybridImpl repository) async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      await repository.syncPush();
      await repository.syncPull();
      state = AsyncData(await repository.getAllBencana());
    } catch (e) {
      // _isSyncing = false;
    } finally {
      _isSyncing = false;
    }
  }

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
      // ref.invalidateSelf(); ganti menjadi state AsyncData
      state = AsyncData(await repository.getAllBencana());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBencana(String id) async {
    try {
      final repository = ref.read(bencanaRepositoryProvider);
      await repository.deleteBencana(id);
      // final currentList = state.value ?? [];
      // state = AsyncData(currentList.where((b) => b.id != id).toList()); ganti menjadi state async data
      state = AsyncData(await repository.getAllBencana());
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
      // final currentList = state.value ?? [];
      // state = AsyncData([
      //   for (final b in currentList)
      //     if (b.id == id) updated else b,
      // ]);
      state = AsyncData(await repository.getAllBencana());

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
