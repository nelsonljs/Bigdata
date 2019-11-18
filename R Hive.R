library("DBI")
library("rJava")
library("RJDBC")
hive.class.path = list.files(path=c("/usr/lib/hive/lib"), pattern="jar", full.names=T);
hadoop.lib.path = list.files(path=c("/usr/lib/hive/lib"), pattern="jar", full.names=T);

hadoop.class.path = list.files(path=c("/usr/lib/hadoop/lib"), pattern="jar", full.names=T);

cp = c(hive.class.path, hadoop.lib.path, hadoop.class.path, "/usr/lib/hadoop-mapreduce/hadoop-mapreduce-client-core.jar")
.jinit(classpath=cp)

drv <- JDBC("org.apache.hive.jdbc.HiveDriver","hive-jdbc.jar",identifier.quote="`")

url.dbc <-paste0("jdbc:hive2://quickstart.cloudera:10000/default");

conn <- dbConnect(drv, url.dbc, "", "");dbListTables(conn);

dbGetQuery(conn, "select * from food");

