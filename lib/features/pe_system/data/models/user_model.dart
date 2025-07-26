class UserModel{
  final int id;
  final String email;
  UserModel({required this.id, required this.email});
  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(id: json['id']??0, email: json['email']??'');
  }
  Map<String, dynamic> toJson(){
    return{
      'id':id,
      'email': email,
    };
  }
}