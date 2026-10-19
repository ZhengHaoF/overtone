import 'dart:math';

/// 随机播放的洗牌工具（Fisher-Yates）。
///
/// 语义是「队列顺序即播放顺序」：洗牌直接重排播放队列，不另存一份播放顺序。
/// 这样 next/previous、队列持久化、MPRIS 队列、队列面板全部沿用既有机制，
/// 随机模式下「上一首」也自然等于「刚才播的那首」。

/// 随机源注入点（单测用）。null = 每次调用新建 [Random]。
///
/// 对齐 `netease_crypto.dart` 的 `debugRandom` 模式：生产代码不感知，
/// 测试注入固定种子即可复现同一排列。
Random? debugShuffleRandom;

Random _resolve(Random? injected) => injected ?? debugShuffleRandom ?? Random();

/// 取随机源（与 [shuffledQueue] 共用同一个注入点）。
///
/// 供需要「洗牌之外还要抽随机下标」的调用方使用（如随机模式下的队列追加），
/// 这样单测注入 [debugShuffleRandom] 就能复现整条链路。
Random shuffleRandom([Random? rng]) => _resolve(rng);

/// 身份比较：优先用调用方给的 [keyOf]（`identityKey` 之类），
/// 否则退回引用比较。
bool _same<T>(T a, T b, String Function(T)? keyOf) =>
    keyOf == null ? identical(a, b) : keyOf(a) == keyOf(b);

/// 返回 [items] 的一个随机排列（不修改入参）。
///
/// - [pinIndex]：该槽位的元素留在原地。用于「切入随机模式不跳歌」与
///   「随机模式点歌时把选中曲目钉在 startIndex」——当前曲目不动，
///   `currentIndex` 也不用变。
/// - [avoidFirst]：该元素保证不出现在 0 号位。用于「随机列表整队播完后
///   重洗，不从刚播完那首开始」。
/// - [keyOf]：[avoidFirst] 的身份取值函数。缺省按引用比较，而队列里的元素
///   随时长/质量回填会被换成新实例，调用方应传 `(t) => t.identityKey`。
///
/// [pinIndex] 与 [avoidFirst] 按场景二选一；同时给出时 [pinIndex] 优先。
List<T> shuffledQueue<T>(
  List<T> items, {
  int? pinIndex,
  T? avoidFirst,
  String Function(T)? keyOf,
  Random? rng,
}) {
  final n = items.length;
  if (n < 2) return List<T>.of(items);

  if (pinIndex != null) {
    // 先摘出钉位元素、只洗剩下的，保证「钉位固定的排列」均匀分布；
    // 若洗完整队再对调会把分布压偏（n=3 时两种结果 4:2）。
    final pin = pinIndex.clamp(0, n - 1);
    final rest = List<T>.of(items)..removeAt(pin);
    final random = _resolve(rng);
    for (var i = rest.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final tmp = rest[i];
      rest[i] = rest[j];
      rest[j] = tmp;
    }
    return <T>[...rest.sublist(0, pin), items[pin], ...rest.sublist(pin)];
  }

  final out = List<T>.of(items);
  final random = _resolve(rng);
  for (var i = n - 1; i > 0; i--) {
    final j = random.nextInt(i + 1);
    final tmp = out[i];
    out[i] = out[j];
    out[j] = tmp;
  }
  final first = out.first;
  if (avoidFirst != null && _same(first, avoidFirst, keyOf)) {
    // 与 1..n-1 中随机一个对调：0 号位必然避开它，分布偏置可忽略。
    final j = 1 + random.nextInt(n - 1);
    out[0] = out[j];
    out[j] = first;
  }
  return out;
}
