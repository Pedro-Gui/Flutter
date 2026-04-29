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
      ...(hideCompleted ? { situacao: { $ne: "concluido" } } : {}),
      ...(search ? { title: { $regex: search, $options: 'i' } } : {}),
    }, {
      ...(pagina !=null ? { limit: 6, skip: (pagina-1)*6 } : {}),  
    });
  },
  "task"(taskId) {
    if (!this.userId) {
      return this.ready();
    }

    return TodoCollection.find({ _id: taskId });
  }
});
