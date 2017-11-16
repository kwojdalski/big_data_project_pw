if(!'pacman' %in% installed.packages()) install.packages('pacman')
require(pacman)
p_load(knitr, xtable, rmarkdown, stargazer, XML)
filename = 'report'
rmd_name <- paste0(filename, '.Rmd')
tex_name <- paste0(filename, '.tex')
pdf_name <- paste0(filename, '.pdf')
#render(rmd_name, envir = globalenv(), encoding = 'UTF-8', intermediates_dir = 'intermediates_files', clean = F)
render(rmd_name, envir = globalenv(), encoding = 'UTF-8')
x <- readLines(tex_name)
pos <- grep('begin\\{figure\\}\\[htbp\\]', x)
pos <- grep('begin\\{figure\\}', x) %>% {c(., add(.,1),add(.,2))}
x[pos] <- gsub('htbp', 'H', x[pos])
writeLines(x, tex_name)
tools::texi2pdf(tex_name, clean = TRUE)  # gives foo.pdf



system2('open', args = 'report.pdf', wait = FALSE)

file <- list.files('./src',pattern = '\\.Rmd$',full.names = T)
backup_files <- function(file) file.path(dirname(file),'backup', paste0("__", basename(file)))
lapply(file, function(x) knitr::wrap_rmd(x, backup = backup_files(x))) 

my_report_1 <- function(...) {
  browser()
  fmt <- rmarkdown::pdf_document(keep_tex = TRUE, ...)
  
  fmt$knitr$knit_hooks$size = function(before, options, envir) {
    if (before) return(paste0("\n \\", options$size, "\n\n"))
    else return("\n\n \\normalsize \n")
  }
  
  return(fmt)
}

my_report_1('./report.Rmd')

#list.files(recursive = T) %>% {.[stringr::str_detect(.,'.(r|R)md$')]} %>% .[4] %>% wrap_rmd()

