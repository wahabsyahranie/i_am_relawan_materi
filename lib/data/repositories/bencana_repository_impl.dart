import 'package:iam_relawan/data/repositories/bencana_repository.dart';
import 'package:iam_relawan/data/services/bencana_database_service.dart';
import 'package:iam_relawan/domain/models/bencana_list.dart';

class BencanaRepositoryImpl implements BencanaRepository {
  BencanaRepositoryImpl(this._service);

  final BencanaDatabaseService _service;

  @override
  Future<void> tambahBencana(BencanaList bencana) async {
    await _service.insertBencana({
      'id': bencana.id,
      'name': bencana.name,
      'location': bencana.location,
      'description': bencana.description,
      'createdAt': bencana.createdAt,
      'updatedAt': bencana.updatedAt,
      'nameReporter': bencana.nameReporter,
      'phoneNumber': bencana.phoneNumber,
    });
  }

  @override
  Future<List<BencanaList>> getAllBencana() async {
    final rows = await _service.getAllBencana();
    return rows
        .map(
          (row) => BencanaList(
            name: row['name'] as String,
            location: row['location'] as String,
            description: row['description'] as String,
            createdAt: row['createdAt'] as String,
            updatedAt: row['updatedAt'] as String,
            nameReporter: row['nameReporter'] as String,
            phoneNumber: row['phoneNumber'] as String,
            id: row['id'] as String,
          ),
        )
        .toList();
  }

  @override
  Future<void> deleteBencana(String id) async {
    await _service.deleteBencana(id);
  }

  @override
  Future<void> updateBencana(BencanaList bencana) async {
    await _service.updateBencana(bencana.id!, {
      'name': bencana.name,
      'location': bencana.location,
      'description': bencana.description,
      'createdAt': bencana.createdAt,
      'updatedAt': bencana.updatedAt,
      'nameReporter': bencana.nameReporter,
      'phoneNumber': bencana.phoneNumber,
    });
  }

}
