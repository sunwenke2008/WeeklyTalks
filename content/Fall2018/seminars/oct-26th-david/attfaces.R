###########################################################
# Online Principal Component Analysis in High Dimension: 
# Which Algorithm to Choose?
# Hervé Cardot and David Degras 
###########################################################




###########
# Packages
###########

# Run this line if packages are not installed yet
# install.packages(c("jpeg","MASS","onlinePCA","pixmap"))

# Load packages
library(pixmap)
library(jpeg)
library(onlinePCA)
library(MASS)


#####################
# Download AT&T data
#####################

URL <- "http://www.cl.cam.ac.uk/Research/DTG/attarchive/pub/data/att_faces.zip" # dataset url
dir.create("tmp") # create new directory
setwd("tmp")
download.file(URL,"att_faces.zip")
unzip("att_faces.zip")


###################
# Read in the data
###################

# fnames <- list.files(recursive=T, full.names=T)
# fnames <- grep(".pgm",fnames,value=T)
fnames <- paste0("./s",rep(1:40,each=10),"/",rep(1:10,40),".pgm")
x <- sapply(fnames, function(img) suppressWarnings(read.pnm(img)@grey)) 
dimnames(x) <- NULL
xnorm2 <- colSums(x^2) # image energy (squared norm)	
n <- ncol(x) # number of images = 400
d <- nrow(x) # image dimension = 112*92


#############
# Parameters
#############

pca <- vector("list",4)
names(pca) <- c("batch","ipca","sga","cci")

# Number of PC
q <- 40


###############################
# Split the data into training
# and testing subsets
###############################

# Leave one image out for each subject for testing
test <- sample(10,40,T) + seq.int(0,390,10)
train <- (1:n)[-test]
# Randomize the order of training and testing data 
test <- sample(test) 
train <- sample(train)



##########################################################################



######################
# 1. DATA COMPRESSION
######################



############
# Batch PCA
############

pca[["batch"]] <- batchpca(x[,train],q)


#############
# Online PCA
#############

# Initialization
ti <- train[1]
init <- list(values = xnorm2[ti], 
			vectors = as.matrix(x[,ti]/sqrt(xnorm2[ti])))
pca[["ipca"]] <- pca[["cci"]] <- init # use 1 PC to initialize IPCA & CCIPCA
pca[["sga"]] <- batchpca(x[,train[1:q]],q) # use q PC to initialize SGA
cst <- 5e-4 # constant in learning rate gamma=cst/n for SGA
rm(ti,init)			

# Loop 
for (i in 2:length(train))
{
	ti <- train[i]
	pca[["ipca"]] <- incRpca(pca[["ipca"]]$values, pca[["ipca"]]$vectors, 
					x[,ti], i-1, q=min(i,q))
	if (i>q) {
	pca[["sga"]] <- sgapca(pca[["sga"]]$values, pca[["sga"]]$vectors, 
					x[,ti], cst/i, q) }
	pca[["cci"]] <- ccipca(pca[["cci"]]$values, pca[["cci"]]$vectors, 
					x[,ti], i-1, q, l=0)
}

# Fix the loss of orthogonality in CCIPCA 
pca[["cci"]]$vectors <- qr.Q(qr(pca[["cci"]]$vectors))

# # Align eigenfaces of online algorithms on corresponding eigenfaces of batch PCA 
for (i in 2:4)
{
check <- colSums(pca[[i]]$vectors*pca[["batch"]]$vectors) > 0
pca[[i]]$vectors[,!check] <- - pca[[i]]$vectors[,!check]
}



#######################
# Performance measures
#######################

# Squared norm of reconstructed images
xhatnorm2 <- sapply(pca, function(pc) colSums(crossprod(pc$vectors,x)^2))

# Squared norm of reconstruction errors
E <- xnorm2 - xhatnorm2
colnames(E) <- names(pca)
summary(E)

# Relative error on training data 
sqrt(colSums(E[train,]) / sum(xnorm2[train])) # Euclidean/Frobenius norm
colSums(E[train,]) / sum(xnorm2[train]) # energy: squared norm
colMeans(E[train,] / xnorm2[train]) # average relative error (energy) as in SKL paper

# Relative error on test data
sqrt(colSums(E[test,]) / sum(xnorm2[test]))
colSums(E[test,]) / sum(xnorm2[test]) 
colMeans(E[test,] / xnorm2[test])


########
# Plots
########

# Color palette 
col <- grey(seq(0,1,len=30))

# Destination folder for images 
dir.create("results")
DEST <- "results"

# Top 5 eigenfaces of each method
par(mfrow=c(4,5))
for (i in 1:4)
for (j in 1:5)
{
	img <- pca[[i]]$vectors[,j]
	dim(img) <- c(112,92)
	img <- (img - min(img))/(max(img)-min(img))
	NAME <- paste0(DEST,"/eigface_",names(pca)[i],"_",j,".jpg")
	writeJPEG(img,NAME,quality=1) # create jpeg image
	# image(t(img[112:1,]), col=col, xaxt="n", yaxt="n", 
		# main=paste0(names(pca)[i], " PC",j)) # plot in R
}

# Face reconstruction (4 examples)
par(mfrow=c(5,4))
s <- sample(test,4)
for (i in 1:5)
for (j in 1:4)
{
	if (i==1) { 
		img <- x[,s[j]] # original image
		NAME <- 	paste0(DEST,"/face_data_",j,".jpg")
	} else {
		pcscore <- crossprod(pca[[i-1]]$vectors,x[,s[j]])
		img <- pca[[i-1]]$vectors %*% pcscore # reconstructed image 
		NAME <- paste0(DEST,"/face_",names(pca)[i-1],"_",j,".jpg")
	}
	dim(img) <- c(112,92) # restore original dimensions
	writeJPEG(img, NAME, quality=1) # export the image to jpeg format
	# image(t(img[112:1,]), col=col, xaxt="n", yaxt="n") # plot in R
}



##########################################################################



#########################################
# 2. FACE RECOGNITION: FISHERFACE METHOD
#########################################


# Subject labels
labs <- as.factor(rep(1:40,each=10))

# PC scores of subjects for each PCA method
xscore <- lapply(pca, function(z) crossprod(x,z$vectors))

# LDA of PC scores on training set
lda.xscore <- lapply(xscore, lda, grouping = labs, subset = train)

# PC scores for testing set
xscore.test <- lapply(xscore, function(z) z[test,])

# Classification based on LDA model
pred <- mapply(predict, obj = lda.xscore, newdata = xscore.test,
				MoreArgs = list(dimen=30), SIMPLIFY = F)
pred <- lapply(pred, function(z) z$class)

# Classification rate
classif.rate <- sapply(pred, function(z) mean(z == labs[test]))
classif.rate


