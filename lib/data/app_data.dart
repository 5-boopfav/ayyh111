class CityPreset {
  final String name;
  final double latitude;
  final double longitude;
  final String methodKey;

  const CityPreset({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.methodKey,
  });
}

const List<CityPreset> kCities = [
  CityPreset(
    name: 'الرياض',
    latitude: 24.7136,
    longitude: 46.6753,
    methodKey: 'umm_al_qura',
  ),
  CityPreset(
    name: 'مكة المكرمة',
    latitude: 21.3891,
    longitude: 39.8579,
    methodKey: 'umm_al_qura',
  ),
  CityPreset(
    name: 'المدينة المنورة',
    latitude: 24.5247,
    longitude: 39.5692,
    methodKey: 'umm_al_qura',
  ),
  CityPreset(
    name: 'جدة',
    latitude: 21.4858,
    longitude: 39.1925,
    methodKey: 'umm_al_qura',
  ),
  CityPreset(
    name: 'القاهرة',
    latitude: 30.0444,
    longitude: 31.2357,
    methodKey: 'egyptian',
  ),
  CityPreset(
    name: 'دبي',
    latitude: 25.2048,
    longitude: 55.2708,
    methodKey: 'dubai',
  ),
  CityPreset(
    name: 'عمان',
    latitude: 31.9539,
    longitude: 35.9106,
    methodKey: 'muslim_world_league',
  ),
];

class SurahInfo {
  final int number;
  final String name;
  final int startPage;
  final String revelationType;

  const SurahInfo({
    required this.number,
    required this.name,
    required this.startPage,
    required this.revelationType,
  });
}

class JuzInfo {
  final int number;
  final String title;
  final int startPage;

  const JuzInfo({
    required this.number,
    required this.title,
    required this.startPage,
  });
}

class PageThemePreset {
  final String id;
  final String name;
  final double hue;
  final double shade;

  const PageThemePreset({
    required this.id,
    required this.name,
    required this.hue,
    required this.shade,
  });
}

const List<PageThemePreset> kPageThemePresets = [
  PageThemePreset(
      id: 'mushaf_blue', name: 'أزرق المصحف', hue: 196.0, shade: 0.08),
  PageThemePreset(
      id: 'classic_cream', name: 'ورقي كلاسيكي', hue: 38.0, shade: 0.14),
  PageThemePreset(
      id: 'sage_calm', name: 'زيتوني هادئ', hue: 152.0, shade: 0.16),
  PageThemePreset(
      id: 'warm_ivory', name: 'عاجي دافئ', hue: 30.0, shade: 0.22),
  PageThemePreset(
      id: 'sand_stone', name: 'رملي مريح', hue: 46.0, shade: 0.32),
];

const List<SurahInfo> kSurahs = [
  SurahInfo(number: 1, name: 'الفاتحة', startPage: 1, revelationType: 'مكية'),
  SurahInfo(number: 2, name: 'البقرة', startPage: 2, revelationType: 'مدنية'),
  SurahInfo(number: 3, name: 'آل عمران', startPage: 50, revelationType: 'مدنية'),
  SurahInfo(number: 4, name: 'النساء', startPage: 77, revelationType: 'مدنية'),
  SurahInfo(number: 5, name: 'المائدة', startPage: 106, revelationType: 'مدنية'),
  SurahInfo(number: 6, name: 'الأنعام', startPage: 128, revelationType: 'مكية'),
  SurahInfo(number: 7, name: 'الأعراف', startPage: 151, revelationType: 'مكية'),
  SurahInfo(number: 8, name: 'الأنفال', startPage: 177, revelationType: 'مدنية'),
  SurahInfo(number: 9, name: 'التوبة', startPage: 187, revelationType: 'مدنية'),
  SurahInfo(number: 10, name: 'يونس', startPage: 208, revelationType: 'مكية'),
  SurahInfo(number: 11, name: 'هود', startPage: 221, revelationType: 'مكية'),
  SurahInfo(number: 12, name: 'يوسف', startPage: 235, revelationType: 'مكية'),
  SurahInfo(number: 13, name: 'الرعد', startPage: 249, revelationType: 'مدنية'),
  SurahInfo(number: 14, name: 'إبراهيم', startPage: 255, revelationType: 'مكية'),
  SurahInfo(number: 15, name: 'الحجر', startPage: 262, revelationType: 'مكية'),
  SurahInfo(number: 16, name: 'النحل', startPage: 267, revelationType: 'مكية'),
  SurahInfo(number: 17, name: 'الإسراء', startPage: 282, revelationType: 'مكية'),
  SurahInfo(number: 18, name: 'الكهف', startPage: 293, revelationType: 'مكية'),
  SurahInfo(number: 19, name: 'مريم', startPage: 305, revelationType: 'مكية'),
  SurahInfo(number: 20, name: 'طه', startPage: 312, revelationType: 'مكية'),
  SurahInfo(number: 21, name: 'الأنبياء', startPage: 322, revelationType: 'مكية'),
  SurahInfo(number: 22, name: 'الحج', startPage: 332, revelationType: 'مدنية'),
  SurahInfo(number: 23, name: 'المؤمنون', startPage: 342, revelationType: 'مكية'),
  SurahInfo(number: 24, name: 'النور', startPage: 350, revelationType: 'مدنية'),
  SurahInfo(number: 25, name: 'الفرقان', startPage: 359, revelationType: 'مكية'),
  SurahInfo(number: 26, name: 'الشعراء', startPage: 367, revelationType: 'مكية'),
  SurahInfo(number: 27, name: 'النمل', startPage: 377, revelationType: 'مكية'),
  SurahInfo(number: 28, name: 'القصص', startPage: 385, revelationType: 'مكية'),
  SurahInfo(number: 29, name: 'العنكبوت', startPage: 396, revelationType: 'مكية'),
  SurahInfo(number: 30, name: 'الروم', startPage: 404, revelationType: 'مكية'),
  SurahInfo(number: 31, name: 'لقمان', startPage: 411, revelationType: 'مكية'),
  SurahInfo(number: 32, name: 'السجدة', startPage: 415, revelationType: 'مكية'),
  SurahInfo(number: 33, name: 'الأحزاب', startPage: 418, revelationType: 'مدنية'),
  SurahInfo(number: 34, name: 'سبأ', startPage: 428, revelationType: 'مكية'),
  SurahInfo(number: 35, name: 'فاطر', startPage: 434, revelationType: 'مكية'),
  SurahInfo(number: 36, name: 'يس', startPage: 440, revelationType: 'مكية'),
  SurahInfo(number: 37, name: 'الصافات', startPage: 446, revelationType: 'مكية'),
  SurahInfo(number: 38, name: 'ص', startPage: 453, revelationType: 'مكية'),
  SurahInfo(number: 39, name: 'الزمر', startPage: 458, revelationType: 'مكية'),
  SurahInfo(number: 40, name: 'غافر', startPage: 467, revelationType: 'مكية'),
  SurahInfo(number: 41, name: 'فصلت', startPage: 477, revelationType: 'مكية'),
  SurahInfo(number: 42, name: 'الشورى', startPage: 483, revelationType: 'مكية'),
  SurahInfo(number: 43, name: 'الزخرف', startPage: 489, revelationType: 'مكية'),
  SurahInfo(number: 44, name: 'الدخان', startPage: 496, revelationType: 'مكية'),
  SurahInfo(number: 45, name: 'الجاثية', startPage: 499, revelationType: 'مكية'),
  SurahInfo(number: 46, name: 'الأحقاف', startPage: 502, revelationType: 'مكية'),
  SurahInfo(number: 47, name: 'محمد', startPage: 507, revelationType: 'مدنية'),
  SurahInfo(number: 48, name: 'الفتح', startPage: 511, revelationType: 'مدنية'),
  SurahInfo(number: 49, name: 'الحجرات', startPage: 515, revelationType: 'مدنية'),
  SurahInfo(number: 50, name: 'ق', startPage: 518, revelationType: 'مكية'),
  SurahInfo(number: 51, name: 'الذاريات', startPage: 520, revelationType: 'مكية'),
  SurahInfo(number: 52, name: 'الطور', startPage: 523, revelationType: 'مكية'),
  SurahInfo(number: 53, name: 'النجم', startPage: 526, revelationType: 'مكية'),
  SurahInfo(number: 54, name: 'القمر', startPage: 528, revelationType: 'مكية'),
  SurahInfo(number: 55, name: 'الرحمن', startPage: 531, revelationType: 'مدنية'),
  SurahInfo(number: 56, name: 'الواقعة', startPage: 534, revelationType: 'مكية'),
  SurahInfo(number: 57, name: 'الحديد', startPage: 537, revelationType: 'مدنية'),
  SurahInfo(number: 58, name: 'المجادلة', startPage: 542, revelationType: 'مدنية'),
  SurahInfo(number: 59, name: 'الحشر', startPage: 545, revelationType: 'مدنية'),
  SurahInfo(number: 60, name: 'الممتحنة', startPage: 549, revelationType: 'مدنية'),
  SurahInfo(number: 61, name: 'الصف', startPage: 551, revelationType: 'مدنية'),
  SurahInfo(number: 62, name: 'الجمعة', startPage: 553, revelationType: 'مدنية'),
  SurahInfo(number: 63, name: 'المنافقون', startPage: 554, revelationType: 'مدنية'),
  SurahInfo(number: 64, name: 'التغابن', startPage: 556, revelationType: 'مدنية'),
  SurahInfo(number: 65, name: 'الطلاق', startPage: 558, revelationType: 'مدنية'),
  SurahInfo(number: 66, name: 'التحريم', startPage: 560, revelationType: 'مدنية'),
  SurahInfo(number: 67, name: 'الملك', startPage: 562, revelationType: 'مكية'),
  SurahInfo(number: 68, name: 'القلم', startPage: 564, revelationType: 'مكية'),
  SurahInfo(number: 69, name: 'الحاقة', startPage: 566, revelationType: 'مكية'),
  SurahInfo(number: 70, name: 'المعارج', startPage: 568, revelationType: 'مكية'),
  SurahInfo(number: 71, name: 'نوح', startPage: 570, revelationType: 'مكية'),
  SurahInfo(number: 72, name: 'الجن', startPage: 572, revelationType: 'مكية'),
  SurahInfo(number: 73, name: 'المزمل', startPage: 574, revelationType: 'مكية'),
  SurahInfo(number: 74, name: 'المدثر', startPage: 575, revelationType: 'مكية'),
  SurahInfo(number: 75, name: 'القيامة', startPage: 577, revelationType: 'مكية'),
  SurahInfo(number: 76, name: 'الإنسان', startPage: 578, revelationType: 'مدنية'),
  SurahInfo(number: 77, name: 'المرسلات', startPage: 580, revelationType: 'مكية'),
  SurahInfo(number: 78, name: 'النبأ', startPage: 582, revelationType: 'مكية'),
  SurahInfo(number: 79, name: 'النازعات', startPage: 583, revelationType: 'مكية'),
  SurahInfo(number: 80, name: 'عبس', startPage: 585, revelationType: 'مكية'),
  SurahInfo(number: 81, name: 'التكوير', startPage: 586, revelationType: 'مكية'),
  SurahInfo(number: 82, name: 'الانفطار', startPage: 587, revelationType: 'مكية'),
  SurahInfo(number: 83, name: 'المطففين', startPage: 587, revelationType: 'مكية'),
  SurahInfo(number: 84, name: 'الانشقاق', startPage: 589, revelationType: 'مكية'),
  SurahInfo(number: 85, name: 'البروج', startPage: 590, revelationType: 'مكية'),
  SurahInfo(number: 86, name: 'الطارق', startPage: 591, revelationType: 'مكية'),
  SurahInfo(number: 87, name: 'الأعلى', startPage: 591, revelationType: 'مكية'),
  SurahInfo(number: 88, name: 'الغاشية', startPage: 592, revelationType: 'مكية'),
  SurahInfo(number: 89, name: 'الفجر', startPage: 593, revelationType: 'مكية'),
  SurahInfo(number: 90, name: 'البلد', startPage: 594, revelationType: 'مكية'),
  SurahInfo(number: 91, name: 'الشمس', startPage: 595, revelationType: 'مكية'),
  SurahInfo(number: 92, name: 'الليل', startPage: 595, revelationType: 'مكية'),
  SurahInfo(number: 93, name: 'الضحى', startPage: 596, revelationType: 'مكية'),
  SurahInfo(number: 94, name: 'الشرح', startPage: 596, revelationType: 'مكية'),
  SurahInfo(number: 95, name: 'التين', startPage: 597, revelationType: 'مكية'),
  SurahInfo(number: 96, name: 'العلق', startPage: 597, revelationType: 'مكية'),
  SurahInfo(number: 97, name: 'القدر', startPage: 598, revelationType: 'مكية'),
  SurahInfo(number: 98, name: 'البينة', startPage: 598, revelationType: 'مدنية'),
  SurahInfo(number: 99, name: 'الزلزلة', startPage: 599, revelationType: 'مدنية'),
  SurahInfo(number: 100, name: 'العاديات', startPage: 599, revelationType: 'مكية'),
  SurahInfo(number: 101, name: 'القارعة', startPage: 600, revelationType: 'مكية'),
  SurahInfo(number: 102, name: 'التكاثر', startPage: 600, revelationType: 'مكية'),
  SurahInfo(number: 103, name: 'العصر', startPage: 601, revelationType: 'مكية'),
  SurahInfo(number: 104, name: 'الهمزة', startPage: 601, revelationType: 'مكية'),
  SurahInfo(number: 105, name: 'الفيل', startPage: 601, revelationType: 'مكية'),
  SurahInfo(number: 106, name: 'قريش', startPage: 602, revelationType: 'مكية'),
  SurahInfo(number: 107, name: 'الماعون', startPage: 602, revelationType: 'مكية'),
  SurahInfo(number: 108, name: 'الكوثر', startPage: 602, revelationType: 'مكية'),
  SurahInfo(number: 109, name: 'الكافرون', startPage: 603, revelationType: 'مكية'),
  SurahInfo(number: 110, name: 'النصر', startPage: 603, revelationType: 'مدنية'),
  SurahInfo(number: 111, name: 'المسد', startPage: 603, revelationType: 'مكية'),
  SurahInfo(number: 112, name: 'الإخلاص', startPage: 604, revelationType: 'مكية'),
  SurahInfo(number: 113, name: 'الفلق', startPage: 604, revelationType: 'مكية'),
  SurahInfo(number: 114, name: 'الناس', startPage: 604, revelationType: 'مكية'),
];

const List<JuzInfo> kJuzList = [
  JuzInfo(number: 1, title: 'الجزء الأول', startPage: 1),
  JuzInfo(number: 2, title: 'الجزء الثاني', startPage: 22),
  JuzInfo(number: 3, title: 'الجزء الثالث', startPage: 42),
  JuzInfo(number: 4, title: 'الجزء الرابع', startPage: 62),
  JuzInfo(number: 5, title: 'الجزء الخامس', startPage: 82),
  JuzInfo(number: 6, title: 'الجزء السادس', startPage: 102),
  JuzInfo(number: 7, title: 'الجزء السابع', startPage: 121),
  JuzInfo(number: 8, title: 'الجزء الثامن', startPage: 142),
  JuzInfo(number: 9, title: 'الجزء التاسع', startPage: 162),
  JuzInfo(number: 10, title: 'الجزء العاشر', startPage: 182),
  JuzInfo(number: 11, title: 'الجزء الحادي عشر', startPage: 201),
  JuzInfo(number: 12, title: 'الجزء الثاني عشر', startPage: 222),
  JuzInfo(number: 13, title: 'الجزء الثالث عشر', startPage: 242),
  JuzInfo(number: 14, title: 'الجزء الرابع عشر', startPage: 262),
  JuzInfo(number: 15, title: 'الجزء الخامس عشر', startPage: 282),
  JuzInfo(number: 16, title: 'الجزء السادس عشر', startPage: 302),
  JuzInfo(number: 17, title: 'الجزء السابع عشر', startPage: 322),
  JuzInfo(number: 18, title: 'الجزء الثامن عشر', startPage: 342),
  JuzInfo(number: 19, title: 'الجزء التاسع عشر', startPage: 362),
  JuzInfo(number: 20, title: 'الجزء العشرون', startPage: 382),
  JuzInfo(number: 21, title: 'الجزء الحادي والعشرون', startPage: 402),
  JuzInfo(number: 22, title: 'الجزء الثاني والعشرون', startPage: 422),
  JuzInfo(number: 23, title: 'الجزء الثالث والعشرون', startPage: 442),
  JuzInfo(number: 24, title: 'الجزء الرابع والعشرون', startPage: 462),
  JuzInfo(number: 25, title: 'الجزء الخامس والعشرون', startPage: 482),
  JuzInfo(number: 26, title: 'الجزء السادس والعشرون', startPage: 502),
  JuzInfo(number: 27, title: 'الجزء السابع والعشرون', startPage: 522),
  JuzInfo(number: 28, title: 'الجزء الثامن والعشرون', startPage: 542),
  JuzInfo(number: 29, title: 'الجزء التاسع والعشرون', startPage: 562),
  JuzInfo(number: 30, title: 'الجزء الثلاثون', startPage: 582),
];

class ThikrItem {
  final String id;
  final String category;
  final String title;
  final String text;
  final int targetCount;

  const ThikrItem({
    required this.id,
    required this.category,
    required this.title,
    required this.text,
    required this.targetCount,
  });
}

const List<String> kThikrCategories = [
  'أذكار الصباح',
  'أذكار المساء',
  'أذكار بعد الصلاة',
  'أدعية واستغفار',
];

const List<ThikrItem> kThikrItems = [
  ThikrItem(
    id: 'm_1',
    category: 'أذكار الصباح',
    title: 'سَيِّدُ الِاسْتِغْفَارِ وَالذِّكْرُ',
    text: 'أصبحنا وأصبح الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
    targetCount: 1,
  ),
  ThikrItem(
    id: 'm_2',
    category: 'أذكار الصباح',
    title: 'ذِكْرُ الصَّبَاحِ',
    text: 'اللهم بك أصبحنا وبك أمسينا وبك نحيا وبك نموت وإليك النشور.',
    targetCount: 1,
  ),
  ThikrItem(
    id: 'm_3',
    category: 'أذكار الصباح',
    title: 'رِضَا اللَّهِ',
    text: 'رضيت بالله رباً، وبالإسلام ديناً، وبمحمد صلى الله عليه وسلم نبياً.',
    targetCount: 3,
  ),
  ThikrItem(
    id: 'm_4',
    category: 'أذكار الصباح',
    title: 'تَسْبِيحُ الصَّبَاحِ',
    text: 'سبحان الله وبحمده، عدد خلقه، ورضا نفسه، وزنة عرشه، ومداد كلماته.',
    targetCount: 3,
  ),
  ThikrItem(
    id: 'm_5',
    category: 'أذكار الصباح',
    title: 'الِاسْتِغْفَارُ الْعَظِيمُ',
    text: 'أستغفر الله العظيم الذي لا إله إلا هو الحي القيوم وأتوب إليه.',
    targetCount: 3,
  ),
  ThikrItem(
    id: 'e_1',
    category: 'أذكار المساء',
    title: 'ذِكْرُ الْمَسَاءِ',
    text: 'أمسينا وأمسى الملك لله، والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.',
    targetCount: 1,
  ),
  ThikrItem(
    id: 'e_2',
    category: 'أذكار المساء',
    title: 'الْمَصِيرُ إِلَى اللَّهِ',
    text: 'اللهم بك أمسينا وبك أصبحنا وبك نحيا وبك نموت وإليك المصير.',
    targetCount: 1,
  ),
  ThikrItem(
    id: 'e_3',
    category: 'أذكار المساء',
    title: 'كَلِمَاتُ اللَّهِ التَّامَّاتُ',
    text: 'أعوذ بكلمات الله التامات من شر ما خلق.',
    targetCount: 3,
  ),
  ThikrItem(
    id: 'e_4',
    category: 'أذكار المساء',
    title: 'الْحِفْظُ بِاسْمِ اللَّهِ',
    text: 'بسم الله الذي لا يضر مع اسمه شيء في الأرض ولا في السماء وهو السميع العليم.',
    targetCount: 3,
  ),
  ThikrItem(
    id: 'p_1',
    category: 'أذكار بعد الصلاة',
    title: 'الِاسْتِغْفَارُ وَالسَّلَامُ',
    text: 'أستغفر الله، أستغفر الله، أستغفر الله. اللهم أنت السلام ومنك السلام، تباركت يا ذا الجلال والإكرام.',
    targetCount: 1,
  ),
  ThikrItem(
    id: 'p_2',
    category: 'أذكار بعد الصلاة',
    title: 'سُبْحَانَ اللَّهِ',
    text: 'سبحان الله.',
    targetCount: 33,
  ),
  ThikrItem(
    id: 'p_3',
    category: 'أذكار بعد الصلاة',
    title: 'الْحَمْدُ لِلَّهِ',
    text: 'الحمد لله.',
    targetCount: 33,
  ),
  ThikrItem(
    id: 'p_4',
    category: 'أذكار بعد الصلاة',
    title: 'اللَّهُ أَكْبَرُ',
    text: 'الله أكبر.',
    targetCount: 33,
  ),
  ThikrItem(
    id: 'd_1',
    category: 'أدعية واستغفار',
    title: 'حَسَنَةُ الدُّنْيَا وَالْآخِرَةِ',
    text: 'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار.',
    targetCount: 3,
  ),
  ThikrItem(
    id: 'd_2',
    category: 'أدعية واستغفار',
    title: 'الْهُدَى وَالتُّقَى',
    text: 'اللهم إني أسألك الهدى والتقى والعفاف والغنى.',
    targetCount: 3,
  ),
  ThikrItem(
    id: 'd_3',
    category: 'أدعية واستغفار',
    title: 'تَسْبِيحُ يُونُسَ عَلَيْهِ السَّلَامُ',
    text: 'لا إله إلا أنت سبحانك إني كنت من الظالمين.',
    targetCount: 3,
  ),
];
