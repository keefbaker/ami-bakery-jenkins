import groovy.json.JsonSlurper
def replace_ami() {
    // Assuming all is well, replace the old AMI with
    // the new one.
    def new_ami = 'nothing'
    Jenkins.instance.clouds.each {
        // Put the name you gave your ec2plugin cloud here
        if (it.displayName == 'fm') {
            it.getTemplates().each {
                if (it.getDisplayName().toLowerCase().contains("$OLD_PLUGIN".toLowerCase())) {
                new_ami = it.getAmi()
            }
        }
    }
    if (new_ami.startsWith("ami-")) {
        println("iterating through clouds now")
        Jenkins.instance.clouds.each {
            // Put the name you gave your ec2plugin cloud here
            if (it.displayName == 'fm') {
            it.getTemplates().each {
                if (it.getDisplayName().toLowerCase().contains("$EC2_PLUGIN_AMI".toLowerCase())) {
                it.setAmi("$new_ami")
                println("Set AMI in Jenkins to $new_ami")
                } else {
                def failname = it.getDisplayName().toLowerCase()
                println("No match for $EC2_PLUGIN_AMI on $failname")
                    }
                }
            }
        }
    } else {
        println("Could not ascertain the new AMI")
        println("output was: $new_ami")
        assert false : "new ami not found"
    }
    Jenkins.instance.save()
}
pipeline {
   agent { label 'fakenode' }
   parameters {
       string(name: 'EC2_PLUGIN_AMI', defaultValue: 'linux-workers', description: 'Which EC2 Plugin AMI are we updating?')
       string(name: 'OLD_PLUGIN', defaultValue: 'intermediary', description: 'Which contains the correct AMI?')
   }
   environment {
       AWS_MAX_ATTEMPTS = 450
       AWS_DEFAULT_REGION = 'eu-west-1'
   }
   stages {
      stage('Build Test') {
          steps {
            sh '''
            echo "I would run lots of tests here"
            '''
            }
          }
      }
      stage('replace AMI') {
          steps {
              replace_ami()
          }
      }
      stage('Cleanup old AMI\'s') {
        steps {
            sh """
            export CREATE_AMI_NAME=${params.NEW_AMI_NAME}
            python ami_cleanup.py
            """
        }
      }
    }
    post {
        always {
            cleanWs deleteDirs: true, notFailBuild: true
        }
    }
}
