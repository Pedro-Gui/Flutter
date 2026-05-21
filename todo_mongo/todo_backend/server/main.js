import { Meteor } from 'meteor/meteor';
import { Mongo } from 'meteor/mongo';
import { Accounts } from 'meteor/accounts-base';
import "../imports/api/tasksMethods";
import "../imports/api/TasksPublications";
import { TodoCollection } from "../imports/api/TasksCollection";
import { fetch } from 'meteor/fetch'; // Meteor 3.0+ já tem fetch nativo

// Função auxiliar para transformar URL em Base64
async function getBase64FromUrl(url) {
  if (!url) return null;
  try {
    const response = await fetch(url);
    const arrayBuffer = await response.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);
    return buffer.toString('base64');
  } catch (e) {
    console.error("Erro ao converter imagem do Google:", e);
    return null;
  }
}

Meteor.startup(async () => {
  const USER_NAME = 'UserTest';
  const USER_EMAIL = 'teste@teste.com';
  const USER_PASSWORD = '123';
  let idDoUsuarioDeTeste;
  const userExists = await Accounts.findUserByUsername(USER_NAME);


  if (!userExists) {
    await Accounts.createUserAsync({
      username: USER_NAME,
      email: USER_EMAIL,
      password: USER_PASSWORD,
    });
    console.log('Usuário de teste criado com sucesso!');
  } else {
    idDoUsuarioDeTeste = userExists._id;
  }

  const quantidade = await TodoCollection.find().countAsync();

  if (quantidade === 0) {
    console.log('Coleção TODO está vazia. Inserindo tarefas de exemplo...');

    const tarefasIniciais = [
      {
        title: 'Configurar servidor Meteor',
        userId: idDoUsuarioDeTeste,
        ownerUsername: USER_NAME,
        situacao: 'emAndamento',
        privado: false,
        createdAt: new Date(),
      },

      {
        title: 'Conectar Flutter via DDP',
        userId: idDoUsuarioDeTeste,
        ownerUsername: USER_NAME,
        situacao: 'concluido',
        privado: false,
        createdAt: new Date(),
      },

      {
        title: 'Fazer o primeiro CRUD funcionar no mobile',
        userId: idDoUsuarioDeTeste,
        ownerUsername: USER_NAME,
        situacao: 'naoConcluido',
        privado: true,
        createdAt: new Date(),
      }
    ];

    for (const tarefa of tarefasIniciais) {
      await TodoCollection.insertAsync(tarefa);
    }

    console.log('Tarefas de exemplo criadas com sucesso!');
  } else {
    console.log(`A coleção TODO já possui ${quantidade} tarefas.`);
  }

});


Accounts.registerLoginHandler('googleNative', async (loginRequest) => {

  if (!loginRequest.googleNative) {
    return undefined;
  }

  const { idToken } = loginRequest.googleNative;

  try {
    const response = await fetch(`https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`);
    const googleData = await response.json();

    if (googleData.error) {
      throw new Meteor.Error(403, 'Token do Google inválido ou expirado.');
    }

    const email = googleData.email;

    let user = await Meteor.users.findOneAsync({ 'emails.address': email });

    if (!user) {
      const userId = await Accounts.createUserAsync({
        email: email,
      });
      let safeUsername = googleData.name;
      let usernameExists = await Accounts.findUserByUsername(safeUsername);

      while (usernameExists) {
        const uniqueSuffix = Math.floor(1000 + Math.random() * 9000);
        safeUsername = `${googleData.name}_${uniqueSuffix}`;
        usernameExists = await Accounts.findUserByUsername(safeUsername);
      }
      const base64Imagem = await getBase64FromUrl(googleData.picture);

      await Meteor.users.updateAsync(userId, {
        $set: {
          'username': safeUsername,
          'profile.name': safeUsername,
          'profile.imagem': base64Imagem,
          'services.google': googleData
        }
      });

      user = await Meteor.users.findOneAsync(userId);
    }
    return { userId: user._id };

  } catch (error) {
    console.error("Erro na validação com o Google:", error);
    throw new Meteor.Error(500, 'Falha interna ao processar o login via Google.');
  }
});

// $env:MONGO_URL="mongodb://localhost:27017/TODO"
// meteor run