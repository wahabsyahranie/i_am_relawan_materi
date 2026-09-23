import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iam_relawan/domain/models/bencana_list.dart';
import 'package:iam_relawan/ui/bencana/view_models/bencana_view_model.dart';

class EditBencanaScreen extends ConsumerStatefulWidget {
  const EditBencanaScreen({super.key, required this.bencana});

  final BencanaList bencana;

  @override
  ConsumerState<EditBencanaScreen> createState() => _EditBencanaScreenState();
}

class _EditBencanaScreenState extends ConsumerState<EditBencanaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _nameReporterController;
  late final TextEditingController _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bencana.name);
    _locationController = TextEditingController(text: widget.bencana.location);
    _descriptionController = TextEditingController(
      text: widget.bencana.description,
    );
    _nameReporterController = TextEditingController(
      text: widget.bencana.nameReporter,
    );
    _phoneNumberController = TextEditingController(
      text: widget.bencana.phoneNumber,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _nameReporterController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _updateBencana() async {
    if (_formKey.currentState!.validate()) {
      final berhasil = await ref
          .read(bencanaViewModelProvider.notifier)
          .updateBencana(
            id: widget.bencana.id!,
            createdAt: widget.bencana.createdAt,
            name: _nameController.text,
            location: _locationController.text,
            description: _descriptionController.text,
            nameReporter: _nameReporterController.text,
            phoneNumber: _phoneNumberController.text,
          );

      if (!mounted) return;

      if (berhasil) {
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui laporan, coba lagi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Laporan Bencana',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Jenis Bencana'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Lokasi'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameReporterController,
                  decoration: const InputDecoration(labelText: 'Nama Pelapor'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateBencana,
                  child: const Text('Simpan Laporan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  
  }
}
