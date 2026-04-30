import { Meteor } from "meteor/meteor";
import { TodoCollection } from "./TasksCollection";

Meteor.publish({
  "tasks"(hideCompleted = false, search = null, pagina = null, sortDescending = null) {
    const userId = this.userId;
    if (!userId) {
      return this.ready();
    }
    
    const sortDirection = sortDescending ? -1 : 1;

    return TodoCollection.find({
      $or: [
        { privado: false },
        { userId: userId }
      ],
      ...(hideCompleted ? { situacao: { $ne: "concluido" } } : {}),
      ...(search ? { title: { $regex: search, $options: 'i' } } : {}),
    }, {
      ...(sortDescending!=null ?{ sort: { createdAt: sortDirection }}:{}),
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
