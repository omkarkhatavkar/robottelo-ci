echo
echo "========================================"
echo "Satellite and Capsule Server information"
echo "========================================"
echo "Satellite Hostname: ${SATELLITE_SERVER_HOSTNAME}"
echo "Capsule Hostname: ${SERVER_HOSTNAME}"
echo "Credentials: admin/changeme"
echo "========================================"

export INTERFACE="${INTERFACE}"
export SUBNET="${SUBNET}"
export NETMASK="${NETMASK}"
export GATEWAY="${GATEWAY}"

export CAPSULE_FQDN="${CAPSULE_SERVER_HOSTNAME}"
export SATELLITE_FQDN="${SATELLITE_SERVER_HOSTNAME}"

if [[ "${RERUN}" == "false" ]]; then
    fab -t 60 -D -H "root@${SATELLITE_FQDN}" "generate_capsule_certs"
    fab -D -H "root@${CAPSULE_FQDN}" "setup_capsule_firewall"

    if [[ "${PARTITION_DISK}" == "true" ]]; then
        fab -D -H "root@${CAPSULE_FQDN}" "partition_disk"
    fi
fi

# This is the actual stage where in the capsule box is registered,
# capsule package installed and then satellite-installer --scenarios capsule run.
fab -D -H "root@${CAPSULE_FQDN}" "setup_capsule"

# Configures all the needed libvirt stuff for setting up capsule.
if [[ "${PROVISIONING_SETUP}" == "true" ]]; then
    fab -D -H "root@${CAPSULE_FQDN}" "setup_external_capsule"
fi

# Configures all the needed stuff for provisioning on Capsule
wget https://raw.githubusercontent.com/SatelliteQE/robottelo-ci/master/scripts/satellite6-populate-capsule-template.sh

cp satellite6-populate-capsule-template.sh satellite6-populate-capsule.sh
chmod +x satellite6-populate-capsule.sh
