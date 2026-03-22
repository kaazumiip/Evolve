import '../models/emoticon_model.dart';

class EmoticonDataService {
  static List<EmoticonModel> _parseEmoticons() {
    // Data parsed from PDF: Kaomoji Japanese Emoticons
    final rawData = <String, List<String>>{
      'Happy': [
        '(* ^ ω ^)', '(´ ∀ ` *)', '٩(◕‿◕｡)۶', '(o^▽^o)', '(⌒▽⌒)☆',
        '(o･ω･o)', '(^人^)', '(o´▽`o)', '(*´▽`*)', '( ´ ω ` )',
        '(≧◡≦)', '(⌒‿⌒)', '(*°▽°*)', '(✧ω✧)', '(´｡• ᵕ •｡`)',
        '( ´ ▽ ` )', '(￣▽￣)', '╰(*´︶`*)╯', '(☆▽☆)', '(╯✧▽✧)╯',
        'o(❛ᴗ❛)o', '( ‾́◡ ‾́)', '(๑˘︶˘๑)', '°˖✧◝(⁰▿⁰)◜✧˖°',
        '(.❛ ᴗ ❛.)', '( ˙▿˙ )', '(¯▿¯)', '( ◕▿◕ )', '(ᵔ◡ᵔ)',
        '⸜(*ˊᗜˋ*)⸝', '(>⩊<)', '(ᗒ⩊ᗕ)', '(ᵔ⩊ᵔ)',
      ],
      'Love': [
        '(ﾉ´ з `)ノ', '(♡μ_μ)', '(*^^*)♡', '(♡-_-♡)', '(￣ε￣＠)',
        'ヽ(♡‿♡)ノ', '(─‿‿─)♡', '(´｡• ᵕ •｡`) ♡', '(*♡∀♡)',
        '(´ ω `♡)', '♡( ◡‿◡ )', '(◕‿◕)♡', '(ღ˘⌣˘ღ)', '(♡°▽°♡)',
        '♡(｡- ω -)', '(´• ω •`) ♡', '(´ ε ` )♡', '╰(*´︶`*)╯♡',
        '(*˘︶˘*).｡.:*♡', '(♡˙︶˙♡)', '(≧◡≦) ♡', '(⌒▽⌒)♡',
        '(*¯ ³¯*)♡', '❤(ɔˆз(ˆ⌣ˆc)', '(´♡‿♡`)', '(°◡°♡)',
        '( ´  ` ) ♡', '(˘˘ ♡)',
      ],
      'Sad': [
        '(ノ_<。)', '(-_-)', '(´-ω-`)', '(μ_μ)', '(ﾉД`)',
        '(-ω-、)', 'o(TヘTo)', '( ; ω ; )', '(｡╯︵╰｡)', '( ﾟ，_ゝ｀)',
        '(个_个)', '(╯︵╰,)', '( ╥ω╥ )', '(╯_╰)', '(╥_╥)',
        '(／ˍ・、)', '(ノ_<、)', '(╥﹏╥)', '(つω`｡)', '(｡T ω T｡)',
        '(T_T)', '(>_<)', '(っ˘̩╭╮˘̩)っ', 'o(〒﹏〒)o', '(｡•́︿•̀｡)',
        '(ಥ﹏ಥ)', '(ಡ‸ಡ)',
      ],
      'Angry': [
        '(＃`Д´)', '(`皿´＃)', '( ` ω ´ )', 'ヽ( `д´*)ノ', '(・`ω´・)',
        '(`ー´)', 'ヽ(`⌒´メ)ノ', '凸(`△´＃)', '( `ε´ )', 'ψ( ` ∇ ´ )ψ',
        'ヾ(`ヘ´)ﾉﾞ', 'ヽ(‵﹏´)ノ', '(╬`益´)', '凸( ` ﾛ ´ )凸',
        'Σ(▼□▼メ)', '(°ㅂ°╬)', 'ψ(▼へ▼メ)～→', '(ノ°益°)ノ',
        '(‡▼益▼)', '٩(╬ʘ益ʘ╬)۶', '(╬ Ò﹏Ó)', '(凸ಠ益ಠ)凸',
        '(ﾉಥ益ಥ)ﾉ', '(≖､≖╬)',
      ],
      'Sleepy': [
        '[(－－)]..zzZ', '(－_－) zzZ', '(∪｡∪)｡｡｡zzZ', '(－ω－) zzZ',
        '(￣o￣) zzZZzzZZ', '(( _ _ ))..zzzZZ', '(￣ρ￣)..zzZZ',
        '(－.－)...zzz', '(＿ ＿*) Z z z', '(x . x) ~~zzZ',
      ],
      'Hugging': [
        '(づ￣ ³￣)づ', '(つ≧▽≦)つ', '(つ✧ω✧)つ', '(づ ◕‿◕ )づ',
        '(⊃｡•́‿•̀｡)⊃', '(つ . •́_ʖ •̀.)つ', '(っಠ‿ಠ)っ', '(づ◡﹏◡)づ',
        '⊂(´• ω •`⊂)', '⊂(･ω･*⊂)', '⊂(￣▽￣)⊃', '⊂( ´ ▽ ` )⊃',
        '( ~*-*)~', '(っ ᵔ◡ᵔ)っ', '(っ╹ᆺ╹)っ',
      ],
      'Excited': [
        '☆*:.｡.o(≧▽≦)o.｡.:*☆', '٩(◕‿◕｡)۶', '(ﾉ≧∀≦)ﾉ ♪',
        '(ノ°∀°)ノ⌒･*:.｡.', '(╯✧▽✧)╯', '(*≧ω≦*)',
        '∑d(°∀°d)', '(✯◡✯)', 'ヽ(*⌒▽⌒*)ﾉ', 'o(≧▽≦)o',
        '(b ᵔ▽ᵔ)b', '(๑˃ᴗ˂)و', '(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧',
      ],
      'Embarrassed': [
        '(⌒_⌒;)', '(o^ ^o)', '(*/ω＼)', '(*/。＼)', '(*/_＼)',
        '(*ﾉωﾉ)', '(o-_-o)', '(*μ_μ)', '( ◡‿◡ *)', '(ᵔ.ᵔ)',
        '(*ﾉ∀`*)', '(//▽//)', '(//ω//)', '(*^.^*)', '(*ﾉ▽ﾉ)',
        '(￣▽￣*)ゞ', '(⁄ ⁄•⁄ω⁄•⁄ ⁄)', '(*/▽＼*)', '(„ಡωಡ„)',
        '( 〃▽〃)', '(///￣ ￣///)',
      ],
      'Surprised': [
        'w(°ｏ°)w', 'ヽ(°〇°)ﾉ', 'Σ(O_O)', 'Σ(°ロ°)', '(⊙_⊙)',
        '(o_O)', '(O_O;)', '(O.O)', '(°ロ°) !', '(o_O) !',
        '(□_□)', 'Σ(□_□)', '∑(O_O;)',
      ],
      'Confused': [
        '(￣ω￣;)', 'σ(￣、￣〃)', '(￣～￣;)', '(-_-;)・・・',
        '┐(\'～\`;)┌', '(・_・ヾ', '┐(￣ヘ￣;)┌', '(・_・;)',
        '(￣_￣)・・・', '(＠_＠)', 'Σ(￣。￣ﾉ)', '(・・ ) ?',
        '(•ิ_•ิ)?', '(◎ ◎)ゞ', '(ーー;)', '(・・?)',
      ],
      'Greeting': [
        '(*・ω・)ﾉ', '(￣▽￣)ノ', '(°▽°)/', '( ´ ∀ ` )ﾉ', '(^-^*)/',
        '(´• ω •`)ﾉ', 'ヾ(*\'▽\'*)', '＼(⌒▽⌒)', 'ヾ(☆▽☆)', '( ´ ▽ ` )ﾉ',
        '(^０^)ノ', '~ヾ(・ω・)', '(・∀・)ノ', 'ヾ(・ω・*)', '(*°ｰ°)ﾉ',
        '(o´ω`o)ﾉ', '(⌒ω⌒)ﾉ', '(≧▽≦)/', '(✧∀✧)/',
      ],
      'Winking': [
        '(^_~)', '( ﾟｵ⌒)', '(^_-)≡☆', '(^ω~)', '(>ω^)', '(~人^)',
        '(^_-)', '( -_・)', '(^_<)〜☆', '(^人<)〜☆', '☆⌒(≧▽° )',
        '(^_<)', '(^_−)☆', '(･ω<)☆', '(^.~)☆', '(^.~)',
        '(｡•̀ᴗ-)✧', '(>ᴗ•)', '☆(>ᴗ•)',
      ],
    };

    final emoticons = <EmoticonModel>[];
    for (final entry in rawData.entries) {
      for (final face in entry.value) {
        emoticons.add(EmoticonModel(face: face, category: entry.key));
      }
    }
    return emoticons;
  }

  static final List<EmoticonModel> allEmoticons = _parseEmoticons();

  static List<String> get categories {
    final cats = allEmoticons.map((e) => e.category).toSet().toList();
    cats.sort();
    return cats;
  }

  static List<EmoticonModel> getTrending() {
    // Return a curated trending list across popular categories
    final trending = <EmoticonModel>[];
    const trendingCategories = ['Happy', 'Love', 'Hugging', 'Excited', 'Sleepy', 'Sad'];
    for (final cat in trendingCategories) {
      final catEmoticons = allEmoticons.where((e) => e.category == cat).take(2);
      trending.addAll(catEmoticons);
    }
    return trending;
  }

  static List<EmoticonModel> filterByCategory(String category) {
    if (category == 'All') return allEmoticons;
    return allEmoticons.where((e) => e.category == category).toList();
  }

  static List<EmoticonModel> search(String query) {
    if (query.isEmpty) return allEmoticons;
    final lower = query.toLowerCase();
    return allEmoticons
        .where((e) =>
    e.face.toLowerCase().contains(lower) ||
        e.category.toLowerCase().contains(lower))
        .toList();
  }
}
