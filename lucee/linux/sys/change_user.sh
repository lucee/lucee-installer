#!/bin/bash
#
# ----------------------------------------------------------------------------------
# Purpose:	Changes the user that the CFML server runs as and creates custom
#		control script based on that user.
# Author:	Jordan Michaels (jordan@viviotech.net)
# Copyright:	Jordan Michaels, 2010-2018, All rights reserved.
#
# Usage: 	change_user.sh username /path/to/installdir [nobackup] [servicename]
#
#		username must start with a lower-case letter and must be alphanumeric
#		servicename is optional, defaults to lucee_ctl
# ----------------------------------------------------------------------------------
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
# OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ----------------------------------------------------------------------------------

if [[ ! $(id -u) = "0" ]]; then
	echo "Error: This script needs to be run as root.";
	echo "Exiting...";
	exit;
fi

# test user input

# validate username
if [[ -z "$1" ]]; then
	echo "Error: No User Name Specified.";
	echo "";
	echo "Usage: ./change_user.sh username /path/to/installdir [nobackup]";
	exit 1;
elif [[ ! "$1" =~ ^[a-z][a-zA-Z0-9_-]+$ ]]; then  # make sure username is a valid format
	echo "Error: Invalid User Name";
	echo "";
	echo "Rules for User Names:";
	echo "1) User Names must start with a lower-case letter"
	echo "2) User Names must contain only alphanumeric characters, hyphens, or underscores.";
	echo "";
	echo "Usage: ./change_user.sh username /path/to/installdir [nobackup]";
	exit 1;
else
	myUserName=$1;
fi

# validate install dir
if [[ -z "$2" ]]; then
	echo "Error: No Installation Directory Specified.";
	echo "";
	echo "Usage: ./change_user.sh username /path/to/installdir [nobackup]";
	exit 1;
elif [[ ! -d "$2" ]]; then  # make sure it's a directory
	echo "Error: Directory provided does not exist or is not a directory.";
	echo "";
	echo "Usage: ./change_user.sh username /path/to/installdir [nobackup]";
	exit 1;
elif [[ ! -d "$2/tomcat/" ]]; then  # make sure it contains tomcat
	echo "Error: Directory provided doesn't appear to be valid.";
	echo "";
	echo "Usage: ./change_user.sh username /path/to/installdir [nobackup]";
	exit 1;
else
	myInstallDir=$2;
fi

# default service name
myServiceName="lucee_ctl"

# parse optional arguments
myControlNeedsBackup=1
for arg in "$3" "$4"; do
	if [[ "$arg" = "nobackup" ]]; then
		myControlNeedsBackup=0
	elif [[ -n "$arg" && "$arg" != "lucee" ]]; then
		# treat non-empty, non-legacy values as service name
		myServiceName="$arg"
	fi
done

if [[ ${myControlNeedsBackup} -eq 1 ]]; then
	echo "${myServiceName} will be backed up to ${myServiceName}.old";
else
	echo "${myServiceName} will NOT be backed up!";
fi

###################
# begin functions #
###################

# check to see if the user exists
function checkUserExists {
	echo -n "Checking to see if user exists...";
	myUserNeedsCreating=0;
	if id -u "${myUserName}" >/dev/null 2>&1; then
		echo "[FOUND]";
	else
		echo "[NOT FOUND]";
		myUserNeedsCreating=1;
	fi
}

function checkGroupExists {
	echo -n "Checking to see if group exists...";
	myGroupNeedsCreating=0;
	if getent group "${myUserName}" >/dev/null 2>&1; then
		echo "[FOUND]";
	else
		echo "[NOT FOUND]";
		myGroupNeedsCreating=1;
	fi
}

# function to create the new user
function createUserAndGroup {
	echo "Initializing user and group creation process...";
	checkUserExists;
	checkGroupExists;
	if [[ ${myGroupNeedsCreating} -eq 1 ]]; then
		echo -n "Creating Group...";
		groupadd ${myUserName} -r;
		echo "[DONE]";
	fi
	if [[ ${myUserNeedsCreating} -eq 1 ]]; then
		echo -n "Creating User...";
		useradd ${myUserName} -g ${myUserName} -d ${myInstallDir} -s /bin/false -r;
		echo "[DONE]";
	fi
}

function updateInstallDir {
	echo -n "Applying new permissions to Installation Directory...";
	chown -R ${myUserName}:${myUserName} ${myInstallDir};
	echo "[DONE]";
}

function processControlScriptTemplate {
	local template_file="$1"
	local output_file="$2"
	
	# (envsubst would have been simpler, but sed is universally available)
	local -a sed_args=()
	local -a template_vars=("myInstallDir" "myUserName")
	
	for var in "${template_vars[@]}"; do
		local var_value="${!var}"
		# Escape forward slashes for sed
		if [[ "$var" == "myInstallDir" ]]; then
			var_value="${var_value//\//\\/}"
		fi
		sed_args+=("-e" "s/\${${var}}/${var_value}/g")
	done
	
	sed "${sed_args[@]}" "$template_file" > "$output_file"
}

function rebuildControlScript {
	echo "Rebuilding Control Scripts for new User...";
	# backup current control script
	if [[ ${myControlNeedsBackup} -eq 1 && -f "${myInstallDir}/${myServiceName}" ]]; then
		# If we're backing up and file exists, do it
		mv ${myInstallDir}/${myServiceName} ${myInstallDir}/${myServiceName}.old;
	else
		# otherwise, just remove the old file
		rm -f ${myInstallDir}/${myServiceName}
	fi

	# create the control script from easier to maintain separate template
	TomcatControlScript="${myInstallDir}/${myServiceName}";
	local scriptDir="$(dirname "${BASH_SOURCE[0]}")"

	# Process the template to generate the control script
	processControlScriptTemplate "${scriptDir}/lucee_ctl_template" "$TomcatControlScript"

	# make it executable
	chmod 744 $TomcatControlScript;

	# see if there's a control script in the init directory
	if [[ -f /etc/init.d/${myServiceName} ]]; then
		# if there is, copy the new control script over it
		cp -f $TomcatControlScript /etc/init.d/${myServiceName};
	fi
}


#####################
# Run function list #
#####################

createUserAndGroup;
rebuildControlScript;
updateInstallDir;
