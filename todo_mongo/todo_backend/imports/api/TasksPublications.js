import { Meteor } from "meteor/meteor";
import { TodoCollection } from "./TasksCollection";

Meteor.publish({
  "tasks"(hideCompleted = false, search = null, pagina = null) {
    const userId = this.userId;
    if (!userId) {
      return this.ready();
    }

    return TodoCollection.find({
      $or: [
        { privado: false },
        { userId: userId }
      ],
      ...(hideCompleted ? { situacao: { $ne: "Concluída" } } : {}),
      ...(search ? { name: { $regex: search, $options: 'i' } } : {}),
    }, {
      ...(pagina !=null ? { limit: 4, skip: (pagina-1)*4 } : {}),  
    });
  },
  "task"(taskId) {
    if (!this.userId) {
      return this.ready();
    }

    return TodoCollection.find({ _id: taskId });
  }
});

Meteor.publish('listaTodos', function () {
    if (!this.userId) {
      return this.ready(); 
    }
    return TodoCollection.find({});
  });
