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

    html: `<h2>Recuperação de Senha</h2>

<p>Olá ${nickname}</p>

<p>Recebemos uma solicitação para redefinir sua senha.</p>

<p>
<a href="${link}">
Clique aqui para redefinir sua senha
</a>
</p>

<p>Este link expira em 1 hora.</p>

<p>
Equipe SteriApp<br>
ODONTOTECSANTOS<br>
WosonLatam Técnologia e Biossegurança!
</p>
`

  });

};