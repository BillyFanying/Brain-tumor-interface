
u_test <- function(data.trn, data.test, p.val = 0.05){
  # 要求data.trn 第一列是label，第二列起是特征；data.test一样
  wilcox = c()
  for (num in 1:length(data.trn)){
    test <- wilcox.test(data.trn[which(data.trn$label == 0),num], 
                        data.trn[which(data.trn$label == 1),num])
    wilcox[num] <- test$p.value
  }
  
  #保留U检验P值小于0.05的变量，包括第一列label，label的p值小于0.05
  data.trn <- data.trn[,which(wilcox< p.val)] 
  data.test <-data.test[,which(wilcox< p.val)]
  
  return(list(data.trn, data.test))
}

