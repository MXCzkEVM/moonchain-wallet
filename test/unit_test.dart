import 'package:datadashwallet/common/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatBigNumber', () {
    test('formats a big number greater than or equal to 1000000 correctly', () {
      final result = Formatter.formatBigNumber(320000000000);
      expect(result, equals('320B'));
    });
    test('formats a big number greater than or equal to 1000000 correctly', () {
      final result = Formatter.formatBigNumber(32000000000);
      expect(result, equals('32B'));
    });
    test('formats a big number greater than or equal to 1000000 correctly', () {
      final result = Formatter.formatBigNumber(320000000);
      expect(result, equals('320M'));
    });

    test('formats a big number greater than or equal to 1000000 correctly', () {
      final result = Formatter.formatBigNumber(1200000);
      expect(result, equals('1.2M'));
    });

    test('formats a big number between 1000 and 999999 correctly', () {
      final result = Formatter.formatBigNumber(2500);
      expect(result, equals('2.5K'));
    });

    test('formats a big number less than 1000 correctly', () {
      final result = Formatter.formatBigNumber(500);
      expect(result, equals('500'));
    });

    test('formats a big number less than 1000 correctly', () {
      final result = Formatter.formatBigNumber(500.654);
      expect(result, equals('500.654'));
    });

    test('formats a big number less than 1000 correctly', () {
      final result = Formatter.formatBigNumber(0.0001);
      expect(result, equals('0.0001'));
    });
  });

  group('formatWalletAddress', () {
    test('formats a wallet correctly', () {
      final result = Formatter.formatWalletAddress(
          "0xE87FfF848427687077d522d1A04449902d34083a");
      expect(result, equals('0xE87...083a'));
    });

    test('formats a wallet correctly', () {
      final result = Formatter.formatWalletAddress(
          "0x3393961d01C6513f44f2655D60AB9613F47fD6b5");
      expect(result, equals('0x339...D6b5'));
    });
  });
}
