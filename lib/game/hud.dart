import 'package:flutter/material.dart';
import 'safari_game.dart';

class HudOverlay extends StatelessWidget {
  final SafariGame game;
  const HudOverlay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game.controller,
      builder: (context, _) {
        final c = game.controller;
        if (c.screen == Screen.start) {
          return _startOverlay(c);
        }
        return Stack(
          children: [
            _compactTopHud(c),
            _skillDock(c),
            if (c.toastVisible) _toast(c.toast),
            if (c.screen == Screen.result) _resultModal(c),
            if (c.screen == Screen.stages) _stagesModal(c),
            if (c.screen == Screen.shop) _shopModal(c),
            if (c.screen == Screen.pause) _pauseModal(c),
          ],
        );
      },
    );
  }

  Widget _startOverlay(SafariController c) {
    return Container(
      color: const Color(0x33061d1c),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'SAFARI HUNTER BLITZ',
              style: TextStyle(
                fontFamily: 'Bungee',
                fontSize: 56,
                color: const Color(0xffffe66d),
                shadows: const [
                  Shadow(offset: Offset(3, 4), color: Color(0xff604127)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xe4183e2c),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xc2fff2b2)),
              ),
              child: Text(
                c.status,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xfffff9d8),
                ),
              ),
            ),
            const SizedBox(height: 22),
            if (c.started)
              ElevatedButton(
                onPressed: () => game.startGame(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffefb73d),
                  foregroundColor: Color(0xff3b3824),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'MULAI',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _compactTopHud(SafariController c) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xe61b3c30),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x88fff0a5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 5),
                    // Row(
                    //   children: [
                    //     _resource('●', '${c.coins}', const Color(0xffffd34f)),
                    //     const SizedBox(width: 3),
                    //     _resource('★', '${c.seeds}', const Color(0xffffe888)),
                    //     const SizedBox(width: 3),
                    //     _resource('♦', '${c.gems}', const Color(0xff76ecff)),
                    //   ],
                    // ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '◆ ${c.challengeName}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xffffe88b),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 72,
                          child: LinearProgressIndicator(
                            value: c.pressure.clamp(0, 1),
                            minHeight: 4,
                            backgroundColor: const Color(0x66304839),
                            color: const Color(0xff71d886),
                          ),
                        ),
                      ],
                    ),
                    if (c.mutatorName != null) ...[
                      const SizedBox(height: 4),
                      _mutator(c.mutatorName!, c.mutatorTime),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 116,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xe61b3c30),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x88fff0a5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.track_changes,
                        size: 14,
                        color: Color(0xffffe780),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'TARGET',
                        style: TextStyle(
                          fontFamily: 'Bungee',
                          fontSize: 10,
                          color: Color(0xffffe780),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ...c.targets
                      .take(3)
                      .map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xffffd74f),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  t.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xfffff9db),
                                  ),
                                ),
                              ),
                              Text(
                                '${t.remaining}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xffffea77),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  if (c.targets.isEmpty)
                    const Text(
                      'Gelombang berikutnya',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 9,
                        color: Color(0xffcde2b6),
                      ),
                    ),
                  if (c.targets.length > 3)
                    const Text(
                      '+ target lain',
                      style: TextStyle(fontSize: 9, color: Color(0xffcde2b6)),
                    ),
                  if (c.guardianVisible) ...[
                    const SizedBox(height: 5),
                    const Divider(color: Color(0x72ffe267), height: 1),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'PENJAGA',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Color(0xffffe16a),
                            ),
                          ),
                        ),
                        Text(
                          '${c.guardianHp}/${c.guardianMaxHp}',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Color(0xffffe16a),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    LinearProgressIndicator(
                      value: c.guardianMaxHp > 0
                          ? c.guardianHp / c.guardianMaxHp
                          : 0,
                      minHeight: 3,
                      backgroundColor: const Color(0x4c071d18),
                      color: const Color(0xffffe16a),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _compactStat(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: RichText(
      text: TextSpan(
        text: '$label ',
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: Color(0xffcde2b6),
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              fontFamily: 'Bungee',
              fontSize: 10,
              color: Color(0xfffff0a0),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _topHud(SafariController c) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _woodChip('${c.stageIndex + 1}', 'A${c.area} - ${c.stageName}'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _resource('●', '${c.coins}', const Color(0xffffd34f)),
                    const SizedBox(width: 4),
                    _resource('★', '${c.seeds}', const Color(0xffffe888)),
                    const SizedBox(width: 4),
                    _resource('♦', '${c.gems}', const Color(0xff76ecff)),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xd653391f),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0x99ffed8b)),
                  ),
                  child: Text(
                    '◆ ${c.challengeName}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: c.challengeActive
                          ? const Color(0xffffe88b)
                          : const Color(0xffffe88b),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _badge(
                    '⏱',
                    c.time.toStringAsFixed(1),
                    color: c.time < 8
                        ? const Color(0xffb93d36)
                        : const Color(0xff1f4833),
                    urgent: c.time < 8,
                  ),
                  const SizedBox(height: 5),
                  _badge('SKOR', c.score.toString(), small: true),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  _badge(
                    'GELOMBANG',
                    '${c.wave}/5',
                    color: c.wave == 4
                        ? const Color(0xff1c597b)
                        : (c.wave == 5
                              ? const Color(0xff873027)
                              : const Color(0xff1f4833)),
                  ),
                  const SizedBox(width: 5),
                  _badge(
                    'COMBO',
                    'x${[1, 2, 3, 5, 8, 10][c.combo.clamp(0, 5)]}',
                    hot: c.combo >= 4,
                  ),
                ],
              ),
              const SizedBox(height: 5),
              _pressure(c.pressure),
              if (c.mutatorName != null)
                _mutator(c.mutatorName!, c.mutatorTime),
            ],
          ),
          Container(
            width: 120,
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xee1d3e2d),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xc6fff5c4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '◎ TARGET',
                  style: TextStyle(
                    fontFamily: 'Bungee',
                    fontSize: 11,
                    color: Color(0xffffe780),
                  ),
                ),
                const SizedBox(height: 4),
                ...c.targets
                    .take(3)
                    .map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xffffd74f),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                t.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xfffff9db),
                                ),
                              ),
                            ),
                            Text(
                              'x${t.remaining}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xffffea77),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (c.targets.isEmpty)
                  const Text(
                    'Gelombang berikutnya...',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                      color: Color(0xffcde2b6),
                    ),
                  ),
                if (c.targets.length > 3)
                  const Text(
                    '+ target lain',
                    style: TextStyle(fontSize: 10, color: Color(0xffcde2b6)),
                  ),
                if (c.guardianVisible) ...[
                  const SizedBox(height: 6),
                  Divider(color: const Color(0x72ffe267), height: 1),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'PENJAGA',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Color(0xffffe16a),
                          ),
                        ),
                      ),
                      Text(
                        '${c.guardianHp}/${c.guardianMaxHp}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xffffe16a),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  LinearProgressIndicator(
                    value: c.guardianMaxHp > 0
                        ? c.guardianHp / c.guardianMaxHp
                        : 0,
                    backgroundColor: const Color(0x4c071d18),
                    color: const Color(0xffffe16a),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _woodChip(String num, String name) => Container(
    decoration: BoxDecoration(
      color: const Color(0xee36572c),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xc6fff5c4)),
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xfff5bf41),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                fontFamily: 'Bungee',
                fontSize: 18,
                color: Color(0xff3b3824),
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xfffff9db),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _resource(String sym, String val, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xee1b4137),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: const Color(0x99fff1a3)),
    ),
    child: RichText(
      text: TextSpan(
        text: '$sym ',
        style: TextStyle(fontSize: 13, color: color),
        children: [
          TextSpan(
            text: val,
            style: const TextStyle(fontSize: 13, color: Color(0xfffff9db)),
          ),
        ],
      ),
    ),
  );

  Widget _badge(
    String label,
    String value, {
    Color color = const Color(0xff1f4833),
    bool urgent = false,
    bool hot = false,
    bool small = false,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration:
        BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xc6fff5c4)),
        ).copyWith(
          color: urgent
              ? const Color(0xffb93d36)
              : (hot ? const Color(0xff9e4a27) : color),
        ),
    child: Column(
      children: [
        if (!small)
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Color(0xffcde2b6),
            ),
          ),
        Text(
          value,
          style: TextStyle(
            fontSize: small ? 18 : 16,
            fontFamily: 'Bungee',
            color: const Color(0xfffff0a0),
          ),
        ),
      ],
    ),
  );

  Widget _pressure(double p) => Container(
    width: 104,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xe61b4137),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xa6fff1a3)),
    ),
    child: Column(
      children: [
        const Text(
          'TEKANAN',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: Color(0xffd7edc5),
          ),
        ),
        const SizedBox(height: 3),
        LinearProgressIndicator(
          value: p.clamp(0, 1),
          backgroundColor: const Color(0xbf071d18),
          color: const Color(0xff71d886),
        ),
      ],
    ),
  );

  Widget _mutator(String name, double t) => Container(
    width: 104,
    margin: const EdgeInsets.only(top: 5),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xee334530),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xffffe58b)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Color(0xfffff5bd),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${t.toInt()}s',
          style: const TextStyle(fontSize: 11, color: Color(0xffffe16b)),
        ),
      ],
    ),
  );

  Widget _skillDock(SafariController c) => Positioned(
    bottom: 20,
    left: 0,
    right: 0,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: _woodChip(
            '${c.stageIndex + 1}',
            'A${c.area} - ${c.stageName}',
          ),
        ),

        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              _compactStat(
                'TIME',
                c.time.toStringAsFixed(1),
                c.time < 8 ? const Color(0xffb93d36) : const Color(0xff285c45),
              ),
              const SizedBox(width: 4),
              _compactStat('SCORE', '${c.score}', const Color(0xff285c45)),
              const SizedBox(width: 4),
              Expanded(
                child: _compactStat(
                  'WAVE',
                  '${c.wave}/5',
                  const Color(0xff285c45),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _bagButton(c),
            const SizedBox(width: 8),
            _skillBtn(c, 'freeze', '❄', 'Beku', c.skillCharges['freeze'] ?? 0),
            const SizedBox(width: 8),
            _skillBtn(c, 'bait', '🍃', 'Umpan', c.skillCharges['bait'] ?? 0),
            const SizedBox(width: 8),
            _skillBtn(c, 'burst', '✦', 'Ledakan', c.skillCharges['burst'] ?? 0),
          ],
        ),
      ],
    ),
  );

  Widget _skillBtn(
    SafariController c,
    String skill,
    String icon,
    String label,
    int remaining,
  ) => GestureDetector(
    onTap: remaining <= 0 ? null : () => game.useSkill(skill),
    child: Container(
      width: 92,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: remaining <= 0
            ? const Color(0x552d5c40)
            : const Color(0xf02d5c40),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xe6fff5b8)),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 21)),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xfffff8ca),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: remaining <= 0
                    ? const Color(0x55304438)
                    : const Color(0x664d7045),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                remaining > 0 ? '${remaining}x' : 'Habis',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Color(0xfff7dc72),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _bagButton(SafariController c) => GestureDetector(
    onTap: () => game.showShop(),
    child: Container(
      width: 58,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffffd866), Color(0xffd9902f)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xfffff1a1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55101f1a),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('★', style: TextStyle(fontSize: 19, color: Color(0xfffff6b8))),
          Text(
            'Toko',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xff4b3820),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _toast(String msg) => Positioned(
    top: 96,
    left: 0,
    right: 0,
    child: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xef1e4832),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xffffe98a)),
        ),
        child: Text(
          msg,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xfffff8c7),
          ),
        ),
      ),
    ),
  );

  Widget _resultModal(SafariController c) => _modal(
    Column(
      children: [
        Text(
          c.resultTitle,
          style: TextStyle(
            fontFamily: 'Bungee',
            fontSize: 44,
            color: c.resultSuccess
                ? const Color(0xffffe16b)
                : const Color(0xffff8e72),
            shadows: const [
              Shadow(offset: Offset(3, 3), color: Color(0xff694022)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (i) => Icon(
              Icons.star,
              size: 46,
              color: i < c.resultStars
                  ? const Color(0xffffd84f)
                  : const Color(0x4c0f2a22),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Area ${c.area} - ${c.stageName}',
          style: const TextStyle(fontFamily: 'Bungee', fontSize: 22),
        ),
        const SizedBox(height: 8),
        Text(
          'SKOR',
          style: const TextStyle(fontSize: 12, color: Color(0xffbdddac)),
        ),
        Text(
          '${c.score}',
          style: const TextStyle(
            fontFamily: 'Bungee',
            fontSize: 44,
            color: Color(0xfffff2a4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          c.resultFacts,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xffd5ecc8),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          children: [
            _btn('Ulang', () => game.beginStage(c.stageIndex), secondary: true),
            if (c.resultSuccess && c.stageIndex < 19)
              _btn(
                'Stage ${c.stageIndex + 2}',
                () => game.beginStage(c.stageIndex + 1),
              ),
            _btn('Peta', () => game.showStages(), secondary: true),
          ],
        ),
      ],
    ),
  );

  Widget _stagesModal(SafariController c) => _modal(
    Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PETA SAFARI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xfff1d26b),
                  ),
                ),
                Text(
                  'Pilih Stage',
                  style: TextStyle(fontFamily: 'Bungee', fontSize: 22),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => game.closeModal(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x33122c2a),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    '×',
                    style: TextStyle(fontSize: 24, color: Color(0xfffff7c3)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0x55204b3a),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0x668fe0a4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.explore, color: Color(0xffffe16b), size: 19),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'PROGRES SAFARI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: Color(0xffcde8c4),
                  ),
                ),
              ),
              Text(
                '${c.stageNodes.where((n) => n.stars > 0).length}/${c.stageNodes.length}',
                style: const TextStyle(
                  fontFamily: 'Bungee',
                  color: Color(0xffffe16b),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: c.stageNodes
              .map(
                (n) => GestureDetector(
                  onTap: n.locked ? null : () => game.beginStage(n.index),
                  child: Container(
                    width: 146,
                    height: 82,
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: n.locked
                            ? [const Color(0x55203c2b), const Color(0x33203c2b)]
                            : [
                                const Color(0xcc245840),
                                const Color(0x99203d32),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: n.locked
                            ? const Color(0x447ca889)
                            : const Color(0x99ffe58b),
                      ),
                      boxShadow: n.locked
                          ? null
                          : const [
                              BoxShadow(
                                color: Color(0x33101f1a),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: n.locked
                                    ? const Color(0x445e856f)
                                    : const Color(0xffe5b43e),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Center(
                                child: n.locked
                                    ? const Icon(
                                        Icons.lock,
                                        size: 14,
                                        color: Color(0xffb5d0b2),
                                      )
                                    : Text(
                                        '${n.index + 1}',
                                        style: const TextStyle(
                                          fontFamily: 'Bungee',
                                          fontSize: 13,
                                          color: Color(0xff2f3b28),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                n.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xfffff7c8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          n.locked ? 'Terkunci' : n.challengeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: n.locked
                                ? const Color(0xff9bb99d)
                                : const Color(0xffffdd68),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: List.generate(
                            3,
                            (i) => Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Icon(
                                Icons.star,
                                size: 13,
                                color: i < n.stars
                                    ? const Color(0xffffd752)
                                    : const Color(0x557b926f),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        _btn('★ Toko Upgrade', () => game.showShop(), secondary: true),
      ],
    ),
  );

  Widget _shopModal(SafariController c) => _modal(
    Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xfff3c84b), Color(0xffb8752f)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(17),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55301816),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xfffff4b0),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOKO HUTAN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                      color: Color(0xffffdf73),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Upgrade Permanen',
                    style: TextStyle(fontFamily: 'Bungee', fontSize: 22),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Perkuat perlengkapan safari kamu.',
                    style: TextStyle(fontSize: 12, color: Color(0xffc9e7c4)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => game.closeModal(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x33122c2a),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x55fff0a5)),
                ),
                child: const Center(
                  child: Text(
                    '×',
                    style: TextStyle(fontSize: 24, color: Color(0xfffff7c3)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff254f3c), Color(0xff17382f)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x88f2d66d)),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Color(0xffffe56e), size: 22),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'BINTANG SAFARI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Color(0xffcce6bc),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => game.enableTestMoney(),
                child: const SizedBox.shrink(),
              ),
              Text(
                '${c.seeds}',
                style: const TextStyle(
                  fontFamily: 'Bungee',
                  fontSize: 22,
                  color: Color(0xffffe56e),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...c.shopItems.map((it) {
          final lvl = game.save.upgrades[it.id] ?? 0;
          final maxed = lvl >= it.max;
          final price = maxed ? 0 : it.prices[lvl];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: maxed
                    ? [const Color(0x552e6548), const Color(0x33204435)]
                    : [const Color(0xaa24533d), const Color(0x66152f28)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: maxed
                    ? const Color(0x6689d29a)
                    : const Color(0x88ffe38a),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0x55203d31),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    _shopIcon(it.id),
                    color: const Color(0xffffdf70),
                    size: 23,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        it.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xfffff0a0),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        it.detail,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xffc7e1bd),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(
                            it.max,
                            (i) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(right: 4),
                                height: 5,
                                decoration: BoxDecoration(
                                  color: i < lvl
                                      ? const Color(0xffffd752)
                                      : const Color(0xff173a2e),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$lvl/${it.max}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xffb8d9b2),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: maxed ? null : () => game.buyUpgrade(it.id, price),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: maxed
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xffffd860), Color(0xffe5a735)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: maxed ? const Color(0x44552a1a) : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: maxed
                            ? const Color(0x448acb98)
                            : const Color(0xffffefaa),
                      ),
                    ),
                    child: Text(
                      maxed ? 'MAX' : '★ $price',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: maxed
                            ? const Color(0xff9dcc9c)
                            : const Color(0xff3b3824),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 6),
        _btn('PILIH PETA', () => game.showStages(), secondary: true),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.info_outline, size: 15, color: Color(0xffa8d0a5)),
            SizedBox(width: 5),
            Text(
              'Dapatkan Bintang dari stage.',
              style: TextStyle(fontSize: 12, color: Color(0xffc7e1bd)),
            ),
          ],
        ),
      ],
    ),
  );

  IconData _shopIcon(String id) => switch (id) {
    'time' => Icons.hourglass_bottom,
    'radar' => Icons.radar,
    'score' => Icons.bolt,
    'freeze' => Icons.ac_unit,
    'bait' => Icons.grass,
    'burst' => Icons.auto_awesome,
    _ => Icons.upgrade,
  };

  Widget _pauseModal(SafariController c) => _modal(
    Column(
      children: [
        const Text(
          'JEDA',
          style: TextStyle(
            fontFamily: 'Bungee',
            fontSize: 44,
            color: Color(0xffffe16b),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          c.stageName,
          style: const TextStyle(fontFamily: 'Bungee', fontSize: 22),
        ),
        const SizedBox(height: 8),
        const Text(
          'Target menunggumu.',
          style: TextStyle(color: Color(0xffd7edc5)),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          children: [
            _btn('Lanjut', () => game.togglePause()),
            _btn('Ulang', () => game.beginStage(c.stageIndex), secondary: true),
            _btn('Peta', () => game.showStages(), secondary: true),
          ],
        ),
      ],
    ),
  );

  Widget _modal(Widget child) => Container(
    color: const Color(0x8e081d19),
    child: Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 680),
        decoration: BoxDecoration(
          color: const Color(0xfa3a623d),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xfff6d46b)),
        ),
        child: SingleChildScrollView(child: child),
      ),
    ),
  );

  Widget _btn(String label, VoidCallback onTap, {bool secondary = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: secondary
                  ? const [Color(0xff367657), Color(0xff214d3d)]
                  : const [Color(0xffffd866), Color(0xffd9902f)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xfffff0a5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44101f1a),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xfffff8d0),
            ),
          ),
        ),
      );
}
