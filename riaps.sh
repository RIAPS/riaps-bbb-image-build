#!/bin/bash -e
# RIAPS setup script to be called from inside the chroot
# Called by chroot.sh after intializing the root filesystem

export LC_ALL=C

cd /opt/riaps-install
rcn_start=`date +%s`
echo ">>>>> RCN Execution start time was $rcn_start."
/bin/bash elinux.sh
rcn_end=`date +%s`
diff=`expr $rcn_end - $rcn_start`
echo ">>>>> RCN Execution time was $(($diff/60)) minutes and $(($diff%60)) seconds."
/bin/bash base_bbb_bootstrap.sh
riaps_end=`date +%s`
diff=`expr $riaps_end - $rcn_end`
echo ">>>>> RIAPS Execution time was $(($diff/60)) minutes and $(($diff%60)) seconds."
