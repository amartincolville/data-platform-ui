#!/usr/bin/env bash
##
## Replace project placeholders
##
##
VALID_ENVS="beta qa sandbox dispload prod"
validate_env() { echo ${VALID_ENVS} | grep -F -q -w "$1"; }
## Check this is a different repo than template
REMOTE_REPO=$(git remote get-url origin | cut -d '/' -f2 | cut -d "." -f -1)
if [[ ${REMOTE_REPO} == "new-project-template" ]]; then
	echo "Oh-oh 🙁"
	echo "This repository is intended to be used as a template for other projects, you can not run this script on the template repository."
	echo "Here: https://help.github.com/en/articles/creating-a-repository-from-a-template you can find more info about how to create a repository from a template."
	exit 2
fi

## Check you know what are you doing :)
echo "Hello 👋!"
echo "Let's configure your new project."
echo "Did you read the project README? (y/N)"
read -n 1 README_READ
echo
case ${README_READ} in
	[Yy])
		;;
	*)
		echo
		echo "Oh, please take a look at it before running this script."
		exit 2
		;;
esac

## Project name
echo "First of all, what's the name?"
read PROJECT_NAME
echo "Good choice!"

## Environments
echo "In which environments will it live?"
echo "(Write them separated by a whitespace ie: beta prod)"
read PROJECT_ENVIRONMENTS
for i in ${PROJECT_ENVIRONMENTS}; do
	if ! validate_env ${i}; then
		echo "Sorry, environment ${i} is not valid :("
		echo "Valid environments are: ${VALID_ENVS}"
		exit 2
	fi
done
echo "Perfect, it will run on ${PROJECT_ENVIRONMENTS}"

## Notifications
echo "To which Slack channel do you want to send the build notification messages for ${PROJECT_NAME}?"
read NOTIFICATION_CHANNEL

## Verify info
echo "In summary, we are going to create ${PROJECT_NAME} in ${PROJECT_ENVIRONMENTS}"
echo "The repository name is ${REMOTE_REPO}"
echo "And you want to notify #${NOTIFICATION_CHANNEL} about build updates"
echo "Is that correct? (y/N)"
read -n 1 DO_REPLACEMENT
echo
case ${DO_REPLACEMENT} in
	[Yy])
		;;
	*)
		echo
		echo "Ok, doing nothing :)"
		exit 2
		;;
esac

SPIN_PROJECT_NAME="$(echo "$PROJECT_NAME"| sed 's/-/_/g')"
## Perform the changes
sed -i "s/%%PROJECT_NAME%%/${PROJECT_NAME}/g" ansible/templates/dockerapp.default.j2
sed -i "s/%%PROJECT_NAME%%/${SPIN_PROJECT_NAME}/g" spinnaker/Makefile
sed -i "s/%%PROJECT_NAME%%/${SPIN_PROJECT_NAME}/g" spinnaker/application.json
sed -i "s/%%PROJECT_NAME%%/${PROJECT_NAME}/g" ../Makefile
sed -i "s/%%PROJECT_NAME%%/${PROJECT_NAME}/g" ../Jenkinsfile
sed -i "s/%%NOTIFICATION_CHANNEL%%/${NOTIFICATION_CHANNEL}/g" ../Jenkinsfile
sed -i "s/%%PROJECT_REPO%%/${REMOTE_REPO}/g" ../Jenkinsfile

for i in ${PROJECT_ENVIRONMENTS}; do
	mv spinnaker/${i}.json.tmpl spinnaker/${i}.json
	sed -i "s/%%NOTIFICATION_CHANNEL%%/${NOTIFICATION_CHANNEL}/g" spinnaker/${i}.json
	sed -i "s/%%PROJECT_NAME%%/${SPIN_PROJECT_NAME}/g" spinnaker/${i}.json
done
echo "Updated Jenkinsfile, Makefile and Spinnaker"

## Cleanup
echo "Cleanup"
rm spinnaker/*.tmpl provision.sh ../README.md ../CHECKLIST.md
env_exists() { echo ${PROJECT_ENVIRONMENTS} | grep -F -q -w "$1"; }
for i in ${VALID_ENVS}; do
	if ! env_exists ${i}; then
		sed -i "/${i}/d" spinnaker/Makefile
	fi
done
echo "Done."
echo "Remember to add variables in Consul"
echo "Remember to add secrets in Vault, even a dummy one if none are needed"
echo "Remember to read the documentation about Consul and Vault :D"
echo "https://stuart-team.atlassian.net/wiki/spaces/EN/pages/906985485"
