import nodemailer from "nodemailer";

export const sendResetPasswordEmail =
async (email, token, nickname) => {

  const transporter = nodemailer.createTransport({

    host: process.env.EMAIL_HOST,
    port: Number(process.env.EMAIL_PORT),
    secure: false,

    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    }

  });

  const link =
`steriapp://reset-password/${token}`;

  await transporter.sendMail({

    from: `"SteriApp" <${process.env.EMAIL_USER}>`,

    to: email,

    subject: "Recuperação de Senha",

    text: `
Olá ${nickname}

Recebemos uma solicitação para redefinir sua senha.

Acesse:

${link}

Este link expira em 1 hora.

Equipe SteriApp
ODONTOTECSANTOS
WosonLatam tecnologia e biossegurança!
`

  });

};