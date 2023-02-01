
glm_step <- function(data.trn){
  #logistic挑选特征  根据AIC值  越小越好
  model.null = glm(label ~ 1, 
                   data=data.trn,
                   family = binomial(link="logit") )
  
  model.full = glm(label ~ .,
                   data=data.trn,
                   family = binomial(link="logit") )
  
  logit_model <- step(model.null,         
                      scope = list(upper=model.full),
                      direction="both",
                      trace = FALSE, # false时不输出step过程
                      #test="Chisq",
                      data=data.trn)
  
  return(logit_model)
}