import 'package:Agragami/auth/prasentation/widgets/appValidators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppValidators.userId', () {
    test('null value is rejected', () {
      expect(AppValidators.userId(null), 'Enter User ID');
    });

    test('empty / whitespace value is rejected', () {
      expect(AppValidators.userId(''), 'Enter User ID');
      expect(AppValidators.userId('   '), 'Enter User ID');
    });

    test('valid user id passes', () {
      expect(AppValidators.userId('AG24M001'), isNull);
    });
  });

  group('AppValidators.requiredField', () {
    test('null and empty values are rejected with field name', () {
      expect(AppValidators.requiredField(null, 'Name'), 'Name is required');
      expect(AppValidators.requiredField('  ', 'Name'), 'Name is required');
    });

    test('filled value passes', () {
      expect(AppValidators.requiredField('Rahim', 'Name'), isNull);
    });
  });

  group('AppValidators.email', () {
    test('null / empty is rejected', () {
      expect(AppValidators.email(null), 'Please enter an email');
      expect(AppValidators.email(''), 'Please enter an email');
    });

    test('missing @ is rejected', () {
      expect(AppValidators.email('rahim.mail.com'), 'Please enter a valid email');
    });

    test('missing dot is rejected', () {
      expect(AppValidators.email('rahim@mail'), 'Please enter a valid email');
    });

    test('valid emails pass', () {
      expect(AppValidators.email('rahim@mail.com'), isNull);
      expect(AppValidators.email('  rahim@mail.com  '), isNull);
    });
  });

  group('AppValidators.password', () {
    test('null / empty is rejected', () {
      expect(AppValidators.password(null), 'Password is required');
      expect(AppValidators.password(''), 'Password is required');
    });

    test('shorter than 8 characters is rejected', () {
      expect(
        AppValidators.password('Ab1!xyz'),
        'Password must be at least 8 characters',
      );
    });

    test('8+ characters passes', () {
      expect(AppValidators.password('Abcdefg1'), isNull);
    });
  });

  group('AppValidators.confirmPassword', () {
    test('null / empty is rejected', () {
      expect(
        AppValidators.confirmPassword(null, 'Abcdefg1'),
        'Please confirm your password',
      );
    });

    test('mismatch is rejected', () {
      expect(
        AppValidators.confirmPassword('Abcdefg2', 'Abcdefg1'),
        'Passwords do not match',
      );
    });

    test('matching password passes', () {
      expect(AppValidators.confirmPassword('Abcdefg1', 'Abcdefg1'), isNull);
    });
  });

  group('AppValidators.phone', () {
    test('empty is rejected', () {
      expect(AppValidators.phone(null), 'Phone is required');
      expect(AppValidators.phone(''), 'Phone is required');
    });

    test('valid bangladeshi numbers pass', () {
      expect(AppValidators.phone('01712345678'), isNull);
      expect(AppValidators.phone('01912345678'), isNull);
      expect(AppValidators.phone('+8801712345678'), isNull);
    });

    test('invalid numbers are rejected', () {
      expect(AppValidators.phone('0112345678'), 'Enter valid Bangladesh phone');
      expect(AppValidators.phone('12345'), 'Enter valid Bangladesh phone');
      expect(AppValidators.phone('0171234567'), 'Enter valid Bangladesh phone');
    });
  });

  group('AppValidators.Nid', () {
    test('empty is rejected', () {
      expect(AppValidators.Nid(null), 'NID is required');
      expect(AppValidators.Nid('   '), 'NID is required');
    });

    test('non digit / wrong length is rejected', () {
      expect(AppValidators.Nid('12345'), 'NID must be 10–17 digits long');
      expect(AppValidators.Nid('abcdefghij'), 'NID must be 10–17 digits long');
      expect(
        AppValidators.Nid('1234567890123456789'),
        'NID must be 10–17 digits long',
      );
    });

    test('10 to 17 digits pass', () {
      expect(AppValidators.Nid('1234567890'), isNull);
      expect(AppValidators.Nid('12345678901234567'), isNull);
    });
  });

  group('AppValidators.nominee & nomineeRelation', () {
    test('empty nominee is rejected', () {
      expect(AppValidators.nominee(''), 'Nominee Name is required');
      expect(AppValidators.nominee(null), 'Nominee Name is required');
    });

    test('empty nominee relation is rejected', () {
      expect(AppValidators.nomineeRelation(''), 'Nominee Relation is required');
      expect(AppValidators.nomineeRelation(null), 'Nominee Relation is required');
    });

    test('filled values pass', () {
      expect(AppValidators.nominee('Karim'), isNull);
      expect(AppValidators.nomineeRelation('Father'), isNull);
    });
  });
}
