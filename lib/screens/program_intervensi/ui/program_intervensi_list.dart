import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'program_detail_page.dart';
import '../../../model/program_intervensi.dart';

class ProgramIntervensiListPage extends StatefulWidget {
  const ProgramIntervensiListPage({super.key});

  @override
  _ProgramIntervensiListPageState createState() =>
      _ProgramIntervensiListPageState();
}

class _ProgramIntervensiListPageState extends State<ProgramIntervensiListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  String _selectedRange = 'Semua'; // Rentang waktu terpilih

  final List<String> _timeRangeOptions = [
    'Semua',
    'Hari ini',
    'Satu Minggu',
    'Satu Bulan',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk memeriksa apakah program ada di dalam rentang waktu
  bool _isWithinTimeRange(DateTime postingDate) {
    final now = DateTime.now();
    switch (_selectedRange) {
      case 'Hari ini':
        return postingDate.year == now.year &&
            postingDate.month == now.month &&
            postingDate.day == now.day;
      case 'Satu Minggu':
        return postingDate.isAfter(now.subtract(const Duration(days: 7)));
      case 'Satu Bulan':
        return postingDate.isAfter(now.subtract(const Duration(days: 30)));
      default:
        return true; // Jika 'Semua', tidak ada filter berdasarkan waktu
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Program Intervensi',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.lato(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari program berdasarkan judul...',
                    hintStyle: GoogleFonts.lato(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  cursorColor: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedRange,
                  icon: const Icon(Icons.arrow_downward, color: Colors.white),
                  iconSize: 24,
                  elevation: 16,
                  style: GoogleFonts.lato(color: Colors.white),
                  underline: Container(
                    height: 2,
                    color: Colors.white,
                  ),
                  dropdownColor: Colors.white,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRange = newValue!;
                    });
                  },
                  selectedItemBuilder: (BuildContext context) {
                    return _timeRangeOptions.map<Widget>((String item) {
                      return Text(item,
                          style: GoogleFonts.lato(color: Colors.white));
                    }).toList();
                  },
                  items: _timeRangeOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: GoogleFonts.lato(color: Colors.black),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('program_intervensi')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tidak ada program intervensi."));
          }

          // Mengambil data program dan filter berdasarkan pencarian dan rentang waktu
          final programList = snapshot.data!.docs.map((doc) {
            return ProgramIntervensi.fromFirestore(
                doc.data() as Map<String, dynamic>);
          }).where((program) {
            final DateTime postingDate = DateTime.parse(program.tanggalPosting);

            // Filter berdasarkan pencarian dan rentang waktu
            return program.namaProgram.toLowerCase().contains(_searchText) &&
                _isWithinTimeRange(postingDate);
          }).toList();

          if (programList.isEmpty) {
            return const Center(child: Text("Program tidak ditemukan."));
          }

          return ListView.builder(
            itemCount: programList.length,
            itemBuilder: (context, index) {
              final program = programList[index];
              final String summary = program.deskripsi.length > 100
                  ? "${program.deskripsi.substring(0, 100)}..."
                  : program.deskripsi;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () {
                    // Navigasi ke halaman detail
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProgramDetailPage(program: program),
                      ),
                    );
                  },
                  splashColor: Colors.blueAccent.withOpacity(0.2),
                  highlightColor: Colors.blueAccent.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.assignment,
                          size: 40,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Menampilkan nama program
                              Text(
                                program.namaProgram,
                                style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Menampilkan ringkasan deskripsi program
                              Text(
                                summary,
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
