# Access Virtual Container Host Log Bundles #

Virtual container hosts (VCHs) provide log bundles that you can download from the VCH Admin portal. To aid in troubleshooting errors, you can access and download different log bundles with container logs. 

It is recommended that you collect the log bundles with container logs and no just the different log bundles unless unable to do so or otherwise instructed.

- [Collecting Log Bundles](#collect-logs)
- [Viewing Logs Live](#live-logs)
- [Collecting Logs Manually](#manual)
- [Setting the Log Size Cap](#log-size-cap)
- [Troubleshooting VCH Creation Errors](#troubleshooting)

## Collecting Log Bundles <a id="collect-logs"></a>

1. Access the VCH Admin Portal at https://<i>vch_address</i>:2378. For more information about the VCH Admin portal, see [VCH Administration Portal](access_vicadmin.md).
2. Depending on the error you are troubleshooting, you can download the following log bundles:

	a. **Log Bundle** contains logs that relate specifically to the VCH that you created. 

	b. **Log Bundle with container logs** contains the logs for the VCH and also includes the logs regarding the containers that the VCH manages.

	**NOTE**: If the VCH is unable to connect to vSphere, logs that require a vSphere connection are disabled, and you see an error message. For information about accessing logs manually, see [Collecting Logs Manually](#manual) below.
3. Leave the browser open for the log bundle to download to the browser once the collection has finished.

## Viewing Live Logs <a id="live-logs"></a> 

See the Live logs (tail files) to view the current status of how components are running. Live logs can help you to see information about current commands and changes as you make them. For example, when you are troubleshooting an issue, you can see whether your command worked or failed by looking at the live logs. 

You can view the following live logs:

1. **Docker Personality** is the interface to Docker. When configured with client certificate security, it reports unauthorized access attempts to the Docker server web page. 
	
	The live logs are located in the `https://vch_address:2378/logs/tail/docker-personality.log` file
2. **Port Layer Service** is the interface to vSphere. 

	The live logs are located in the `https://vch_address:2378/logs/tail/port-layer.log` file. 
3. **Initialization & watchdog** reports:
 - Network configuration
 - Component launch status for the other components
 - Reports component failures and restart counts
 	
	At higher debug levels, the component output is duplicated in the log files for those components, so `init.log`  includes a superset of the log data.

	The live logs are located in the `https://vch_address:2378/logs/tail/init.log` file.

  	 **NOTE:** This log file is duplicated on the datastore in a file in the endpoint VM folder named `tether.debug`, to allow the debugging of early stage initialization and network configuration issues.
1. **Admin Server** includes logs for the VCH admin server, may contain processes that failed, and network issues. When configured with client certificate security, it reports unauthorized access attempts to the admin server web page. 

	The live logs are located in the `https://vch_address:2378/logs/tail/vicadmin.log` file.

Optionally, you can share the non-live version of the logs with administrators or VMware Support to help you to resolve issues.

Logs also include the `vic-machine` commands used during VCH deployment to help you resolve issues.

## Collecting Logs Manually <a id="manual"></a>
If the VCH Admin portal is offline, use `vic-machine debug` to enable SSH on the VCH and use `scp -r` to capture the logs from `/var/log/vic/`.

## Setting the Log Size Cap <a id="log-size-cap"></a>
The log size cap is set at 20MB. If the size exceeds 20 MB, vSphere Integrated Containers Engine compresses the files and saves a history of the last two rotations. The following files are rotated:

`/var/log/vic/port-layer.log` <br>
`/var/log/vic/init.log` <br>
`/var/log/vic/docker-personality.log` <br>
`/var/log/vic/vicadmin.log`

vSphere Integrated Containers Engine logs any errors that occur during log rotation.

## Troubleshooting VCH Creation Errors <a id="troubleshooting"></a>##

During a creation of a VCH, a log file named `vic-machine_<timestamp>_create_<id>.log` populates. You can find that file on the target datastore in a folder with the same name as the VCH that you specified for the `vic-machine create` command. 