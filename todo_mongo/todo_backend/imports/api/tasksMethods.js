import { Meteor } from "meteor/meteor";
import { TodoCollection } from "./TasksCollection";
import { Accounts } from 'meteor/accounts-base';

Meteor.methods({
  "tasks.insert"(doc) {
    if (!this.userId) {
      throw new Meteor.Error("Not-authorized.");
    }

    return TodoCollection.insertAsync({
      ...doc,
      userId: this.userId,
      createdAt: new Date(),
    });
  },
  "tasks.toggleSituacao"({ _id, situacao }) {
    return TodoCollection.updateAsync(_id, {
      $set: { situacao: situacao },
    });
  },
  "tasks.delete"({ _id }) {
    return TodoCollection.removeAsync(_id);
  },
  "tasks.edit"({ _id, doc }) {
    if (!this.userId) {
      throw new Meteor.Error("Not-authorized.");
    }

    return TodoCollection.updateAsync(
      _id,
      {
        $set: {
          ...doc,
          userId: this.userId,
          createdAt: new Date(),
        }
      });
  },
  /* async "CreateUser"(doc) {

    if (!doc.email || !doc.password || !doc.username) {
      return new Meteor.Error('campos-obrigatorios', 'Email, Nome de Usuário e Senha são obrigatórios.');
    }

    if (!(await Accounts.findUserByEmail(doc.email))) {
      if (!(await Accounts.findUserByUsername(doc.username))) {
        const userId = await Accounts.createUserAsync({
          username: doc.username,
          email: doc.email,
          password: doc.password,
          profile: {
            firstname: doc.firstname,
            lastname: doc.lastname,
            empresa: doc.empresa,
            sexo: doc.sexo,
            imagem: doc.imagem,
            dataNasc: new Date(doc.dataNasc),
            createdAt: new Date(),
          },
        });

        if (userId) {
          Accounts.sendVerificationEmail(userId, doc.email);
        }
        return ("Cadastro feito com sucesso");
      }

      return new Meteor.Error('usuario-existente', 'Cadastro já existente!');
    }
    return new Meteor.Error('email-existente', 'Cadastro já existente!');
  },
  async "EditUser"(doc) {

    if (!this.userId) {
      return new Meteor.Error('nao-autorizado', 'Você precisa estar logado para editar seu perfil.');
    }

    const user = await Meteor.users.findOneAsync(this.userId);
    if (!user) {
      return new Meteor.Error('usuario-nao-encontrado', 'Usuário não encontrado.');
    }

    if (doc.username && doc.username !== user.username) {
      if (await Accounts.findUserByUsername(doc.username)) {
        return new Meteor.Error('usuario-existente', 'Usuário já está em uso.');
      }
      await Accounts.setUsername(this.userId, doc.username);

    }

    const emailAtual = user.emails && user.emails[0] ? user.emails[0].address : null;
    if (doc.email && doc.email !== emailAtual) {
      if (await Accounts.findUserByEmail(doc.email)) {
        return new Meteor.Error('email-existente', 'Email já está em uso.');
      }
      if (emailAtual) {
        await Accounts.replaceEmailAsync(
          this.userId,
          emailAtual,
          doc.email,
          false,  // this param is optional 
        );
      } else {
        await Accounts.addEmailAsync(this.userId, doc.email, false);
      }
      Accounts.sendVerificationEmail(this.userId, doc.email);
    }

    if (doc.firstname && doc.lastname && doc.empresa && doc.sexo && doc.dataNasc && doc.imagem) {
      await Meteor.users.updateAsync(this.userId, {
        $set: {
        profile: {
          firstname: doc.firstname,
          lastname: doc.lastname,
          empresa: doc.empresa,
          sexo: doc.sexo,
          imagem: doc.imagem,
          dataNasc: new Date(doc.dataNasc),
          createdAt: new Date(),
        }
      }
      });
    }
    return ("Edição feita com sucesso");
  },

  async "getUserImagem"(targetUserId) {
    if (!this.userId) {
      return new Meteor.Error('nao-autorizado', 'Você precisa estar logado para ver imagens.');
    }

    const user = await Meteor.users.findOneAsync(targetUserId, {
      projection: { 'profile.imagem': 1 }
    });

    if (!user) {
      return new Meteor.Error('nao-encontrado', 'Usuário não encontrado.');
    }
    return {imagem: user?.profile?.imagem, reason: "Sucesso"};
  } */
});