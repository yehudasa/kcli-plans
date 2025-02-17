yum -y install git wget
{% if branch != "master" %}
yum -y install https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.6.9-1.el7.ans.noarch.rpm
{% else %}
yum -y install epel-release
yum -y install ansible python-netaddr
{% endif %}
yum -y install http://download-ib01.fedoraproject.org/pub/epel/testing/7/x86_64/Packages/p/python2-notario-0.0.14-1.el7.noarch.rpm
mkdir /root/ceph-ansible-keys
sed -i "s/#host_key_checking/host_key_checking = True/" /etc/ansible/ansible.cfg
sed -i "s/#log_path/log_path/" /etc/ansible/ansible.cfg
cd /root
git clone https://github.com/ceph/ceph-ansible.git
cd ceph-ansible
git checkout {{ branch }}
cp site.yml.sample site.yml
cp /root/all.yml group_vars
{% if type == 'ovirt' %}
sh /root/ovirt_fix_inventory.sh
rm -rf /root/ovirt_fix_inventory.sh
{% endif %}
ansible-playbook -i /root/inventory site.yml
