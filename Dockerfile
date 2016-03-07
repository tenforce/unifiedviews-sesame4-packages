FROM maven:3.3-jdk-8
ADD virt_sesame4.jar /tmp
ADD virtjdbc4.jar /tmp
RUN mvn install:install-file -Dfile=/tmp/virtjdbc4.jar \
	       -DgroupId=eu.comsode \
	       -DartifactId=com.openlinksw.virtuoso.virtjdbc4_1 \
	       -Dversion=4.0 -Dpackaging=jar \
   && mvn install:install-file -Dfile=/tmp/virt_sesame4.jar -DgroupId=eu.comsode \
		 -DartifactId=com.openlinksw.virtuoso.virt_sesame4 \
		 -Dversion=4 -Dpackaging=jar
