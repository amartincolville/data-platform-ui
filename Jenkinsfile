#!groovy
@Library('stuart-jenkins-pipelines') _

pipeline {
    agent any
    environment {
        slackNotificationChannel = "%%NOTIFICATION_CHANNEL%%"
    }

    options {
        buildDiscarder(logRotator(daysToKeepStr: '20', numToKeepStr: '100'))
        timestamps()
        timeout(time: 3, unit: 'HOURS')
        ansiColor('xterm')
    }

    stages {
        stage('Abort previous build if running') {
            steps {
                script {
                    common.abortPreviousRunningBuilds()
                }
            }
        }

        stage('Prepare environment') {
            steps {
                script {
                    jobName = env.JOB_NAME - "/${env.GIT_BRANCH}"

                    developBranch = "develop"
                    masterBranch = "master"

                    projectRepo = "%%PROJECT_REPO%%"
                    projectName = "%%PROJECT_NAME%%"

                    dockerRegistry = (env.GIT_BRANCH in [masterBranch, developBranch]) ? "${DOCKER_REGISTRY}" : "${DOCKER_REGISTRY_DEV}"
                    dockerImageName = "${projectRepo}/${projectName}"

                    gitRevisionShort = env.GIT_COMMIT.take(7)
                    IMAGE_NAME_NO_VERSION = "${dockerRegistry}/${dockerImageName}"
                    IMAGE_NAME = "${IMAGE_NAME_NO_VERSION}:${gitRevisionShort}"

                 }
            }
        }

        stage('Build docker image') {
            environment {
                IMAGE_NAME = "${IMAGE_NAME}"
            }
            steps {
                script {
                    log.info 'Building docker image...'
                    try {
                        lastCompletedBuildShortCommit = getLastCompletedBuildCommit(jobName, env.GIT_URL, env.GIT_BRANCH).take(7)
                        dockerPull("${IMAGE_NAME_NO_VERSION}:${lastCompletedBuildShortCommit}")
                        env.CACHE_FROM = "${IMAGE_NAME_NO_VERSION}:${lastCompletedBuildShortCommit}"
                    } catch (e) {
                        log.info "There was an error ${e}"
                    }
                    safeRun "make build"
                    dockerPush(IMAGE_NAME, true, true) // With debug (image: IMAGE_NAME, stream: true, debug: true)
                }
            }
        }

        stage('Images and artifacts') {
            when {
                anyOf {
                    branch masterBranch;
                    branch developBranch
                    }
            }
            steps{
                script {
                    try {
                        log.info("Pushing image to registry..")
                        dockerTagAndPush(IMAGE_NAME, "${IMAGE_NAME_NO_VERSION}:${env.GIT_BRANCH}")
                    } catch (e) {
                        log.info "There was an error pushing docker images ${e}"
                    }
                    withCredentials([
                        [ $class: 'UsernamePasswordMultiBinding',
                        credentialsId: 'b4146a0c-999d-48ee-8745-0e4d478d7363',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY' ]
                      ]) {
                        bakeImmutableAMI(IMAGE_NAME, projectName)
                        slackNotification("${projectName} AMI built successfully. We will now deploy it with Spinnaker.", slackNotificationChannel, 'green')
                    }
                }
            }
        }
    }


    post {
        always {
            script {
                notifyBuild(currentBuild.result, env.slackNotificationChannel)
            }
        }
    }
}
