import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SubhanApp());
}

// ========== الثوابت والألوان ==========
class AppColors {
  // الوضع العادي (النابض بالحياة)
  static const Color bgLight = Color(0xFF050D14);
  static const Color cardLight = Color(0xFF142633);
  static const Color primaryLight = Color(0xFF33B299);
  static const Color accentLight = Color(0xFFFFBF33);
  static const Color textLight = Color(0xFFFAFAEF);
  static const Color textMutedLight = Color(0xFF99BFCC);

  // الوضع الليلي
  static const Color bgDark = Color(0xFF030308);
  static const Color cardDark = Color(0xFF0D0D1A);
  static const Color primaryDark = Color(0xFF1A6659);
  static const Color accentDark = Color(0xFFD99B26);
  static const Color textDark = Color(0xFFE6E6F2);
  static const Color textMutedDark = Color(0xFF8099B3);

  static const Color danger = Color(0xFFD94040);
  static const Color success = Color(0xFF33D966);

  static const List<Color> counterColors = [
    Color(0xFFFFD700), // ذهبي
    Color(0xFF33D966), // أخضر
    Color(0xFF3380E6), // أزرق
    Color(0xFF994DCC), // بنفسجي
    Color(0xFFE6334D), // أحمر
    Color(0xFFFF8C1A), // برتقالي
    Color(0xFFF26699), // وردي
  ];

  static Color getCounterColor(int count) {
    int index = (count ~/ 100).clamp(0, counterColors.length - 1);
    return counterColors[index];
  }
}

// ========== البيانات الأساسية (أذكار وأدعية) ==========
final Map<String, List<Map<String, dynamic>>> azkarData = {
  "أذكار الصباح": [
    {"text": "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ رَبِّ الْعَالَمِينَ", "count": 1},
    {"text": "رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا وَبِمُحَمَّدٍ نَبِيًّا", "count": 1},
    {"text": "اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ", "count": 1},
    {"text": "حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ", "count": 7},
    {"text": "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ وَزِنَةَ عَرْشِهِ وَمِدَادَ كَلِمَاتِهِ", "count": 3},
  ],
  "أذكار المساء": [
    {"text": "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ رَبِّ الْعَالَمِينَ", "count": 1},
    {"text": "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ", "count": 3},
    {"text": "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ", "count": 3},
  ],
  "بعد الصلاة": [
    {"text": "أَسْتَغْفِرُ اللَّهَ", "count": 3},
    {"text": "سُبْحَانَ اللَّهِ", "count": 33},
    {"text": "الْحَمْدُ لِلَّهِ", "count": 33},
    {"text": "اللَّهُ أَكْبَرُ", "count": 34},
  ],
};

final Map<String, List<Map<String, String>>> adiyaData = {
  "أدعية قرآنية": [
    {"text": "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ", "source": "البقرة 201"},
    {"text": "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي", "source": "طه 25-26"},
    {"text": "رَبِّ زِدْنِي عِلْمًا", "source": "طه 114"},
  ],
  "أدعية نبوية": [
    {"text": "اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى", "source": "مسلم"},
    {"text": "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ وَالْعَجْزِ وَالْكَسَلِ", "source": "البخاري"},
  ],
};

// ========== التطبيق الرئيسي ==========
class SubhanApp extends StatefulWidget {
  const SubhanApp({Key? key}) : super(key: key);

  @override
  State<SubhanApp> createState() => _SubhanAppState();

  static _SubhanAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_SubhanAppState>()!;
}

class _SubhanAppState extends State<SubhanApp> {
  bool isNightMode = false;

  void toggleTheme(bool value) {
    setState(() {
      isNightMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سُبْحَان',
      debugShowCheckedModeBanner: false,
      themeMode: isNightMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.bgLight,
        primaryColor: AppColors.primaryLight,
        fontFamily: 'NotoNaskhArabic',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark,
        primaryColor: AppColors.primaryDark,
        fontFamily: 'NotoNaskhArabic',
      ),
      home: const HomeScreen(),
    );
  }
}

// ========== الشاشة الرئيسية ==========
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int count = 0;
  int yesterday = 0;
  int totalAllTime = 0;
  int target = 33;
  List<String> favorites = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      count = prefs.getInt('count') ?? 0;
      yesterday = prefs.getInt('yesterday') ?? 0;
      totalAllTime = prefs.getInt('total_all_time') ?? 0;
      target = prefs.getInt('target') ?? 33;
      favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = SubhanApp.of(context).isNightMode;
    final bgCard = isDark ? AppColors.cardDark : AppColors.cardLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              // الهيدر
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "✨ سُبْحَان ✨",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: accentColor),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.redAccent),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesScreen(favorites: favorites))),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        color: textColor,
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // بطاقة التاريخ والإحصائيات السريعة
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: bgCard,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: const Offset(0, 3))],
                ),
                child: Column(
                  children: [
                    Text("۩ بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem("اليوم", "$count", textColor),
                        _statItem("الأمس", "$yesterday", textColor),
                        _statItem("الإجمالي", "$totalAllTime", textColor),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // أزرار التنقل الرئيسية
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    _menuCard(context, "✨ المسبحة الإلكترونية", const TasbihScreen(), Colors.teal),
                    _menuCard(context, "📖 الأذكار اليومية", const AzkarScreen(), Colors.indigo),
                    _menuCard(context, "🙏 الأدعية المباركة", const DuaaScreen(), Colors.deepPurple),
                    _menuCard(context, "📊 إحصاءات وحفظ", SettingsScreen(), Colors.brown),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.7))),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _menuCard(BuildContext context, String title, Widget screen, Color color) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// ========== شاشة المسبحة الإلكترونية ==========
class TasbihScreen extends StatefulWidget {
  const TasbihScreen({Key? key}) : super(key: key);

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int count = 0;
  int target = 33;
  String currentZikr = "سُبْحَانَ اللَّهِ";

  void increment() async {
    setState(() {
      count++;
    });
    if (count >= target) {
      _saveCommit();
    }
  }

  void _saveCommit() async {
    final prefs = await SharedPreferences.getInstance();
    int total = prefs.getInt('total_all_time') ?? 0;
    total += count;
    await prefs.setInt('total_all_time', total);
    await prefs.setInt('count', (prefs.getInt('count') ?? 0) + count);
  }

  @override
  Widget build(BuildContext context) {
    Color dynamicColor = AppColors.getCounterColor(count);

    return Scaffold(
      appBar: AppBar(title: const Text("المسبحة الإلكترونية"), backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(currentZikr, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: increment,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dynamicColor.withOpacity(0.2),
                  border: Border.all(color: dynamicColor, width: 4),
                ),
                child: Center(
                  child: Text(
                    "$count",
                    style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: dynamicColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => setState(() => count = 0),
              icon: const Icon(Icons.refresh),
              label: const Text("إعادة الصفر"),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== شاشة الأذكار ==========
class AzkarScreen extends StatelessWidget {
  const AzkarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الأذكار اليومية")),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: azkarData.entries.map((entry) {
          return ExpansionTile(
            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            children: entry.value.map((item) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(item['text'], textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("التكرار: ${item['count']}", style: const TextStyle(color: Colors.grey)),
                          IconButton(
                            icon: const Icon(Icons.share, size: 20),
                            onPressed: () => Share.share("${item['text']}\n\n[تطبيق سُبْحَان]"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

// ========== شاشة الأدعية ==========
class DuaaScreen extends StatelessWidget {
  const DuaaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الأدعية المباركة")),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: adiyaData.entries.map((entry) {
          return ExpansionTile(
            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            children: entry.value.map((item) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(item['text']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("المصدر: ${item['source']}", style: const TextStyle(color: Colors.amber, fontSize: 12)),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

// ========== شاشة المفضلة ==========
class FavoritesScreen extends StatelessWidget {
  final List<String> favorites;
  const FavoritesScreen({Key? key, required this.favorites}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المفضلة")),
      body: favorites.isEmpty
          ? const Center(child: Text("لا توجد عناصر في المفضلة"))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(favorites[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () => Share.share(favorites[index]),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ========== شاشة الإعدادات ==========
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = SubhanApp.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("الإعدادات")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("الوضع الليلي"),
            value: appState.isNightMode,
            onChanged: (val) => appState.toggleTheme(val),
          ),
          const Divider(),
          const ListTile(
            title: Text("عن التطبيق"),
            subtitle: Text("تطبيق سُبْحَان - النسخة المتكاملة (مطور باستخدام Flutter)"),
          ),
        ],
      ),
    );
  }
}

