import { Mongo } from "meteor/mongo";

export const TodoCollection = new Mongo.Collection('TODO');