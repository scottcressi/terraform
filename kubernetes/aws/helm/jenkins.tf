resource "kubernetes_namespace" "jenkins" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "jenkins"
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "3.1.8"
  namespace  = "jenkins"

  depends_on = [kubernetes_namespace.jenkins]

  values = [<<EOF
rbac:
  create: true
controller:
  JenkinsUrl: http://jenkins-k8s.${var.environment}.${var.zone}.com
  HostName: jenkins-k8s.${var.environment}.${var.zone}.com
  adminPassword: foo
  authorizationStrategy: |-
    <authorizationStrategy class="hudson.security.ProjectMatrixAuthorizationStrategy">
      <permission>hudson.model.Hudson.Administer:admin</permission>
    </authorizationStrategy>
  tag: "2.235.5"
  csrf:
    defaultCrumbIssuer:
      enabled: true
  serviceType: ClusterIP
  ingress:
    hostName: jenkins-k8s.${var.environment}.${var.zone}.com
    enabled: false
    ApiVersion: extensions/v1beta1
    annotations:
      kubernetes.io/ingress.class: nginx
      kubernetes.io/tls-acme: "true"
      nginx.ingress.kubernetes.io/whitelist-source-range: "0.0.0.0"
  installPlugins:
  - kubernetes
  - workflow-job
  - workflow-aggregator
  - credentials-binding
  - git
  - matrix-auth
  - ansicolor
  - prometheus
  - job-dsl
  overwriteJobs: true
  overwriteConfig: true
  numExecutors: 1
  jobs:
    seed: |-
      <?xml version='1.1' encoding='UTF-8'?>
      <project>
        <description></description>
        <keepDependencies>false</keepDependencies>
        <properties/>
        <scm class="hudson.plugins.git.GitSCM" plugin="git@4.3.0">
          <configVersion>2</configVersion>
          <userRemoteConfigs>
            <hudson.plugins.git.UserRemoteConfig>
              <url>https://github.com/${var.jenkinsgithubuser}/jenkins.git</url>
            </hudson.plugins.git.UserRemoteConfig>
          </userRemoteConfigs>
          <branches>
            <hudson.plugins.git.BranchSpec>
              <name>*/master</name>
            </hudson.plugins.git.BranchSpec>
          </branches>
          <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
          <submoduleCfg class="list"/>
          <extensions/>
        </scm>
        <canRoam>true</canRoam>
        <disabled>false</disabled>
        <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
        <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
        <triggers>
          <hudson.triggers.SCMTrigger>
            <spec>* * * * *</spec>
            <ignorePostCommitHooks>false</ignorePostCommitHooks>
          </hudson.triggers.SCMTrigger>
        </triggers>
        <concurrentBuild>false</concurrentBuild>
        <builders>
          <javaposse.jobdsl.plugin.ExecuteDslScripts plugin="job-dsl@1.77">
            <targets>seed.groovy</targets>
            <usingScriptText>false</usingScriptText>
            <sandbox>false</sandbox>
            <ignoreExisting>false</ignoreExisting>
            <ignoreMissingFiles>false</ignoreMissingFiles>
            <failOnMissingPlugin>false</failOnMissingPlugin>
            <failOnSeedCollision>false</failOnSeedCollision>
            <unstableOnDeprecation>false</unstableOnDeprecation>
            <removedJobAction>DELETE</removedJobAction>
            <removedViewAction>DELETE</removedViewAction>
            <removedConfigFilesAction>DELETE</removedConfigFilesAction>
            <lookupStrategy>JENKINS_ROOT</lookupStrategy>
          </javaposse.jobdsl.plugin.ExecuteDslScripts>
        </builders>
        <publishers/>
        <buildWrappers/>
      </project>
EOF
  ]

}
