#!/bin/bash

# If we use function instead of this, bash would attempt to allocate the output and run out of memory.
if [ "$1" = "--internal-generate-script" ];
then
	shift
	input="$1"
	shift
	cmd="$1"
	shift

	if [ "$input" = "." ] || [ "$input" = "./" ];
	then
		cd_cmd='cd /home/user/input_directory > /dev/null'
	else
		cd_cmd=''
	fi

	cmd_escaped="`printf "%q" "$cmd"`"

	echo 'helper="`mktemp`"'
	echo 'cat <<EOF > "$helper"'
	echo '#!/bin/bash'
	echo 'tar -x >/dev/null'
	echo "$cd_cmd"

	printf "%q" "$cmd"

	while [ $# -gt 0 ];
	do
		printf " %q" "$1"
		shift
	done

	echo ' >&2 || exit 1'
	echo EOF
	echo 'chmod +x "$helper"'
	echo 'exec "$helper"'

	if [ "$input" = "." ] || [ "$input" = "./" ];
	then
		tar --transform='s/^\./input_directory/' -c .
	else
		tar -c "$input"
	fi

	exit 0
fi

if [ $# -lt 4 ] || [ "$1" = "--help" ];
then
	echo "Usage: $0 INPUT COMMAND [COMMAND_ARGS ...]" >&2
	echo "INPUT - the file or directory that will be copied to dispvm. If it's '.', dispvm will cd into it before running the command".
	echo "COMMAND - command to execute"
	exit 1
fi

vm_name='$dispvm'
while echo "$1" | grep -q '^--';
do
	case "$1" in
		"--vm-name")
			vm_name='$dispvm:'"$2"
			shift
			;;
		"--")
			break
			;;
	esac
	shift
done

service="qubes.VMShell"
case "$vm_name" in '$dispvm'|'$dispvm:'*)
	service="$service+WaitForSession"
esac

input="$1"
shift
cmd="$1"
shift

"$0" --internal-generate-script "$input" "$cmd" "$@" | /usr/lib/qubes/qrexec-client-vm "$vm_name" "$service"
exit $?
