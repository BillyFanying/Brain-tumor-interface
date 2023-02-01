
get_lasso_result<- function(cvmodel,label.trn, feat.trn,label.test,feat.test, lamda = 'lambda.min'){
  if(lamda == 'lambda.min'){
    coefficients<-coef(cvmodel,s=cvmodel$lambda.min) # 通过指定 λ 值，抓取出某一个模型的系数
  }else if(lamda == 'lambda.1se'){
    coefficients<-coef(cvmodel,s=cvmodel$lambda.1se) # 通过指定 λ 值，抓取出某一个模型的系数
  }
  
  #coefficients<-coef(cvmodel,s=cvmodel$lambda.min)
  Active.Index<-which(coefficients!=0) #系数不为0的特征索引，第一个是截距常数
  Active.coefficients<-coefficients[Active.Index]   #系数不为0的特征系数值
 
  # 根据列数保存剩余特征，务必确保第一列是label，第二列就是特征
  data.trn = data.frame(label = label.trn, feat.trn)
  data.test = data.frame(label = label.test,feat.test)
  lasso.trn = data.trn[(Active.Index)] #拿出来第一列label，第二列特征
  lasso.test = data.test[(Active.Index)]
  
  return(list(lasso.trn,lasso.test))
}