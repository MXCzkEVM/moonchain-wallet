// Define the weights for each sleep stage
final Map<int, double> weights = {
  1: 1.0, // Deep sleep
  2: 0.5, // Light sleep
  3: 0.5, // REM sleep
  4: 0.1, // Awake
  5: 0.1, // Awake
};
// Define the threshold for normal sleep quality
const double threshold = 0.5;

class BlueberryRingDataAnalyzer {
  static double calculateSleepQuality(List<int> sleepData) {
    double totalWeight = 0.0;
    double weightedSum = 0.0;

    for (int stage in sleepData) {
      double weight = weights[stage] ?? 0.0;
      weightedSum += weight;
      totalWeight += 1.0;
    }

    return weightedSum / totalWeight;
  }

  static bool isSleepQualityBelowNormal(List<int> sleepData) {
    double sleepQuality = calculateSleepQuality(sleepData);
    return sleepQuality < threshold;
  }

  static bool isSleepQualityNormal(List<int> sleepData) {
    if (isSleepQualityBelowNormal(sleepData)) {
      return true;
    } else {
      return false;
    }
  }
}
