class ApiError {  
  final int statusCode;  
  final String? message;  

  const ApiError(this.statusCode, [this.message]);  

  ApiError.fromJson(this.statusCode, Map<String, dynamic> json)  
      : message = json['message'] as String?;  
}