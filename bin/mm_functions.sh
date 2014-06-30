# You may want to add those functions to your ~/.bashrc,
# otherwise you can load them for your own shell scripts:
# [ -r /opt/monkeyman/bin/mm_functions.sh ] && . /opt/monkeyman/bin/mm_functions.sh

MM_PATH="/opt/monkeyman"
MM_VMINFO="${MM_PATH}/bin/vminfo.pl"

mm_vm_find()	{ "${MM_VMINFO}" --conditions "${@}" --short --short --xpath "/listvirtualmachinesresponse/virtualmachine/hostname/text()" --xpath "/listvirtualmachinesresponse/virtualmachine/instancename/text()"; }
mm_vm_info()    { "${MM_VMINFO}" --conditions "${@}"; }
mm_vm_whereis() { local A=($(mm_vm_find "${@}")); [ "${#A[@]}" -eq 2 ] && echo "The VM you're looking for is ${A[1]} at ${A[0]}"; }
mm_vm_dumpxml() { local A=($(mm_vm_find "${@}")); [ "${#A[@]}" -eq 2 ] && ssh "${A[0]}" virsh dumpxml "${A[1]}"; }
mm_vm_tcpdump() { local A=($(mm_vm_find "${@}")); [ "${#A[@]}" -eq 2 ] && (shift 2; ssh "${A[0]}" "tcpdump -l -i \$(virsh dumpxml ${A[1]} | xpath \"string(/domain/devices/interface[@type='bridge']/target/@dev)\" 2>/dev/null)";); }
mm_vm_reset()   { local A=($(mm_vm_find "${@}")); [ "${#A[@]}" -eq 2 ] && ssh "${A[0]}" virsh reset "${A[1]}"; }
