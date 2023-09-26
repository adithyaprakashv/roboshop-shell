#if mysql or mongodb instance-type should be t3.medium , for all others it is t2.micro

for i in "${NAMES[@]}"
do 
	if [[ $i == "mongodb" || $i = "mysql" ]] 
	then
		INSTANCE_TYPE="t3.medium"
	else
		INSTANCE_TYPE="t2.micro"
	fi
    echo "creating $i instances"
	IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID  --instance-type $INSTANCE_TYPE --security-group-ids 
	$SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "created $i instances: $IP_ADDRESS"
done