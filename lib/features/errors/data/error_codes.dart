import '../models/error_model.dart';

final List<ErrorModel> errorCodes = [

  const ErrorModel(
    code: "Er01",
    title: "Alta temperatura no gerador de vapor",
    description: "Temperatura elevada detectada no gerador de vapor da autoclave.",
  ),

  const ErrorModel(
    code: "Er02",
    title: "Alta temperatura no anel de aquecimento",
    description: "Temperatura excessiva no sistema de aquecimento.",
  ),

  const ErrorModel(
    code: "Er03",
    title: "Alta temperatura na câmara",
    description: "Temperatura da câmara acima do limite seguro.",
  ),

  const ErrorModel(
    code: "Er04",
    title: "Falha em manter temperatura e pressão",
    description: "Sistema não conseguiu manter temperatura e pressão constantes durante o ciclo.",
  ),

  const ErrorModel(
    code: "Er05",
    title: "Falha ao liberar pressão",
    description: "O sistema não conseguiu liberar a pressão interna da câmara.",
  ),

  const ErrorModel(
    code: "Er06",
    title: "Porta aberta durante o ciclo",
    description: "Sensor detectou abertura da porta durante o processo de esterilização.",
  ),

  const ErrorModel(
    code: "Er07",
    title: "Tempo de ciclo excedido",
    description: "O ciclo ultrapassou o tempo máximo permitido.",
  ),

  const ErrorModel(
    code: "Er08",
    title: "Alta pressão na câmara",
    description: "Pressão da câmara acima do limite seguro.",
  ),

  const ErrorModel(
    code: "Er09",
    title: "Sensores de temperatura divergentes",
    description: "Sensores de temperatura da câmara não coincidem (modelos com duplo sensor).",
  ),

  const ErrorModel(
    code: "Er10",
    title: "Temperatura e pressão inconsistentes",
    description: "Valores de temperatura e pressão não correspondem ao esperado.",
  ),

  const ErrorModel(
    code: "Er12",
    title: "Falha de vácuo",
    description: "Sistema de vácuo não conseguiu atingir o nível necessário.",
  ),

  const ErrorModel(
    code: "Er98",
    title: "Queda de energia",
    description: "Falha de energia detectada durante o ciclo.",
  ),

  const ErrorModel(
    code: "Er99",
    title: "Saída forçada",
    description: "Ciclo interrompido manualmente ou por emergência.",
  ),

];