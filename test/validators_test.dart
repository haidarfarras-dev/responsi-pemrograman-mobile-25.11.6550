import 'package:flutter_test/flutter_test.dart';
import 'package:responsi_profil_mahasiswa/utils/validators.dart';

void main() {
  group('sanitize', () {
    test('menghapus karakter < > " dan \'', () {
      expect(Validators.sanitize('<b>"Halo"</b> \'dunia\''), 'bHalo/b dunia');
    });

    test('singleLine memadatkan whitespace', () {
      expect(Validators.sanitize('a  \n b', singleLine: true), 'a b');
    });
  });

  group('validateTitle', () {
    test('kosong ditolak', () => expect(Validators.validateTitle(''), isNotNull));
    test('kurang dari 3 ditolak', () => expect(Validators.validateTitle('ab'), isNotNull));
    test('3 karakter diterima', () => expect(Validators.validateTitle('abc'), isNull));
    test('50 karakter diterima', () => expect(Validators.validateTitle('a' * 50), isNull));
    test('51 karakter ditolak', () => expect(Validators.validateTitle('a' * 51), isNotNull));
    test('hanya karakter khusus ditolak', () => expect(Validators.validateTitle('<<<>>>'), isNotNull));
  });

  group('validateContent', () {
    test('kurang dari 10 ditolak', () => expect(Validators.validateContent('pendek'), isNotNull));
    test('10 karakter diterima', () => expect(Validators.validateContent('a' * 10), isNull));
    test('1000 karakter diterima', () => expect(Validators.validateContent('a' * 1000), isNull));
    test('1001 karakter ditolak', () => expect(Validators.validateContent('a' * 1001), isNotNull));
  });

  group('profil', () {
    test('NIM valid', () => expect(Validators.validateNim('25.11.6550'), isNull));
    test('NIM huruf ditolak', () => expect(Validators.validateNim('abc123'), isNotNull));
    test('email valid', () => expect(Validators.validateEmail('a@b.ac.id'), isNull));
    test('email tidak valid', () => expect(Validators.validateEmail('abc'), isNotNull));
  });
}
