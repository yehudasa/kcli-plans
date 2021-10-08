mkdir /root/bootstrap
dnf install python3-remoto -y 2>&1 | tee /root/bootstrap/dnf.log
dnf install firewalld -y 2>&1 | tee -a /root/bootstrap/dnf.log
export PATH=/root/bin:$PATH
mkdir /root/bin
{% if ceph_dev_folder is defined %}
  cp /mnt/{{ ceph_dev_folder }}/src/cephadm/cephadm /root/bin/cephadm
{% else %}
  cd /root/bin
  curl --silent --remote-name --location https://raw.githubusercontent.com/ceph/ceph/master/src/cephadm/cephadm
{% endif %}
chmod +x /root/bin/cephadm
mkdir -p /etc/ceph
mon_ip=$(ifconfig eth0  | grep 'inet ' | awk '{ print $2}')
cephadm add-repo --release pacific 2>&1 | tee -a /root/bootstrap/cephadm.log
{% if ceph_dev_folder is defined %}
  cephadm bootstrap --mon-ip $mon_ip --initial-dashboard-password {{ admin_password }} --allow-fqdn-hostname --dashboard-password-noupdate --shared_ceph_folder /mnt/{{ ceph_dev_folder }}
{% else %}
  cephadm bootstrap --mon-ip $mon_ip --initial-dashboard-password {{ admin_password }} --allow-fqdn-hostname --dashboard-password-noupdate
{% endif %}
fsid=$(cat /etc/ceph/ceph.conf | grep fsid | awk '{ print $3}')
{% for number in range(1, nodes) %}
  ssh-copy-id -f -i /etc/ceph/ceph.pub  -o StrictHostKeyChecking=no root@{{ prefix }}-node-0{{ number }}.{{ domain }}
  cephadm shell --fsid $fsid -c /etc/ceph/ceph.conf -k /etc/ceph/ceph.client.admin.keyring ceph orch host add {{ prefix }}-node-0{{ number }}.{{ domain }}
{% endfor %}
{% if nodes > 0 and nodes < 3 %}
  cephadm shell --fsid $fsid -c /etc/ceph/ceph.conf -k /etc/ceph/ceph.client.admin.keyring ceph config set global osd_pool_default_size {{ nodes }}
  cephadm shell --fsid $fsid -c /etc/ceph/ceph.conf -k /etc/ceph/ceph.client.admin.keyring ceph config set global osd_pool_default_min_size {{ nodes }}
{% endif %}
cephadm shell --fsid $fsid -c /etc/ceph/ceph.conf -k /etc/ceph/ceph.client.admin.keyring ceph orch apply osd --all-available-devices
