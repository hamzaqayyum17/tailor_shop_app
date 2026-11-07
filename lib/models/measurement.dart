class Measurement {
  final String customerId;


  final double kameezLength;
  final double chest;
  final double waist;
  final double shoulder;
  final double sleeve;
  final double neck;
  final double daman;


  final double shalwarLength;
  final double shalwarWaist;
  final double hip;
  final double pancha;

  final String notes;

  final String collarStyle;
  final String damanType;  
  final int sidePockets;   
  final bool frontPocket;
  final bool shalwarPocket;

  Measurement({
    required this.customerId,
    this.kameezLength = 0,
    this.chest = 0,
    this.waist = 0,
    this.shoulder = 0,
    this.sleeve = 0,
    this.neck = 0,
    this.daman = 0,
    this.shalwarLength = 0,
    this.shalwarWaist = 0,
    this.hip = 0,
    this.pancha = 0,
    this.notes = '',
    this.collarStyle = 'Collar',
    this.damanType = 'Gol',
    this.sidePockets = 1,
    this.frontPocket = true,
    this.shalwarPocket = true,
  });

  
  Map<String, Object?> toMap() {
    return {
      'customerId': customerId,
      'kameezLength': kameezLength,
      'chest': chest,
      'waist': waist,
      'shoulder': shoulder,
      'sleeve': sleeve,
      'neck': neck,
      'daman': daman,
      'shalwarLength': shalwarLength,
      'shalwarWaist': shalwarWaist,
      'hip': hip,
      'pancha': pancha,
      'notes': notes,
      'collarStyle': collarStyle,
      'damanType': damanType,
      'sidePockets': sidePockets,
      'frontPocket': frontPocket ? 1 : 0, 
      'shalwarPocket': shalwarPocket ? 1 : 0,
    };
  }


  factory Measurement.fromMap(Map<String, Object?> map) {
    double d(Object? value) => (value as num?)?.toDouble() ?? 0;

    return Measurement(
      customerId: map['customerId'] as String,
      kameezLength: d(map['kameezLength']),
      chest: d(map['chest']),
      waist: d(map['waist']),
      shoulder: d(map['shoulder']),
      sleeve: d(map['sleeve']),
      neck: d(map['neck']),
      daman: d(map['daman']),
      shalwarLength: d(map['shalwarLength']),
      shalwarWaist: d(map['shalwarWaist']),
      hip: d(map['hip']),
      pancha: d(map['pancha']),
      notes: (map['notes'] as String?) ?? '',
      collarStyle: (map['collarStyle'] as String?) ?? 'Collar',
      damanType: (map['damanType'] as String?) ?? 'Gol',
      sidePockets: (map['sidePockets'] as int?) ?? 1,
      frontPocket: ((map['frontPocket'] as int?) ?? 1) == 1,     // 1 -> true
      shalwarPocket: ((map['shalwarPocket'] as int?) ?? 1) == 1,
    );
  }
}