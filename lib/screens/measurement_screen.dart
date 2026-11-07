import 'package:flutter/material.dart';
import '../data/measurement_repository.dart';
import '../models/customer.dart';
import '../models/measurement.dart';

class MeasurementScreen extends StatefulWidget {
  final Customer customer;
  final String? dressType;
  const MeasurementScreen({super.key, required this.customer, this.dressType});

  @override
  State<MeasurementScreen> createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  final _kameezLength = TextEditingController();
  final _chest = TextEditingController();
  final _waist = TextEditingController();
  final _shoulder = TextEditingController();
  final _sleeve = TextEditingController();
  final _neck = TextEditingController();
  final _daman = TextEditingController();
  final _shalwarLength = TextEditingController();
  final _shalwarWaist = TextEditingController();
  final _pancha = TextEditingController();
  final _notes = TextEditingController();
  String _collarStyle = 'Collar';
  String _damanType = 'Gol';
  int _sidePockets = 1;
  bool _frontPocket = true;
  bool _shalwarPocket = true;

  // Should the Kameez section be shown?
  bool get _showKameez {
    final t = widget.dressType;
    return t == null ||
        t == 'Shalwar Kameez' ||
        t == 'Kameez only' ||
        t == 'Kurta' ||
        t == 'Other';
  }

  // Should the Shalwar section be shown?
  bool get _showShalwar {
    final t = widget.dressType;
    return t == null ||
        t == 'Shalwar Kameez' ||
        t == 'Shalwar only' ||
        t == 'Other';
  }

  // 0 -> empty box, otherwise show the number.
  String _toText(double value) => value == 0 ? '' : value.toString();

  // Typed text -> number. Empty or wrong text becomes 0.
  double _toNumber(TextEditingController c) =>
      double.tryParse(c.text.trim()) ?? 0;

  @override
  void initState() {
    super.initState();
    // If this customer already has measurements, fill the boxes.
    final old = measurementRepository.getForCustomer(widget.customer.id);
    if (old != null) {
      _kameezLength.text = _toText(old.kameezLength);
      _chest.text = _toText(old.chest);
      _waist.text = _toText(old.waist);
      _shoulder.text = _toText(old.shoulder);
      _sleeve.text = _toText(old.sleeve);
      _neck.text = _toText(old.neck);
      _daman.text = _toText(old.daman);
      _shalwarLength.text = _toText(old.shalwarLength);
      _shalwarWaist.text = _toText(old.shalwarWaist);
      _pancha.text = _toText(old.pancha);
      _notes.text = old.notes;
      _collarStyle = old.collarStyle;
      _damanType = old.damanType;
      _sidePockets = old.sidePockets;
      _frontPocket = old.frontPocket;
      _shalwarPocket = old.shalwarPocket;
    }
  }

  @override
  void dispose() {
    // Free all controllers at once.
    for (final c in [
      _kameezLength,
      _chest,
      _waist,
      _shoulder,
      _sleeve,
      _neck,
      _daman,
      _shalwarLength,
      _shalwarWaist,
      _pancha,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final measurement = Measurement(
      customerId: widget.customer.id,
      kameezLength: _toNumber(_kameezLength),
      chest: _toNumber(_chest),
      waist: _toNumber(_waist),
      shoulder: _toNumber(_shoulder),
      sleeve: _toNumber(_sleeve),
      neck: _toNumber(_neck),
      daman: _toNumber(_daman),
      shalwarLength: _toNumber(_shalwarLength),
      shalwarWaist: _toNumber(_shalwarWaist),
      pancha: _toNumber(_pancha),
      notes: _notes.text.trim(),
      collarStyle: _collarStyle,
      damanType: _damanType,
      sidePockets: _sidePockets,
      frontPocket: _frontPocket,
      shalwarPocket: _shalwarPocket,
    );

    measurementRepository.save(measurement);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Measurements saved')));
    Navigator.pop(context);
  }

  Widget _numberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          suffixText: 'inch',
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _heading(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _collarChooser() {
    return RadioGroup<String>(
      groupValue: _collarStyle,
      onChanged: (value) {
        if (value != null) setState(() => _collarStyle = value);
      },
      child: const Column(
        children: [
          RadioListTile<String>(title: Text('Collar'), value: 'Collar'),
          RadioListTile<String>(title: Text('Ban'), value: 'Ban'),
        ],
      ),
    );
  }

  Widget _choice<T>(
    String title,
    T selected,
    Map<T, String> options,
    void Function(T) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        RadioGroup<T>(
          groupValue: selected,
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          child: Column(
            children: options.entries
                .map(
                  (e) => RadioListTile<T>(title: Text(e.value), value: e.key),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.dressType == null
              ? 'Measurements: ${widget.customer.name}'
              : '${widget.dressType}: ${widget.customer.name}',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showKameez) ...[
              _heading('Kameez', Icons.checkroom),
              _numberField('Length (Lambai)', _kameezLength),
              _numberField('Chest (Chaati)', _chest),
              _numberField('Waist (Kamar)', _waist),
              _numberField('Shoulder (Teera)', _shoulder),
              _numberField('Sleeve (Bazu)', _sleeve),
              _numberField('Neck (Gala)', _neck),
              _numberField('Daman (Bottom width)', _daman),
              const Text(
                'Collar design',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              _collarChooser(),
              _choice<String>('Daman type', _damanType, {
                'Gol': 'Gol (round)',
                'Chokor': 'Chokor (square)',
              }, (v) => setState(() => _damanType = v)),
              _choice<int>('Side pockets', _sidePockets, {
                1: '1 pocket',
                2: '2 pockets',
              }, (v) => setState(() => _sidePockets = v)),
              // SwitchListTile(
              //   title: const Text('Front pocket'),
              //   value: _frontPocket,
              //   onChanged: (v) => setState(() => _frontPocket = v),
              // ),
              CheckboxListTile(
                title: const Text('Front pocket'),
                value: _frontPocket,
                onChanged: (v) => setState(() => _frontPocket = v ?? false),
              ),
            ],

            if (_showShalwar) ...[
              _heading('Shalwar', Icons.straighten),
              _numberField('Length (Lambai)', _shalwarLength),
              _numberField('Waist (Kamar)', _shalwarWaist),
              _numberField('Pancha (Bottom opening)', _pancha),
              // SwitchListTile(
              //   title: const Text('Shalwar pocket'),
              //   value: _shalwarPocket,
              //   onChanged: (v) => setState(() => _shalwarPocket = v),
              // ),
              CheckboxListTile(
                title: const Text('Shalwar pocket'),
                value: _shalwarPocket,
                onChanged: (v) => setState(() => _shalwarPocket = v ?? false),
              ),
            ],

            _heading('Notes', Icons.note_alt_outlined),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Example: likes loose fit',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save Measurements'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
