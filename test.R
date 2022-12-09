
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
ssX = as.Date(ss$x, origin=as.Date("1970-01-01"))
ssY = ss$y

OK = ssY > 0
ssX = ssX[OK]
ssY = ssY[OK]

res = inflect(ssY, 10)
peak = res$maxima
valley = res$minima
nPeak = length(peak)
nValley = length(valley)
nMax = max(nPeak, nValley)
peak = c(peak, rep(NA, times=nMax-nPeak))
valley = c(valley, rep(NA, times=nMax-nValley))

# p = 0.05
# OK = ssY[peak] >= quantile(ssY[peak], p, na.rm=TRUE) | ssY[valley] >= quantile(ssY[valley], p, na.rm=TRUE)
# peak = peak[OK]
# valley = valley[OK]

names(valley)=rep("v", length(valley))
names(peak)=rep("p", length(peak))
all = sort(c(peak, valley))
id = cumsum(rle(names(all))$lengths)
all = all[id]

peak = all[names(all) == "p"]
valley = all[names(all) == "v"]

if (valley[1] < peak[1]) {
    valley = valley[-1]
}
if (valley[length(valley)] < peak[length(peak)]) {
    peak = peak[-length(peak)]
}



# 'V2114010_HYDRO_QJM.txt'
# cut gap for data = data[10000:11000,]

names(peak) = NULL
names(valley) = NULL

cut = function (peak, valley, X) {
    return (X[peak:valley])
}

add = function (X, n) {
    return (c(X, rep(NULL, n-length(X))))
}

ABS = mapply(cut, peak, valley, list(X=ssX))
# nMaxABS = max(sapply(ABS, length))
# ABS = lapply(ABS, add, n=nMaxABS)
# ABS = matrix(unlist(ABS), ncol=length(ABS))

ORD = mapply(cut, peak, valley, list(X=logb(ssY)))
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

OK = Tau > 0 & Tau < quantile(Tau, 0.9)
ABS = ABS[OK]
ORD = ORD[OK]
Alpha = Alpha[OK]
Beta = Beta[OK]
Tau = Tau[OK]


# x11(width=18, height=10)
# plot(data$Date, logb(data$Q_sim), type="l")
# lines(ssX, logb(ssY), col='blue')
# points(ssX[peak], logb(ssY[peak]), col='red')
# points(ssX[valley], logb(ssY[valley]), col='yellow')

# nLine = length(Tau)
# for (i in 1:nLine) {
#     lines(ABS[[i]], ABS[[i]]*Alpha[i] + Beta[i], col='green')
# }


medianTau = median(Tau)

## FIG1 ______________________________________________________________
fig1 = plotly::plot_ly()

## Q _________________________________________________________________
fig1 = plotly::add_trace(fig1,
                         type="scatter",
                         mode="lines",
                         x=data$Date,
                         y=logb(data$Q_sim),
                         line=list(color="white",
                                   width=6),
                         hoverinfo="none",
                         legendgroup='Q',
                         showlegend=FALSE)

fig1 = plotly::add_trace(fig1,
                         type="scatter",
                         mode="lines",
                         x=data$Date,
                         y=logb(data$Q_sim),
                         line=list(color="Turquoise",
                                   width=1.5),
                         xhoverformat="%d/%m/%Y",
                         hovertemplate = paste0(
                             "jour",
                             " ", "%{x}<br>",
                             "<b>Q </b> %{y}",
                             "<extra></extra>"),
                         hoverlabel=list(bgcolor="Turquoise",
                                         font=list(size=12),
                                         bordercolor="white"),
                         legendgroup='Q',
                         name="<b>Q</b> [m<sup>3</sup>.s<sup>-1</sup>]")

## Q spline __________________________________________________________
fig1 = plotly::add_trace(fig1,
                         type="scatter",
                         mode="lines",
                         x=ssX,
                         y=logb(ssY),
                         line=list(color="white",
                                   width=4),
                         hoverinfo="none",
                         legendgroup='ssQ',
                         showlegend=FALSE)

fig1 = plotly::add_trace(fig1,
                         type="scatter",
                         mode="lines",
                         x=ssX,
                         y=logb(ssY),
                         line=list(color="Teal",
                                   width=1.5),
                         xhoverformat="%d/%m/%Y",
                         hovertemplate = paste0(
                             "jour",
                             " ", "%{x}<br>",
                             "<b>Q spline </b> %{y}",
                             "<extra></extra>"),
                         hoverlabel=list(bgcolor="Teal",
                                         font=list(size=12),
                                         bordercolor="white"),
                         legendgroup='ssQ',
                         name="<b>Q spline</b> [m<sup>3</sup>.s<sup>-1</sup>]")


## Fit _______________________________________________________________
nLine = length(Tau)
for (i in 1:nLine) {
    if (i == 1) {
        showlegend = TRUE
    } else {
        showlegend = FALSE
    }

    fig1 = plotly::add_trace(fig1,
                             type="scatter",
                             mode="lines",
                             x=ABS[[i]],
                             y=as.numeric(ABS[[i]])*Alpha[i] + Beta[i],
                             line=list(color="white",
                                       width=2),
                             hoverinfo="none",
                             legendgroup='fit',
                             showlegend=FALSE)

    fig1 = plotly::add_trace(fig1,
                             type="scatter",
                             mode="lines",
                             x=ABS[[i]],
                             y=as.numeric(ABS[[i]])*Alpha[i] + Beta[i],
                             line=list(color="CornflowerBlue ",
                                       width=1),
                             xhoverformat="%d/%m/%Y",
                             hovertemplate = paste0(
                                 "jour",
                                 " ", "%{x}<br>",
                                 "<b>fit </b> %{y}",
                                 "<extra></extra>"),
                             hoverlabel=list(bgcolor="CornflowerBlue ",
                                             font=list(size=12),
                                             bordercolor="white"),
                             legendgroup='fit',
                             showlegend=showlegend,
                             name="<b>Linear fit</b>")
}

## Peak and valley ___________________________________________________
fig1 = plotly::add_trace(fig1,
                         type="scatter",
                         mode="markers",
                         x=ssX[peak],
                         y=logb(ssY[peak]),
                         marker=list(
                             color='transparent',
                             size=6,
                             line=list(
                                 color='DarkOrange',
                                 width=1)),
                         xhoverformat="%d/%m/%Y",
                         hovertemplate = paste0(
                             "jour",
                             " ", "%{x}<br>",
                             "<b>peak </b> %{y}",
                             "<extra></extra>"),
                         hoverlabel=list(bgcolor="DarkOrange",
                                         font=list(size=12),
                                         bordercolor="white"),
                         legendgroup='peak',
                         name="<b>Peak</b>")

fig1 = plotly::add_trace(fig1,
                         type="scatter",
                         mode="markers",
                         x=ssX[valley],
                         y=logb(ssY[valley]),
                         marker=list(
                             color='transparent',
                             size=6,
                             line=list(
                                 color='DarkSlateBlue',
                                 width=1)),
                         xhoverformat="%d/%m/%Y",
                         hovertemplate = paste0(
                             "jour",
                             " ", "%{x}<br>",
                             "<b>valley </b> %{y}",
                             "<extra></extra>"),
                         hoverlabel=list(bgcolor="DarkSlateBlue",
                                         font=list(size=12),
                                         bordercolor="white"),
                         legendgroup='valley',
                         name="<b>Valley</b>")

## Annotation ________________________________________________________
fig1 = plotly::add_annotations(fig1,
                               x=0.01,
                               y=1.05,
                               xref="paper",
                               yref="paper",
                               text=paste0("<b>",
                                           Code,
                                           "</b> - ",
                                           Model),
                               showarrow=FALSE,
                               xanchor='left',
                               yanchor='bottom',
                               font=list(color="LightSeaGreen ",
                                         size=25))

fig1 = plotly::add_annotations(fig1,
                               x=0.01,
                               y=1,
                               xref="paper",
                               yref="paper",
                               text=paste0("<b>Tau </b>:<b> ",
                                           round(medianTau, 2),
                                           "</b> jours"),
                               showarrow=FALSE,
                               xanchor='left',
                               yanchor='bottom',
                               font=list(color="LightSeaGreen ",
                                         size=20))

fig1 = plotly::layout(fig1,
                      separators='. ',
                      yaxis=list(
                          title=list(
                              font=list(color="DarkGrey")),
                          gridcolor="WhiteSmoke",
                          gridwidth=1,
                          ticks="outside",
                          tickcolor="DarkGrey",
                          tickfont=list(color="Grey"),
                          showline=FALSE,
                          zerolinecolor="WhiteSmoke",
                          zerolinewidth=2,
                          fixedrange=TRUE),

                      xaxis=list(showgrid=FALSE,
                                 ticks="outside",
                                 tickcolor="DarkGrey",
                                 tickfont=
                                     list(color="Grey"),
                                 showline=TRUE,
                                 linewidth=2,
                                 linecolor="LightGrey",
                                 showticklabels=TRUE),

                      autosize=TRUE,
                      plot_bgcolor="transparent",
                      paper_bgcolor='transparent',
                      showlegend=TRUE)


## FIG2 ______________________________________________________________
fig2 = plotly::plot_ly()
fig2 = plotly::add_histogram(fig2,
                             x=Tau,
                             nbinsx=20,
                             bargap=0.05,
                             color_discrete_sequence=list("MediumTurquoise"),
                             name="<b>Histogram de Tau</b>")

## FIG _______________________________________________________________
fig = plotly::subplot(fig1, fig2,
                      widths=c(4/5, 1/5),
                      margin=0.02)

fig = plotly::layout(fig,

                     margin=list(l=25,
                                 r=25,
                                 b=25,
                                 t=75,
                                 pad=0),

                     autosize=TRUE,
                     plot_bgcolor="transparent",
                     paper_bgcolor='transparent',
                     showlegend=TRUE)


fig = plotly::config(fig,
                     locale="fr",
                     displaylogo=FALSE,
                     toImageButtonOptions =
                         list(format="svg")
                     # modeBarButtonsToRemove =
                     #     list("lasso2d",
                     #          "select2d",
                     #          "drawline",
                     #          "zoom2d",
                     #          "drawrect",
                     #          "autoScale2d",
                     #          "hoverCompareCartesian",
                     #          "hoverClosestCartesian")
                     ) 

fig


# hist(Tau, breaks=20)
