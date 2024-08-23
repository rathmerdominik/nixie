set -o errexit
set -o nounset
set -o pipefail

opts=$(getopt --options r:m:b:l:c:L --longoptions=root:,boot-label:,main-label:,legacy --name "$0" -- "$@")

eval set -- "$opts"

root=/mnt
bootlbl=BOOT
mainlbl=main
firmware=uefi
while true; do
  case "$1" in
  -r | --root)
    root=$2
    shift 2
    ;;
  -b | --boot-label)
    bootlbl=${2^^}
    shift 2
    ;;
  -l | --main-label)
    mainlbl=$2
    shift 2
    ;;
  -L | --legacy)
    firmware=legacy
    shift
    ;;
  --)
    shift
    break
    ;;
  esac
done

if [[ $# != 1 ]]; then
  printf '%s\n' "$0: an argument specifying the block device is required" 1>&2
  exit 1
fi

blkdev=$1

if [[ $firmware == "uefi"]]; then
  sfdisk --label gpt --quiet -- "$blkdev" <<EOF
,512M,U;
,,L;
EOF
elif [[ $firmware == "legacy"]]; then
  sfdisk --label mbr --quiet -- "$blkdev" <<EOF
,512M,83,boot
EOF
fi

parts=()
json=$(sfdisk --json -- "$blkdev")
while IFS= read -r k; do
  parts+=("$(jq --argjson k "$k" --raw-output '.partitiontable.partitions[$k].node' <<<"$json")")
done < <(jq '.partitiontable.partitions | keys[]' <<<"$json")

bootfs="${parts[0]}"
mainblkdev="${parts[1]}"

mkfs.vfat -F 32 -n "$bootlbl" -- "$bootfs" >/dev/null

mkfs.ext4 -q -F -L "$mainlbl" -- "$mainblkdev"
mkdir --parents -- "$root"
mount --options noatime -- "$mainblkdev" "$root"

mkdir -- "$root/boot"
mount -- "$bootfs" "$root/boot"
