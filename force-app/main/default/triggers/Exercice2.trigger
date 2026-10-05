trigger Exercice2 on Contact (before Insert, before Update, before Delete, after Insert, after update, after Delete, after UnDelete) {
new Exercice2TriggerHandler().run();
}