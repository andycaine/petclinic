repositories.remote << 'http://repo1.maven.org/maven2'

def spring_repos(repos)
  repos.map { | repo | "http://repository.springsource.com/maven/bundles/#{repo}" }
end
repositories.remote << spring_repos(['release', 'external', 'milestone', 'snapshot'])

def compile_deps
  transitive(%w(context orm oxm web.servlet aspects).map { |m| "org.springframework:org.springframework.#{m}:jar:3.0.0.RELEASE" }, 
             'org.aspectj:com.springsource.org.aspectj.weaver:jar:1.6.8.RELEASE',
             'org.slf4j:com.springsource.slf4j.api:jar:1.5.6',
             'org.hibernate:com.springsource.org.hibernate:jar:3.3.2.GA',
             'org.hibernate:com.springsource.org.hibernate.ejb:jar:3.4.0.GA',
             'org.hibernate:com.springsource.org.hibernate.annotations:jar:3.4.0.GA',
             'javax.persistence:com.springsource.javax.persistence:jar:1.0.0',
             'com.oracle.toplink.essentials:com.springsource.oracle.toplink.essentials:jar:2.0.0.b41-beta2',
             'org.apache.openjpa:com.springsource.org.apache.openjpa:jar:1.1.0',
             'javax.servlet:com.springsource.javax.servlet.jsp.jstl:jar:1.2.0',
             'org.apache.taglibs:com.springsource.org.apache.taglibs.standard:jar:1.1.2',
             'com.sun.syndication:com.springsource.com.sun.syndication:jar:1.0.0')
end

def provided_deps
  transitive('javax.servlet:com.springsource.javax.servlet:jar:2.5.0',
             'javax.servlet:com.springsource.javax.servlet.jsp:jar:2.1.0')
end

def runtime_deps
  transitive('org.slf4j:com.springsource.slf4j.org.apache.commons.logging:jar:1.5.6',
             'org.slf4j:com.springsource.slf4j.log4j:jar:1.5.6',
             'org.apache.log4j:com.springsource.org.apache.log4j:jar:1.2.15',
             'org.apache.commons:com.springsource.org.apache.commons.dbcp:jar:1.2.2.osgi',
             'org.apache.commons:com.springsource.org.apache.commons.pool:jar:1.5.3',
             'org.hsqldb:com.springsource.org.hsqldb:jar:1.8.0.9',
             'com.mysql.jdbc:com.springsource.com.mysql.jdbc:jar:5.1.6', 
             'org.jdom:com.springsource.org.jdom:jar:1.1.0', 
             'javax.transaction:com.springsource.javax.transaction:jar:1.1.0')
end

def test_deps
  transitive('org.junit:com.springsource.org.junit:jar:4.7.0',
             'org.springframework:org.springframework.test:jar:3.0.0.RELEASE')
end

SPRING = transitive(%w(context orm oxm web.servlet aspects).map { |m| "org.springframework:org.springframework.#{m}:jar:3.0.0.RELEASE" })
ASPECTJ = artifacts('org.aspectj:com.springsource.org.aspectj.weaver:jar:1.6.8.RELEASE')
SLF4J_API = artifacts('org.slf4j:com.springsource.slf4j.api:jar:1.5.6')
HIBERNATE = artifacts('org.hibernate:com.springsource.org.hibernate:jar:3.3.2.GA')
JAVAX_PERSISTENCE = artifacts('javax.persistence:com.springsource.javax.persistence:jar:1.0.0')
TOPLINK = artifacts('com.oracle.toplink.essentials:com.springsource.oracle.toplink.essentials:jar:2.0.0.b41-beta2')
HIBERNATE_EJB = artifacts('org.hibernate:com.springsource.org.hibernate.ejb:jar:3.4.0.GA')
HIBERNATE_ANNOTATIONS = transitive('org.hibernate:com.springsource.org.hibernate.annotations:jar:3.4.0.GA')
OPENJPA = transitive('org.apache.openjpa:com.springsource.org.apache.openjpa:jar:1.1.0')
JSTL = artifact('javax.servlet:com.springsource.javax.servlet.jsp.jstl:jar:1.2.0')
TAGLIBS = artifact('org.apache.taglibs:com.springsource.org.apache.taglibs.standard:jar:1.1.2')
SYNDICATION = artifact('com.sun.syndication:com.springsource.com.sun.syndication:jar:1.0.0')


SLF4J_CL = artifact('org.slf4j:com.springsource.slf4j.org.apache.commons.logging:jar:1.5.6') # runtime
SLF4J_LOG4J = artifact('org.slf4j:com.springsource.slf4j.log4j:jar:1.5.6') # runtime
LOG4J = artifact('org.apache.log4j:com.springsource.org.apache.log4j:jar:1.2.15') # runtime
DBCP = artifact('org.apache.commons:com.springsource.org.apache.commons.dbcp:jar:1.2.2.osgi') # runtime
COMMONS_POOL = artifact('org.apache.commons:com.springsource.org.apache.commons.pool:jar:1.5.3') # runtime
HSQLDB = artifact('org.hsqldb:com.springsource.org.hsqldb:jar:1.8.0.9') # runtime
JAVAX_TRX = artifact('javax.transaction:com.springsource.javax.transaction:jar:1.1.0')
MYSQL = artifact('com.mysql.jdbc:com.springsource.com.mysql.jdbc:jar:5.1.6')
JDOM = artifact('org.jdom:com.springsource.org.jdom:jar:1.1.0') # runtime

SERVLET = artifact('javax.servlet:com.springsource.javax.servlet:jar:2.5.0') # provided
SERVLET_JSP = artifact('javax.servlet:com.springsource.javax.servlet.jsp:jar:2.1.0') # provided

# Testing deps
JUNIT = artifact('org.junit:com.springsource.org.junit:jar:4.7.0')
SPRING_TEST = artifact('org.springframework:org.springframework.test:jar:3.0.0.RELEASE')

COMPILE_DEPS = [SPRING, ASPECTJ, SLF4J_API, HIBERNATE, JAVAX_PERSISTENCE, TOPLINK, HIBERNATE_EJB, HIBERNATE_ANNOTATIONS, OPENJPA, JSTL, TAGLIBS, SYNDICATION]
RUNTIME_DEPS = [SLF4J_CL, SLF4J_LOG4J, LOG4J, DBCP, COMMONS_POOL, HSQLDB, JAVAX_TRX, MYSQL, JDOM]
PROVIDED_DEPS = [SERVLET,SERVLET_JSP]
TEST_DEPS = [JUNIT, SPRING_TEST]

desc 'Petclinic'
define 'petclinic' do
  project.group = 'org.springframework.samples'
  project.version = '1.0.0-SNAPSHOT'
  compile.with COMPILE_DEPS + PROVIDED_DEPS
  test.with TEST_DEPS + RUNTIME_DEPS
  package(:war, :id => 'petclinic').libs += RUNTIME_DEPS
  package(:war).libs -= PROVIDED_DEPS
end

namespace :tomcat do
  desc 'Deploy the app to Tomcat'
  task :deploy => :package do
    CARGO = transitive(group('cargo-core-uberjar', 'cargo-ant', :under => 'org.codehaus.cargo', :version => '1.2.4'))
    ant('tomcat') do |ant|
      ant.taskdef :resource => 'cargo.tasks', :classpath => CARGO.join(':')
      
      ant.cargo(:containerId => 'tomcat6x', :action => 'redeploy', :type => 'remote') { |ant|
        ant.configuration(:type => 'runtime') { |ant|
          ant.property :name => 'cargo.hostname', :value => 'localhost'
          ant.property :name => 'cargo.servlet.port', :value => '8080'
          ant.property :name => 'cargo.remote.username', :value => 'admin'
          ant.property :name => 'cargo.remote.password', :value => 'admin'
          ant.deployable(:type => 'war', :file => project(:petclinic).packages.first) { |ant|
            ant.property :name => 'context', :value => 'petclinic'
          }
        }
      }
    end
  end
end

task :test => ['db:populate', 'db:migrate']

