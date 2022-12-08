
inflect <- function(x, threshold=1){
  up   <- sapply(1:threshold, function(n) c(x[-(seq(n))], rep(NA, n)))
  down <-  sapply(-1:-threshold, function(n) c(rep(NA, abs(n)), x[-seq(length(x), length(x) - abs(n) + 1)]))
  a    <- cbind(x, up, down)
  list(minima = which(apply(a, 1, min) == a[, 1]), maxima = which(apply(a, 1, max) == a[, 1]))
}

data = data[!is.na(data$Q_sim),]


ss = smooth.spline(data$Date,
                   data$Q_sim,
                   df=10,
                   spar=0.5,
                   # nknots=length(data$Date)*2/3,
                   nknots=length(data$Date)/1.5,
                   # w=data$Q_sim/max(data$Q_sim)
                   w=1/sqrt(data$Q_sim/max(data$Q_sim))
                   )

# peak = which(diff(sign(diff(ss$y))) == -2) + 1

res = inflect(ss$y, 10)
peak = res$maxima
valley = res$minima
nPeak = length(peak)
nValley = length(valley)
nMax = max(nPeak, nValley)
peak = c(peak, rep(NA, times=nMax-nPeak))
valley = c(valley, rep(NA, times=nMax-nValley))

p = 0.2
OK = ss$y[peak] >= quantile(ss$y[peak], p, na.rm=TRUE) | ss$y[valley] >= quantile(ss$y[valley], p, na.rm=TRUE)
peak = peak[OK]
valley = valley[OK]

names(valley)=rep("v", length(valley))
names(peak)=rep("p", length(peak))
all = sort(c(peak, valley))
id = cumsum(rle(names(all))$lengths)
all = all[id]

peak = all[names(all) == "p"]
valley = all[names(all) == "v"]

names(peak) = NULL
names(valley) = NULL

cut = function (peak, valley, X) {
    return (X[peak:valley])
}

add = function (X, n) {
    return (c(X, rep(NULL, n-length(X))))
}

ABS = mapply(cut, peak, valley, list(X=ss$x))
# nMaxABS = max(sapply(ABS, length))
# ABS = lapply(ABS, add, n=nMaxABS)
# ABS = matrix(unlist(ABS), ncol=length(ABS))

ORD = mapply(cut, peak, valley, list(X=logb(ss$y)))
# nMaxORD = max(sapply(ORD, length))
# ORD = lapply(ORD, add, n=nMaxORD)
# ORD = matrix(unlist(ORD), ncol=length(ORD))

# lm.fit(ABS, ORD)


fit = function (X, Y) {
    res = lm(Y~X)$coefficients
    res = c(alpha=res[[2]], beta=res[[1]])
    return (res)
}

Coef = mapply(fit, ABS, ORD, SIMPLIFY=FALSE)
Alpha = sapply(Coef, '[[', "alpha")
Beta = sapply(Coef, '[[', "beta")
Tau = -1/Alpha

x11(width=18, height=10)
plot(data$Date, logb(data$Q_sim), type="l")
lines(ss$x, logb(ss$y), col='blue')
points(ss$x[peak], logb(ss$y[peak]), col='red')
points(ss$x[valley], logb(ss$y[valley]), col='yellow')

nLine = length(Coef)
for (i in 1:nLine) {
    lines(ABS[[i]], ABS[[i]]*Alpha[i] + Beta[i], col='green')
}


