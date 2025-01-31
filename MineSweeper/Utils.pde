static class Utils {

  public static Boolean isBetween(Tuple<Integer, Integer> numbers, Tuple<Integer, Integer> first, Tuple<Integer, Integer> second) {
    return (numbers.first >= first.first && numbers.first <= second.first && numbers.second >= first.second && numbers.second <= second.second);
  }

}
