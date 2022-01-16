
class APIPath{
  static String user(String uid) => 'users/$uid';
  static String users() => 'users';

  static String attraction(String attractionId) => 'attractions/$attractionId';
  static String attractions() => 'attractions';
}
