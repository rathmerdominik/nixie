set -o errexit
set -o nounset
set -o pipefail

opts=$(getopt --options r:m:b:l:c: --longoptions=root:,boot-label:,main-label: --name "$0" -- "$@")

eval set -- "$opts"

root=/mnt
bootlbl=BOOT
mainlbl=main
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

sfdisk --label gpt --quiet -- "$blkdev" <<EOF
,512M,U;
,,L;
EOF

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
