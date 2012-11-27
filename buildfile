repositories.remote << 'http://repo1.maven.org/maven2'

def spring_repos(repos)
  repos.map { |repo| "http://repository.springsource.com/maven/bundles/#{repo}" }
end

repositories.remote << spring_repos(['release', 'external', 'milestone', 'snapshot'])

SPRING_VERSION = '3.0.0.RELEASE'
SLF4J_VERSION = '1.5.6'
COMPILE_DEPS = artifacts('com.oracle.toplink.essentials:com.springsource.oracle.toplink.essentials:jar:2.0.0.b41-beta2',
                         'com.sun.syndication:com.springsource.com.sun.syndication:jar:1.0.0',
                         'edu.oswego.cs.concurrent:com.springsource.edu.oswego.cs.dl.util.concurrent:jar:1.3.4',
                         'javax.persistence:com.springsource.javax.persistence:jar:1.0.0',
                         'javax.servlet:com.springsource.javax.servlet.jsp.jstl:jar:1.2.0',
                         'net.sourceforge.cglib:com.springsource.net.sf.cglib:jar:2.2.0',
                         'net.sourceforge.serp:com.springsource.serp:jar:1.13.1',
                         'org.antlr:com.springsource.antlr:jar:2.7.6',
                         'org.aopalliance:com.springsource.org.aopalliance:jar:1.0.0',
                         'org.apache.commons:com.springsource.org.apache.commons.collections:jar:3.2.1',
                         'org.apache.commons:com.springsource.org.apache.commons.lang:jar:2.1.0',
                         'org.apache.openjpa:com.springsource.org.apache.openjpa:jar:1.1.0',
                         'org.apache.taglibs:com.springsource.org.apache.taglibs.standard:jar:1.1.2',
                         'org.aspectj:com.springsource.org.aspectj.weaver:jar:1.6.8.RELEASE',
                         'org.dom4j:com.springsource.org.dom4j:jar:1.6.1',
                         'org.hibernate:com.springsource.org.hibernate:jar:3.3.2.GA',
                         'org.hibernate:com.springsource.org.hibernate.annotations:jar:3.4.0.GA',
                         'org.hibernate:com.springsource.org.hibernate.annotations.common:jar:3.3.0.ga',
                         'org.hibernate:com.springsource.org.hibernate.ejb:jar:3.4.0.GA',
                         'org.jboss.javassist:com.springsource.javassist:jar:3.9.0.GA',
                         'org.jboss.util:com.springsource.org.jboss.util:jar:2.0.4.GA',
                         'org.objectweb.asm:com.springsource.org.objectweb.asm:jar:1.5.3',
                         "org.slf4j:com.springsource.slf4j.api:jar:#{SLF4J_VERSION}",
                         "org.springframework:org.springframework.aop:jar:#{SPRING_VERSION}",
                         "org.springframework:org.springframework.asm:jar:#{SPRING_VERSION}",
                         "org.springframework:org.springframework.aspects:jar:#{SPRING_VERSION}",
                         "org.springframework:org.springframework.beans:jar:#{SPRING_VERSION}",
                         "org.springframework:org.springframework.context:jar:#{SPRING_VERSION}",
                         "org.springframework:org.springframework.core:jar:#{SPRING_VERSION}",
                         "org.springframework:org.springframework.expression:jar:#{SPRING_VERSION}",
                         "org.springframework:org.springframework.jdbc:jar:#{SPRING_VERSION}",
                         "org.springframework:org.springframework.orm:jar:#{SPRING_VERSION}",
                         "org.springframework:org.springframework.oxm:jar:#{SPRING_VERSION}",
                         "org.springframework:org.springframework.transaction:jar:#{SPRING_VERSION}",
                         "org.springframework:org.springframework.web:jar:#{SPRING_VERSION}",
                         "org.springframework:org.springframework.web.servlet:jar:#{SPRING_VERSION}")

RUNTIME_DEPS = artifacts('org.hsqldb:com.springsource.org.hsqldb:jar:1.8.0.9',
                         'org.jdom:com.springsource.org.jdom:jar:1.1.0',
                         "org.slf4j:com.springsource.slf4j.log4j:jar:#{SLF4J_VERSION}",
                         "org.slf4j:com.springsource.slf4j.org.apache.commons.logging:jar:#{SLF4J_VERSION}",
                         'org.apache.log4j:com.springsource.org.apache.log4j:jar:1.2.15',
                         'org.apache.commons:com.springsource.org.apache.commons.pool:jar:1.5.3',
                         'org.apache.commons:com.springsource.org.apache.commons.dbcp:jar:1.2.2.osgi',
                         'com.mysql.jdbc:com.springsource.com.mysql.jdbc:jar:5.1.6')

TEST_DEPS = artifacts('javax.transaction:com.springsource.javax.transaction:jar:1.1.0',
                      'org.junit:com.springsource.org.junit:jar:4.7.0',
                      "org.springframework:org.springframework.test:jar:#{SPRING_VERSION}")

PROVIDED_DEPS = artifacts('javax.servlet:com.springsource.javax.servlet:jar:2.5.0',
                          'javax.servlet:com.springsource.javax.servlet.jsp:jar:2.1.0',
                          'javax.xml.bind:com.springsource.javax.xml.bind:jar:2.1.7')


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
  CARGO = transitive(group('cargo-core-uberjar', 'cargo-ant', :under => 'org.codehaus.cargo', :version => '1.2.4'))
  desc 'Deploy the app to Tomcat'
  task :deploy => :package do
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

