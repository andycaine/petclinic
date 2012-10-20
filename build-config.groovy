

environments {

  local {
    tomcat {
      username = "admin"
      password = "admin"
      host = "localhost"
    }

    db {
      host = "localhost"
      dba {
        username = "root"
        password = "password"
      }

    }
  }

  development {

    tomcat {
      username = "admin"
      password = "admin"
      host = "192.168.33.11"
    }

    db {
      host = "192.168.33.11"
      dba {
        username = "root"
        password = "password"
      }

    }

  }

  test {

    tomcat {
      username = "admin"
      password = "admin"
      host = "192.168.33.12"
    }

    db {
      host = "192.168.33.12"
      dba {
        username = "dba"
        password = "password"
      }

    }
  }

  production {

    tomcat {
      username = "admin"
      password = "admin"
      host = "192.168.33.13"
    }

    db {
      host = "192.168.33.13"
      dba {
        username = "dba"
        password = "password"
      }

    }
  }

}