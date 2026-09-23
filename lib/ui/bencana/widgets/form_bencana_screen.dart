import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iam_relawan/ui/bencana/view_models/bencana_view_model.dart';

class FormBencanaScreen extends ConsumerStatefulWidget {
  const FormBencanaScreen({super.key});

  @override
  ConsumerState<FormBencanaScreen> createState() => _FormBencanaScreenState();
}

class _FormBencanaScreenState extends ConsumerState<FormBencanaScreen> {
  // Controller
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameReporterController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  // Fungsi menyimpan bencana
  Future<void> _simpanBencana() async {
    if (_formKey.currentState!.validate()) {
      final berhasil = await ref
          .read(bencanaViewModelProvider.notifier)
          .tambahBencana(
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
          const SnackBar(content: Text('Gagal menyimpan laporan, coba lagi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Laporan Bencana',
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
                  onPressed: _simpanBencana,
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
