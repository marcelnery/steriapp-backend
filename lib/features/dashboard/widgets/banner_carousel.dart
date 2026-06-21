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

  "https://backend-nu-nine-29.vercel.app/banners/banner1.png",

  "https://backend-nu-nine-29.vercel.app/banners/banner2.png",

  "https://backend-nu-nine-29.vercel.app/banners/banner3.png",

  "https://backend-nu-nine-29.vercel.app/banners/banner4.png",

  "https://backend-nu-nine-29.vercel.app/banners/banner5.png",

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

          height: 260,

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


// AGORA AS IMAGENS VIRAO DO MONGO E DO SITE PARA ALTERAÇÃO 20/06

                 child: Image.network(

  banners[index],

  fit: BoxFit.cover,

  loadingBuilder: (
    context,
    child,
    loadingProgress,
  ) {

    if (loadingProgress == null) {
      return child;
    }

    return const Center(
      child: CircularProgressIndicator(),
    );
  },

  errorBuilder: (
    context,
    error,
    stackTrace,
  ) {

    return Container(

      color: Colors.grey.shade200,

      child: const Center(

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(
              Icons.image_not_supported,
              size: 40,
            ),

            SizedBox(height: 10),

            Text(
              "Banner indisponível",
            ),

          ],
        ),
      ),
    );
  },
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