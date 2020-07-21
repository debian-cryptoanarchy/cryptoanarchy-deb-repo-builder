# Bash library for accessing system lnd
#
# Oficial stable API:
# Currently only lnd_* variables defined in this file are considered stable:
#
# lnd_admin_macaroon_file
# lnd_invoice_macaroon_file
# lnd_readonly_macaroon_file
# lnd_max_macaroon_file - macaroon file with the highest permissions for the current user
# lnd_cert_file
# lnd_grpc_port
# lnd_rest_port
#
# !!! Any other artefacts (e.g. function lnd_get_option) may stop working in any version!!!


test -z "$lnd_network" && lnd_network=mainnet
test -z "$lnd_config_file" && lnd_config_file="/etc/lnd-system-$lnd_network/lnd.conf"

lnd_get_option() {
	grep '^'"$1"'[ \t]*=' "$lnd_config_file" | sed 's/^'"$1"'[ \t]*=[ \t]*//' | tr -d '\n'
}

lnd_admin_macaroon_file="`lnd_get_option adminmacaroonpath`"
lnd_invoice_macaroon_file="`lnd_get_option invoicemacaroonpath`"
lnd_readonly_macaroon_file="`lnd_get_option readonlymacaroonpath`"
lnd_cert_file="`lnd_get_option tlscertpath`"
lnd_grpc_port="`lnd_get_option rpclisten | sed 's/^.*://'`"
lnd_rest_port="`lnd_get_option restlisten | sed 's/^.*://'`"

if [ -r "$lnd_admin_macaroon_file" ];
then
	lnd_max_macaroon_file="$lnd_admin_macaroon_file"
else
	if [ -r "$lnd_invoice_macaroon_file" ];
	then
		lnd_max_macaroon_file="$lnd_invoice_macaroon_file"
	else
		if [ -r "$lnd_readonly_macaroon_file" ];
		then
			lnd_max_macaroon_file="$lnd_readonly_macaroon_file"
		else
			lnd_max_macaroon_file=""
		fi
	fi
fi
