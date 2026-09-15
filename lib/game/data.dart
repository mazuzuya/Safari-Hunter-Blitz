// Port of game js/game/data.js
// Animal / stage / guardian / totem definitions for Safari Hunter Blitz.

class Animal {
  final String id;
  final String name;
  final String zone;
  final String sheet;
  final String animation;
  final int row;
  final double size;
  final int? waveTier;

  const Animal({
    required this.id,
    required this.name,
    required this.zone,
    required this.sheet,
    required this.animation,
    required this.row,
    required this.size,
    this.waveTier,
  });

  factory Animal.fromCommon(String id, String name, String zone, int sheet, int row, double size) =>
      Animal(
        id: id,
        name: name,
        zone: zone,
        sheet: 'ANIMALS_SHEET_${sheet.toString().padLeft(2, "0")}',
        animation: '${id}_move',
        row: row,
        size: size,
      );

  factory Animal.fromArea(String id, String name, String zone, int area, int row, double size) =>
      Animal(
        id: id,
        name: name,
        zone: zone,
        sheet: 'AREA_ANIMALS_${area.toString().padLeft(2, "0")}',
        animation: '${id}_move',
        row: row,
        size: size,
      );

  factory Animal.fromWave(String id, String name, String sheet, int row, double size, int waveTier) =>
      Animal(
        id: id,
        name: name,
        zone: 'land',
        sheet: sheet,
        animation: '${id}_move',
        row: row,
        size: size,
        waveTier: waveTier,
      );
}

final List<Animal> ANIMALS = [
  Animal.fromCommon('capybara', 'Capybara', 'land', 1, 0, 74),
  Animal.fromCommon('kelinci', 'Kelinci', 'land', 1, 1, 70),
  Animal.fromCommon('ayam', 'Ayam', 'land', 1, 2, 68),
  Animal.fromCommon('kambing', 'Kambing', 'land', 1, 3, 76),
  Animal.fromCommon('sapi', 'Sapi', 'land', 1, 4, 82),
  Animal.fromCommon('kucing', 'Kucing', 'land', 1, 5, 68),
  Animal.fromCommon('anjing', 'Anjing', 'land', 2, 0, 72),
  Animal.fromCommon('babi', 'Babi', 'land', 2, 1, 72),
  Animal.fromCommon('domba', 'Domba', 'land', 2, 2, 72),
  Animal.fromCommon('rubah', 'Rubah', 'land', 2, 3, 72),
  Animal.fromCommon('beruang', 'Beruang', 'land', 2, 4, 86),
  Animal.fromCommon('panda', 'Panda', 'land', 2, 5, 80),
  Animal.fromCommon('jerapah', 'Jerapah', 'land', 3, 0, 108),
  Animal.fromCommon('gajah', 'Gajah', 'land', 3, 1, 88),
  Animal.fromCommon('harimau', 'Harimau', 'land', 3, 2, 76),
  Animal.fromCommon('singa', 'Singa', 'land', 3, 3, 82),
  Animal.fromCommon('pipit', 'Burung Pipit', 'sky', 3, 4, 54),
  Animal.fromCommon('nuri', 'Nuri', 'sky', 3, 5, 62),
  Animal.fromCommon('elang', 'Elang', 'sky', 4, 0, 76),
  Animal.fromCommon('kelelawar', 'Kelelawar', 'sky', 4, 1, 58),
  Animal.fromCommon('kupu', 'Kupu-kupu', 'sky', 4, 2, 50),
  Animal.fromCommon('merpati', 'Merpati', 'sky', 4, 3, 58),
  Animal.fromCommon('lebah', 'Lebah', 'sky', 4, 4, 44),
  Animal.fromCommon('capung', 'Capung', 'sky', 4, 5, 48),
  Animal.fromCommon('hantu', 'Burung Hantu', 'sky', 5, 0, 64),
  Animal.fromCommon('angsa', 'Angsa', 'sky', 5, 1, 72),
  Animal.fromCommon('koi', 'Ikan Koi', 'water', 5, 2, 66),
  Animal.fromCommon('katak', 'Katak', 'water', 5, 3, 56),
  Animal.fromCommon('bebek', 'Bebek', 'water', 5, 4, 62),
  Animal.fromCommon('kura', 'Kura-kura', 'water', 5, 5, 66),
  Animal.fromCommon('paus', 'Paus', 'water', 6, 0, 92),
  Animal.fromCommon('lumba', 'Lumba-lumba', 'water', 6, 1, 76),
  Animal.fromCommon('gurita', 'Gurita', 'water', 6, 2, 70),
  Animal.fromCommon('kepiting', 'Kepiting', 'water', 6, 3, 58),
  Animal.fromCommon('ubur', 'Ubur-ubur', 'water', 6, 4, 66),
  Animal.fromCommon('kudalaut', 'Kuda Laut', 'water', 6, 5, 58),
  Animal.fromCommon('zebra', 'Zebra', 'land', 7, 0, 78),
  Animal.fromCommon('badak', 'Badak', 'land', 7, 1, 88),
  Animal.fromCommon('kanguru', 'Kanguru', 'land', 7, 2, 82),
  Animal.fromCommon('monyet', 'Monyet', 'land', 7, 3, 64),
  Animal.fromCommon('celeng', 'Celeng', 'land', 7, 4, 70),
  Animal.fromCommon('unta', 'Unta', 'land', 7, 5, 90),
  Animal.fromCommon('kuda_nil', 'Kuda Nil', 'land', 8, 0, 86),
  Animal.fromCommon('macan_tutul', 'Macan Tutul', 'land', 8, 1, 72),
  Animal.fromCommon('gorila', 'Gorila', 'land', 8, 2, 84),
  Animal.fromCommon('serigala', 'Serigala', 'land', 8, 3, 72),
  Animal.fromCommon('bangau', 'Bangau', 'sky', 8, 4, 68),
  Animal.fromCommon('tukan', 'Tukan', 'sky', 8, 5, 60),
  Animal.fromCommon('flamingo', 'Flamingo', 'sky', 9, 0, 70),
  Animal.fromCommon('merak', 'Merak', 'sky', 9, 1, 68),
  Animal.fromCommon('rangkong', 'Rangkong', 'sky', 9, 2, 64),
  Animal.fromCommon('tupai_terbang', 'Tupai Terbang', 'sky', 9, 3, 56),
  Animal.fromCommon('hiu', 'Hiu', 'water', 9, 4, 76),
  Animal.fromCommon('pari', 'Pari Manta', 'water', 9, 5, 72),
  Animal.fromCommon('penguin', 'Penguin', 'water', 10, 0, 62),
  Animal.fromCommon('anjing_laut', 'Anjing Laut', 'water', 10, 1, 70),
  Animal.fromCommon('walrus', 'Walrus', 'water', 10, 2, 82),
  Animal.fromCommon('buntal', 'Ikan Buntal', 'water', 10, 3, 54),
  Animal.fromCommon('todak', 'Ikan Todak', 'water', 10, 4, 72),
  Animal.fromCommon('buaya', 'Buaya', 'water', 10, 5, 76),
  Animal.fromArea('alpaka', 'Alpaka', 'land', 1, 0, 80),
  Animal.fromArea('poni', 'Kuda Poni', 'land', 1, 1, 76),
  Animal.fromArea('ayam_jago', 'Ayam Jago', 'land', 1, 2, 68),
  Animal.fromArea('kelinci_belang', 'Kelinci Belang', 'land', 1, 3, 64),
  Animal.fromArea('landak', 'Landak', 'land', 1, 4, 58),
  Animal.fromArea('kalkun', 'Kalkun', 'land', 1, 5, 70),
  Animal.fromArea('orangutan', 'Orangutan', 'land', 2, 0, 78),
  Animal.fromArea('tapir', 'Tapir', 'land', 2, 1, 76),
  Animal.fromArea('jaguar', 'Jaguar', 'land', 2, 2, 72),
  Animal.fromArea('kukang', 'Kukang', 'land', 2, 3, 56),
  Animal.fromArea('kasuari', 'Kasuari', 'land', 2, 4, 82),
  Animal.fromArea('makaw', 'Burung Makaw', 'sky', 2, 5, 62),
  Animal.fromArea('rusa_gazel', 'Rusa Gazel', 'land', 3, 0, 76),
  Animal.fromArea('burung_unta', 'Burung Unta', 'land', 3, 1, 94),
  Animal.fromArea('meerkat', 'Meerkat', 'land', 3, 2, 50),
  Animal.fromArea('babi_kutil', 'Babi Kutil', 'land', 3, 3, 72),
  Animal.fromArea('wildebeest', 'Wildebeest', 'land', 3, 4, 82),
  Animal.fromArea('burung_sekretaris', 'Burung Sekretaris', 'sky', 3, 5, 70),
  Animal.fromArea('rubah_fennec', 'Rubah Fennec', 'land', 4, 0, 62),
  Animal.fromArea('oryx', 'Oryx', 'land', 4, 1, 84),
  Animal.fromArea('jerboa', 'Jerboa', 'land', 4, 2, 50),
  Animal.fromArea('kalajengking', 'Kalajengking', 'land', 4, 3, 54),
  Animal.fromArea('roadrunner', 'Roadrunner', 'land', 4, 4, 62),
  Animal.fromArea('burung_hantu_gurun', 'Burung Hantu Gurun', 'sky', 4, 5, 60),
  Animal.fromArea('bekantan', 'Bekantan', 'land', 5, 0, 72),
  Animal.fromArea('ikan_gelodok', 'Ikan Gelodok', 'water', 5, 1, 52),
  Animal.fromArea('raja_udang', 'Burung Raja Udang', 'sky', 5, 2, 56),
  Animal.fromArea('biawak', 'Biawak', 'land', 5, 3, 66),
  Animal.fromArea('ibis', 'Burung Ibis', 'sky', 5, 4, 66),
  Animal.fromArea('berang_sungai', 'Berang-berang Sungai', 'water', 5, 5, 64),
  Animal.fromArea('ikan_badut', 'Ikan Badut', 'water', 6, 0, 50),
  Animal.fromArea('hiu_martil', 'Hiu Martil', 'water', 6, 1, 78),
  Animal.fromArea('belut_moray', 'Belut Moray', 'water', 6, 2, 68),
  Animal.fromArea('udang_mantis', 'Udang Mantis', 'water', 6, 3, 56),
  Animal.fromArea('dugong', 'Dugong', 'water', 6, 4, 76),
  Animal.fromArea('penyu_sisik', 'Penyu Sisik', 'water', 6, 5, 68),
  Animal.fromArea('salamander_api', 'Salamander Api', 'land', 7, 0, 50),
  Animal.fromArea('kambing_gunung', 'Kambing Gunung', 'land', 7, 1, 76),
  Animal.fromArea('kondor', 'Kondor', 'sky', 7, 2, 76),
  Animal.fromArea('panther_hitam', 'Panther Hitam', 'land', 7, 3, 72),
  Animal.fromArea('kepiting_lava', 'Kepiting Lava', 'water', 7, 4, 54),
  Animal.fromArea('tokek_terbang', 'Tokek Terbang', 'sky', 7, 5, 54),
  Animal.fromArea('ngengat_bulan', 'Ngengat Bulan', 'sky', 8, 0, 58),
  Animal.fromArea('kunang_kunang', 'Kunang-kunang', 'sky', 8, 1, 42),
  Animal.fromArea('rakun', 'Rakun', 'land', 8, 2, 64),
  Animal.fromArea('kucing_hitam', 'Kucing Hitam', 'land', 8, 3, 64),
  Animal.fromArea('cumi_cumi', 'Cumi-cumi', 'water', 8, 4, 66),
  Animal.fromArea('ubur_bulan', 'Ubur-ubur Bulan', 'water', 8, 5, 62),
  Animal.fromArea('rubah_arktik', 'Rubah Arktik', 'land', 9, 0, 66),
  Animal.fromArea('burung_hantu_salju', 'Burung Hantu Salju', 'sky', 9, 1, 64),
  Animal.fromArea('rusa_kutub', 'Rusa Kutub', 'land', 9, 2, 86),
  Animal.fromArea('narwhal', 'Narwhal', 'water', 9, 3, 76),
  Animal.fromArea('puffin', 'Puffin', 'sky', 9, 4, 54),
  Animal.fromArea('beruang_kutub', 'Beruang Kutub', 'land', 9, 5, 84),
  Animal.fromArea('elang_emas', 'Elang Emas', 'sky', 10, 0, 76),
  Animal.fromArea('macan_awan', 'Macan Awan', 'land', 10, 1, 72),
  Animal.fromArea('phoenix', 'Phoenix', 'sky', 10, 2, 72),
  Animal.fromArea('kirin', 'Kirin', 'land', 10, 3, 88),
  Animal.fromArea('koi_awan', 'Koi Awan', 'water', 10, 4, 68),
  Animal.fromArea('capy_terbang', 'Capybara Terbang', 'sky', 10, 5, 66),
  Animal.fromWave('cheetah_wave', 'Cheetah Kilat', 'WAVE4_ANIMALS', 0, 70, 4),
  Animal.fromWave('blackbuck_wave', 'Blackbuck Kilat', 'WAVE4_ANIMALS', 1, 76, 4),
  Animal.fromWave('jackrabbit_wave', 'Jackrabbit Kilat', 'WAVE4_ANIMALS', 2, 62, 4),
  Animal.fromWave('emu_wave', 'Emu Kilat', 'WAVE4_ANIMALS', 3, 82, 4),
  Animal.fromWave('armadillo_elite', 'Armadillo Elite', 'WAVE5_ANIMALS', 0, 68, 5),
  Animal.fromWave('bison_elite', 'Bison Elite', 'WAVE5_ANIMALS', 1, 94, 5),
  Animal.fromWave('yak_elite', 'Yak Elite', 'WAVE5_ANIMALS', 2, 90, 5),
  Animal.fromWave('kura_raksasa_elite', 'Kura-kura Raksasa', 'WAVE5_ANIMALS', 3, 84, 5),
];

const Map<int, List<String>> WAVE_ROSTERS = {
  4: ['cheetah_wave', 'blackbuck_wave', 'jackrabbit_wave', 'emu_wave'],
  5: ['armadillo_elite', 'bison_elite', 'yak_elite', 'kura_raksasa_elite'],
};

final Map<String, Animal> ANIMAL_BY_ID = {
  for (final a in ANIMALS) a.id: a,
};

final Map<String, List<Animal>> ANIMALS_BY_ZONE = {
  'sky': ANIMALS.where((a) => a.zone == 'sky').toList(),
  'land': ANIMALS.where((a) => a.zone == 'land').toList(),
  'water': ANIMALS.where((a) => a.zone == 'water').toList(),
};

const List<List<String>> AREA_ADDITIONS = [
  ['capybara', 'kelinci', 'ayam', 'kambing', 'sapi', 'kucing', 'anjing', 'babi'],
  ['domba', 'rubah', 'beruang', 'panda', 'pipit', 'nuri', 'monyet', 'tukan'],
  ['zebra', 'badak', 'kanguru', 'jerapah', 'gajah', 'harimau', 'singa', 'elang'],
  ['unta', 'celeng', 'serigala', 'kelelawar', 'kupu', 'merpati', 'lebah', 'capung'],
  ['kuda_nil', 'buaya', 'katak', 'bebek', 'kura', 'bangau', 'flamingo', 'rangkong'],
  ['koi', 'paus', 'lumba', 'gurita', 'kepiting', 'ubur', 'kudalaut', 'hiu', 'pari', 'buntal', 'todak'],
  ['macan_tutul', 'gorila', 'tupai_terbang', 'merak', 'hantu'],
  ['angsa'],
  ['penguin', 'anjing_laut', 'walrus'],
  [],
];

const List<List<String>> AREA_EXCLUSIVES = [
  ['alpaka', 'poni', 'ayam_jago', 'kelinci_belang', 'landak', 'kalkun'],
  ['orangutan', 'tapir', 'jaguar', 'kukang', 'kasuari', 'makaw'],
  ['rusa_gazel', 'burung_unta', 'meerkat', 'babi_kutil', 'wildebeest', 'burung_sekretaris'],
  ['rubah_fennec', 'oryx', 'jerboa', 'kalajengking', 'roadrunner', 'burung_hantu_gurun'],
  ['bekantan', 'ikan_gelodok', 'raja_udang', 'biawak', 'ibis', 'berang_sungai'],
  ['ikan_badut', 'hiu_martil', 'belut_moray', 'udang_mantis', 'dugong', 'penyu_sisik'],
  ['salamander_api', 'kambing_gunung', 'kondor', 'panther_hitam', 'kepiting_lava', 'tokek_terbang'],
  ['ngengat_bulan', 'kunang_kunang', 'rakun', 'kucing_hitam', 'cumi_cumi', 'ubur_bulan'],
  ['rubah_arktik', 'burung_hantu_salju', 'rusa_kutub', 'narwhal', 'puffin', 'beruang_kutub'],
  ['elang_emas', 'macan_awan', 'phoenix', 'kirin', 'koi_awan', 'capy_terbang'],
];

List<List<String>> _buildAreaPools() {
  final pools = <List<String>>[];
  for (int i = 0; i < AREA_ADDITIONS.length; i++) {
    final flat = <String>[];
    for (int j = 0; j <= i; j++) flat.addAll(AREA_ADDITIONS[j]);
    pools.add(flat);
  }
  pools[9] = ANIMALS.where((a) => a.waveTier == null).map((a) => a.id).toList();
  return pools;
}

final List<List<String>> AREA_POOLS = _buildAreaPools();

const List<AreaDef> AREAS = [
  AreaDef(name: 'Ladang Ceria', bg: 'BG_PASTURE'),
  AreaDef(name: 'Hutan Zamrud', bg: 'BG_JUNGLE'),
  AreaDef(name: 'Savana Emas', bg: 'BG_SAVANNA'),
  AreaDef(name: 'Gurun Oasis', bg: 'BG_DESERT'),
  AreaDef(name: 'Delta Mangrove', bg: 'BG_MANGROVE'),
  AreaDef(name: 'Kerajaan Koral', bg: 'BG_CORAL'),
  AreaDef(name: 'Dataran Vulkanik', bg: 'BG_VOLCANO'),
  AreaDef(name: 'Samudra Malam', bg: 'BG_NIGHT_OCEAN'),
  AreaDef(name: 'Arktika Aurora', bg: 'BG_ARCTIC'),
  AreaDef(name: 'Kuil Langit', bg: 'BG_SKY_TEMPLE'),
];

class AreaDef {
  final String name;
  final String bg;
  const AreaDef({required this.name, required this.bg});
}

const Map<String, String> CHALLENGE_NAMES = {
  'gentle': 'Pemanasan',
  'burrow': 'Sembunyi Rumput',
  'zigzag': 'Terbang Zigzag',
  'camouflage': 'Kabut Kamuflase',
  'stampede': 'Gelombang Kawanan',
  'reverse': 'Balik Arah',
  'mirage': 'Fatamorgana Palsu',
  'sandstorm': 'Badai Pasir',
  'tide': 'Pasang Naik',
  'ambush': 'Akar Menyergap',
  'current': 'Arus Deras',
  'bubble': 'Gelembung Buta',
  'heat': 'Kabut Panas',
  'lava': 'Lari Lava',
  'dark': 'Sorot Bulan',
  'moonshift': 'Arah Bulan',
  'snow': 'Badai Salju',
  'ice': 'Lantai Es',
  'portal': 'Portal Awan',
  'chaos': 'Chaos Legenda',
};

class Stage {
  final String name;
  final int area;
  final String areaName;
  final List<String> zones;
  final List<String> targets;
  final double time;
  final double speed;
  final int total;
  final int difficulty;
  final String bg;
  final List<String> pool;
  final List<String> localPool;
  final double worldScale;
  final String challenge;
  final String challengeName;

  Stage({
    required this.name,
    required this.area,
    required this.areaName,
    required this.zones,
    required this.targets,
    required this.time,
    required this.speed,
    required this.total,
    required this.difficulty,
    required this.bg,
    required this.pool,
    required this.localPool,
    required this.worldScale,
    required this.challenge,
    required this.challengeName,
  });
}

Stage _s(String name, int area, List<String> zones, List<String> targets, double time,
    double speed, int total, int difficulty, String challenge) {
  return Stage(
    name: name,
    area: area,
    areaName: AREAS[area - 1].name,
    zones: zones,
    targets: targets,
    time: time,
    speed: speed,
    total: total,
    difficulty: difficulty,
    bg: AREAS[area - 1].bg,
    pool: [...AREA_POOLS[area - 1], ...AREA_EXCLUSIVES[area - 1]],
    localPool: AREA_EXCLUSIVES[area - 1],
    worldScale: area < 3 ? 1 : 1 + (area - 2) * 0.08,
    challenge: challenge,
    challengeName: CHALLENGE_NAMES[challenge]!,
  );
}

final List<Stage> STAGES = [
  _s('Jejak Alpaka', 1, ['land'], ['alpaka'], 45, 0.72, 10, 1, 'gentle'),
  _s('Rumput Bersembunyi', 1, ['land'], ['poni', 'ayam_jago', 'kelinci_belang'], 44, 0.8, 14, 1, 'burrow'),
  _s('Sayap Kanopi', 2, ['land', 'sky'], ['orangutan', 'makaw'], 42, 0.88, 16, 2, 'zigzag'),
  _s('Kabut Zamrud', 2, ['land', 'sky'], ['jaguar', 'tapir', 'kasuari'], 40, 0.96, 19, 2, 'camouflage'),
  _s('Gelombang Emas', 3, ['land', 'sky'], ['rusa_gazel', 'meerkat', 'burung_sekretaris'], 38, 1.04, 21, 2, 'stampede'),
  _s('Kawanan Berbalik', 3, ['land', 'sky'], ['burung_unta', 'wildebeest', 'babi_kutil'], 37, 1.12, 24, 3, 'reverse'),
  _s('Oasis Semu', 4, ['land', 'sky'], ['rubah_fennec', 'oryx'], 36, 1.2, 25, 3, 'mirage'),
  _s('Badai Gurun', 4, ['land', 'sky'], ['jerboa', 'roadrunner', 'burung_hantu_gurun'], 34, 1.3, 28, 3, 'sandstorm'),
  _s('Pasang Mangrove', 5, ['land', 'sky', 'water'], ['bekantan', 'raja_udang', 'ikan_gelodok'], 34, 1.36, 29, 3, 'tide'),
  _s('Akar Menyergap', 5, ['land', 'sky', 'water'], ['biawak', 'ibis', 'berang_sungai'], 33, 1.43, 32, 4, 'ambush'),
  _s('Arus Martil', 6, ['sky', 'land', 'water'], ['ikan_badut', 'hiu_martil', 'dugong'], 32, 1.5, 33, 4, 'current'),
  _s('Gelembung Koral', 6, ['sky', 'land', 'water'], ['belut_moray', 'udang_mantis', 'penyu_sisik'], 31, 1.56, 36, 4, 'bubble'),
  _s('Kabut Bara', 7, ['sky', 'land', 'water'], ['salamander_api', 'kondor', 'panther_hitam'], 30, 1.62, 37, 4, 'heat'),
  _s('Lari Lava', 7, ['sky', 'land', 'water'], ['kambing_gunung', 'kepiting_lava', 'tokek_terbang'], 29, 1.7, 40, 4, 'lava'),
  _s('Sorot Bulan', 8, ['sky', 'land', 'water'], ['ngengat_bulan', 'rakun', 'ubur_bulan'], 29, 1.76, 41, 5, 'dark'),
  _s('Arah Bulan', 8, ['sky', 'land', 'water'], ['kunang_kunang', 'kucing_hitam', 'cumi_cumi'], 28, 1.82, 44, 5, 'moonshift'),
  _s('Badai Aurora', 9, ['sky', 'land', 'water'], ['rubah_arktik', 'burung_hantu_salju', 'narwhal'], 28, 1.88, 45, 5, 'snow'),
  _s('Lantai Es', 9, ['sky', 'land', 'water'], ['rusa_kutub', 'puffin', 'beruang_kutub'], 27, 1.94, 48, 5, 'ice'),
  _s('Portal Kawanan', 10, ['sky', 'land', 'water'], ['elang_emas', 'macan_awan', 'koi_awan'], 26, 2, 50, 5, 'portal'),
  _s('Chaos Satu Layar', 10, ['sky', 'land', 'water'], [], 25, 2.08, 55, 5, 'chaos'),
];

class Guardian {
  final String id;
  final String name;
  final String zone;
  final String sheet;
  final String animation;
  final double size;
  final int hp;
  const Guardian({required this.id, required this.name, required this.zone, required this.sheet, required this.animation, required this.size, required this.hp});
}

const Map<int, Guardian> GUARDIANS = {
  4: Guardian(id: 'guardian_kerbau', name: 'Kerbau Daun Emas', zone: 'land', sheet: 'GUARDIAN_SHEET', animation: 'guardian_kerbau_move', size: 150, hp: 5),
  9: Guardian(id: 'guardian_buaya', name: 'Buaya Akar Raya', zone: 'water', sheet: 'GUARDIAN_SHEET', animation: 'guardian_buaya_move', size: 164, hp: 6),
  14: Guardian(id: 'guardian_burung_hantu', name: 'Burung Hantu Bulan', zone: 'sky', sheet: 'GUARDIAN_SHEET', animation: 'guardian_burung_hantu_move', size: 158, hp: 7),
  19: Guardian(id: 'guardian_griffin', name: 'Griffin Kuil Langit', zone: 'sky', sheet: 'GUARDIAN_SHEET', animation: 'guardian_griffin_move', size: 176, hp: 9),
};

class Totem {
  final String id;
  final String name;
  final String risk;
  final String zone;
  final String sheet;
  final String animation;
  final double size;
  const Totem({required this.id, required this.name, required this.risk, required this.zone, required this.sheet, required this.animation, required this.size});
}

const Map<String, Totem> TOTEMS = {
  'sun': Totem(id: 'totem_sun', name: 'Matahari', risk: 'Skor x2 - gerak cepat', zone: 'land', sheet: 'TOTEM_SHEET', animation: 'totem_sun_move', size: 104),
  'moon': Totem(id: 'totem_moon', name: 'Bulan', risk: 'Gerak lambat - ring hilang', zone: 'land', sheet: 'TOTEM_SHEET', animation: 'totem_moon_move', size: 104),
  'storm': Totem(id: 'totem_storm', name: 'Badai', risk: 'Target ramai - salah -4 dtk', zone: 'land', sheet: 'TOTEM_SHEET', animation: 'totem_storm_move', size: 104),
  'bloom': Totem(id: 'totem_bloom', name: 'Mekar', risk: '+3 dtk & rare x2 - decoy tumbuh', zone: 'land', sheet: 'TOTEM_SHEET', animation: 'totem_bloom_move', size: 104),
};

List<String> chooseTargets(int stageIndex) {
  final source = STAGES[stageIndex].targets;
  if (source.isNotEmpty) return [...source];
  final pool = ANIMALS.where((a) => a.waveTier == null).toList();
  pool.shuffle();
  return pool.take(5).map((a) => a.id).toList();
}

Map<String, int> distributeTargets(List<String> ids, int total) {
  final result = <String, int>{for (final id in ids) id: total ~/ ids.length};
  for (int i = 0; i < total % ids.length; i++) result[ids[i]] = result[ids[i]]! + 1;
  return result;
}

// Tweak defaults (mirror of tweaks.json values).
class Tuning {
  double speedScale = 1;
  double spawnScale = 1;
  double rareChance = 0.05;
  double pressureIntensity = 1;
  double guardianHpScale = 1;
  double totemDuration = 8;
  double formationGapScale = 1;
  double wave4Speed = 1.65;
  double eliteTapCount = 3;
  bool haptics = true;
}
