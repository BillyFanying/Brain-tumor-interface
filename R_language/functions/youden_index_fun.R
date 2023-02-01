
get_youden_index<- function(roc.model){
  
  auc.trn = roc.model
  train.index = auc.trn$sensitivities + auc.trn$specificities
  train.max.index = which( train.index == max(train.index) )
  auc.trn$specificities[train.max.index]
  auc.trn$sensitivities[train.max.index]
  
  return(list(auc.trn$specificities[train.max.index][1], #多个最佳工作点，返回第一个
              auc.trn$sensitivities[train.max.index][1]))
}