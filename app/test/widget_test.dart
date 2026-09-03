import 'package:flutter_test/flutter_test.dart';
import 'package:trovey/theme/tokens.dart';

void main() {
  test('sky wash is not the generic cream template', () {
    expect(TroveyColors.sky.toARGB32(), isNot(0xFFF4F1EA));
  });
}
