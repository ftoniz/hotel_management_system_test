extension SafetyList<E> on List<E> {
  E? tryFirstWhere(bool Function(E e) test) {
    var list = where(test);
    return list.isNotEmpty ? list.first : null;
  }
}
