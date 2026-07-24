import 'dart:async';
import 'package:flutter/material.dart';

import 'label_print_page.dart';
import '../../cycles/models/cycle_model.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/auth_service.dart';
import '../services/label_counter_service.dart';





class LabelSplashPage extends StatefulWidget {
  final CycleModel? lastCycle;

  const LabelSplashPage({
    super.key,
    required this.lastCycle,
  });

  @override
  State<LabelSplashPage> createState() => _LabelSplashPageState();
}

class _LabelSplashPageState extends State<LabelSplashPage>
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late AnimationController _progressController;

  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;

  late Animation<double> _backgroundOpacity;
  late AnimationController _overlayController;
  late Animation<double> _overlayOpacity;
  late Animation<double> _progress;

//=====================================
// DADOS DA SESSÃO
//=====================================

final counter = LabelCounterService.instance;

String clinicName = "";

String operatorName = "";

String dentistName = "";

String autoclaveModel = "";

int nextCycle = 0;

bool sessionLoaded = false;


  final List<bool> _steps = [
    false,
    false,
    false,
    false,
    false,
  ];

  final List<String> stepTitles = [

    

    "Validando dados da clínica",

    "Identificando Autoclave Woson",

    "Carregando rastreabilidade",

    "Preparando etiquetas inteligentes",

    "Sistema Pronto!"

  ];

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _overlayController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 1200),
);

_overlayOpacity = Tween<double>(
  begin: 0,
  end: 1,
).animate(
  CurvedAnimation(
    parent: _overlayController,
    curve: Curves.easeInOut,
  ),
);

    _backgroundOpacity = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeOut,
    );

    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );

    _logoScale = Tween<double>(
      begin: .80,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    _progress = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );
//=====================================
// CARREGA TODA A SESSÃO DO LABEL
//=====================================

Future<void> _loadSessionData() async {

  try {

    //----------------------------------------------------
    // contador
    //----------------------------------------------------

    await counter.load();

    //----------------------------------------------------
    // token
    //----------------------------------------------------

    final token = await AuthService.getToken();

    //----------------------------------------------------
    // usuário
    //----------------------------------------------------

    final response = await http.get(

      Uri.parse(
        "https://backend-nu-nine-29.vercel.app/api/user",
      ),

      headers: {

        "Authorization": "Bearer $token",

        "Content-Type": "application/json",

      },

    );

    if (response.statusCode != 200) {

      print("Erro carregando usuário");

      return;

    }

    final data = jsonDecode(response.body);

    //----------------------------------------------------
    // autoclaves cadastradas
    //----------------------------------------------------

    final autoclaves = data["autoclaves"] ?? [];

    Map<String,dynamic>? selectedAutoclave;

    if(widget.lastCycle != null){

      final cicloSerial = widget.lastCycle!.serialNumber

          .replaceAll("SN.:", "")

          .replaceAll("SN.", "")

          .replaceAll("SN:", "")

          .replaceAll(":", "")

          .trim();

      for(final a in autoclaves){

        final cadastro =

            (a["serial"] ?? "")

                .toString()

                .replaceAll("SN.:","")

                .replaceAll("SN.","")

                .replaceAll("SN:","")

                .replaceAll(":","")

                .trim();

        if(cadastro == cicloSerial){

          selectedAutoclave =

              Map<String,dynamic>.from(a);

          break;

        }

      }

    }

    //----------------------------------------------------
    // grava sessão
    //----------------------------------------------------

    clinicName = data["clinic"] ?? "";

    operatorName = data["operator"] ?? "";

    dentistName = data["dentist"] ?? "";

    autoclaveModel =

        selectedAutoclave?["model"] ?? "";

    //----------------------------------------------------
    // próximo ciclo
    //----------------------------------------------------

    final lastBleCycle =

        widget.lastCycle?.cycleNumber ?? 0;

    nextCycle =

        counter.getNextCycle(lastBleCycle);

    sessionLoaded = true;

    print("================================");

    print("SESSION LABEL");

    print(clinicName);

    print(operatorName);

    print(dentistName);

    print(autoclaveModel);

    print(nextCycle);

    print("================================");

  }

  catch(e){

    print(e);

  }

}
    _startAnimation();
  }

  Future<void> _startAnimation() async {

_backgroundController.forward();

await Future.delayed(
  const Duration(milliseconds: 2500),
);

// começa escurecendo
_overlayController.forward();

await Future.delayed(
  const Duration(milliseconds: 1200),
);

// só agora aparece o conteúdo
_logoController.forward();

await Future.delayed(
  const Duration(milliseconds: 350),
);
_progressController.forward();

    Future.delayed(
      const Duration(milliseconds: 900),
      () => _activateStep(0),
    );

    Future.delayed(
      const Duration(milliseconds: 1800),
      () => _activateStep(1),
    );

    Future.delayed(
      const Duration(milliseconds: 2800),
      () => _activateStep(2),
    );

    Future.delayed(
      const Duration(milliseconds: 3800),
      () => _activateStep(3),
    );

    Future.delayed(
      const Duration(milliseconds: 4700),
      () => _activateStep(4),
    );

    Future.delayed(
      const Duration(milliseconds: 5600),
      () {

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(

            transitionDuration:
                const Duration(milliseconds: 1000),

            pageBuilder: (context, animation, secondaryAnimation) {

              return LabelPrintPage(
                lastCycle: widget.lastCycle,
              );

            },

           transitionsBuilder:(context, animation, secondaryAnimation, child) {

              return FadeTransition(

                opacity: animation,

                child: child,

              );

            },

          ),
        );

      },
    );

  }

  void _activateStep(int index) {

    if (!mounted) return;

    setState(() {

      _steps[index] = true;

    });

  }

  @override
  void dispose() {

    _backgroundController.dispose();

    _logoController.dispose();

    _progressController.dispose();

    _overlayController.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: AnimatedBuilder(

        animation: _progressController,

        builder: (context, child) {

          return Stack(

            fit: StackFit.expand,

            children: [

              //=====================================
              // IMAGEM DE FUNDO
              //=====================================
FadeTransition(
  opacity: _backgroundOpacity,
  child: Image.asset(
    "assets/images/label_splash.png",
    fit: BoxFit.cover,
  ),
),

              //=====================================
// OVERLAY ROXO
//=====================================


//=====================================
// ESCALA DE CINZA + ESCURECIMENTO
//=====================================

FadeTransition(
  opacity: _overlayOpacity,
  child: ColorFiltered(
    colorFilter: const ColorFilter.matrix(<double>[

      0.2126,0.7152,0.0722,0,0,
      0.2126,0.7152,0.0722,0,0,
      0.2126,0.7152,0.0722,0,0,
      0,0,0,1,0,

    ]),
    child: Container(
      color: Colors.black.withOpacity(.65),
    ),
  ),
),

FadeTransition(
  opacity: _overlayOpacity,
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [

          Colors.black.withOpacity(.20),

          Colors.black.withOpacity(.45),

          Colors.black.withOpacity(.65),

          const Color(0xff5E2B97).withOpacity(.45),

        ],
      ),
    ),
  ),
),

              //=====================================
              // TEXTO GIGANTE AO FUNDO
              //=====================================

              Align(

                alignment: Alignment.bottomCenter,

                child: Padding(

                  padding: const EdgeInsets.only(bottom: 70),

                  child: RotatedBox(

                    quarterTurns: 3,

                    child: Text(

                      "RASTREABILIDADE",

                      style: TextStyle(

                        fontSize: 74,

                        fontWeight: FontWeight.w900,

                        color: Colors.white.withOpacity(.08),

                        letterSpacing: 6,

                      ),

                    ),

                  ),

                ),

              ),

              SafeArea(

                child: Padding(

                  padding: const EdgeInsets.symmetric(

                    horizontal: 28,

                    vertical: 25,

                  ),

                  child: Column(

                    children: [

                      const Spacer(),

                      //=====================================
                      // LOGO
                      //=====================================

                      const SizedBox(height: 20),

                      FadeTransition(

                        opacity: _logoOpacity,

                        child: const Text(

                          "STERIAPP",

                          style: TextStyle(
  fontSize: 40,
  fontWeight: FontWeight.w900,
  letterSpacing: 2,
  color: Colors.white,
  shadows: [

    Shadow(
      color: Colors.black54,
      blurRadius: 18,
      offset: Offset(0,3),
    ),

    Shadow(
      color: Color(0xff5E2B97),
      blurRadius: 25,
    ),

  ],
),

 ),

 ),
                  
                     const SizedBox(height: 20),

FadeTransition(

  opacity: _logoOpacity,

  child: Text(
  "CENTRAL INTELIGENTE",
  style: TextStyle(
    color: Colors.white70,
    fontSize: 15,
    letterSpacing: 2,
    fontWeight: FontWeight.w600,
  ),
),

),

const SizedBox(height: 2),

FadeTransition(

  opacity: _logoOpacity,

  child: Text(
  "DE RASTREABILIDADE",
  style: TextStyle(
    color: Colors.white,
    fontSize: 26,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
    shadows: [
      Shadow(
        color: Colors.black54,
        blurRadius: 15,
      )
    ],
  ),
),

),

const SizedBox(height: 16),

Container(

  width: 70,

  height: 3,

  decoration: BoxDecoration(

    color: const Color(0xff5E2B97),

    borderRadius: BorderRadius.circular(20),

  ),

),

const SizedBox(height: 18),

FadeTransition(

  opacity: _logoOpacity,

  child: Text(
  "Preparando sua experiência...",
  style: TextStyle(
    fontSize: 18,
    color: Colors.white,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w600,
    shadows: [
      Shadow(
        color: Colors.black54,
        blurRadius: 12,
      ),
    ],
  ),
),

),
  

                      const SizedBox(height: 40),

                      //=====================================
                      // CHECKLIST
                      //=====================================

                     
FadeTransition(

  opacity: _logoOpacity,

  child: Card(

    elevation: 10,

    shadowColor: Colors.black26,

    shape: RoundedRectangleBorder(

      borderRadius: BorderRadius.circular(20),

    ),

                        child: Padding(

                          padding: const EdgeInsets.all(24),

                          child: Column(

                            children: [

                              _CheckItem(

                                title: stepTitles[0],

                                checked: _steps[0],

                              ),

                              _CheckItem(

                                title: stepTitles[1],

                                checked: _steps[1],

                              ),

                              _CheckItem(

                                title: stepTitles[2],

                                checked: _steps[2],

                              ),

                              _CheckItem(

                                title: stepTitles[3],

                                checked: _steps[3],

                              ),

                              _CheckItem(

                                title: stepTitles[4],

                                checked: _steps[4],

                              ),

                              const SizedBox(height: 26),

                              ClipRRect(

                                borderRadius:

                                    BorderRadius.circular(30),

                                child: LinearProgressIndicator(

                                  minHeight: 10,

                                  value: _progress.value,

                                  backgroundColor:

                                      Colors.grey.shade300,

                                  valueColor:

                                      const AlwaysStoppedAnimation(

                                    Color(0xff5E2B97),

                                  ),

                                ),

                              ),

                              const SizedBox(height: 12),

                              Text(

                                "${(_progress.value * 100).round()}%",

                                style: const TextStyle(

                                  fontWeight: FontWeight.bold,

                                  color: Color(0xff5E2B97),

                                  fontSize: 18,

                                ),

                              ),

                              const SizedBox(height: 30),

                              const Text(
                                "Conforme RDC ANVISA nº 1002/2025",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 6),

                              const Text(
                                "Tecnologia que protege.",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff5E2B97),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ),

                      const Spacer(),

                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {

  final String title;
  final bool checked;

  const _CheckItem({
    required this.title,
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {

    return AnimatedOpacity(

      duration: const Duration(milliseconds: 400),

      opacity: checked ? 1 : .25,

      child: Padding(

        padding: const EdgeInsets.symmetric(vertical: 7),

        child: Row(

          children: [

            AnimatedContainer(

              duration: const Duration(milliseconds: 300),

              width: 24,
              height: 24,

              decoration: BoxDecoration(

                color: checked
                    ? const Color(0xff5E2B97)
                    : Colors.grey.shade300,

                shape: BoxShape.circle,

              ),

              child: Icon(

                checked
                    ? Icons.check
                    : Icons.circle_outlined,

                color: Colors.white,

                size: 16,

              ),

            ),

            const SizedBox(width: 14),

            Expanded(

              child: Text(

                title,

                style: TextStyle(

                  fontSize: 15,

                  fontWeight: checked
                      ? FontWeight.w600
                      : FontWeight.w400,

                  color: checked
                      ? Colors.black87
                      : Colors.black45,

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}

