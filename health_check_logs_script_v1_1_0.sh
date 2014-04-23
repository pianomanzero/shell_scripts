#! /bin/bash
#
# Written by: Darren Schaat
# Created: March 27th 2014
# Disclaimer: This script is provided without any official support from EMC or it's affiliates.
 
# Version 1.0
# Initial Release

# Version 1.0.1
# 1. Added line that grabs the cluster GUID at the beginning of the script
# 2. Improved headers
# 3. Changed some of the headers wording to match wording found in the "docu51782_Isilon-Cluster-Health-Check-Tests.xlsx' file
# 4. Improved formatting

# Version 1.0.2
# 1. Added Color

# Version 1.0.3
# 1. Added separate file for "Cluster Information" not relevant to the Pass/Fail tests of the report doc.
# 2. Added "Cluster Name" information into file 'parsed_health_check_logs.txt'.
# 3. Patch information now only outputs the 'patch-<number>'

# Version 1.0.4
# 1. Removed second file and combined all output back to one file 'parsed_health_check_logs.txt'
# 2. Changed order of output to match Report doc.
# 3. Changed output displayed for "Diagnostic Check" to display all output.
# 4. Added headers to make it easier to differentiate what output belongs to what sections of the Report doc. 

# Version 1.1.0
# Changed version progression
# Minor Bug Fixes:
# 1. Fixed "Cluster Name" where a cluster name containing multiple hyphens in the name would not output correctly.
# 2. Fixed "Check Disk Space" where it would not output percentages >80% as intended. 

# Personal Note:
# The idea behind this script is so you will have everything you need for the health check Report document orginized in one file.
# This will allow information to be found more quickly as we will only need to look in one file rather than several.
# Some of the output can be rather large like the "Interface Configurations" and cannot be avoided.
# Other outputs have been filtered similar to 'tpark' where instead of showing all the healthy drives
# we are only looking for non-healthy drives.

#Echo Script Version

echo " "
echo "Health Check Log Script Version 1.1.0"
sleep 1
echo "Gathering required information"
sleep 1

# "Take only what you need to survive!" - Lonestar
# Start of Cluster Information log parse

#Grabs GUID of cluster from file "celog_events.xml"
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mCluster GUID" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat ../../../celog_events.xml|grep -oE "<guid>[[:alnum:]]{36}"|cut -d '>' -f 2 >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m######################################################" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo -e "\e[1mCluster information" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo -e "\e[93m######################################################" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mCluster Name" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
ls ../../../|grep [[:alnum:]]-[[:digit:]] >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mCluster OneFS Version:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat cluster_onefs_version.txt|head -1 >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mDocument Status of Installed Packages:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat document_status_of_installed_packages.txt|grep -oE "patch-[[:alnum:]]{6}" >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mDocument Node Type Information:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat document_node_type_information.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mDocument Cluster Node Serial Number:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat document_cluster_node_serial_number.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt


echo -e "\e[93m######################################################" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo -e "\e[1mHealth check tests and results" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo -e "\e[93m######################################################" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mCluster OneFS Version:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat cluster_onefs_version.txt|head -1 >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mFree Space on Cluster:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat free_space_on_cluster.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mCheck Disk Space:">> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo "     NOTE: If there is no output then space is <80%" >> ./parsed_health_check_logs.txt
echo "           /dev is always 100% and intentionally excluded" >> ./parsed_health_check_logs.txt
echo -e "           IQ nodes can have root <=95% and this is normal. \e[1mKB Article 89552 \e[94m(https://support.emc.com/kb/89552)" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
cat check_disk_space.txt|grep 7[5-9]%|grep -v /ifs >> ./parsed_health_check_logs.txt
cat check_disk_space.txt|grep 8[0-9]%|grep -v /ifs >> ./parsed_health_check_logs.txt
cat check_disk_space.txt|grep 9[0-9]%|grep -v /ifs >> ./parsed_health_check_logs.txt
cat check_disk_space.txt|grep 1[0-9][0-9]%|grep -v /dev >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mCheck VHS Status:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat check_vhs_status.txt|grep "VHS Size" >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mCheck License Status:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo "     NOTE: Output will only show expired licences" >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
cat check_license_status.txt|egrep -v "Activated|Inactive" >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mCheck Battery Status:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo "     NOTE: If no output then all batteries are reporting as 'Good'" >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
cat check_battery_status.txt|grep -v Good >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mCheck Mirrors on Boot Drives Intact:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo "     NOTE: If no output then all boot mirrors are reporting 'COMPLETE'" >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
cat check_mirrors_on_boot_drives_intact.txt|grep DEGRADED >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mCheck the Status of Boot Drives Alive Electrically:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat check_boot_drive_status_electrically.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mReview Node Firmware Level:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat review_node_firmware_level.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mReview Status of Service Lights:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo "     NOTE: If no output than status of lights are 'off'" >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
cat review_status_of_service_lights.txt|grep -v off >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

# Still not 100% sure this filters correctly
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mDiagnostic Check:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
cat diagnostic_check.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mReview Drive Status:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat review_drive_status.txt|grep -v HEALTHY >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mReview Job Status:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat review_job_status.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mReview Critical Events:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat review_critical_events.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mReview Emergency Events:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat review_emergency_event.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mValidate Date and Time Consistency:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat validate_date_and_time_consistency.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mReview Email Notification Status:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat review_email_notification_status.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mReview Notification List for Events:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat review_notification_list_for_events.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mReview Storage Pool Health:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo "     NOTE: Only valid for OneFS 7.1.X.X and above" >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
cat review_storage_pool_health.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mReview Authentication Provider Status:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat review_authentication_provider_status.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mReview AD Domain:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo "     NOTE: Output will be blank if not joined to AD" >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
cat review_ad_domain.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mValidate SPNs:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat validate_spns.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mValidate SupportIQ Connectivity:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat validate_supportiq_connectivity.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mValidate if SupportIQ and ESRS are both Enabled:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo "     NOTE: Service 'connectemc' is the ESRS service is not found in OneFS versions before 7.1.X.X" >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
cat validate_if_both_supportiq_and_esrs_are_enabled.txt|egrep -i "supportiq|connectemc" >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mReview SMB Logging Level:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo "     NOTE: In OneFS 6.5.X.X and earlier logging level 'error' is the same as 'warning'" >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
cat review_smb_logging_level.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mReview Group Status:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat review_group_status.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mReview Gateway Priorities:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat review_gateway_priorities.txt|grep Priority >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m######################################################" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo -e "\e[1mSupplemental cluster information" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo -e "\e[93m######################################################" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mDocument Interface Configurations:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat document_interface_configuration.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
echo -e "\e[92mDocument Uptime:" >> ./parsed_health_check_logs.txt
echo -e "\e[93m------------------------------------------------------" >> ./parsed_health_check_logs.txt
tput sgr0 >> ./parsed_health_check_logs.txt
cat document_uptime.txt >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt
echo " " >> ./parsed_health_check_logs.txt

# "I always have my coffee when I watch radar, you know that...Everybody knows that!" - Dark Helmet

echo " "
echo "File 'parsed_health_check_logs.txt' has been created in directory:"
pwd
echo " "
tput sgr0
