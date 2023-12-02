import 'package:dio/dio.dart';
import 'package:firebase_setup/api_intigrate/model/post_model.dart';
import 'package:get/get.dart';


class PostController extends GetxController {
  
  bool isLoading = false;
  Dio dio = Dio();
  List<PostModel>postListData = [];
  
  
  @override
  void onInit() {
    super.onInit();
    getPostData();
  }
  
  startLoading(){
    isLoading = true;
    update();
  }
  
  stopLoading(){
    isLoading = false;
    update();
  }
  
  Future<void>getPostData()async{
    try{
      startLoading();
      var response = await dio.get("https://jsonplaceholder.typicode.com/posts");
      print(response.data);
      
      if(response.statusCode == 200){
        stopLoading();
        List jsonData = response.data;
        List<PostModel>postList = jsonData.map((e) => PostModel.fromJson(e)).toList();
        postListData.addAll(postList);
        update();
        
        
      }else{
        print(response.statusCode);
        update();
      }
      
    }catch(e){
      print(e);
      update();
    }
  }
}