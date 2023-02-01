

stratified_sampling <- function(data, seednum = 0, proportion = 0.67){
  # 要求data第一列是label，第二列起是特征列
  # proportion 是训练集比例
  data$ID = c(1:dim(data)[1])
  set.seed(seednum)
  data.trn = sampleBy(formula = ~ label, frac= proportion, data = data)
  train_sub = data.trn$ID
  data = subset(data, select = -ID)
  
  data.trn = data[train_sub,]
  data.test = data[-train_sub,]
  
  return(list(data.trn,data.test))
}

# size是各个层抽取样本的个数，第一个是label=0的个数，0.67*（label为0的人数），
# 第二个是label=1的个数，0.67*（label为1的人数），
# data: 抽样数据
# stratanames: 进行分层所依据的变量名称
# size: 各层中要抽出的观测样本数
# method: 选择4中抽样方法，分别为无放回、有放回、泊松、系统抽样，默认为srswor
# description: 选择是否输出含有各层基本信息的结果。
# description = T, 会给出共有多少层，每层中带抽样本总数及实际抽取样本数。
#  https://www.zhihu.com/question/26022513/answer/34757700
