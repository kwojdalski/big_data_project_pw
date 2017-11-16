#if (nchar(Sys.getenv("SPARK_HOME"))) Sys.setenv(SPARK_HOME = "D:/spark-2.1.1-bin-hadoop2.7")
if (!nchar(Sys.getenv("SPARK_HOME"))) Sys.setenv(SPARK_HOME = "C:\\Users\\Krzysztof\\AppData\\Local\\rstudio\\spark\\Cache/spark-2.1.0-bin-hadoop2.7")
if (!"pacman"%in% installed.packages()) install.packages('pacman')
source('xml.R')
.libPaths(c(file.path(Sys.getenv("SPARK_HOME"),"R","lib"),.libPaths()))
library(SparkR, lib.loc = c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib")))
require(pacman)
p_load(purrr, plyr, dplyr, sparklyr, dplyr, sparkxml, tidyr, magrittr, ggplot2, ggthemes)
# Run as admin!!!!
# config <- spark_config()
# config$sparklyr.gateway.port = 10000
sc <-  spark_connect(master = "local", spark_home=spark_home_dir(version = "2.1.0"))

x <- hive_context(sc) %>%
    invoke("read") %>%
    invoke("format", "com.databricks.spark.xml") %>%
    #invoke("option", 'rootTag','posts') %>%
    invoke("option", 'rowTag','posts') %>%
    #invoke("load", 'music_datasets/Posts_example.xml')
    invoke("load", 'music_datasets/Posts_example.xml')

#sdf <- sdf_register(x, name = 'test2')
posts_df <-spark_read_text(sc, 'test', path = 'music_datasets/Posts.xml')

posts_df %<>%  mutate(
 Id               = regexp_extract(line, 'Id="([0-9]+)"',1)%>% as.integer(),
 ParentId         = regexp_extract(line, 'ParentId="([0-9]+)"',1),
 AcceptedAnswerId = regexp_extract(line, 'AcceptedAnswerId="([0-9]+)"',1),
 CreationDate     = regexp_extract(line, 'CreationDate="(.*?)"',1),
 ViewCount        = regexp_extract(line, 'ViewCount="([0-9]+)"',1)%>% as.integer(),
 Score            = regexp_extract(line, 'Score="([0-9]+)"',1)%>% as.integer(),
 Body             = regexp_extract(line, 'Body="(.*?)"',1),
 LastEditorUserId = regexp_extract(line, 'LastEditorUserId="([0-9]+)"',1) ,
 LastEditDate     = regexp_extract(line, 'LastEditDate="(.*?)"',1) ,
 LastActivityDate = regexp_extract(line, 'LastActivityDate="(.*?)"',1) ,
 Title            = regexp_extract(line, 'Title="(.*?)"',1),
 Tags             = regexp_extract(line, 'Tags="(.*?)"',1),
 AnswerCount      = regexp_extract(line, 'AnswerCount="([0-9]+)"',1)%>% as.integer(),
 CommentCount     = regexp_extract(line, 'CommentCount="([0-9]+)"',1)%>% as.integer(),
 FavouriteCount   = regexp_extract(line, 'FavoriteCount="([0-9]+)"',1) %>% as.integer()
) %>% select(-line)


posts_df_head <- posts_df %>% head(100) %>%  collect()
options(digits.secs= 6)
collected %<>% mutate(CreationDate = as.POSIXct(CreationDate, format =  '%Y-%m-%dT%H:%M:%S'))





# Selecting ---------------------------------------------------------------
require(lubridate)
# Extracting info
ggplot(collected, aes(x = AnswerCount, y = FavouriteCount)) + geom_point() + theme_economist()
ggplot(collected, aes(x = hour(CreationDate))) + geom_bar(stat='count') + theme_economist()
collected %>% 
  group_by(hour = hour(CreationDate)) %>% 
  summarize(mean_views = mean(ViewCount, na.rm =T)) %>% 
  ggplot(aes(x = hour, y=mean_views)) + geom_bar(stat='identity') + theme_economist()




