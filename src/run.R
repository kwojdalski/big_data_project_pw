#if (nchar(Sys.getenv("SPARK_HOME"))) Sys.setenv(SPARK_HOME = "D:/spark-2.1.1-bin-hadoop2.7")
if (nchar(Sys.getenv("SPARK_HOME"))) Sys.setenv(SPARK_HOME = "C:\\Users\\Krzysztof\\AppData\\Local\\rstudio\\spark\\Cache/spark-2.1.0-bin-hadoop2.7")
if (!"pacman"%in% installed.packages()) install.packages('pacman')

#.libPaths(c(file.path(Sys.getenv("SPARK_HOME"),"R","lib"),.libPaths()))
# library(SparkR, lib.loc = c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib")))
# require(pacman)
#spark_install(version = "2.1.0", hadoop_version = "2.7")
# spark_home_dir()
# spark_installed_versions()
Sys.getenv('JAVA_HOME')

# 
# devtools::install_github("SKKU-SKT/ggplot2.SparkR")
# p_load(dplyr, sparklyr, dplyr, sparkxml, sparkhaven,ggplot2.SparkR)
# library(sparkxml)
# Run as admin!!!!
# config <- spark_config()
# config$sparklyr.gateway.port = 10000
# sc <-  spark_connect(master = "local", spark_home=spark_home_dir(version = "2.1.0"))
# 
# books_df <- sparkxml:::spark_read_xml(sc, path = 'data/books.xml', option = list(table="xml_table"), name='books_test')
# books_df

sc <- sparkR.session(master = "local[*]", sparkConfig = list(spark.driver.memory = "2g"))
rdd <- read.text('./music.stackexchange.com/Posts.xml')
head(rdd)


# Selecting ---------------------------------------------------------------


zz <- rdd %>% SparkR::select(
  regexp_extract(rdd$value,'Id="([0-9]+)"',1) %>% alias('Id') %>% cast('integer'),
  regexp_extract(rdd$value,'ParentId="([0-9]+)"',1) %>% alias('ParentId')%>% cast('integer'),
  regexp_extract(rdd$value,'AcceptedAnswerId="([0-9]+)"',1) %>% alias('AcceptedAnswerId')%>% cast('integer'),
  regexp_extract(rdd$value,'CreationDate="([\\w:\\.\\-]+)"',1) %>% alias('CreationDate') %>% cast('timestamp'),
  regexp_extract(rdd$value,'ViewCount="([0-9]+)"',1) %>% alias('ViewCount')%>% cast('integer'),
  regexp_extract(rdd$value,'Score="([0-9]+)"',1) %>% alias('Score')%>% cast('integer'),
  regexp_extract(rdd$value,'Body="(.*?)"',1) %>% alias('Body'),
  regexp_extract(rdd$value,'LastEditorUserId="([0-9]+)"',1) %>% alias('LastEditorUserId')%>% cast('integer'),
  regexp_extract(rdd$value,'LastEditDate="([\\w:\\.\\-]+)"',1) %>% alias('LastEditDate')%>% cast('timestamp'),
  regexp_extract(rdd$value,'LastActivityDate="([\\w:\\.\\-]+)"',1) %>% alias('LastActivityDate')%>% cast('timestamp'),
  regexp_extract(rdd$value,'Title="(.*?)"',1) %>% alias('Title'),
  regexp_extract(rdd$value,'Tags="(.*?)"',1) %>% alias('Tags'),
  regexp_extract(rdd$value,'AnswerCount="([0-9]+)"',1) %>% alias('AnswerCount')%>% cast('integer'),
  regexp_extract(rdd$value,'CommentCount="([0-9]+)"',1) %>% alias('CommentCount')%>% cast('integer'),
  regexp_extract(rdd$value,'FavoriteCount="([0-9]+)"',1) %>% alias('FavoriteCount')%>% cast('integer')
) 

# Extracting info
zz <- as.data.frame(zz)
require(ggplot2)
ggplot(zz, aes(x = FavoriteCount, y = AnswerCount)) + geom_point()




?gapply




###############





to_date_udf = func.udf(to_date,types.DateType())
posts_df2=posts_df.withColumn('CreationDate',func.trunc(to_date_udf('CreationDate'),'mm'))


'''a na tych data frame dzia³aj± zwyk³e sql.
Jak w ten sam sposób wczytasz inne tabele, to mozna robiæ joiny dla ka¿dej zarejestowanej tabeli'''
'''rejestruje siê tak:'''
posts_df2.registerTempTable('posts')
posts_df2.printSchema()
posts_df2.show()

'''zapytania piszesz tak:'''

query = """
SELECT 
Id,
ViewCount,
Body,
Tags,
LastActivityDate

FROM posts
"""
a1 = sqlContext.sql(query)
a1.show()
