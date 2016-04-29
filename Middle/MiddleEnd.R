
getData <- function(v1, v2, fact){
  #* Aggregate dataset
  variables <- c(fact, v1, v2)

  final.table %>% select_(.dots=c("pop", variables)) %>% mutate(pop=as.numeric(pop)) %>% group_by_(.dots=fact) %>%
    summarise_each_(funs(sum(.*pop, na.rm=TRUE)/sum(pop)),c(v1, v2))
}

getDataPred <- function(v1, v2, fact){
  #* Aggregate dataset
  variables <- c(fact, v1, v2)
  final.pred.table %>% select_(.dots=c("pop", variables)) %>% mutate(pop=as.numeric(pop)) %>% group_by_(.dots=fact) %>% 
    summarise_each_(funs(sum(.*pop, na.rm=TRUE)/sum(pop)),c(v1, v2))
}

num2str <- function(number) {
  string <- format(number, digits=3)
}

source_encoding = "UTF-8"
destination_encoding = "UTF-8"

#* @post /plotPost
function(data){
  j <- jsonlite::fromJSON(data)
  var1 = j$var1
  var2 = j$var2
  fact <- append('annee', j$factor)
  print(j)
  
  dat <- getData(v1=var1, v2=var2, fact=fact)

  datpred <- getDataPred(v1=var1, v2=var2, fact=fact)
  symbol <- 1
  col <- 1
  if('age.agg' %in% fact){
    col <- 'age.agg'
  }
  if('sexe' %in% fact){
    symbol <- 'sexe'
  }
  if(is.null(var2)){
    #* Univariate plot
    if(col=='age.agg'){
      p <- dat %$% plot_ly(type = "scatter", y=get(var1)
                           , fill='tozeroy'
                           # , group=age.agg
                           , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>Age</b> : ",age.agg, "<br><b>",var1,"</b> : ", num2str(get(var1))), source_encoding, destination_encoding)
                           , color= age.agg
                           , hoverinfo="text"
                           , x=unique(annee)
                           , mode='lines+markers'
      ) %>%
        layout(xaxis = list(title=iconv("Année", source_encoding, destination_encoding)), yaxis = list(title=dico[[var1]])
               # layout(xaxis = list(title="Année"), yaxis = list(title=dico[[var1]])
               , title=""
               , margin=list(b=-5, l=-5)
        )
      # Predictions !
      p <- datpred %$% add_trace(y = get(var1), x=annee
                                 , type = "scatter"
                                 , mode = 'lines'
                                 , text = ""
                                 , hoverinfo=""
                                 , color= age.agg
                                 , line=list(dash="dot")
                                 , showlegend=FALSE)
    } else {
      if(symbol=="sexe"){
        p <- plot_ly() %>%
          layout(xaxis = list(title=iconv("Année", source_encoding, destination_encoding)), yaxis = list(title=dico[[var1]])
                 , title=""
                 , margin=list(b=-5, l=-5))
        p <- dat  %$% add_trace(p, y = get(var1), x=annee
                                , type = "scatter"
                                , fill='tozeroy'
                                , color=sexe
                                , mode='lines+markers'
                                , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>",var1,"</b> : ", num2str(get(var1))), source_encoding, destination_encoding)
                                , hoverinfo="text"
        )
        p <- datpred %$% add_trace(y = get(var1), x=annee
                                   , type = "scatter"
                                   , color = sexe
                                   , mode = 'lines'
                                   , text = ""
                                   , hoverinfo=""
                                   , line=list(dash="dot")
                                   , showlegend=FALSE)
      }else{
        # simple plot univarié sans split
        p <- dat %$% plot_ly(y = get(var1), x=annee
                             , type = "scatter"
                             , name = "data"
                             , fill='tozeroy'
                             , mode='lines+markers'
                             , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>",var1,"</b> : ", num2str(get(var1))), source_encoding, destination_encoding)
                             , hoverinfo="text"
        ) %>%
          layout(xaxis = list(title=iconv("Année", source_encoding, destination_encoding)), yaxis = list(title=dico[[var1]])
                 # layout(xaxis = list(title="Année"), yaxis = list(title=dico[[var1]])
                 , title=""
                 , margin=list(b=-5, l=-5))
        p <- datpred %$% add_trace(y = get(var1), x=annee
                                   , name = iconv("prediction", source_encoding, destination_encoding)
                                   , type = "scatter"
                                   , mode = 'lines')
      }
    }
  } else {
    #* Bivariate plot
    if(col=='age.agg'){
      if(symbol == 'sexe'){
        p <- plot_ly() %>%
          layout(xaxis = list(title=dico[[var1]])
                 , yaxis = list(title=dico[[var2]])
                 , title=""
                 , margin=list(b=-5, l=-5)
                 , hovermode ='closest')
        p <- dat %>% filter(sexe=='femme') %$% add_trace(p, x = get(var1), y=get(var2)
                                                         , mode = "markers"
                                                         , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>Age</b> : ",age.agg, "<br><b>Sexe</b> : ",sexe, "<br><b>",var1,"</b> : ",num2str(get(var1)), "<br><b>",var2,"</b> : ",num2str(get(var2))), source_encoding, destination_encoding)
                                                         , hoverinfo="text"
                                                         , marker=list(size=20
                                                                       , symbol="diamond-tall"
                                                                       , opacity=(annee-min(annee))/length(unique(annee))),
                                                         group=age.agg
        )  
        p <- dat %>% filter(sexe=='homme') %$% add_trace(p, x = get(var1), y=get(var2)
                                                         , mode = "markers"
                                                         , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>Age</b> : ",age.agg, "<br><b>Sexe</b> : ",sexe, "<br><b>",var1,"</b> : ",num2str(get(var1)), "<br><b>",var2,"</b> : ",num2str(get(var2))), source_encoding, destination_encoding)
                                                         , hoverinfo="text"
                                                         , marker=list(size=20
                                                                       , symbol="star"
                                                                       , opacity=(annee-min(annee))/length(unique(annee))),
                                                         group=age.agg
        ) 
      } else {
        # With Age | without Sexe
        p <- dat %$% plot_ly(x = get(var1), y=get(var2)
                             , mode = "markers"
                             , hoverinfo="text"
                             , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>Age</b> : ",age.agg, "<br><b>",var1,"</b> : ",num2str(get(var1)), "<br><b>",var2,"</b> : ",num2str(get(var2))), source_encoding, destination_encoding)
                             , marker=list(size=20
                                           , opacity=(annee-min(annee))/length(unique(annee))),
                             group=age.agg
        ) %>%
          layout(xaxis = list(title=dico[[var1]])
                 , yaxis = list(title=dico[[var2]])
                 , title=""
                 , margin=list(b=-5, l=-5)
                 , hovermode ='closest'
          )
      }
    } else {
      if(symbol == 'sexe'){
        # Without Age | With Sexe
        p <- plot_ly() %>%
          layout(xaxis = list(title=dico[[var1]])
                 , yaxis = list(title=dico[[var2]])
                 , title=""
                 , margin=list(b=-5, l=-5)
                 , hovermode ='closest')
        p <- dat %>% filter(sexe=='femme') %$% add_trace(x = get(var1), y=get(var2)
                                                         , mode = "markers"
                                                         , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>Sexe</b> : ",sexe, "<br><b>",var1,"</b> : ",num2str(get(var1)), "<br><b>",var2,"</b> : ",num2str(get(var2))), source_encoding, destination_encoding)
                                                         , name="Femme"
                                                         , hoverinfo="text"
                                                         , marker=list(size=12
                                                                       , symbol="diamond-tall"
                                                                       , opacity=(annee-min(annee))/(nrow(dat)/2))
        )
        p <- dat %>% filter(sexe=='homme') %$% add_trace(x = get(var1), y=get(var2)
                                                         , mode = "markers"
                                                         , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>Sexe</b> : ",sexe, "<br><b>",var1,"</b> : ",num2str(get(var1)), "<br><b>",var2,"</b> : ",num2str(get(var2))), source_encoding, destination_encoding)
                                                         , name="Homme"
                                                         , hoverinfo='text'
                                                         , marker=list(size=12
                                                                       , symbol="star"
                                                                       , opacity=(annee-min(annee))/(nrow(dat)/2))
        )
      } else {
        p <- dat %$% plot_ly(x = get(var1), y=get(var2)
                             , mode = "markers"
                             , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>",var1,"</b> : ",num2str(get(var1)), "<br><b>",var2,"</b> : ",num2str(get(var2))), source_encoding, destination_encoding)
                             , hoverinfo="text"
                             , marker=list(size=12
                                           , opacity=(annee-min(annee))/nrow(dat))
        ) %>%
          layout(xaxis = list(title=dico[[var1]])
                 , yaxis = list(title=dico[[var2]]), title=""
                 , margin=list(b=-5, l=-5)
          )
      }    
    }
  }
  
  #* Convert plotly graph into JSON
  p.widget <- as.widget(p)
  jsonlite::toJSON(p.widget$x, force=TRUE, simplifyVector=FALSE
                   , faltten=TRUE
                   , auto_unbox = TRUE, digit=10)
}





#* @post /plotPost2
function(data){
  j <- jsonlite::fromJSON(data)
  var1 = j$var1
  var2 = j$var2
  fact <- append('annee', j$factor)
  dat <- getData(v1=var1, v2=var2, fact=fact)
  datpred <- getDataPred(v1=var1, v2=var2, fact=fact)
  symbol <- 1
  col <- 1
  if('age.agg' %in% fact){
    col <- 'age.agg'
  }
  if('sexe' %in% fact){
    symbol <- 'sexe'
  }
  if(is.null(var2)){
    print('JE FAIS UN PLOT UNIVARIE')
    #* Univariate plot
    if(col=='age.agg'){
      p <- dat %$% plot_ly(type = "scatter", y=get(var1)
                           , fill='tozeroy'
                           # , group=age.agg
                           , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>Age</b> : ",age.agg, "<br><b>",var1,"</b> : ", num2str(get(var1))), source_encoding, destination_encoding)
                           , color= age.agg
                           , hoverinfo="text"
                           , x=unique(annee)
                           , mode='lines+markers'
      ) %>%
        layout(xaxis = list(title=iconv("Année", source_encoding, destination_encoding)), yaxis = list(title=dico[[var1]])
               # layout(xaxis = list(title="Année"), yaxis = list(title=dico[[var1]])
               , title=""
               , margin=list(b=-5, l=-5)
        )
      # Predictions !
      p <- datpred %$% add_trace(y = get(var1), x=annee
                                 , type = "scatter"
                                 , mode = 'lines'
                                 , text = ""
                                 , hoverinfo=""
                                 , color= age.agg
                                 , line=list(dash="dot")
                                 , showlegend=FALSE)
    } else {
      if(symbol=="sexe"){
        p <- plot_ly() %>%
          layout(xaxis = list(title=iconv("Année", source_encoding, destination_encoding)), yaxis = list(title=dico[[var1]])
                 , title=""
                 , margin=list(b=-5, l=-5))
        p <- dat  %$% add_trace(p, y = get(var1), x=annee
                                , type = "scatter"
                                , fill='tozeroy'
                                , color=sexe
                                , mode='lines+markers'
                                , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>",var1,"</b> : ", num2str(get(var1))), source_encoding, destination_encoding)
                                , hoverinfo="text"
        )
        p <- datpred %$% add_trace(y = get(var1), x=annee
                                   , type = "scatter"
                                   , color = sexe
                                   , mode = 'lines'
                                   , text = ""
                                   , hoverinfo=""
                                   , line=list(dash="dot")
                                   , showlegend=FALSE)
      }else{
        # simple plot univarié sans split
        p <- dat %$% plot_ly(y = get(var1), x=annee
                             , type = "scatter"
                             , name = "data"
                             , fill='tozeroy'
                             , mode='lines+markers'
                             , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>",var1,"</b> : ", num2str(get(var1))), source_encoding, destination_encoding)
                             , hoverinfo="text"
        ) %>%
          layout(xaxis = list(title=iconv("Année", source_encoding, destination_encoding)), yaxis = list(title=dico[[var1]])
                 # layout(xaxis = list(title="Année"), yaxis = list(title=dico[[var1]])
                 , title=""
                 , margin=list(b=-5, l=-5))
        p <- datpred %$% add_trace(y = get(var1), x=annee
                                   , name = iconv("prediction", source_encoding, destination_encoding)
                                   , type = "scatter"
                                   , mode = 'lines')
      }
    }
  } else {
    #* Bivariate plot
    var2_cut <-dat %$% cut(x = get(var2), 13,labels = seq(from=10, to=1210, by =100))
    dat$var2_cut <- var2_cut
    if(col=='age.agg'){
      # With Age | without Sexe
      p <- dat %$% plot_ly(x = annee, y=get(var1)
                           , mode = "markers"
                           , hoverinfo="text"
                           , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>Age</b> : ",age.agg, "<br><b>",var1,"</b> : ",num2str(get(var1)), "<br><b>",var2,"</b> : ",num2str(get(var2))), source_encoding, destination_encoding)
                           # , marker=list(size=20
                           #               , opacity=(annee-min(annee))/length(unique(annee))),
                           , marker=list(size= var2_cut, sizemode='area')
                           #, group=age.agg
                           , color=age.agg
      ) %>%
        layout(xaxis = list(title=iconv("Année", source_encoding, destination_encoding))
               , yaxis = list(title=dico[[var1]], rangemode="tozero")
               , title=""
               , margin=list(b=-5, l=-5)
               , hovermode ='closest'
        )
      p <- datpred %$% add_trace(p, x = annee, y=get(var1)
                                 , mode = "lines"
                                 , hoverinfo="text"
                                 , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>Age</b> : ",age.agg, "<br><b>",var1,"</b> : ",num2str(get(var1)), "<br><b>",var2,"</b> : ",num2str(get(var2))), source_encoding, destination_encoding)
                                 , hoverinfo=""
                                 , line=list(dash="dot")
                                 , color=age.agg
                                 , showlegend=FALSE
      )
    } else {
      if(symbol == 'sexe'){
        # Without Age | With Sexe
        dat %<>% mutate(sexe = factor(sexe))
        p <- plot_ly() %>%
          layout(xaxis = list(title=iconv("Année", source_encoding, destination_encoding))
                 , yaxis = list(title=dico[[var1]], rangemode="tozero")
                 , title=""
                 , margin=list(b=-5, l=-5)
                 , hovermode ='closest')
        p <- dat  %$% add_trace(p, x = annee, y=get(var1)
                                , mode = "markers"
                                , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>Sexe</b> : ",sexe, "<br><b>",var1,"</b> : ",num2str(get(var1)), "<br><b>",var2,"</b> : ",num2str(get(var2))), source_encoding, destination_encoding)
                                , hoverinfo='text'
                                , color=sexe
                                , marker=list(size= var2_cut
                                              ,sizemode='area')
        )
        p <- datpred %$% add_trace(p, x = annee, y=get(var1)
                                   , mode = "lines"
                                   , hoverinfo="text"
                                   , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>Sexe</b> : ",sexe, "<br><b>",var1,"</b> : ",num2str(get(var1)), "<br><b>",var2,"</b> : ",num2str(get(var2))), source_encoding, destination_encoding)
                                   , hoverinfo=""
                                   , line=list(dash="dot")
                                   , color=sexe
                                   , showlegend=FALSE
        )
      } else {
        p <- dat %$% plot_ly(x = annee , y=get(var1)
                             , mode = "markers"
                             , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>",var1,"</b> : ",num2str(get(var1)), "<br><b>",var2,"</b> : ",num2str(get(var2))), source_encoding, destination_encoding)
                             , hoverinfo="text"
                             , name = var2
                             , marker=list(size= var2_cut, sizemode="area")
        ) %>%
          layout(xaxis = list(title=iconv("Année", source_encoding, destination_encoding))
                 , yaxis = list(title=dico[[var1]], rangemode="tozero"), title=""
                 , margin=list(b=-5, l=-5)
          )
        p <- datpred %$% add_trace(p, x = annee, y=get(var1)
                                   , mode = "lines"
                                   , hoverinfo="text"
                                   , text = iconv(paste0("<b>Année</b> : ", annee, "<br><b>",var1,"</b> : ",num2str(get(var1)), "<br><b>",var2,"</b> : ",num2str(get(var2))), source_encoding, destination_encoding)
                                   , hoverinfo=""
                                   , line=list(dash="dot")
                                   , showlegend=FALSE
        )
      }    
    }
  }
  
  #* Convert plotly graph into JSON
  p.widget <- as.widget(p)
  jsonlite::toJSON(p.widget$x, force=TRUE, simplifyVector=FALSE
                   , faltten=TRUE
                   , auto_unbox = TRUE, digit=10)
}

