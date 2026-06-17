import nodemailer from "nodemailer";

export const sendWelcomeEmail = async (user) => {

  const transporter = nodemailer.createTransport({

    host: process.env.EMAIL_HOST,
    port: Number(process.env.EMAIL_PORT),
    secure: false,

    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },

  });

  const message = `
Bem-vindo ao SteriApp

Dados do Cadastro

Clínica: ${user.clinic}

Dentista: ${user.dentist}

Operador: ${user.operator}

Login: ${user.nickname}

E-mail: ${user.email}

Seu cadastro foi realizado com sucesso.

Guarde estes dados em local seguro.

Equipe SteriApp
OdontoTec Santos
WosonLatam Técnologia e Biossegurança!
`;

  await transporter.sendMail({

    from: `"SteriApp" <${process.env.EMAIL_USER}>`,
    to: user.email,
    subject: "Cadastro realizado com sucesso",
    text: message,

  });

};