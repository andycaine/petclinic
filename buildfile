

# Maven Central
repositories.remote << 'http://repo1.maven.org/maven2'
# SpringSource Enterprise Bundle Repository - SpringSource Releases
repositories.remote << 'http://repository.springsource.com/maven/bundles/release'
# SpringSource Enterprise Bundle Repository - External Releases
repositories.remote << 'http://repository.springsource.com/maven/bundles/external'
# SpringSource Enterprise Bundle Repository - SpringSource Milestones
repositories.remote << 'http://repository.springsource.com/maven/bundles/milestone'
# SpringSource Enterprise Bundle Repository - Snapshot Releases
repositories.remote << 'http://repository.springsource.com/maven/bundles/snapshot'


SPRING = ['context', 'orm', 'oxm', 'web.servlet', 'aspects'].map do |m| 
  transitive("org.springframework:org.springframework.#{m}:jar:3.0.0.RELEASE")
end

ASPECTJ = transitive('org.aspectj:com.springsource.org.aspectj.weaver:jar:1.6.8.RELEASE')

SLF4J_API = transitive('org.slf4j:com.springsource.slf4j.api:jar:1.5.6')
SLF4J_CL = transitive('org.slf4j:com.springsource.slf4j.org.apache.commons.logging:jar:1.5.6') # runtime
SLF4J_LOG4J = transitive('org.slf4j:com.springsource.slf4j.log4j:jar:1.5.6') # runtime
LOG4J = transitive('org.apache.log4j:com.springsource.org.apache.log4j:jar:1.2.15') # runtime
DBCP = transitive('org.apache.commons:com.springsource.org.apache.commons.dbcp:jar:1.2.2.osgi') # runtime
COMMONS_POOL = transitive('org.apache.commons:com.springsource.org.apache.commons.pool:jar:1.5.3') # runtime
HSQLDB = transitive('org.hsqldb:com.springsource.org.hsqldb:jar:1.8.0.9') # runtime
HIBERNATE = transitive('org.hibernate:com.springsource.org.hibernate:jar:3.3.2.GA')
JAVAX_PERSISTENCE = transitive('javax.persistence:com.springsource.javax.persistence:jar:1.0.0')
TOPLINK = transitive('com.oracle.toplink.essentials:com.springsource.oracle.toplink.essentials:jar:2.0.0.b41-beta2')
HIBERNATE_EJB = transitive('org.hibernate:com.springsource.org.hibernate.ejb:jar:3.4.0.GA')
HIBERNATE_ANNOTATIONS = transitive('org.hibernate:com.springsource.org.hibernate.annotations:jar:3.4.0.GA')
OPENJPA = transitive('org.apache.openjpa:com.springsource.org.apache.openjpa:jar:1.1.0')
SERVLET = transitive('javax.servlet:com.springsource.javax.servlet:jar:2.5.0') # provided
SERVLET_JSP = transitive('javax.servlet:com.springsource.javax.servlet.jsp:jar:2.1.0') # provided
JSTL = transitive('javax.servlet:com.springsource.javax.servlet.jsp.jstl:jar:1.2.0')
TAGLIBS = transitive('org.apache.taglibs:com.springsource.org.apache.taglibs.standard:jar:1.1.2')
SYNDICATION = transitive('com.sun.syndication:com.springsource.com.sun.syndication:jar:1.0.0')
JDOM = transitive('org.jdom:com.springsource.org.jdom:jar:1.1.0') # runtime
JAXB = transitive('javax.xml.bind:com.springsource.javax.xml.bind:jar:2.1.7') # provided
MYSQL = 'com.mysql.jdbc:com.springsource.com.mysql.jdbc:jar:5.1.6'
# Testing deps
JUNIT = 'org.junit:com.springsource.org.junit:jar:4.7.0'
SPRING_TEST = transitive('org.springframework:org.springframework.test:jar:3.0.0.RELEASE')
JAVAX_TRX = 'javax.transaction:com.springsource.javax.transaction:jar:1.1.0'

# Build deps
DBDEPLOY = group('dbdeploy-core', 'dbdeploy-ant', :under => 'com.dbdeploy', :version => '3.0M3')
CARGO = transitive(group('cargo-core-uberjar', 'cargo-ant', :under => 'org.codehaus.cargo', :version => '1.2.4'))
#CARGO_ANT = artifact('org.codehaus.cargo:cargo-ant:jar:1.2.4')
#CARGO_UBER = artifact('org.codehaus.cargo:cargo-core-uberjar:jar:1.2.4')

desc 'petclinic'
define 'petclinic' do
  project.group = 'org.springframework.samples'
  project.version = '1.0.0-SNAPSHOT'
  compile.with SPRING, SLF4J_API, ASPECTJ, SERVLET, SYNDICATION, TOPLINK, HIBERNATE
  test.with JUNIT, SPRING_TEST, JAVAX_TRX, SLF4J_CL, SLF4J_LOG4J, DBCP, MYSQL, OPENJPA, HIBERNATE, HIBERNATE_EJB, HIBERNATE_ANNOTATIONS
  package(:war, :id => 'petclinic').libs += artifacts(JAVAX_TRX, SLF4J_CL, SLF4J_LOG4J, DBCP, MYSQL, OPENJPA, HIBERNATE, HIBERNATE_EJB, HIBERNATE_ANNOTATIONS)
  package(:war).libs -= SERVLET

  task 'tomcat_deploy' => :package do
    ant('tomcat') do |ant|
      ant.taskdef :resource => 'cargo.tasks', :classpath => CARGO.join(':')

      ant.cargo(:containerId => 'tomcat6x', :action => 'redeploy', :type => 'remote') { |ant|
        ant.configuration(:type => 'runtime') { |ant|
          ant.property :name => 'cargo.hostname', :value => 'localhost'
          ant.property :name => 'cargo.servlet.port', :value => '8080'
          ant.property :name => 'cargo.remote.username', :value => 'admin'          
          ant.property :name => 'cargo.remote.password', :value => 'admin'
          ant.deployable(:type => 'war', :file => packages.first) { |ant|
            ant.property :name => 'context', :value => 'petclinic'
          }
        }
      }
    end
  end

  task 'dbmigrate' => :artifacts do
    ant('dbmigrate') do |ant|
      ant.taskdef :name => 'dbdeploy', :classname => 'com.dbdeploy.AntTarget', :classpath => artifacts(DBDEPLOY, MYSQL).join(':')
      ant.dbdeploy :driver => "com.mysql.jdbc.Driver", :url => "jdbc:mysql://localhost/petclinic", :userid => 'acaine', :password => 'password', :dir => 'db'
    end
  end

end

#task 'tomcat_deploy' => :package do
#  puts project('petclinic').packages
#  puts 'hi'
#end
