library(data.table)
library(dplyr)
library(magrittr)
library(rvest)
library(RSelenium)

##########################

### Instructions to run only once ###

#checkForServer()

##########################

#Starting the RSelenium server
startServer()
url <- "https://www.lvmh.fr/talents/nous-rejoindre/nos-offres/liste-des-offres/?job=&place=&experience=&activity=&contract=&reference=#gt_offers-results"
remDr <- remoteDriver(browserName="firefox", port=4444) # instantiate remote driver to connect to Selenium Server
remDr$open() # open web browser
remDr$navigate(url)

#Clicking on button to expand the list -- used SelectorGadget to find the css code for button
NextPageButton <- remDr$findElement("css selector", ".btn--std")
NextPageButton$clickElement()
NextPageButton$clickElement()
NextPageButton$clickElement()
NextPageButton$clickElement()
NextPageButton$clickElement()

#Extracting the table from the page
webtable <- remDr$findElements("css selector", "td")
tabletxt <- lapply(webtable, function(x){x$getElementAttribute("outerHTML")[[1]]})
tablefinal = lapply(tabletxt, function(x){read_html(x) %>% html_text()} )
cleantable = unlist(tablefinal) 
#Cleaning the file to get a csv
cleantable = gsub("(?<=[\\s])\\s*|^\\s+|\\s+$", "", cleantable, perl=TRUE)
cleantable = gsub("Nouveau\n","",cleantable)
cleanmatrix = t(matrix(cleantable, nrow=3))
data=as.data.frame(cleanmatrix,stringsAsFactors=F)
colnames(data)=c("poste","compagnie","pays")
write.csv(data,"webscrapingLVMH.csv")




##### GRAVEYARD ###############

elem <- remDr$findElements("css selector", "#js-jobs a")
elemtxt = lapply(elem, function(x){x$getElementAttribute("outerHTML")[[1]]})
elemfinal = lapply(elemtxt, function(x){read_html(x) %>% html_nodes ("a") %>% html_text()})
delist = unlist(elemfinal)

page <- read_html("https://www.lvmh.fr/talents/nous-rejoindre/nos-offres/liste-des-offres/?job=&place=&experience=&activity=&contract=&reference=#gt_offers-results")

elem = remDr$findElements(using = 'class name', "is-new")
elemtxt = lapply(elem, function(x){x$getElementAttribute("outerHTML")[[1]]})
elemfinal = lapply(elemtxt, function(x){read_html(x) %>% html_nodes ("h3") %>% html_text()})


elemtxt <- elem1$getElementAttribute("outerHTML")[[1]] # gets us the HTML
elemfinal <- read_html(elemtxt) %>% html_nodes ("h3") %>% html_text()


localurl = "LVMH.htm"
localpage = read_html(localurl)
localresults <- read_html(localurl) %>% html_nodes ("h3") %>% html_text()



doc<-htmlParse(remDr$getPageSource()[[1]])

elem <- remDr$findElement("css selector", "h3")

txt <- emploi$getElementText()


### Standard HTML parsing (no RSelenium)
intitulé <- page %>% html_nodes ("h3") %>% html_text()
intitulé = intitulé[1:10]
société <- page %>% html_nodes ("td:nth-child(2)") %>% html_text()
pays <- page %>% html_nodes (".detail__h") %>% html_text()

offres=data.table(intitulé, société, pays)
