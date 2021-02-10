def label = "worker-${UUID.randomUUID().toString()}"

podTemplate(label: label, containers: [
  containerTemplate(name: 'terraform', image: 'hashicorp/terraform', command: 'cat', ttyEnabled: true)
],
)

{

  node(label) {

    properties([
      parameters([
        string(name: 'channel', defaultValue: '#somechannel', description: 'Slack channel', )
       ])
    ])

    def myRepo = checkout scm
    def gitCommit = myRepo.GIT_COMMIT
    def gitBranch = myRepo.GIT_BRANCH
    def shortGitCommit = "${gitCommit[0..10]}"
    def previousGitCommit = sh(script: "git rev-parse ${gitCommit}~", returnStdout: true)

    //stage('git') {
    //ansiColor('xterm'){
    //  try {
    //    container('git') {
    //        git branch: 'master', credentialsId: 'github', url: 'git@github.com:scottcressi/terraform.git'
    //    }
    //  }
    //  catch (exc) {
    //    println "Failed to test - ${currentBuild.fullDisplayName}"
    //    throw(exc)
    //  }
    //}}

    stage('init') {
    ansiColor('xterm'){
      try {
        container('terraform') {
          sh """
            ls -la
            cd kubernetes/aws/network
            terraform init
            """
        }
      }
      catch (exc) {
        println "Failed to test - ${currentBuild.fullDisplayName}"
        throw(exc)
      }
    }}

    stage('plan') {
    ansiColor('xterm'){
      try {
        container('terraform') {
        withAWS(credentials: 'aws-credentials') {
          sh """
            cd kubernetes/aws/network
            terraform plan -var="environment=dev"
            """
        }
        }
      }
      catch (exc) {
        println "Failed to test - ${currentBuild.fullDisplayName}"
        throw(exc)
      }
    }}

    stage('approval'){
    ansiColor('xterm'){
        script {
            def deploymentDelay = input id: 'Deploy',
                message: 'Deploy to production?',
                submitter: 'test,admin',
                parameters: [
                choice(choices: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24'],
                description: 'Hours to delay deployment?',
                name: 'deploymentDelay')
                ]
            sleep time: deploymentDelay.toInteger(), unit: 'HOURS'
        }
    }}

    stage('deploy') {
    ansiColor('xterm'){
      try {
        container('terraform') {
          sh """
            cd kubernetes/aws/network
            terraform apply # -auto-approve
            """
          slackSend (color: '#439FE0', message: 'hello!', channel: '${params.channel}')
        }
      }
      catch (exc) {
        println "Failed to test - ${currentBuild.fullDisplayName}"
        throw(exc)
      }
    }}

  }
}
