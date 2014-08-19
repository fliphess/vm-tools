	if [ "${BASE_IMAGE}" == "base-agent1.c1" ] ; then
		SRV="agent1.c1"
		MAC="00:16:3e:00:09:0c"
		IMAGE="image-wheezy.img"

	elif [ "${BASE_IMAGE}" == "base-nagios666.c1" ] ; then
		SRV="nagios666.c1"
	        MAC="00:16:3e:00:06:5e"
	        IMAGE="nagios666.c1.img"

	elif [ "${BASE_IMAGE}" == "base-web1.c79" ] ; then
		SRV="web1.c79"
	        MAC="00:16:3e:00:0a:00"
	        IMAGE="web1.c79.img"

	elif [ "${BASE_IMAGE}" == "base-web2.c79" ] ; then
		SRV="web2.c79"
	        MAC="00:16:3e:00:0a:02"
	        IMAGE="web2.c79.img"

	elif [ "${BASE_IMAGE}" == "base-puppet-ca1.c1" ] ; then
		SRV="puppet-ca1.c1"
	        MAC="00:16:3e:00:09:a4"
	        IMAGE="puppet-ca1.c1.img"

	elif [ "${BASE_IMAGE}" == "base-puppetmaster1.c1" ] ; then
		SRV="puppetmaster1.c1"
	        MAC="00:16:3e:00:09:9f"
	        IMAGE="puppetmaster1.c1.img"

	else 
		echo "No settings found for image $BASE_IMAGE"
		exit 1
	fi

	VM_SETTINGS=( "${SRV}" "${MAC}" "${IMAGE}" )
