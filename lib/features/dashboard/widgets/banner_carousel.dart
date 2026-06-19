import 'dart:async';
import 'package:flutter/material.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() =>
      _BannerCarouselState();
}

class _BannerCarouselState
    extends State<BannerCarousel> {

  final PageController controller =
      PageController();

  int current = 0;

  final banners = [

    "assets/banners/banner1.png",
    "assets/banners/banner2.png",
    "assets/banners/banner3.png",
    "assets/banners/banner4.png",
    "assets/banners/banner5.png",

  ];


  @override
  void initState() {
    super.initState();

    Timer.periodic(
      const Duration(seconds: 5),
      (timer) {

        if (!mounted) {
          timer.cancel();
          return;
        }

        current++;

        if (current >= banners.length) {
          current = 0;
        }

        controller.animateToPage(
          current,
          duration:
              const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

      },
    );
  }


  @override
  Widget build(BuildContext context) {

    return Column(

      children: [

        SizedBox(

          height: 160,

          child: PageView.builder(

            controller: controller,

            itemCount: banners.length,

            onPageChanged: (index){

              setState(() {
                current = index;
              });

            },

            itemBuilder: (context,index){

              return Padding(

                padding:
                    const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),

                child: ClipRRect(

                  borderRadius:
                      BorderRadius.circular(18),

                  child: Image.asset(

                    banners[index],

                    fit: BoxFit.cover,

                  ),
                ),
              );

            },

          ),
        ),


        const SizedBox(height: 10),


        Row(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children:

          List.generate(

            banners.length,

            (index) => Container(

              margin:
                  const EdgeInsets.all(4),

              width:
                  current == index ? 18 : 8,

              height: 8,

              decoration: BoxDecoration(

                borderRadius:
                    BorderRadius.circular(10),

                color:
                  current == index
                  ? const Color(0xFF5E2B97)
                  : Colors.grey,

              ),

            ),

          ),

        )

      ],

    );
  }
}