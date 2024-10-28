class Category {
  final String id;
  final String name;

  Category(this.id, this.name);

  @override
  operator ==(other) => other is Category && other.id == id;

  @override
  int get hashCode => Object.hash(id, name);
}
