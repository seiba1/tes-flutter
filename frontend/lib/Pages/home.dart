import 'package:flutter/material.dart';
import '../Service/serviceapi.dart';
import './ss_them.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, String> _user = {};
  List _kamera = [];
  bool _loadingKamera = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _user = await ServiceApi.getUserInfo();
    final res = await ServiceApi.getKamera();
    if (!mounted) return;
    setState(() {
      _loadingKamera = false;
      if (res is Map && res['status'] == 'success') {
        _kamera = res['data'] ?? [];
      }
    });
  }

  void _logout() async {
    await ServiceApi.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
  }

  int get _aktif => _kamera.where((k) => k['status'] == 'aktif').length;
  int get _maint => _kamera.where((k) => k['status'] == 'maintenance').length;
  int get _offline => _kamera.where((k) => k['status'] == 'nonaktif').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: bgGradient,
        child: SafeArea(
          child: Column(
            children: [
              // ── Navbar ──
              Container(
                color: ssWhite,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [ssBlue500, ssBlue700]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.videocam_rounded, color: ssWhite, size: 20),
                    ),
                    const SizedBox(width: 10),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w900),
                        children: [
                          TextSpan(text: "Smart", style: TextStyle(color: ssGray800)),
                          TextSpan(text: "Studio", style: TextStyle(color: ssBlue600)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        builder: (_) => _logoutSheet(),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xffEFF6FF),
                        child: Text(
                          (_user['username'] ?? 'U').substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: ssBlue600, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Greeting
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [ssBlue500, ssBlue700],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: ssBlue600.withValues(alpha: 0.3),
                                blurRadius: 16, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Selamat datang, ${_user['username'] ?? 'User'} 👋",
                                style: const TextStyle(color: ssWhite, fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(_user['email'] ?? '',
                                style: const TextStyle(color: Color(0xffBFDBFE), fontSize: 12)),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: ssWhite.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _user['role'] == 'admin' ? '👑 Admin' : '👤 User',
                                style: const TextStyle(color: ssWhite, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stat Cards
                      const Text("Statistik Kamera",
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 16,
                              fontWeight: FontWeight.w800, color: ssGray800)),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: _statCard("${_kamera.length}", "Total",
                            ssBlue600, Icons.videocam_rounded, const Color(0xffEFF6FF))),
                        const SizedBox(width: 10),
                        Expanded(child: _statCard("$_aktif", "Aktif",
                            ssGreenD, Icons.check_circle_rounded, const Color(0xffF0FDF4))),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: _statCard("$_maint", "Maintenance",
                            const Color(0xffD97706), Icons.warning_rounded, const Color(0xffFFFBEB))),
                        const SizedBox(width: 10),
                        Expanded(child: _statCard("$_offline", "Offline",
                            const Color(0xffDC2626), Icons.cancel_rounded, const Color(0xffFEF2F2))),
                      ]),
                      const SizedBox(height: 20),

                      // Daftar Kamera
                      const Text("Daftar Kamera",
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 16,
                              fontWeight: FontWeight.w800, color: ssGray800)),
                      const SizedBox(height: 10),
                      _loadingKamera
                          ? const Center(child: CircularProgressIndicator(color: ssBlue500))
                          : _kamera.isEmpty
                              ? _emptyKamera()
                              : Column(children: _kamera.map((k) => _kameraCard(k)).toList()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color, IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ssWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x142563EB), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
              color: color, fontFamily: 'Nunito')),
          Text(label, style: const TextStyle(fontSize: 11, color: ssGray500, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }

  Widget _kameraCard(Map k) {
    final status = k['status'] ?? 'nonaktif';
    final Color statusColor = status == 'aktif' ? ssGreenD
        : status == 'maintenance' ? const Color(0xffD97706) : const Color(0xffDC2626);
    final Color statusBg = status == 'aktif' ? const Color(0xffF0FDF4)
        : status == 'maintenance' ? const Color(0xffFFFBEB) : const Color(0xffFEF2F2);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ssWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0F2563EB), blurRadius: 12, offset: Offset(0, 3))],
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: const Color(0xffEFF6FF), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.videocam_rounded, color: ssBlue600, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k['nama'] ?? '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ssGray800)),
          Text(k['lokasi'] ?? '-', style: const TextStyle(fontSize: 12, color: ssGray500)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
          child: Text(status[0].toUpperCase() + status.substring(1),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
        ),
      ]),
    );
  }

  Widget _emptyKamera() => Container(
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(color: ssWhite, borderRadius: BorderRadius.circular(16)),
    child: const Column(children: [
      Icon(Icons.videocam_off_rounded, size: 48, color: ssGray300),
      SizedBox(height: 12),
      Text("Belum ada kamera terdaftar", style: TextStyle(color: ssGray500, fontSize: 14)),
    ]),
  );

  Widget _logoutSheet() => Container(
    padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40, height: 4,
          decoration: BoxDecoration(color: ssGray200, borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 20),
      CircleAvatar(
        radius: 28,
        backgroundColor: const Color(0xffEFF6FF),
        child: Text((_user['username'] ?? 'U').substring(0, 1).toUpperCase(),
            style: const TextStyle(color: ssBlue600, fontWeight: FontWeight.w800, fontSize: 22)),
      ),
      const SizedBox(height: 10),
      Text(_user['username'] ?? '',
          style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w800, color: ssGray800)),
      Text(_user['email'] ?? '', style: const TextStyle(fontSize: 12, color: ssGray500)),
      const SizedBox(height: 24),
      SSButton(label: "Keluar", isLoading: false, onPressed: _logout,
          colors: const [Color(0xffEF4444), Color(0xffDC2626)]),
      const SizedBox(height: 12),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("Batal", style: TextStyle(color: ssGray500, fontSize: 14)),
      ),
    ]),
  );
}