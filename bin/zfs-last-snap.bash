#!/bin/bash
#   FILE: zfs-last-snap.bash
#    LOC: https://github.com/MynaITLabs/zfs-addons
#   DESC: List first and last snapshot for every zfs filesystem
#   DATE: 2025 08 03, igd
#         2026 04 06, igd, updates to saved files
#   PARM: $1 keyboard to ignore selection of filesystems
#
set -euo pipefail # Fail fast if commands error out

NOW="$( date +%Y%m%d-%H%M%S )"
NOW_DAY="$( date +%Y%m%d )"
#
Z="/usr/local/sbin/zfs"
#
LOG_DIR="/tmp/LOGS"
mkdir -p ${LOG_DIR}
cd ${LOG_DIR}
#
LOG_FILE="${LOG_DIR}/zfs-last-snap-${NOW}.log"
TXT_FILE="${LOG_DIR}/zfs-last-snap-${NOW}.txt"
TMP_FILE="${LOG_DIR}/zfs-last-snap-${NOW}.tmp"
#DEB echo  " # LOG_FILE =${LOG_FILE}"
#
ZFS_LIST="${LOG_DIR}/zfs-list-${NOW_DAY}.txt"
#DEB echo  " # ZFS_LIST =${ZFS_LIST}"
ZFS_LIST_SNAPS="${LOG_DIR}/zfs-list-snaps-${NOW_DAY}.txt"

[[ ! -f "${ZFS_LIST}" ]] && "${Z}" list -H > "${ZFS_LIST}" 2> "${LOG_FILE}"
FS_FILTER="JABBERWOKY"  # anything to ignore, default=ignore nothing

if [[ -n "${1:-}" ]]; then
    FS_FILTER="$1"
fi
FS_LIST=$(awk '{print $1}' "${ZFS_LIST}" | grep -v "${FS_FILTER}")

#prev FS_LIST="$( cat ${ZFS_LIST} | grep -v \"${FS_FILTER}\" | awk '{print$1}' )"

#TODO: OPTION santize ${FS} into filename (put inside for loop)
#    FS_SAFE="${FS//\//-}"
#    SNAPS_FILE="${LOG_DIR}/zfs-snaps-${FS_SAFE}-${NOW}.tmp"
SNAPS_FILE="${LOG_DIR}/zfs-snapshots-FS.txt"
#DEB echo  " # SNAPS_FILE =${SNAPS_FILE}"

date > "${ZFS_LIST_SNAPS}"

#DEB echo "## zfs last snap ## "
#DEB echo " # FS_LIST ${FS_LIST}"

P_F="%-60s %-6s %-40s %-40s\n"
# FUTURE: TODO: add wc -l count to details

printf "${P_F}" "File System" "Count" "Snapshot (First)" "Snapshot (Last)" >> "${TXT_FILE}"

echo "${FS_LIST}" | while read -r FS; do
    [[ -z "${FS}" ]] && continue
    #DEB    echo "# FS : ${FS}"

    if (${Z} list -H -t snapshot -o name -s creation "${FS}" > "${SNAPS_FILE}" 2>> "${LOG_FILE}") ; then
        cat "${SNAPS_FILE}" >> "${ZFS_LIST_SNAPS}"

	# Count snapshot lines safely
        SNAP_COUNT=$(wc -l < "${SNAPS_FILE}")

	if [[ ${SNAP_COUNT} -eq 0 ]]; then
            # TODO: check for no snaps
            printf "${P_F}" "${FS}" "WARNING: No snapshots found" "" >> "${TXT_FILE}"
            echo "WARNING: ${FS} has no snapshots. Suggested command: zfs destroy ${FS}"
        else
            # Extract just the snapshot name (after the @)
            SNAP_FIRST_FULL=$(head -n 1 "${SNAPS_FILE}")
            SNAP_LAST_FULL=$(tail -n 1 "${SNAPS_FILE}")
            
            SNAP_FIRST="${SNAP_FIRST_FULL#*@}"
            SNAP_LAST="${SNAP_LAST_FULL#*@}"

            # TODO: If FIRST and LAST are the same raise warning

            if [[ "${SNAP_FIRST}" == "${SNAP_LAST}" ]]; then
                printf "${P_F}" "${FS}" "${SNAP_FIRST} (ONLY ONE)" "${SNAP_LAST} (ONLY ONE)" >> "${TXT_FILE}"
                echo "NOTICE: ${FS} only has one snapshot (${SNAP_FIRST})." >> "${LOG_FILE}"
            else
                printf "${P_F}" "${FS}" "${SNAP_COUNT}" "${SNAP_FIRST}" "${SNAP_LAST}" >> "${TXT_FILE}"
            fi
        fi
    else
        printf "${P_F}" "${FS}" "ERROR: Could not fetch snaps" "" >> "${TXT_FILE}"
    fi

done

echo "Done! Output saved to: ${TXT_FILE}"

exit
# EOF
# ===============================================================
# NOTES
# ===============================================================

