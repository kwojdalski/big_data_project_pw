html2txt <- function(str) {
  xpathApply(htmlParse(str, asText=TRUE),
             "//body//text()", 
             xmlValue)[[1]] 
}
html2txt(posts_df_head$Body)
