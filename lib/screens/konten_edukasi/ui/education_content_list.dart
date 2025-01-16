import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'education_content_detail_screen.dart';

class EducationContentListScreen extends StatefulWidget {
  @override
  _EducationContentListScreenState createState() =>
      _EducationContentListScreenState();
}

class _EducationContentListScreenState
    extends State<EducationContentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  String _selectedRange = 'Semua';

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
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Konten Edukasi',
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
                    hintText: 'Cari konten berdasarkan judul...',
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
              )
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('konten').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Terjadi kesalahan'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final kontenList = snapshot.data!.docs.map((doc) {
              final konten = doc.data() as Map<String, dynamic>;
              final DateTime postingDate =
                  DateTime.parse(konten['tanggal_posting']);
              return konten..['posting_date'] = postingDate;
            }).where((konten) {
              final DateTime postingDate = konten['posting_date'] as DateTime;
              return konten['judul']
                      .toString()
                      .toLowerCase()
                      .contains(_searchText) &&
                  _isWithinTimeRange(postingDate);
            }).toList();

            if (kontenList.isEmpty) {
              return const Center(child: Text("Konten tidak ditemukan."));
            }

            return ListView.builder(
              itemCount: kontenList.length,
              itemBuilder: (context, index) {
                final konten = kontenList[index];

                final String judul = konten['judul'] ?? 'Tanpa Judul';
                final String isiKonten =
                    konten['konten'] ?? 'Deskripsi tidak tersedia';
                final String summary = isiKonten.length > 100
                    ? isiKonten.substring(0, 100) + '...'
                    : isiKonten;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EducationContentDetailScreen(
                            konten: konten,
                          ),
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
                          // Icon di sebelah kiri judul
                          Icon(
                            Icons.school,
                            size: 40,
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Menampilkan judul
                                Text(
                                  judul,
                                  style: GoogleFonts.lato(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Menampilkan ringkasan konten
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
      ),
    );
  }
}
