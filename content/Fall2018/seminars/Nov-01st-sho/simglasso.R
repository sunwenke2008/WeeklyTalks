library("glasso")
library("ggplot2")
library("igraph")
library("MASS")

## Input x: cov matrix, rho: penalty term
## Output: Graphical model
glasso.with.rho <- function(x, rho){
  glasso.result <- glasso(x, rho)
  adjacency <- abs(glasso.result$wi) > 1e-4
  diag(adjacency) <- 0
  adjacency.plot <- graph.adjacency(adjacency, mode = "undirected")
  plot(adjacency.plot)
  glasso.result
}


## Compute KL distance between two adjacency matrix
compKLadj <- function(m0, m1, m1i){
  trace.m1inv_m0 <- sum(diag(m1i %*% m0))
  d <- ncol(m0)
  KL <- log(1/2 * (log(det(m1)/det(m0)) + trace.m1inv_m0 - d))
  KL
}


## Generate a set of rho which give different graphical models
compGLASSO.without.rho <- function(x){
  rho.Max <- 2*max(x)
  rho.list <- seq(0.01, rho.Max, length=1001)
  KLlist <- rep(0, 1000)
  glasso.result <- glasso(x, 0.01)
  m0 <- glasso.result$wi
  for (i in 1:1000) {
    glasso.result <- glasso(x, rho.list[i+1])
    m1 <- glasso.result$wi
    m1i <- glasso.result$w
    KLlist[i] <- compKLadj(m0,m1,m1i)
    m0 <- m1
  }
  KL.data <- data.frame(rho = rho.list[1:(length(KLlist))], log.KL = KLlist)
  KL.plot <- ggplot(KL.data, aes(x = rho, y = log.KL)) + geom_line()
  KL.plot
}


# covariance matrix is known
# knowing (1,3), (2,4) are not connected

Prec <- matrix(0, ncol = 100, nrow = 100)
for(i in sample(1:99, 20)){
  j <- sample((i+1):100,1)
  Prec[i,j] <- runif(1)
  Prec[j,i] <- Prec[i,j]
}

diag(Prec) <- 2

C <- solve(Prec)
data <- mvrnorm(n = 200, mu = rnorm(100, 0, 1), C)

s <- cov(data)

compGLASSO.without.rho(s)

glasso.with.rho(s, 0.2)$wi

adjacency <- abs(glasso(s, 0.1)$wi) > 1e-4
diag(adjacency) <- F

which(adjacency)

PP<-Prec
AA <- matrix(0, ncol = 100, nrow = 100)
AA[which(PP != 0)] <- 1
diag(AA) <- 0

intersect(which(adjacency), which(AA != 0))

length(intersect(which(adjacency), which(AA != 0)))

