import { Meteor } from 'meteor/meteor';
import { Mongo } from 'meteor/mongo';
import { Accounts } from 'meteor/accounts-base';
import "../imports/api/tasksMethods";
import "../imports/api/TasksPublications";
import { TodoCollection } from "../imports/api/TasksCollection";

Meteor.startup(async () => {
  const USER_NAME = 'teste';
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
      { title: 'Configurar servidor Meteor', 
        ownerId: idDoUsuarioDeTeste, 
        ownerUsername: USER_NAME, 
        situacao: 'emAndamento', 
        createdAt: new Date(), },

      { title: 'Conectar Flutter via DDP', 
        ownerId: idDoUsuarioDeTeste, 
        ownerUsername: USER_NAME, 
        situacao: 'concluido', 
        createdAt: new Date(), },

      { title: 'Fazer o primeiro CRUD funcionar no mobile', 
        ownerId: idDoUsuarioDeTeste, 
        ownerUsername: USER_NAME, 
        situacao: 'naoConcluido', 
        createdAt: new Date(), }
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

      await Meteor.users.updateAsync(userId, {
        $set: {
          'profile.name': googleData.name,
          'profile.picture': googleData.picture,
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