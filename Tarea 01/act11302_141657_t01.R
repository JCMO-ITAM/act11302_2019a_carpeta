### TAREA 1 ###
### MICHELLE GARCIA VAZQUEZ 143751 ###
### ANDREA GARDIDA ALVAREZ 141657 ####


### INSTALANDO PAQUETES Y DESCARGANDO DATOS NECESARIOS ###

if(!require("repmis")){install.packages("repmis")}
library("repmis")

data <- source_data("https://github.com/JCMO-ITAM/Data4Analysis/blob/master/d4a_allstateclaim_data.csv?raw=true")


### CALCULA Y GRAFICA LA FUNCION DE VEROSIMILITUD DE BINOMIAL, POISSON Y GEOMETRICA ###

### PONIENDO LOS DATOS EN UNA MATRIZ ####

data <- as.data.frame(data)
colnames(data)
data <- data[which(data$Calendar_Year==2005),]

### SACANDO LAS MEDIDAS DE LA MATRIZ DATA ###

J <- nrow(data)
n0 <- nrow(as.matrix(which(data$Claim_Amount==0)))
J;n0

### INTENTO CON EXPONENCIAL ###

theta0 <- seq(0, 10000,1 )
lik_theta0 <- dexp(theta0, 100 , rate=1, log = FALSE )

plot(theta0, lik_theta0, xlim=c(0,1), ylim=c(0, 1.25 * max(lik_theta0,1.6)), 
     type = "l", ylab= "Verosimilitud", lty = 3,
     xlab= "theta_0", las=1, main="",lwd=2,
     cex.lab=1.5, cex.main=1.5, col = "darkorange", axes=FALSE)
axis(1, at = seq(0,1,.2)) #adds custom x axis
axis(2, las=1) # custom y axis


quantile1 <- list(p=0.5, x=0.85)    # Complemento A
quantile2 <- list(p=0.99999,x=0.95) # Complemento B
quantile3 <- list(p=0.00001,x=0.60) # Complemento C

beta.elicitacion <- function(quantile1,quantile2,quantile3){
  quantile1_p <- quantile1[[1]]; quantile1_q <- quantile1[[2]]
  quantile2_p <- quantile2[[1]]; quantile2_q <- quantile2[[2]]
  quantile3_p <- quantile3[[1]]; quantile3_q <- quantile3[[2]]
  
  priorA <- beta.select(quantile1,quantile2)
  priorA_a <- priorA[1]; priorA_b <- priorA[2]
  
  priorB <- beta.select(quantile1,quantile3)
  priorB_a <- priorB[1]; priorB_b <- priorB[2]
  
  diff_a <- abs(priorA_a - priorB_a); diff_b <- abs(priorB_b - priorB_b)
  step_a <- diff_a / 100; step_b <- diff_b / 100
  if (priorA_a < priorB_a) { start_a <- priorA_a; end_a <- priorB_a }
  else                     { start_a <- priorB_a; end_a <- priorA_a }
  if (priorA_b < priorB_b) { start_b <- priorA_b; end_b <- priorB_b }
  else                     { start_b <- priorB_b; end_b <- priorA_b }
  steps_a <- seq(from=start_a, to=end_a, length.out=1000)
  steps_b <- seq(from=start_b, to=end_b, length.out=1000)
  max_error <- 10000000000000000000
  best_a <- 0; best_b <- 0
  for (a in steps_a)
  {
    for (b in steps_b)
    {
      priorC_q1 <- qbeta(c(quantile1_p), a, b)
      priorC_q2 <- qbeta(c(quantile2_p), a, b)
      priorC_q3 <- qbeta(c(quantile3_p), a, b)
      priorC_error <- abs(priorC_q1-quantile1_q) +
        abs(priorC_q2-quantile2_q) +
        abs(priorC_q3-quantile3_q)
      if (priorC_error < max_error)
      {
        max_error <- priorC_error; best_a <- a; best_b <- b
      }
    }
  }
  print(paste("Elicitacion para a=",best_a,"b=",best_b))
}


if(!require("LearnBayes")){install.packages("LearnBayes")}
library("LearnBayes")

beta.elicitacion(quantile1,quantile2,quantile3)

curve(dbeta(x,52.22,9.52105105105105))

consolidacion.exponencial <- function(successes, total, a, b, print=TRUE,summary=TRUE){
  likelihood_a = successes + 1; likelihood_b = total - successes + 1
  posterior_a = a + successes;  posterior_b = b + total - successes
  theta = seq(0.005, 0.995, length = 500)
  prior = dbeta(theta, a, b)
  likelihood = dbeta(theta, likelihood_a, likelihood_b)
  posterior  = dbeta(theta, posterior_a, posterior_b)
  m = max(c(prior, likelihood, posterior))
  if(print==TRUE){
    plot(theta, posterior, type = "l", ylab = "Density", lty = 2, lwd = 3,
         main = paste("beta(", a, ",", b, ") prior, B(", total, ",", successes, ") data,",
                      "beta(", posterior_a, ",", posterior_b, ") posterior"), ylim = c(0, m), col = "red")
    lines(theta, likelihood, lty = 1, lwd = 3, col = "blue")
    lines(theta, prior, lty = 3, lwd = 3, col = "green")
    legend(x=0.8,y=m, c("Prior", "Likelihood", "Posterior"), lty = c(3, 1, 2),
           lwd = c(3, 3, 3), col = c("green", "blue", "red"))
  }
  if(summary==TRUE){
    calcBetaMode <- function(aa, bb) { BetaMode <- (aa - 1)/(aa + bb - 2); return(BetaMode); }
    calcBetaMean <- function(aa, bb) { BetaMean <- (aa)/(aa + bb); return(BetaMean); }
    calcBetaSd   <- function(aa, bb) { BetaSd <- sqrt((aa * bb)/(((aa + bb)^2) * (aa + bb + 1))); return(BetaSd); }
    prior_mode      <- calcBetaMode(a, b)
    likelihood_mode <- calcBetaMode(likelihood_a, likelihood_b)
    posterior_mode  <- calcBetaMode(posterior_a, posterior_b)
    prior_mean      <- calcBetaMean(a, b)
    likelihood_mean <- calcBetaMean(likelihood_a, likelihood_b)
    posterior_mean  <- calcBetaMean(posterior_a, posterior_b)
    prior_sd        <- calcBetaSd(a, b)
    likelihood_sd   <- calcBetaSd(likelihood_a, likelihood_b)
    posterior_sd    <- calcBetaSd(posterior_a, posterior_b)
    print(paste("Modas=",prior_mode," | ",likelihood_mode," | ",posterior_mode))
    print(paste("Medias=",prior_mean," | ",likelihood_mean," | ",posterior_mean))
    print(paste("sd s=",prior_sd," | ",likelihood_sd," | ",posterior_sd))
  }
}

consolidacion.exponencial(n0, J, 52.22, 9.52,print=TRUE,summary=FALSE)

consolidacion.exponencial(n0, J, 52.22, 9.52,print=FALSE,summary=TRUE)

### NUESTROS RESULTADOS ARROJAN LO SIGUIENTE: ###

###"Modas= 0.857381988617342  |  0.990907851483799  |  0.990883688390031" ###
###"Medias= 0.845804988662132  |  0.990904876888632  |  0.990880714479536"###
###"sd s= 0.0455929848904483  |  0.000165241284816415  |  0.000165443643283756" ###

### DE ESTA GR�FICA PODEMOS CONCLUIR QUE LA FUNCI�N EXPONENCIAL ES LA �NICA QUE CORRE ###
### EXITOSAMENTE CON LOS VALORES QUE DECIDIMOS, LA FUNCI�N LIKELIHOOD ES LA �NICA ###
### QUE CUANDO N ES GRANDE ESTA TIENDE A LA FUNCI�N EXPONENCIAL TE�RICA. ###


### INTENTO CON POISSON ###

theta0 <- seq(0, 10000,1 )
lik_theta0 <- dpois(theta0, 100 , rate=1, log = FALSE )

plot(theta0, lik_theta0, xlim=c(0,1), ylim=c(0, 1.25 * max(lik_theta0,1.6)), 
     type = "l", ylab= "Verosimilitud", lty = 3,
     xlab= "theta_0", las=1, main="",lwd=2,
     cex.lab=1.5, cex.main=1.5, col = "darkorange", axes=FALSE)
axis(1, at = seq(0,1,.2)) #adds custom x axis
axis(2, las=1) # custom y axis


quantile1 <- list(p=0.5, x=0.85)    # Complemento A
quantile2 <- list(p=0.99999,x=0.95) # Complemento B
quantile3 <- list(p=0.00001,x=0.60) # Complemento C

beta.elicitacion <- function(quantile1,quantile2,quantile3){
  quantile1_p <- quantile1[[1]]; quantile1_q <- quantile1[[2]]
  quantile2_p <- quantile2[[1]]; quantile2_q <- quantile2[[2]]
  quantile3_p <- quantile3[[1]]; quantile3_q <- quantile3[[2]]
  
  priorA <- beta.select(quantile1,quantile2)
  priorA_a <- priorA[1]; priorA_b <- priorA[2]
  
  priorB <- beta.select(quantile1,quantile3)
  priorB_a <- priorB[1]; priorB_b <- priorB[2]
  
  diff_a <- abs(priorA_a - priorB_a); diff_b <- abs(priorB_b - priorB_b)
  step_a <- diff_a / 100; step_b <- diff_b / 100
  if (priorA_a < priorB_a) { start_a <- priorA_a; end_a <- priorB_a }
  else                     { start_a <- priorB_a; end_a <- priorA_a }
  if (priorA_b < priorB_b) { start_b <- priorA_b; end_b <- priorB_b }
  else                     { start_b <- priorB_b; end_b <- priorA_b }
  steps_a <- seq(from=start_a, to=end_a, length.out=1000)
  steps_b <- seq(from=start_b, to=end_b, length.out=1000)
  max_error <- 10000000000000000000
  best_a <- 0; best_b <- 0
  for (a in steps_a)
  {
    for (b in steps_b)
    {
      priorC_q1 <- qbeta(c(quantile1_p), a, b)
      priorC_q2 <- qbeta(c(quantile2_p), a, b)
      priorC_q3 <- qbeta(c(quantile3_p), a, b)
      priorC_error <- abs(priorC_q1-quantile1_q) +
        abs(priorC_q2-quantile2_q) +
        abs(priorC_q3-quantile3_q)
      if (priorC_error < max_error)
      {
        max_error <- priorC_error; best_a <- a; best_b <- b
      }
    }
  }
  print(paste("Elicitacion para a=",best_a,"b=",best_b))
}


if(!require("LearnBayes")){install.packages("LearnBayes")}
library("LearnBayes")

beta.elicitacion(quantile1,quantile2,quantile3)

curve(dbeta(x,52.22,9.52105105105105))

consolidacion.poisson <- function(successes, total, a, b, print=TRUE,summary=TRUE){
  likelihood_a = successes + 1; likelihood_b = total - successes + 1
  posterior_a = a + successes;  posterior_b = b + total - successes
  theta = seq(0.005, 0.995, length = 500)
  prior = dbeta(theta, a, b)
  likelihood = dbeta(theta, likelihood_a, likelihood_b)
  posterior  = dbeta(theta, posterior_a, posterior_b)
  m = max(c(prior, likelihood, posterior))
  if(print==TRUE){
    plot(theta, posterior, type = "l", ylab = "Density", lty = 2, lwd = 3,
         main = paste("beta(", a, ",", b, ") prior, B(", total, ",", successes, ") data,",
                      "beta(", posterior_a, ",", posterior_b, ") posterior"), ylim = c(0, m), col = "red")
    lines(theta, likelihood, lty = 1, lwd = 3, col = "blue")
    lines(theta, prior, lty = 3, lwd = 3, col = "green")
    legend(x=0.8,y=m, c("Prior", "Likelihood", "Posterior"), lty = c(3, 1, 2),
           lwd = c(3, 3, 3), col = c("green", "blue", "red"))
  }
  if(summary==TRUE){
    calcBetaMode <- function(aa, bb) { BetaMode <- (aa - 1)/(aa + bb - 2); return(BetaMode); }
    calcBetaMean <- function(aa, bb) { BetaMean <- (aa)/(aa + bb); return(BetaMean); }
    calcBetaSd   <- function(aa, bb) { BetaSd <- sqrt((aa * bb)/(((aa + bb)^2) * (aa + bb + 1))); return(BetaSd); }
    prior_mode      <- calcBetaMode(a, b)
    likelihood_mode <- calcBetaMode(likelihood_a, likelihood_b)
    posterior_mode  <- calcBetaMode(posterior_a, posterior_b)
    prior_mean      <- calcBetaMean(a, b)
    likelihood_mean <- calcBetaMean(likelihood_a, likelihood_b)
    posterior_mean  <- calcBetaMean(posterior_a, posterior_b)
    prior_sd        <- calcBetaSd(a, b)
    likelihood_sd   <- calcBetaSd(likelihood_a, likelihood_b)
    posterior_sd    <- calcBetaSd(posterior_a, posterior_b)
    print(paste("Modas=",prior_mode," | ",likelihood_mode," | ",posterior_mode))
    print(paste("Medias=",prior_mean," | ",likelihood_mean," | ",posterior_mean))
    print(paste("sd s=",prior_sd," | ",likelihood_sd," | ",posterior_sd))
  }
}

consolidacion.poisson(n0, J, 52.22, 9.52,print=TRUE,summary=FALSE)

consolidacion.poisson(n0, J, 52.22, 9.52,print=FALSE,summary=TRUE)

### NUESTROS RESULTADOS ARROJAN LO SIGUIENTE: ###

### "Modas= 0.857381988617342  |  0.990907851483799  |  0.990883688390031"###
### "Medias= 0.845804988662132  |  0.990904876888632  |  0.990880714479536###
### "sd s= 0.0455929848904483  |  0.000165241284816415  |  0.000165443643283756"###

### INTENTO CON BINOMIAL ###

theta0 <- seq(0, 10000,1 )
lik_theta0 <- dbinom(theta0, 100 , 0.5, log = FALSE )

plot(theta0, lik_theta0, xlim=c(0,1), ylim=c(0, 1.25 * max(lik_theta0,1.6)), 
     type = "l", ylab= "Verosimilitud", lty = 3,
     xlab= "theta_0", las=1, main="",lwd=2,
     cex.lab=1.5, cex.main=1.5, col = "darkorange", axes=FALSE)
axis(1, at = seq(0,1,.2)) #adds custom x axis
axis(2, las=1) # custom y axis

### DEFINIMOS LOS CUANTILES PARA FACILITAR FUTURA GRAFICACION ###

quantile1 <- list(p=0.5, x=0.85)    
quantile2 <- list(p=0.99999,x=0.95) 
quantile3 <- list(p=0.00001,x=0.60) 


### AQUI NOS ENCONTRAMOS CON LA INFORMACION DE EXPERTOS ###

beta.elicitacion <- function(quantile1,quantile2,quantile3){
  quantile1_p <- quantile1[[1]]; quantile1_q <- quantile1[[2]]
  quantile2_p <- quantile2[[1]]; quantile2_q <- quantile2[[2]]
  quantile3_p <- quantile3[[1]]; quantile3_q <- quantile3[[2]]
  
  priorA <- beta.select(quantile1,quantile2)
  priorA_a <- priorA[1]; priorA_b <- priorA[2]
  
  priorB <- beta.select(quantile1,quantile3)
  priorB_a <- priorB[1]; priorB_b <- priorB[2]
  
  diff_a <- abs(priorA_a - priorB_a); diff_b <- abs(priorB_b - priorB_b)
  step_a <- diff_a / 100; step_b <- diff_b / 100
  if (priorA_a < priorB_a) { start_a <- priorA_a; end_a <- priorB_a }
  else                     { start_a <- priorB_a; end_a <- priorA_a }
  if (priorA_b < priorB_b) { start_b <- priorA_b; end_b <- priorB_b }
  else                     { start_b <- priorB_b; end_b <- priorA_b }
  steps_a <- seq(from=start_a, to=end_a, length.out=1000)
  steps_b <- seq(from=start_b, to=end_b, length.out=1000)
  max_error <- 10000000000000000000
  best_a <- 0; best_b <- 0
  for (a in steps_a)
  {
    for (b in steps_b)
    {
      priorC_q1 <- qbeta(c(quantile1_p), a, b)
      priorC_q2 <- qbeta(c(quantile2_p), a, b)
      priorC_q3 <- qbeta(c(quantile3_p), a, b)
      priorC_error <- abs(priorC_q1-quantile1_q) +
        abs(priorC_q2-quantile2_q) +
        abs(priorC_q3-quantile3_q)
      if (priorC_error < max_error)
      {
        max_error <- priorC_error; best_a <- a; best_b <- b
      }
    }
  }
  print(paste("Elicitacion para a=",best_a,"b=",best_b))
}


if(!require("LearnBayes")){install.packages("LearnBayes")}
library("LearnBayes")

beta.elicitacion(quantile1,quantile2,quantile3)

curve(dbinom(x, 1000, .05, log=FALSE))

consolidacion.binomial <- function(successes, total, a, b, print=TRUE,summary=TRUE){
  likelihood_a = successes + 1; likelihood_b = total - successes + 1
  posterior_a = a + successes;  posterior_b = b + total - successes
  theta = seq(0.005, 0.995, length = 500)
  prior = dbeta(theta, a, b)
  likelihood = dbinom(theta, 1000, .05, log=FALSE)
  posterior  = dbeta(theta, posterior_a, posterior_b)
  m = max(c(prior, likelihood, posterior))
  if(print==TRUE){
    plot(theta, posterior, type = "l", ylab = "Density", lty = 2, lwd = 3,
         main = paste("beta(", a, ",", b, ") prior, B(", total, ",", successes, ") data,",
                      "beta(", posterior_a, ",", posterior_b, ") posterior"), ylim = c(0, m), col = "red")
    lines(theta, likelihood, lty = 1, lwd = 3, col = "blue")
    lines(theta, prior, lty = 3, lwd = 3, col = "green")
    legend(x=0.8,y=m, c("Prior", "Likelihood", "Posterior"), lty = c(3, 1, 2),
           lwd = c(3, 3, 3), col = c("green", "blue", "red"))
  }
  if(summary==TRUE){
    calcBetaMode <- function(aa, bb) { BetaMode <- (aa - 1)/(aa + bb - 2); return(BetaMode); }
    calcBetaMean <- function(aa, bb) { BetaMean <- (aa)/(aa + bb); return(BetaMean); }
    calcBetaSd   <- function(aa, bb) { BetaSd <- sqrt((aa * bb)/(((aa + bb)^2) * (aa + bb + 1))); return(BetaSd); }
    prior_mode      <- calcBetaMode(a, b)
    likelihood_mode <- calcBetaMode(likelihood_a, likelihood_b)
    posterior_mode  <- calcBetaMode(posterior_a, posterior_b)
    prior_mean      <- calcBetaMean(a, b)
    likelihood_mean <- calcBetaMean(likelihood_a, likelihood_b)
    posterior_mean  <- calcBetaMean(posterior_a, posterior_b)
    prior_sd        <- calcBetaSd(a, b)
    likelihood_sd   <- calcBetaSd(likelihood_a, likelihood_b)
    posterior_sd    <- calcBetaSd(posterior_a, posterior_b)
    print(paste("Modas=",prior_mode," | ",likelihood_mode," | ",posterior_mode))
    print(paste("Medias=",prior_mean," | ",likelihood_mean," | ",posterior_mean))
    print(paste("sd s=",prior_sd," | ",likelihood_sd," | ",posterior_sd))
  }
}

consolidacion.binomial(n0, J, 52, 9,print=TRUE,summary=FALSE)

consolidacion.binomial(n0, J, 52, 9,print=FALSE,summary=TRUE)

### NUESTROS RESULTADOS ARROJARON LO SIGUIENTE: ###

### "Modas= 0.864406779661017  |  0.990907851483799  |  0.990885243120767" ###
### "Medias= 0.852459016393443  |  0.990904876888632  |  0.990882269194186" ###
### "sd s= 0.0450398822842255  |  0.000165241284816415  |  0.000165429854924201" ###



