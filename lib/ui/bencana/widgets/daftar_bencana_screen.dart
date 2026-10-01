import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iam_relawan/domain/models/bencana_list.dart';
import 'package:iam_relawan/ui/bencana/view_models/bencana_view_model.dart';
import 'package:iam_relawan/ui/core/themes/app_theme.dart';

class DaftarBencanaScreen extends ConsumerStatefulWidget {
  const DaftarBencanaScreen({super.key});

  @override
  ConsumerState<DaftarBencanaScreen> createState() =>
      _DaftarBencanaScreenState();
}

class _DaftarBencanaScreenState extends ConsumerState<DaftarBencanaScreen> {
  @override
  Widget build(BuildContext context) {
    final dataBencanaList = ref.watch(
      bencanaViewModelProvider,
    ); // ganti menjadi provider viewmodel
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        // scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Center(
          child: Text(
            'Daftar Bencana',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 1,
                            blurStyle: BlurStyle.normal,
                            offset: Offset(1, 1),
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type name or address...',
                          hintStyle: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'Filter',
                    hint: 'Tombol filter daftar bencana',
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        height: 55,
                        width: 55,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 1,
                              blurStyle: BlurStyle.normal,
                              offset: Offset(1, 1),
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.settings,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: dataBencanaList.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          'Tidak ada laporan ditemukan',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final dataBencana = list[index];
                        return Dismissible(
                          key: ValueKey(dataBencana.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Semantics(
                              label: 'Hapus laporan',
                              child: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.onError,
                              ),
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            final konfirmasi = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus laporan?'),
                                content: Text(
                                  'Laporan "${dataBencana.name}" akan dihapus.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            if (konfirmasi == true) {
                              return await ref
                                  .read(bencanaViewModelProvider.notifier)
                                  .deleteBencana(dataBencana.id!);
                            }
                            return false;
                          },
                          onDismissed: (direction) {},
                          child: DataBencanaCard(dataBencana: dataBencana),
                        );
                      },
                    );
                  },
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Gagal memuat data: $error',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  loading: () => Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Semantics(
        label: 'Tambah laporan bencana baru',
        button: true,
        child: FloatingActionButton(
          onPressed: () => context.goNamed('tambah'),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class DataBencanaCard extends StatelessWidget {
  const DataBencanaCard({super.key, required this.dataBencana});

  final BencanaList dataBencana;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: InkWell(
        onTap: () {
          context.goNamed(
            'detail',
            pathParameters: {
              'id': dataBencana.id.toString(),
            }, 
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: IntrinsicHeight(
            child: Row(
              spacing: 14,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    // height: double.infinity,
                    child: Icon(
                      Icons.local_fire_department,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 45,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dataBencana.name,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            Icons.star,
                            size: 20,
                            color: MaterialTheme.gold.seed,
                          ),
                        ],
                      ),
                      Divider(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.4),
                        thickness: 0.5,
                        height: 10,
                      ),
                      Text(
                        dataBencana.createdAt,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        dataBencana.location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
