import 'package:iam_relawan/domain/models/bencana_list.dart';

abstract class BencanaRepository {
  Future<List<BencanaList>> getAllBencana();
  Future<void> tambahBencana(BencanaList bencana);
  Future<void> deleteBencana(int id);
  Future<void> updateBencana(BencanaList bencana);
}
