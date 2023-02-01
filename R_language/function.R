if(TRUE){
  rm(list=ls())
  library(MASS)
  library(openxlsx)
  library(plyr)
  library(glmnet)
  library(stats)
  library(pROC)
  library(caret)
  library(doBy)
  library(mRMRe)
  
  
  # install.packages('doBy')
  
  
  source('H:\\XiongZhui_Results\\AllResult\\T1\\data_nomal_fun.R')
  source('H:\\XiongZhui_Results\\AllResult\\T1\\u_test_fun.R') 
  source('H:\\XiongZhui_Results\\AllResult\\T1\\sample_fun.R')
  source('H:\\XiongZhui_Results\\AllResult\\T1\\get_lasso_result_fun.R')
  source('H:\\XiongZhui_Results\\AllResult\\T1\\glm_step_fun.R') 
  source('H:\\XiongZhui_Results\\AllResult\\T1\\roc_and_plot_fun.R')
  source('H:\\XiongZhui_Results\\AllResult\\T1\\youden_index_fun.R')
  source('H:\\XiongZhui_Results\\AllResult\\T1\\mrmr_fun.R')
  
  modify.df <- function(df = df.result, num= 1,auc.trn= auc.trn, auc.test = auc.test ){
    num = num 
    
    train.index = auc.trn$sensitivities + auc.trn$specificities
    train.max.index = which( train.index == max(train.index) )[1]
    df[num,'trn.auc'] = round(auc.trn$auc, digits = 3)
    df[num,'trn.spe'] = round(auc.trn$specificities[train.max.index], digits = 3)
    df[num,'trn.sen'] = round(auc.trn$sensitivities[train.max.index], digits = 3)
    
    
    test.index = auc.test$sensitivities + auc.test$specificities
    test.max.index = which(test.index == max(test.index))[1]
    df[num,'test.auc']= round(auc.test$auc, digits = 3)
    df[num,'test.spe']= round(auc.test$specificities[test.max.index], digits = 3)
    df[num,'test.sen']= round(auc.test$sensitivities[test.max.index], digits = 3)
    
    return(df)
  }
}

range.list = c(1:4000) # 
df.result = data.frame(
  num = range.list,
  trn.auc = range.list,
  trn.spe = range.list,
  trn.sen = range.list,
  
  test.auc = range.list,
  test.spe = range.list,
  test.sen = range.list
  
)


for (seednum in range.list){

#seednum=449

#set.seed(seednum)

  if(TRUE){
    data <- read.xlsx("H:\\T790M_Result\\Features\\features_T2FS_790.xlsx") 
    
    
    
    stratified.result = stratified_sampling(data = data, seednum = seednum, proportion = 2/3)
    data.trn = stratified.result[[1]]
    data.test =stratified.result[[2]]
  }   
    write.xlsx(data.trn,'H:/T790M_Result/Result/R/T1_train212.xlsx')
    write.xlsx(data.test,'H:/T790M_Result/Result/R/T1_test212.xlsx')
    
    
    
    
#data.trn <-read.xlsx("H:\\T790M_Result\\Result\\data\\T1_train212_lasso.xlsx")
  
#data.test <-read.xlsx("H:\\T790M_Result\\Result\\data\\T1_test212_lasso.xlsx")
    
    
    
 }
  
  
  if(TRUE){

    u.test.result <- u_test(data.trn = data.trn, data.test = data.test, p.val = 0.05) # 
    data.trn <- u.test.result[[1]] 
    data.test <- u.test.result[[2]]
  }
  
  
  if(TRUE){

    label.trn <- data.trn$label
    feat.trn <- data.trn[,2:length(data.trn)]#
    # feat.trn <- data.matrix(feat.trn)
    label.test <- data.test$label
    feat.test <- data.test[,2:length(data.test)]#
    # feat.test <- data.matrix(feat.test)
    
    z.score.result = z.score(feat.trn = feat.trn, feat.test = feat.test)
    feat.trn <- z.score.result[[1]]
    feat.test <- z.score.result[[2]]
    data.trn = data.frame(label = label.trn, feat.trn)
    data.test = data.frame(label = label.test,feat.test)
    
    
    write.xlsx(data.trn,'H:/T790M_Result/Result/R/T1_train.xlsx')
    write.xlsx(data.test,'H:/T790M_Result/Result/R/T1_test.xlsx')
    
  }
  
  
  if(TRUE){
    # LASSO 
    if(TRUE){
      label.trn <- data.trn$label
      feat.trn <- data.trn[,2:length(data.trn)]
      feat.trn <- data.matrix(feat.trn)
      label.test <- data.test$label
      feat.test <- data.test[,2:length(data.test)]
      feat.test <- data.matrix(feat.test)
    }
    
    set.seed(7)
    cvmodel = cv.glmnet(feat.trn, label.trn, family = "binomial", 
                        type.measure = "auc",nfolds= 5,alpha=1)
    plot(cvmodel)
    
    lambda = "lambda.1se" 
    lasso.result <- get_lasso_result(cvmodel,label.trn, feat.trn,
                                     label.test,feat.test,lamda = lambda) # 选择 s="lambda.min" 或者 s="lambda.1se"
    data.trn = lasso.result[[1]] 
    data.test = lasso.result[[2]]
    
    write.xlsx(data.trn,'H:/T790M_Result/Result/R/T1_train212_lasso.xlsx')
    write.xlsx(data.test,'H:/T790M_Result/Result/R/T1_test212_lasso.xlsx')
    
    
  }
  
  if(TRUE){
    # glm step with AIC
    logit_model <- glm_step(data.trn = data.trn)
    summary(logit_model)
    
    
    score.trn=predict.glm(logit_model,newdata = data.trn, type="link")
    score.test=predict.glm(logit_model,newdata = data.test, type="link")
    
    
    write.xlsx(score.trn,'H:/T790M_Result/Result/R/trainlink.xlsx')
    write.xlsx(score.test,'H:/T790M_Result/Result/R/testlink.xlsx')
    
    
 
    auc.trn <-roc_and_plot(data.trn$label,score.trn,xlab.name = 'Train')
    auc.test <- roc_and_plot(data.test$label, score.test,xlab.name = 'Test')
    
    
    df.result= modify.df( df=df.result, num = seednum, auc.trn = auc.trn, auc.test = auc.test)
  }
  
  if( (seednum%%10) == 0){
   write.xlsx(df.result, 'H:/T790M_Result/Result/T1_4000_790.xlsx')
  }
}

write.xlsx(df.result, 'H:/T790M_Result/Result/T11_4000_790.xlsx')

