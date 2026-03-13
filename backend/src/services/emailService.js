import nodemailer from "nodemailer";

export const sendErrorEmail = async (cycle) => {

  const transporter = nodemailer.createTransport({

    host: process.env.EMAIL_HOST,
    port: Number(process.env.EMAIL_PORT),
    secure: false,

    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    }

  });

  const message = `
ERRO DE AUTOCLAVE DETECTADO

Equipamento: ${cycle.model}
Serial: ${cycle.serialNumber}

Ciclo: ${cycle.cycleNumber}

Programa: ${cycle.program}

Código de erro: ${cycle.errorCode}

Link do laudo:
https://backend-nu-nine-29.vercel.app/laudo/${cycle.id}
`;

  await transporter.sendMail({

    from: `"SteriApp Monitor" <${process.env.EMAIL_USER}>`,
    to: "steriapp@wosonlatam.com.br",
    subject: `⚠️ Erro Autoclave ${cycle.serialNumber}`,
    text: message

  });

};