import 'package:intl/intl.dart';

class Grouping<T> {
  List<Map<String, dynamic>> daysGrouping(
      List<T> array, int Function(T) getDate) {
    Map<String, bool> groups = {};
    for (var item in array) {
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(getDate(item) * 1000);
      groups[DateFormat('yyyy-MM-dd').format(dateTime)] = true;
    }

    final List<Map<String, dynamic>> group = groups.keys.map((day) {
      DateTime time = DateFormat('yyyy-MM-dd').parse(day);
      int start = time.millisecondsSinceEpoch ~/ 1000;
      int end = start + 86400;
      return {
        'start': start,
        'time': time,
        'end': end
      };
    }).toList();

    group.sort((a, b) => (a['start'] as int).compareTo(b['start'] as int));

    return group.map((e) {
      List<T> data = array.where((item) {
        int itemDate = getDate(item);
        return itemDate > e['start'] && itemDate < e['end'];
      }).toList();
      return {
        'time': e['time'],
        'day': DateFormat('dd/MM').format(e['time']),
        'data': data,
        'ytd': DateFormat('yyyy-MM-dd').format(e['time'])
      };
    }).toList();

  }

  List<Map<String, dynamic>> hourGrouping(
      List<T> array, int diff, int Function(T) getDate) {
    if (array.isEmpty) return [];
    List<int> interval = dayInterval(getDate(array[0]));
    int start = interval[0];
    int end = interval[1];
    return arange(start, end, diff).map((date) {
      DateTime time = DateTime.fromMillisecondsSinceEpoch(date * 1000);
      List<T> data = array.where((item) {
        int itemDate = getDate(item);
        return itemDate > date && itemDate < (date + diff);
      }).toList();
      return {
        'hour': DateFormat('HH:mm').format(time),
        'time': time,
        'data': data
      };
    }).toList();
  }

  List<Map<String, dynamic>> diffGrouping(
      List<T> array, int difference, int Function(T) getDate) {
    if (array.isEmpty) return [];
    array.sort((a, b) => getDate(a).compareTo(getDate(b)));
    List<List<T>> grouped = [];
    List<T> group = [array[0]];
    for (int i = 1; i < array.length; i++) {
      if (getDate(array[i]) - getDate(group.last) <= difference) {
        group.add(array[i]);
      } else {
        grouped.add(group);
        group = [array[i]];
      }
    }
    if (group.isNotEmpty) grouped.add(group);

    return grouped.map((data) {
      DateTime time =
          DateTime.fromMillisecondsSinceEpoch(getDate(data.last) * 1000);
      return {
        'day': DateFormat('dd/MM').format(time),
        'time': time,
        'data': data
      };
    }).toList();
  }

  List<int> dayInterval(int unix) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unix * 1000);
    DateTime start = DateTime(dateTime.year, dateTime.month, dateTime.day);
    DateTime end =
        DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
    return [
      start.millisecondsSinceEpoch ~/ 1000,
      end.millisecondsSinceEpoch ~/ 1000
    ];
  }
}

// Example usage with a sample class
class Sample {
  int date;
  Sample(this.date);
}

void main() {
  List<Sample> samples = [
    Sample(1609459200), // 2021-01-01
    Sample(1609545600), // 2021-01-02
    Sample(1609632000), // 2021-01-03
  ];

  Grouping<Sample> grouping = Grouping<Sample>();

  print(grouping.daysGrouping(samples, (sample) => sample.date));
  print(grouping.hourGrouping(samples, 3600, (sample) => sample.date));
  print(grouping.diffGrouping(samples, 86400, (sample) => sample.date));
}

List<int> arange(int x1, [int? x2, int stp = 1]) {
  List<int> z = [];
  if (x2 == null) {
    x2 = x1;
    x1 = 0;
  }
  for (int x = x1; x < x2; x += stp) {
    z.add(x);
  }
  return z;
}
