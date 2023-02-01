
roc_and_plot <- function(label,score, xlab.name='train'){
  auc.test <- roc(label, score)
  #auc.test$auc
  plot(auc.test, print.auc=TRUE, auc.polygon=TRUE,legacy.axes=TRUE, grid=c(0.1, 0.2),
       grid.col=c("green", "red"), max.auc.polygon=TRUE, xlab = xlab.name,
       auc.polygon.col="skyblue", print.thres=TRUE)
}
