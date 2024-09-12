import 'dart:typed_data';

// import 'package:dayjs/dayjs.dart';
import 'package:collection/collection.dart';
import 'package:moonchain_wallet/features/common/common.dart';

typedef GetType = String Function();

class GetMappings {
  static const int last = 0;
  static const int pos = 1;
  static const int next = 2;
}

class BlueberryMethods {
  static final readLevel = Method(uid: 0x13, arg: [1]);
  static final readVersion = Method(uid: 0x27);
  static final readTime = Method(uid: 0x41);
  static final readSteps = Method(uid: 0x52, arg: [1], frag: true);
  static final readSleep = Method(uid: 0x53, arg: [1, 2, 3], frag: true);
  static final readHeartRates = Method(uid: 0x55, arg: [1, 2, 3], frag: true);
  static final readBloodOxygens = Method(uid: 0x66, arg: [1, 2, 3], frag: true);
  static final writeTime = Method(uid: 0x01, arg: [1, 2, 3, 4, 5, 6]);
  static final writeRestore = Method(uid: 0x12, arg: []);
}

class BlueberryCommands {
  static Uint8List readLevel() =>
      BlueberryCommandsUtils.parseMethodBytes(BlueberryMethods.readLevel);
  static Uint8List readVersion() =>
      BlueberryCommandsUtils.parseMethodBytes(BlueberryMethods.readVersion);
  static Uint8List readTime() =>
      BlueberryCommandsUtils.parseMethodBytes(BlueberryMethods.readTime);

  static Uint8List readSteps() {
    const mapping = GetMappings.last;
    return BlueberryCommandsUtils.parseMethodBytes(
        BlueberryMethods.readSteps, [mapping]);
  }

  static Uint8List readSleep() {
    const mapping = GetMappings.last;
    return BlueberryCommandsUtils.parseMethodBytes(
        BlueberryMethods.readSleep, [mapping]);
  }

  static Uint8List readHeartRates() {
    const mapping = GetMappings.last;
    return BlueberryCommandsUtils.parseMethodBytes(
        BlueberryMethods.readHeartRates, [mapping]);
  }

  static Uint8List readBloodOxygens() {
    const mapping = GetMappings.last;
    return BlueberryCommandsUtils.parseMethodBytes(
        BlueberryMethods.readBloodOxygens, [mapping]);
  }
}

class BlueberryResolves {
  static int readLevel(Uint8List data) => data[1];

  static String readVersion(Uint8List data) {
    final values = BlueberryCommandsUtils.radix16bcd(data, no0x: true)
        .map(int.parse)
        .toList();
    return '${values[1]}.${values[2]}${values[3]}${values[4]}';
  }

  static Uint8List readTime(Uint8List data) => data;

  static List<PeriodicSleepData> readSleep(Uint8List data) {
    final sleepDataList = BlueberryCommandsUtils.splitArrayByLength(
            BlueberryCommandsUtils.radix16bcd(data), 130)
        .map((e) => e.map(int.parse).toList())
        .where((item) => item[1] != 0xFF)
        .map((item) {
      final int id = parseInt([item[1], item[2]]);
      final int date =
          parseDate([item[3], item[4], item[5], item[6], item[7], item[8]]);
      final int length = item[9];
      final List<int> sleeps = item.sublist(10, item.length);
      return SleepData(id: id, sleeps: sleeps, length: length, date: date);
    }).toList();

    final periodicSleepData = sleepDataList
        .expand((item) => item.sleeps
            .mapIndexed<PeriodicSleepData>(
              (e, index) {
                final int date = item.date + (index * 60);
                return PeriodicSleepData(date: date, value: e);
              },
            )
            .where((e) => e.value != 0)
            .toList())
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return periodicSleepData;
  }

  static List<StepsData> readSteps(Uint8List data) {
    return BlueberryCommandsUtils.splitArrayByLength(
            BlueberryCommandsUtils.radix16bcd(data), 25)
        .map((item) => item.map(int.parse).toList())
        .toList()
        .where((item) => item[1] != 0xFF)
        .map((item) {
      final int id = parseInt([item[1], item[2]]);
      final int date =
          parseDate([item[3], item[4], item[5], item[6], item[7], item[8]]);
      final int step = parseInt([item[9], item[10]]);
      final int kcal = parseInt([item[11], item[12]]);
      final int km = parseInt([item[13], item[14]]);
      return StepsData(id: id, step: step, kcal: kcal, km: km, date: date);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static List<HeartRateData> readHeartRates(Uint8List data) {
    return BlueberryCommandsUtils.splitArrayByLength(
            BlueberryCommandsUtils.radix16bcd(data), 10)
        .map((item) => item.map(int.parse).toList())
        .toList()
        .where((item) => item[1] != 0xFF)
        .map((item) {
          final int id = parseInt([item[1], item[2]]);
          final int date =
              parseDate([item[3], item[4], item[5], item[6], item[7], item[8]]);
          final int value = item[9];
          return HeartRateData(id: id, value: value, date: date);
        })
        .where((e) => e.value != 0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static List<BloodOxygensData> readBloodOxygens(Uint8List data) {
    return BlueberryCommandsUtils.splitArrayByLength(
            BlueberryCommandsUtils.radix16bcd(data), 10)
        .map((item) => item.map(int.parse).toList())
        .where((item) => item[1] != 0xFF)
        .map((item) {
      final int id = parseInt([item[1], item[2]]);
      final int date =
          parseDate([item[3], item[4], item[5], item[6], item[7], item[8]]);
      final int value = item[9];
      return BloodOxygensData(id: id, value: value, date: date);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}

int parseDate(List<int> data) {
  // 200x24-0x06-0x05 0x06:0x39:0x02
  final parts = BlueberryCommandsUtils.radix16bcd(data, no0x: true);
  final ymd = '20${parts[0]}-${parts[1]}-${parts[2]}';
  final hms = '${parts[3]}:${parts[4]}:${parts[5]}';
  final date = DateTime.parse('$ymd $hms');
  return date.millisecondsSinceEpoch ~/ 1000;
}

int parseInt(List<int> data) {
  return int.parse(data.reversed.map((e) => e.toString()).join(''));
}
