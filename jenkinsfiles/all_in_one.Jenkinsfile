import groovy.json.JsonSlurper
def replace_ami(packerJSON) {
    // Assuming all is well, replace the old AMI with
    // the new one.
    def packerBuild = new JsonSlurper().parseText(packerJSON)
    def new_ami = packerBuild.builds.last().artifact_id.split(':')[1]
    if (new_ami.startsWith("ami-")) {
        Jenkins.instance.clouds.each {
            if (it.displayName == 'AWS') {
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
    } else {
        println("Could not ascertain the new AMI")
        println("output was: $new_ami")
        assert false : "new ami not found"
    }
    Jenkins.instance.save()
}
pipeline {
   agent { label 'packer' }
   parameters {
       string(name: 'EC2_PLUGIN_AMI', defaultValue: 'linux-workers', description: 'Which EC2 Plugin AMI are we updating?')
       string(name: 'NEW_AMI_NAME', defaultValue: 'templater', description: 'What is the beginning of the name of the ami we are about to build?')
       string(name: 'ORIGINAL_AMI_NAME', defaultValue: 'templater', description: 'What is the beginning of the name of the ami to build from?')
   }
   environment {
       AWS_MAX_ATTEMPTS = 450
       AWS_DEFAULT_REGION = 'eu-west-1'

   }
   stages {
      stage('Setup Packer and build files') {
         steps {
            sh """
            export 
            sudo yum install -y wget python-pip tree
            curl https://releases.hashicorp.com/packer/1.6.5/packer_1.6.5_linux_amd64.zip -o packer_1.6.5_linux_amd64.zip
            unzip -o packer_1.6.5_linux_amd64.zip
            chmod 755 packer
            sudo pip install boto3
            sudo curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec
             """

            sh "./packer validate -var=\"create_ami_name=${params.NEW_AMI_NAME}\" -var=\"original_ami_name=${params.ORIGINAL_AMI_NAME}\" packer.pkr.hcl"
         }
      }
      stage('Packer Build') {
        steps {
            sh "./packer build -var=\"create_ami_name=${params.AMI_NAME}\" -var=\"original_ami_name=${params.ORIGINAL_AMI_NAME}\" packer.pkr.hcl"
            stash name: 'packer_output', includes: 'manifest.json'
            }
         }
      stage('Update Jenkins') {
          steps {
            unstash 'packer_output'
            script {
            packerLog = readFile('manifest.json')
            replace_ami(packerLog)
            }
          }
      }
      stage('Cleanup old AMI\'s') {
        steps {
            sh """
            export CREATE_AMI_NAME=${params.CREATE_AMI_NAME}
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
