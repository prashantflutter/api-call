import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/post_controller.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PostController postController = Get.put(PostController());
    return Scaffold(
      appBar: AppBar(title: Text("Post List Data"),backgroundColor: Colors.amber.shade500,),
      body: GetBuilder<PostController>(builder: (_){
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 8),
          color: Colors.amber,
          child:  ListView.builder(
              itemCount: postController.postListData.length,
                itemBuilder: (context,index){
                var indexM = postController.postListData[index];
              return GestureDetector(
                onTap: (){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(indexM.title.toString(),maxLines: 1,style: TextStyle(color: Colors.amber),),
                    backgroundColor: Colors.white,)
                  );
                },
                child: Container(
                    width: double.infinity,
                    height: 80,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child:ListTile(
                      style: ListTileStyle.list,
                      leading: Text(indexM.id.toString()),
                      title: Text(indexM.title.toString(),maxLines: 1,),
                      subtitle: Text(indexM.body.toString(),maxLines: 1,),
                    )),
              );
            }),

        );
      }),
    );
  }
}
