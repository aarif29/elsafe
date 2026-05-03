import 'package:flutter/material.dart';
import '../config/temuan_types.dart';

class MatriksRisikoWidget extends StatefulWidget {
  final String? initialJarak;
  final String? initialIntensitas;
  final String? initialObjek;
  final String? initialAset;
  final String? initialLokasi;
  final void Function(String? level, int skor, {
    required String? jarak,
    required String? intensitas,
    required String? objek,
    required String? aset,
    required String? lokasi,
  }) onChanged;

  const MatriksRisikoWidget({
    super.key,
    this.initialJarak,
    this.initialIntensitas,
    this.initialObjek,
    this.initialAset,
    this.initialLokasi,
    required this.onChanged,
  });

  @override
  State<MatriksRisikoWidget> createState() => _MatriksRisikoWidgetState();
}

class _MatriksRisikoWidgetState extends State<MatriksRisikoWidget> {
  String? _jarak;
  String? _intensitas;
  String? _objek;
  String? _aset;
  String? _lokasi;

  @override
  void initState() {
    super.initState();
    _jarak = widget.initialJarak;
    _intensitas = widget.initialIntensitas;
    _objek = widget.initialObjek;
    _aset = widget.initialAset;
    _lokasi = widget.initialLokasi;
  }

  void _recalculate() {
    final skor = MatriksRisiko.hitungSkor(
      jarak: _jarak,
      intensitas: _intensitas,
      objek: _objek,
      aset: _aset,
      lokasi: _lokasi,
    );
    final level = MatriksRisiko.levelDariSkor(skor);
    widget.onChanged(level, skor,
      jarak: _jarak,
      intensitas: _intensitas,
      objek: _objek,
      aset: _aset,
      lokasi: _lokasi,
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<Map<String, dynamic>> options,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        items: options.map((o) {
          return DropdownMenuItem<String>(
            value: o['value'] as String,
            child: Text(o['label'] as String),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Color _levelColor(String? level) {
    switch (level) {
      case 'Medium':
        return Colors.amber;
      case 'High':
        return Colors.orange;
      case 'Extreme':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final skor = MatriksRisiko.hitungSkor(
      jarak: _jarak,
      intensitas: _intensitas,
      objek: _objek,
      aset: _aset,
      lokasi: _lokasi,
    );
    final level = MatriksRisiko.levelDariSkor(skor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Matriks Risiko',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          label: 'Jarak Aktivitas Terdekat',
          options: MatriksRisiko.jarakAktivitas,
          value: _jarak,
          onChanged: (v) {
            setState(() => _jarak = v);
            _recalculate();
          },
        ),
        _buildDropdown(
          label: 'Intensitas Aktivitas Pihak Ketiga',
          options: MatriksRisiko.intensitasAktivitas,
          value: _intensitas,
          onChanged: (v) {
            setState(() => _intensitas = v);
            _recalculate();
          },
        ),
        _buildDropdown(
          label: 'Jenis Objek Potensi Bahaya',
          options: MatriksRisiko.jenisObjek,
          value: _objek,
          onChanged: (v) {
            setState(() => _objek = v);
            _recalculate();
          },
        ),
        _buildDropdown(
          label: 'Jenis Aset',
          options: MatriksRisiko.jenisAset,
          value: _aset,
          onChanged: (v) {
            setState(() => _aset = v);
            _recalculate();
          },
        ),
        _buildDropdown(
          label: 'Lokasi Objek',
          options: MatriksRisiko.lokasiObjek,
          value: _lokasi,
          onChanged: (v) {
            setState(() => _lokasi = v);
            _recalculate();
          },
        ),
        if (level != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _levelColor(level).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _levelColor(level)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield, color: _levelColor(level), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Level Risiko: $level',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _levelColor(level),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
