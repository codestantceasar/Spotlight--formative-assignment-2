import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../splash/splash_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';



class ProfileScreen extends ConsumerWidget {

  final ValueChanged<bool>? onThemeChanged;

  final bool isDarkMode;



  const ProfileScreen({

    super.key,

    this.onThemeChanged,

    this.isDarkMode = true,

  });



  Stream<DocumentSnapshot<Map<String,dynamic>>> profileStream(
      String uid){

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots();

  }





  Stream<QuerySnapshot<Map<String,dynamic>>> connectionsStream(
      String uid){

    return FirebaseFirestore.instance
        .collection('connections')
        .where(
      'participants',
      arrayContains: uid,
    )
        .snapshots();

  }





  Stream<QuerySnapshot<Map<String,dynamic>>> postsStream(
      String uid){

    return FirebaseFirestore.instance
        .collection('feed_posts')
        .where(
      'authorId',
      isEqualTo: uid,
    )
        .snapshots();

  }





  @override
  Widget build(
      BuildContext context,
      WidgetRef ref){

    final theme =
        Theme.of(context);


    final uid =
        FirebaseAuth.instance.currentUser?.uid;



    if(uid == null){

      return const Center(
        child:
        Text(
          'Please login',
        ),
      );

    }





    return Scaffold(

      backgroundColor:
      theme.scaffoldBackgroundColor,


      body:

      StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(

        stream:
        profileStream(uid),


        builder:(context,profileSnapshot){


          final data =
              profileSnapshot.data?.data()
                  ??
                  {};



          final name =
              data['name']
                  ??
                  'Creator';



          final type =
              data['accountType']
                  ??
                  'creator';



          final bio =
              data['bio']
                  ??
                  'Showcase your talent on Spotlight';



          final skills =

          (data['skills']
          as List<dynamic>?)

              ?.map(
                  (e)=>e.toString()
          )

              .toList()

              ??

              [];





          return StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(


            stream:
            connectionsStream(uid),



            builder:(context,connectionSnapshot){



              final connections =
                  connectionSnapshot.data?.docs
                      ??
                      [];





              return StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(


                stream:
                postsStream(uid),



                builder:(context,postSnapshot){



                  final posts =
                      postSnapshot.data?.docs
                          ??
                          [];





                  return CustomScrollView(

                    slivers:[




                      SliverToBoxAdapter(


                        child:

                        Padding(

                          padding:

                          const EdgeInsets.all(20),


                          child:

                          Column(

                            children:[



                              Row(

                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,


                                children:[



                                  const Text(

                                    'Profile',

                                    style:

                                    TextStyle(

                                      fontSize:30,

                                      fontWeight:
                                      FontWeight.bold,

                                    ),

                                  ),




                                  IconButton(

                                    onPressed:() async {


                                      await FirebaseAuth
                                          .instance
                                          .signOut();



                                      if(!context.mounted)return;



                                      Navigator.pushAndRemoveUntil(

                                        context,

                                        MaterialPageRoute(

                                          builder:(_)=>

                                          const SplashScreen(),

                                        ),

                                            (route)=>false,

                                      );

                                    },


                                    icon:

                                    const Icon(
                                      Icons.logout,
                                    ),

                                  )


                                ],

                              ),





                              const SizedBox(height:20),






                              CircleAvatar(

                                radius:48,


                                backgroundColor:
                                AppColors.primary,


                                child:

                                Icon(

                                  type ==
                                      'organization'

                                      ?

                                  Icons.business

                                      :

                                  Icons.person,


                                  size:50,


                                  color:
                                  AppColors.darkText,

                                ),

                              ),




                              const SizedBox(height:14),




                              Text(

                                name,

                                style:

                                const TextStyle(

                                  fontSize:24,

                                  fontWeight:
                                  FontWeight.bold,

                                ),

                              ),





                              const SizedBox(height:6),





                              Container(

                                padding:

                                const EdgeInsets.symmetric(

                                  horizontal:14,

                                  vertical:6,

                                ),



                                decoration:

                                BoxDecoration(

                                  color:
                                  AppColors.primary
                                      .withAlpha(50),


                                  borderRadius:
                                  BorderRadius.circular(20),

                                ),



                                child:

                                Text(

                                  type ==
                                      'organization'

                                      ?

                                  'Organization'

                                      :

                                  'Creator',



                                  style:

                                  const TextStyle(

                                    color:
                                    AppColors.primary,

                                    fontWeight:
                                    FontWeight.bold,

                                  ),

                                ),

                              ),






                              const SizedBox(height:15),






                              Text(

                                bio,

                                textAlign:
                                TextAlign.center,


                                style:

                                TextStyle(

                                  color:

                                  theme.colorScheme
                                      .onSurface
                                      .withAlpha(180),

                                ),

                              ),






                              const SizedBox(height:20),






                              Row(

                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,


                                children:[


                                  ProfileStat(

                                    value:
                                    posts.length.toString(),

                                    title:
                                    'Posts',

                                  ),


                                  ProfileStat(

                                    value:
                                    connections.length.toString(),

                                    title:
                                    'Network',

                                  ),


                                  ProfileStat(

                                    value:
                                    '0',

                                    title:
                                    'Points',

                                  ),


                                ],


                              ),






                              const SizedBox(height:20),






                              Row(

                                children:[


                                  Expanded(

                                    child:

                                    ElevatedButton(

                                      onPressed:(){

                                        Navigator.push(

                                          context,

                                          MaterialPageRoute(

                                            builder:(_)=>

                                            const EditProfileScreen(),

                                          ),

                                        );

                                      },


                                      child:

                                      const Text(
                                        'Edit Profile',
                                      ),

                                    ),

                                  ),




                                  const SizedBox(width:10),





                                  IconButton(

                                    onPressed:(){

                                      Navigator.push(

                                        context,

                                        MaterialPageRoute(

                                          builder:(_)=>

                                          const SettingsScreen(),

                                        ),

                                      );

                                    },


                                    icon:

                                    const Icon(
                                      Icons.settings,
                                    ),

                                  )


                                ],

                              ),






                              const SizedBox(height:20),





                              if(skills.isNotEmpty)

                                Wrap(

                                  spacing:8,

                                  children:

                                  skills.map(

                                          (skill)=>

                                          Chip(

                                            label:
                                            Text(skill),

                                          )

                                  ).toList(),

                                )





                            ],

                          ),

                        ),


                      ),





                      SliverPadding(

                        padding:

                        const EdgeInsets.all(20),



                        sliver:

                        SliverGrid(

                          delegate:

                          SliverChildBuilderDelegate(

                                  (context,index){


                                final post =
                                posts[index].data();



                                return Container(

                                  decoration:

                                  BoxDecoration(

                                    color:
                                    AppColors.surface,

                                    borderRadius:
                                    BorderRadius.circular(16),

                                  ),


                                  child:

                                  Center(

                                    child:

                                    Text(

                                      post['caption']
                                          ??
                                          '',

                                      maxLines:3,

                                      overflow:
                                      TextOverflow.ellipsis,

                                    ),

                                  ),

                                );


                              },


                              childCount:
                              posts.length

                          ),



                          gridDelegate:

                          const SliverGridDelegateWithFixedCrossAxisCount(

                            crossAxisCount:3,

                            crossAxisSpacing:8,

                            mainAxisSpacing:8,

                          ),

                        ),

                      )





                    ],

                  );



                },


              );


            },


          );


        },


      ),

    );


  }


}




class ProfileStat extends StatelessWidget {


  final String value;

  final String title;



  const ProfileStat({

    super.key,

    required this.value,

    required this.title,

  });



  @override
  Widget build(BuildContext context){


    return Column(

      children:[

        Text(

          value,

          style:

          const TextStyle(

            fontSize:22,

            fontWeight:
            FontWeight.bold,

          ),

        ),


        Text(title),

      ],

    );


  }


}