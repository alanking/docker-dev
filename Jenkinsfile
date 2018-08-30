pipeline {
    agent any
    environment {
        COMPOSE_PROJECT_NAME = 'dev'
        RIT_ENV = 'dev6'
    }
    stages {
        stage('cleanWs') {
            steps {
                cleanWs()
            }
        }
        stage('git clone docker dev') {
            steps {
                slackSend color: "#439FE0", message: "Build Started - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
                git(url: 'https://github.com/MaastrichtUniversity/docker-dev.git', branch: 'jenkins')
            }
        }
        stage('check files') {
            steps {
                sh '''#!/bin/bash
			file="docker-compose.yml"
			if [ -f "$file" ]
			then
			echo "$file found."
			exit 0
			else
			echo "$file not found."
			exit 1
			fi
			'''
            }
        }
        stage('externals pacman') {
            steps {
                //fhml_um_theme_demo
				sh 'docker volume create pacman-fhml_um_theme_demo-data'
				dir('fhml_um_theme_demo'){
					git(url: 'ssh://git@bitbucket.rit.unimaas.nl:7999/ritdev/fhml_um_theme_demo.git',credentialsId: 'SHH-private-key', branch: 'master')
				}
				sh 'docker run -v pacman-fhml_um_theme_demo-data:/data --name helper busybox true'
                sh 'docker cp fhml_um_theme_demo/. helper:/data '
                sh 'docker rm helper'

				//handsontable
				sh 'docker volume create pacman-handsontable-data'
				dir('handsontable'){
                     git(url: 'git@github.com:MaastrichtUniversity/handsontable.git',credentialsId: 'SHH-private-key', branch: 'master')
                }
				sh 'docker run -v pacman-handsontable-data:/data --name helper busybox true'
                sh 'docker cp handsontable/. helper:/data '
                sh 'docker rm helper'
			
				//islandora_ontology_autocomplete
				sh 'docker volume create pacman-islandora_ontology_autocomplete-data'
				dir('islandora_ontology_autocomplete'){
                            git(url: 'git@github.com:MaastrichtUniversity/islandora_ontology_autocomplete.git',credentialsId: 'SHH-private-key', branch: 'master')
                }
				sh 'docker run -v pacman-islandora_ontology_autocomplete-data:/data --name helper busybox true'
                sh 'docker cp islandora_ontology_autocomplete/. helper:/data '
                sh 'docker rm helper'
                
				//islandora_crossref_lookup
				sh 'docker volume create pacman-islandora_crossref_lookup-data'
				dir('islandora_crossref_lookup'){
                            git(url: 'git@github.com:MaastrichtUniversity/islandora_crossref_lookup.git',credentialsId: 'SHH-private-key', branch: 'master')
                }
				sh 'docker run -v pacman-islandora_crossref_lookup-data:/data --name helper busybox true'
                sh 'docker cp islandora_crossref_lookup/. helper:/data '
                sh 'docker rm helper'

				//pacman
				sh 'docker volume create pacman-pacman-data'
				dir('rit-pacman'){
                            git(url: 'git@github.com:MaastrichtUniversity/rit-pacman.git',credentialsId: 'SHH-private-key', branch: 'master')
                }
				sh 'docker run -v pacman-pacman-data:/data --name helper busybox true'
                sh 'docker cp rit-pacman/. helper:/data '
                sh 'docker rm helper'
				
				//rit_landing_page
				sh 'docker volume create pacman-rit_landing_page-data'
				dir('rit_landing_page'){
                            git(url: 'git@github.com:MaastrichtUniversity/rit_landing_page.git',credentialsId: 'SHH-private-key', branch: 'master')
                }
				sh 'docker run -v pacman-rit_landing_page-data:/data --name helper busybox true'
                sh 'docker cp rit_landing_page/. helper:/data '
                sh 'docker rm helper'
				
				//rit_forms
				sh 'docker volume create pacman-rit_forms-data'
				dir('rit_forms'){
                            git(url: 'git@github.com:MaastrichtUniversity/rit_forms.git',credentialsId: 'SHH-private-key', branch: 'master')
                }
				sh 'docker run -v pacman-rit_forms-data:/data --name helper busybox true'
                sh 'docker cp rit_forms/. helper:/data'
                sh 'docker rm helper'
				
				//rit_faker
				sh 'docker volume create pacman-rit_faker-data'
				dir('rit_faker'){
                            git(url: 'git@github.com:MaastrichtUniversity/rit_faker.git',credentialsId: 'SHH-private-key', branch: 'master')
                }
				sh 'docker run -v pacman-rit_faker-data:/data --name helper busybox true'
                sh 'docker cp rit_faker/. helper:/data '
                sh 'docker rm helper'
            }
        }
        stage('externals irods') {
            steps {
                sh 'docker volume create irods-helpers-data'
                sh 'docker volume create irods-microservices-data'
                sh 'docker volume create irods-rules-data'
                dir('rules'){
                    git(url: 'git@github.com:MaastrichtUniversity/irods-ruleset.git',credentialsId: 'SHH-private-key', branch: 'jenkins')
                }
                dir('microservices'){
                    git(url: 'git@github.com:MaastrichtUniversity/irods-microservices.git',credentialsId: 'SHH-private-key', branch: 'master')
                }
                dir('helpers'){
                    git(url: 'git@github.com:MaastrichtUniversity/irods-helper-cmd.git',credentialsId: 'SHH-private-key', branch: 'jenkins')
                }
                sh 'docker run -v irods-helpers-data:/data --name helper busybox true'
                sh 'docker cp helpers/. helper:/data '
                sh 'docker rm helper'

                sh 'docker run -v irods-microservices-data:/data --name helper busybox true'
                sh 'docker cp microservices/. helper:/data '
                sh 'docker rm helper'

                sh 'docker run -v irods-rules-data:/data --name helper busybox true'
                sh 'docker cp rules/. helper:/data '
                sh 'docker rm helper'
            }
        }

        stage('secrets irods') {
            steps {
                withCredentials([file(credentialsId: 'irods.secrets.cfg', variable: 'FILE')]) {
                    sh 'docker volume create irods-secrets-data'
                    sh 'docker run -v irods-secrets-data:/data --name helper busybox true'
                    sh 'docker cp $FILE helper:/data/secrets'
                    sh 'docker rm helper'
                }
            }
        }

        stage('git clone irods-frontend') {
            steps {
                dir('externals'){
                    dir('irods-frontend'){
                        git(url: 'git@github.com:MaastrichtUniversity/irods-frontend.git',credentialsId: 'SHH-private-key', branch: 'master')
                    }
                }
            }
        }
        stage('git clone davrods') {
            steps {
                dir('externals'){
                    dir('rit-davrods'){
                        git(url: 'git@github.com:MaastrichtUniversity/rit-davrods.git',credentialsId: 'SHH-private-key', branch: 'master')
                    }
                }
            }
        }
        stage('git clone metalnx') {
            steps {
                dir('externals'){
                    dir('rit-metalnx-web'){
                        git(url: 'git@github.com:MaastrichtUniversity/rit-metalnx-web.git',credentialsId: 'SHH-private-key', branch: 'master')
                    }
                }
            }
        }
        stage('externals mirthconnect') {
            steps {
                sh 'docker volume create mirthconnect-data'
                dir('channels'){
                    git(url: 'ssh://git@bitbucket.rit.unimaas.nl:7999/mirthc/channels.git',credentialsId: 'SHH-private-key', branch: 'master')
                }
                sh 'docker run -v mirthconnect-data:/data --name helper busybox true'
                sh 'docker cp channels/. helper:/data '
                sh 'docker rm helper'
            }
        }
        stage('git clone crossref-lookup') {
            steps {
                dir('externals'){
                    dir('crossref-lookup'){
                        git(url: 'git@github.com:MaastrichtUniversity/crossref-lookup.git',credentialsId: 'SHH-private-key', branch: 'master')
                    }
                }
            }
        }
        stage('externals crossref-lookup') {
            steps {
                sh 'docker volume create crossref-lookup-data'
                dir('app'){
                    git(url: 'git@github.com:MaastrichtUniversity/crossref-lookup.git',credentialsId: 'SHH-private-key', branch: 'master')
                }
                sh 'docker run -v crossref-lookup-data:/data --name helper busybox true'
                sh 'docker cp app/app/. helper:/data '
                sh 'docker rm helper'
            }
        }
        stage('docker-compose build') {
            steps {
                // new docker compose build? 
               //sh 'docker-compose build --pull --no-cache'
               sh 'docker-compose build'
            }
        }
        stage('docker networks') {
            steps {
                sh '''  if ! docker network inspect corpus_default > /dev/null 2>&1; then
                   docker network create corpus_default
                fi
                 if ! docker network inspect common_default > /dev/null 2>&1; then
                   docker network create common_default
                fi
                if ! docker network inspect oculus_default > /dev/null 2>&1; then
                   docker network create oculus_default
                fi
            '''
            }
        }
        stage('docker-compose up') {
            steps {
                sh 'docker-compose up -d '
				//sh 'docker-compose up '
                sleep(unit: 'MINUTES', time: 10)
            }
        }
        stage('check for exited') {
            steps {
                sh '''#!/bin/bash
			var=$(docker-compose ps | grep Exit)
			echo $var
			var2=$(docker-compose ps)
			echo $var2
			if [ -z "$var" ]
			then
			echo "$var up"
			exit 0
			else
			echo "$var down"
			exit 1
			fi
			'''
            }
        }
		stage('git clone selenium') {
      steps {
        dir('selenium_test'){	
            git(url: 'ssh://git@bitbucket.rit.unimaas.nl:7999/ritdev/selenium_tests.git',credentialsId: 'SHH-private-key', branch: 'docker_dev')
        }
      }
    }
    stage('docker build selenium test') {
      steps {
        dir('selenium_test'){
        sh 'docker build -t selenium_docker_dev_test .'
        }
      }
    }
    stage('docker run selenium test') {
      steps {
        dir('selenium_test'){
            sh "docker volume create selenium-data-${env.JOB_NAME}"
            sh "docker run -e RIT_ENV=${RIT_ENV} --name selenium_docker_dev_test --mount source=selenium-data-${env.JOB_NAME},target=/usr/src/app/test-results selenium_docker_dev_test"
            }
        }
		post {
			always {
				dir('selenium_test'){
				dir('test_results'){ writeFile file:'dummy', text:''
				sh "docker run -v selenium-data-${env.JOB_NAME}:/data --name helper busybox true"
				sh 'docker cp helper:/data .'
				sh 'docker rm helper'
				}
				}
			}
	    }
    }
    }
    post {
        always {
            sh 'docker-compose down'
			sh 'docker rm selenium_docker_dev_test'
            sh '''#!/bin/bash
            set -x
		     if [ "$(docker ps -aq -f status=exited -f name=helper)" ]; then
                # cleanup
                docker rm helper
            fi
                        array=(
"pacman-fhml_um_theme_demo-data"  
"pacman-handsontable-data"    
"pacman-islandora_ontology_autocomplete-data"  
"pacman-islandora_crossref_lookup-data" 
"pacman-pacman-data" 
"pacman-rit_landing_page-data" 
"pacman-rit_forms-data"
"pacman-rit_faker-data" 
"irods-helpers-data" 
"irods-microservices-data" 
"irods-rules-data" 
"mirthconnect-data"
"crossref-lookup-data" 
"irods-secrets-data"
"selenium-data-${env.JOB_NAME}"
)
			for i in "${array[@]}"
			do
				echo "$i\n"
				if [ "$(docker volume ls -f name=\$i)" ]; then
                # cleanup
                docker volume rm $i
            fi
			done
		    '''
		archiveArtifacts artifacts: 'selenium_test/test_results/data/**'
            junit 'selenium_test/test_results/data/*.py.xml'
        }
        success {
            slackSend color: "#00ff04", message: "WAUW amazing :) - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
            echo 'succes'
        }
        failure {
            slackSend color: "#ff0000", message: "Fail better!! - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
            echo 'failure'
        }
    }
}
