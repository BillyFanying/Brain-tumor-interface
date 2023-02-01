

z.score <- function(feat.trn, feat.test){
  #对特征标准化，要求feat.trn 都是特征，不要含有label等其它东西
  train.mean <- apply(feat.trn,2,mean) # 标准化特征值
  train.sd <- apply(feat.trn,2,sd)
  # feat.trn <- scale(feat.trn, center = train.mean, scale = train.sd)
  feat.trn <- scale(feat.trn, center = TRUE, scale = TRUE)
  feat.test <- scale(feat.test, center = train.mean,scale = train.sd)
  
  return(list(feat.trn,feat.test))
}

