class ProgramIntervensi {
  final String namaProgram;
  final String deskripsi;
  final int idProgram;
  final String tanggalPosting;

  ProgramIntervensi({
    required this.namaProgram,
    required this.deskripsi,
    required this.idProgram,
    required this.tanggalPosting,
  });

  factory ProgramIntervensi.fromFirestore(Map<String, dynamic> data) {
    return ProgramIntervensi(
      namaProgram: data['nama_program'] as String,
      deskripsi: data['deskripsi'] as String,
      idProgram: data['id_program'] as int,
      tanggalPosting: data['tanggal_posting'] as String,
    );
  }
}
