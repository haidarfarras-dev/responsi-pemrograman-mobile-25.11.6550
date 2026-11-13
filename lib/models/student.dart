/// Model data mahasiswa yang ditampilkan pada halaman profil.
class Student {
  /// Membuat objek [Student] yang immutable.
  const Student({
    required this.name,
    required this.nim,
    required this.programStudi,
    required this.email,
  });

  /// Profil bawaan yang dipakai saat aplikasi pertama kali dijalankan.
  static const Student defaultProfile = Student(
    name: 'M. Haidar Farras Albar Ramadani',
    nim: '25.11.6550',
    programStudi: 'Informatika',
    email: 'email@students.amikom.ac.id',
  );

  /// Nama lengkap mahasiswa.
  final String name;

  /// Nomor induk mahasiswa.
  final String nim;

  /// Program studi mahasiswa.
  final String programStudi;

  /// Alamat email mahasiswa.
  final String email;

  /// Inisial (maksimal dua huruf) yang diambil dari [name].
  String get initials {
    final words =
        name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  /// Membuat salinan [Student] dengan field tertentu diganti.
  Student copyWith({
    String? name,
    String? nim,
    String? programStudi,
    String? email,
  }) {
    return Student(
      name: name ?? this.name,
      nim: nim ?? this.nim,
      programStudi: programStudi ?? this.programStudi,
      email: email ?? this.email,
    );
  }

  /// Mengubah objek menjadi map JSON untuk disimpan.
  Map<String, dynamic> toJson() => {
        'name': name,
        'nim': nim,
        'programStudi': programStudi,
        'email': email,
      };

  /// Membuat [Student] dari map JSON.
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'] as String? ?? '',
      nim: json['nim'] as String? ?? '',
      programStudi: json['programStudi'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Student &&
          other.name == name &&
          other.nim == nim &&
          other.programStudi == programStudi &&
          other.email == email;

  @override
  int get hashCode => Object.hash(name, nim, programStudi, email);
}
