enum WalnutStage {
  walnut1(
    label: 'Walnut 1',
    assetPath: 'assets/images/walnut1.png',
    minimumBalance: 0,
    maximumBalance: 200,
    perfectWeekReward: 15,
    oneMissedDayReward: 10,
    setWeekReward: 10,
  ),
  walnut15(
    label: 'Walnut 1.5',
    assetPath: 'assets/images/walnut1.5.png',
    minimumBalance: 201,
    maximumBalance: 500,
    perfectWeekReward: 25,
    oneMissedDayReward: 20,
    setWeekReward: 20,
  ),
  walnut2(
    label: 'Walnut 2',
    assetPath: 'assets/images/walnut2.png',
    minimumBalance: 501,
    maximumBalance: 1000,
    perfectWeekReward: 40,
    oneMissedDayReward: 35,
    setWeekReward: 35,
  ),
  walnut25(
    label: 'Walnut 2.5',
    assetPath: 'assets/images/walnut2.5.png',
    minimumBalance: 1001,
    maximumBalance: 2000,
    perfectWeekReward: 60,
    oneMissedDayReward: 55,
    setWeekReward: 55,
  ),
  walnut3(
    label: 'Walnut 3',
    assetPath: 'assets/images/walnut3.png',
    minimumBalance: 2001,
    maximumBalance: null,
    perfectWeekReward: 100,
    oneMissedDayReward: 95,
    setWeekReward: 95,
  );

  const WalnutStage({
    required this.label,
    required this.assetPath,
    required this.minimumBalance,
    required this.maximumBalance,
    required this.perfectWeekReward,
    required this.oneMissedDayReward,
    required this.setWeekReward,
  });

  final String label;
  final String assetPath;
  final int minimumBalance;
  final int? maximumBalance;
  final int perfectWeekReward;
  final int oneMissedDayReward;
  final int setWeekReward;

  static WalnutStage forBalance(int balance) {
    if (balance <= 200) return WalnutStage.walnut1;
    if (balance <= 500) return WalnutStage.walnut15;
    if (balance <= 1000) return WalnutStage.walnut2;
    if (balance <= 2000) return WalnutStage.walnut25;
    return WalnutStage.walnut3;
  }

  double progressFor(int balance) {
    final maximum = maximumBalance;
    if (maximum == null) return 1;
    final previousMaximum = minimumBalance == 0 ? 0 : minimumBalance - 1;
    final capacity = maximum - previousMaximum;
    return ((balance - previousMaximum) / capacity).clamp(0, 1);
  }

  String balanceLabel(int balance) =>
      maximumBalance == null ? '$balance / ∞' : '$balance / $maximumBalance';
}

enum WalnutRewardKind { perfectWeek, oneMissedDay, setWeek }

class WalnutRewardGrant {
  const WalnutRewardGrant({required this.ledgerId, required this.kind});

  final String ledgerId;
  final WalnutRewardKind kind;
}
