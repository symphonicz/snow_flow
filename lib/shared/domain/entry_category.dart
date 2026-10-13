import 'package:equatable/equatable.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';

/// One stroke of a category icon on a 24×24 grid (brief §5). Drawn by the
/// presentation layer with stroke 1.8, round caps and joins, no fill.
sealed class IconShape extends Equatable {
  const IconShape();
}

/// SVG path data, e.g. `M4 11h16`.
class PathShape extends IconShape {
  const PathShape(this.data);

  final String data;

  @override
  List<Object> get props => [data];
}

class RectShape extends IconShape {
  const RectShape({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.rx,
  });

  final double x;
  final double y;
  final double width;
  final double height;
  final double rx;

  @override
  List<Object> get props => [x, y, width, height, rx];
}

class CircleShape extends IconShape {
  const CircleShape({required this.cx, required this.cy, required this.r});

  final double cx;
  final double cy;
  final double r;

  @override
  List<Object> get props => [cx, cy, r];
}

class EllipseShape extends IconShape {
  const EllipseShape({
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
  });

  final double cx;
  final double cy;
  final double rx;
  final double ry;

  @override
  List<Object> get props => [cx, cy, rx, ry];
}

/// A fixed category from brief §5. Colors are ARGB ints because domain/
/// must not import Flutter (#54).
class EntryCategory extends Equatable {
  const EntryCategory({
    required this.id,
    required this.nameTh,
    required this.nameEn,
    required this.types,
    required this.lightColor,
    int? darkColor,
    required this.icon,
  }) : darkColor = darkColor ?? lightColor;

  /// Stored in entries and backups; never change it.
  final String id;
  final String nameTh;
  final String nameEn;
  final Set<EntryType> types;
  final int lightColor;
  final int darkColor;
  final List<IconShape> icon;

  bool allows(EntryType type) => types.contains(type);

  @override
  List<Object> get props => [id];
}

/// The category table of brief §5.
abstract final class Categories {
  static const food = EntryCategory(
    id: 'food',
    nameTh: 'อาหาร',
    nameEn: 'Food',
    types: {EntryType.expense},
    lightColor: 0xFFE07B39,
    icon: [
      PathShape('M4 11h16a8 8 0 0 1-16 0Z'),
      PathShape('M9 7.5c0-1.2 1.2-1.2 1.2-2.5M13.5 7.5c0-1.2 1.2-1.2 1.2-2.5'),
    ],
  );

  static const transport = EntryCategory(
    id: 'transport',
    nameTh: 'เดินทาง',
    nameEn: 'Transport',
    types: {EntryType.expense},
    lightColor: 0xFF3B82C4,
    icon: [
      RectShape(x: 5, y: 4, width: 14, height: 13, rx: 2.5),
      PathShape('M5 11h14M8.5 20v-3M15.5 20v-3'),
    ],
  );

  static const shopping = EntryCategory(
    id: 'shopping',
    nameTh: 'ช้อปปิ้ง',
    nameEn: 'Shopping',
    types: {EntryType.expense},
    lightColor: 0xFFB04A9A,
    icon: [PathShape('M6 8h12l-1 12H7L6 8Z'), PathShape('M9 8a3 3 0 0 1 6 0')],
  );

  static const bills = EntryCategory(
    id: 'bills',
    nameTh: 'บิล/ค่าน้ำไฟ',
    nameEn: 'Bills',
    types: {EntryType.expense},
    lightColor: 0xFF6B5BC4,
    icon: [PathShape('M13 3 6 13h5l-1 8 7-10h-5l1-8Z')],
  );

  static const fun = EntryCategory(
    id: 'fun',
    nameTh: 'บันเทิง',
    nameEn: 'Fun',
    types: {EntryType.expense},
    lightColor: 0xFFC99412,
    icon: [
      PathShape(
        'm12 4 2.4 5 5.6.8-4 3.9 1 5.6-5-2.7-5 2.7 1-5.6-4-3.9 5.6-.8Z',
      ),
    ],
  );

  static const health = EntryCategory(
    id: 'health',
    nameTh: 'สุขภาพ',
    nameEn: 'Health',
    types: {EntryType.expense},
    lightColor: 0xFF2A9D8F,
    icon: [
      PathShape(
        'M12 20s-7-4.4-7-10a4 4 0 0 1 7-2.5A4 4 0 0 1 19 10c0 5.6-7 10-7 10Z',
      ),
    ],
  );

  static const other = EntryCategory(
    id: 'other',
    nameTh: 'อื่นๆ',
    nameEn: 'Other',
    types: {EntryType.expense, EntryType.income},
    lightColor: 0xFF7C879A,
    icon: [
      CircleShape(cx: 6, cy: 12, r: 1.2),
      CircleShape(cx: 12, cy: 12, r: 1.2),
      CircleShape(cx: 18, cy: 12, r: 1.2),
    ],
  );

  static const salary = EntryCategory(
    id: 'salary',
    nameTh: 'เงินเดือน',
    nameEn: 'Salary',
    types: {EntryType.income},
    lightColor: 0xFF0B7A63,
    darkColor: 0xFF4CC3A6,
    icon: [
      RectShape(x: 3, y: 6, width: 18, height: 13, rx: 2.5),
      PathShape('M16 12.5h2M3 9.5h18'),
    ],
  );

  static const side = EntryCategory(
    id: 'side',
    nameTh: 'รายได้เสริม',
    nameEn: 'Side income',
    types: {EntryType.income},
    lightColor: 0xFF2A9D8F,
    icon: [
      PathShape('M12 15V9'),
      PathShape('M12 10.5c0-3 2-5 5-5 0 3-2 5-5 5Z'),
      PathShape('M12 12c0-2.4-1.6-4-4-4 0 2.4 1.6 4 4 4Z'),
      EllipseShape(cx: 12, cy: 18, rx: 7, ry: 2.5),
    ],
  );

  static const transfer = EntryCategory(
    id: 'transfer',
    nameTh: 'ได้รับโอน',
    nameEn: 'Received',
    types: {EntryType.income},
    lightColor: 0xFF3B82C4,
    icon: [PathShape('M17 7 7 17M7 9v8h8')],
  );

  static const all = [
    food,
    transport,
    shopping,
    bills,
    fun,
    health,
    other,
    salary,
    side,
    transfer,
  ];

  static final _byId = {for (final category in all) category.id: category};

  static EntryCategory? byId(String id) => _byId[id];

  /// Categories for the form picker. `other` goes last so the first
  /// (default) category is never `other` (#54).
  static List<EntryCategory> forType(EntryType type) => [
    for (final category in all)
      if (category != other && category.allows(type)) category,
    other,
  ];
}
