lxc launch "$1" "$2" \
    -c security.privileged=true \
    -c security.nesting=true

cat <<EOF | lxc config set "$2"
raw.lxc -
lxc.apparmor.profile=unconfined
lxc.mount.auto=proc:rw sys:rw
cgroup:rw
lxc.cgroup.devices.allow=a
lxc.cap.drop=
EOF

lxc exec "$2" -- bash -c 'while [ "$(systemctl is-system-running 2>/dev/null)" != "running" ] && [ "$(systemctl is-system-running 2>/dev/null)" != "degraded" ]; do :; done'

IP=$(lxc-ip "$2")