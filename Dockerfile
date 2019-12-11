FROM mysql:5.7

LABEL name="Debian9 with JDK8 TOMCAT8 MySQL57"
# set your password and database
ENV MYSQL_ROOT_PASSWORD root
ENV MYSQL_DATABASE finedb
ENV MYSQL_CHARSET utf8

ENV CATALINA_HOME /tomcat
ENV JAVA_HOME /usr/java
ENV JRE_HOME /usr/java/jre
ENV JAVA_OPTS -Dfile.encoding=UTF-8
ENV PATH $PATH:$JAVA_HOME/bin:$JRE_HOME/bin:$CATALINA_HOME/bin

# Install tools
# set timezone and language of yourself.
RUN apt-get update && \
    apt-get install -y locales && \
    sed -ie 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen && \
    locale-gen && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/* && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

ENV LANG zh_CN.UTF-8
ENV LANGUAGE zh_CN:zh
ENV LC_ALL zh_CN.UTF-8

# cp you jdk and tomcat prepare for copy into image
COPY jdk-8u162 /usr/java
COPY tomcat8 /tomcat

# hark shell scripts for some initial opration
RUN cp /usr/java/lib/tools.jar /tomcat/lib/ && \
    sed -i "320i catalina.sh run & " /usr/local/bin/docker-entrypoint.sh && \
    sed -i '269i docker_process_sql --database=mysql <<<"set global innodb_flush_log_at_trx_commit = 2;"' /usr/local/bin/docker-entrypoint.sh && \
    sed -i '269i docker_process_sql --database=mysql <<<"set global sync_binlog=0;"' /usr/local/bin/docker-entrypoint.sh && \
    sed -i 's/\\`$MYSQL_DATABASE\\`/\\`$MYSQL_DATABASE\\` charset=utf8/g' /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

#映射端口和目录
EXPOSE 8080 3306
