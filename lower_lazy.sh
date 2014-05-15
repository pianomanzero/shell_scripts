#!/bin/zsh
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# lower_lazy.sh
#
# custom script to gracefully lower the lazy_queue_goal sysctl stats
# customiezd for the ap-filr-cp4 cluster 
# and not for use as written on any other cluster
# :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


isi_for_array -n6-12 -s isi_cache_stats -z

for (( i = 1 ; i < 61 ; i++ ))
do
  echo "Iteration $i"
  let "lin = 60006000 - 83333 * $i"
  let "mds = 1500000 - 20733 * $i"
  let "data = 25000 + 4583 * $i"

  isi_for_array -n6-12 -s sysctl efs.lin.lock.initiator.lazy_queue_goal=$lin
  sleep 5
  isi_for_array -n6-12 -s sysctl efs.ref.initiator.lazy_queue_goal=$lin
  sleep 5
  isi_for_array -n6-12 -s sysctl efs.mds.block_lock.initiator.lazy_queue_goal=$mds
  sleep 5
  isi_for_array -n6-12 -s sysctl efs.bam.datalock.initiator.lazy_queue_goal=$data
  sleep 5
  isi_for_array -n6-12 -s isi_cache_stats
  sleep 10
done

# Uncomment the following lines if these stats need to persist through reboots and upgrades.
# If this script is being used for upgrade prep, do not set the overrides
