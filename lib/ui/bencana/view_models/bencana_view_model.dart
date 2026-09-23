import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iam_relawan/data/repositories/bencana_repository.dart';
import 'package:iam_relawan/data/repositories/bencana_repository_impl.dart';
import 'package:iam_relawan/data/services/bencana_database_service.dart';
import 'package:iam_relawan/domain/models/bencana_list.dart';

// Menginisiasi repositori yang digunakan
final bencanaRepositoryProvider = Provider<BencanaRepository>((ref) {
  return BencanaRepositoryImpl(BencanaDatabaseService.instance);
});

// Membuat viewmodel untuk mengambil data
class BencanaViewModel extends AsyncNotifier<List<BencanaList>> {
  @override
  //Method Read
  Future<List<BencanaList>> build() async {
    final repository = ref.watch(bencanaRepositoryProvider);
    return repository.getAllBencana();
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
      await repository.tambahBencana(
        BencanaList(
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

  Future<bool> deleteBencana(int id) async {
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
    required int id,
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
