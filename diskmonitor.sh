#CODE
# Default values
THRESHOLD=${1:-80}      # Default threshold = 80%
TARGET_MOUNT=$2         # Optional mount point

echo "Disk Usage Monitoring"
echo "Threshold set to: $THRESHOLD%"
echo "-------------------------------------"

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
    echo "Invalid threshold value. Please provide a number."
    exit 1
fi


if [ -z "$TARGET_MOUNT" ]; then
    DISKS=$(df -h --output=pcent,target -x tmpfs -x devtmpfs | tail -n +2)
else
    DISKS=$(df -h --output=pcent,target -x tmpfs -x devtmpfs | grep " $TARGET_MOUNT$")
fi

# Check if mount exists
if [ -z "$DISKS" ]; then
    echo "No matching disk or mount point found."
    exit 1
fi
ALERT=0

#alt code above

# Process disk usage
while read usage mount; do
    USED=${usage%\%}

    if [ "$USED" -ge "$THRESHOLD" ]; then
        echo "ALERT: Disk usage high on $mount → ${USED}%"
 ALERT=1
    fi
done <<< "$DISKS"


if [ "$ALERT" -eq 0 ]; then    echo "Disk usage is under control."
fi

echo "Disk check complete."
