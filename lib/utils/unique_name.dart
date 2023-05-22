class UniqueName {
  String combineUniqueStrings(String uid1, String uid2) {
    int hashCode = 0;

    for (int i = 0; i < uid1.length; i++) {
      hashCode ^= uid1.codeUnitAt(i);
    }

    for (int i = 0; i < uid2.length; i++) {
      hashCode ^= uid2.codeUnitAt(i);
    }

    String uniqueValue = hashCode.toRadixString(16);
    return uniqueValue;
  }
}
