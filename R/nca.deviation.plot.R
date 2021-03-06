# Plot individual deviation of NCA metrics estimated from observed and simulated
# data
# roxygen comments
#' Plot individual deviation of NCA metrics estimated from observed and simulated
#' data
#'
#' \pkg{nca.deviation.plot} plots individual deviation of selected NCA metrics
#' estimated from observed and simulated data.
#' 
#' \pkg{nca.deviation.plot} plots individual deviation of selected NCA metrics 
#' estimated from observed and simulated data. This function requires three 
#' mandatory arguments, (i) deviation data, (ii) independent variable and (iii) 
#' dependent variables. The deviation of the NCA metrics values estimated from
#' the observed and simulated data are scaled by the "spread" of the simulated
#' metrics values. The "speed" of the simulated data is measured either by the
#' standard deviation or the 95% nonparametric interval.
#' 
#' @param plotdata A data frame containing the scaled deviation values of the
#'   NCA metrics
#' @param xvar x-variable against which the deviation data will be plotted
#'   (\strong{NULL})
#' @param devcol column names/numbers of the data frame containing deviation
#'   data (\strong{NULL})
#' @param figlbl Figure label based on dose identifier and/or population
#'   stratifier (\strong{NULL})
#' @param spread Measure of the spread of simulated data (ppi (95\% parametric
#'   prediction interval) or npi (95\% nonparametric prediction interval))
#'   (\strong{"npi"})
#' @param cunit Unit for concentration (default is \strong{\code{NULL}})
#' @param tunit Unit for time (default is \strong{\code{NULL}})
#' @return returns the data frame with the NPDE values based on the input data.
#' @export
#'

nca.deviation.plot <- function(plotdata,
                               xvar=NULL,
                               devcol=NULL,
                               figlbl=NULL,
                               spread="npi",
                               cunit=NULL,
                               tunit=NULL){
  
  "XVAR" <- "melt" <- "xlab" <- "ylab" <- "theme" <- "element_text" <- "unit" <- "geom_point" <- "facet_wrap" <- "ggplot" <- "aes" <- "labs" <- "na.omit" <- "dist" <- NULL
  rm(list=c("XVAR","melt","xlab","ylab","theme","element_text","unit","geom_point","facet_wrap","ggplot","aes","labs","na.omit","dist"))
  
  if (!is.data.frame(plotdata)) stop("plotdata must be a data frame.")
  if (is.null(xvar)){
    stop("Missing x-variable against which the deviation data will be plotted.")
  }else{
    names(plotdata)[which(names(plotdata)==xvar)] <- "XVAR"
  }
  if (is.null(devcol)){
    stop("Missing column names/numbers of the data frame containing deviation data.")
  }else if (!is.null(devcol) && !is.numeric(devcol)){
    if (!all(devcol%in%names(plotdata))) stop("All column names given as deviation data column must be present in plotdata")
  }else if (!is.null(devcol) && is.numeric(devcol)){
    if (any(devcol <= 0) | (max(devcol) > ncol(plotdata))) stop("Column number for deviation data out of range of plotdata.")
    devcol <- names(plotdata)[devcol]
  }
  
  plotdata <- subset(plotdata, select=c("XVAR",devcol))
  longdata <- melt(plotdata, measure.vars = devcol)
  names(longdata)[c((ncol(longdata)-1):ncol(longdata))] <- c("type","dist")
  longdata <- na.omit(longdata)
  longdata <- subset(longdata, dist!="NaN")
  
  if (nrow(longdata)==0){
    ggplt <- NULL
  }else{
    fctNm <- data.frame()
    npr   <- length(devcol)
    nc    <- ifelse(npr<2, 1, ifelse(npr>=2 & npr<=6, 2, 3))
    for (p in 1:npr){
      if (devcol[p] == "dAUClast" | devcol[p] == "dAUClower_upper" | devcol[p] == "dAUCINF_obs" | devcol[p] == "dAUCINF_pred"){
        if(is.null(cunit) | is.null(tunit)){
          fctNm <- rbind(fctNm, data.frame(prmNm=devcol[p],prmUnit=gsub("^d", "", devcol)[p]))
        }else{
          fctNm <- rbind(fctNm, data.frame(prmNm=devcol[p],prmUnit=paste0(gsub("^d", "", devcol)[p]," (",cunit,"*",tunit,")")))
        }
      }else if (devcol[p] == "dAUMClast"){
        if(is.null(cunit) | is.null(tunit)){
          fctNm <- rbind(fctNm, data.frame(prmNm=devcol[p],prmUnit=gsub("^d", "", devcol)[p]))
        }else{
          fctNm <- rbind(fctNm, data.frame(prmNm=devcol[p],prmUnit=paste0(gsub("^d", "", devcol)[p]," (",cunit,"*",tunit,"^2)")))
        }
      }else if (devcol[p] == "dCmax"){
        if(is.null(cunit)){
          fctNm <- rbind(fctNm, data.frame(prmNm=devcol[p],prmUnit=gsub("^d", "", devcol)[p]))
        }else{
          fctNm <- rbind(fctNm, data.frame(prmNm=devcol[p],prmUnit=paste0(gsub("^d", "", devcol)[p]," (",cunit,")")))
        }
      }else if (devcol[p] == "dTmax" | devcol[p] == "dHL_Lambda_z"){
        if(is.null(tunit)){
          fctNm <- rbind(fctNm, data.frame(prmNm=devcol[p],prmUnit=gsub("^d", "", devcol)[p]))
        }else{
          fctNm <- rbind(fctNm, data.frame(prmNm=devcol[p],prmUnit=paste0(gsub("^d", "", devcol)[p]," (",tunit,")")))
        }
      }else{
        fctNm <- rbind(fctNm, data.frame(prmNm=devcol[p],prmUnit=devcol[p]))
      }
    }
    
    # ggplot options for deviation plots
    ggOpt_dev <- list(xlab(paste("\n",xvar,sep="")), ylab("Deviation\n"),
                      theme(axis.text.x = element_text(angle=45,vjust=1,hjust=1,size=10),
                            axis.text.y = element_text(hjust=0,size=10),
                            strip.text.x = element_text(size=10),
                            title = element_text(size=14,face="bold")),
                      geom_point(size=2),
                      facet_wrap(~type, ncol=nc, scales="free"))
    
    longdata$type <- factor(longdata$type, levels=fctNm$prmNm, labels=fctNm$prmUnit)
    if (is.null(figlbl)){
      ttl <- ifelse (spread=="ppi",
                     "Deviation = (obs-medianSim)/d\nd = distance between medianSim and 95% parametric prediction\ninterval boundary proximal to the observed value\n",
                     "Deviation = (obs-medianSim)/d\nd = distance between medianSim and 95% nonparametric prediction\ninterval boundary proximal to the observed value\n")
    }else{
      ttl <- ifelse (spread=="ppi",
                     paste0("Deviation = (obs-medianSim)/d\nd = distance between medianSim and 95% parametric prediction\ninterval boundary proximal to the observed value\n",figlbl,"\n"),
                     paste0("Deviation = (obs-medianSim)/d\nd = distance between medianSim and 95% nonparametric prediction\ninterval boundary proximal to the observed value\n",figlbl,"\n"))
    }
    ggplt <- ggplot(longdata,aes(as.numeric(as.character(XVAR)),as.numeric(as.character(dist)))) + ggOpt_dev + labs(title = ttl) + theme(plot.title = element_text(size = rel(0.85)))
  }
  return(ggplt)
}

