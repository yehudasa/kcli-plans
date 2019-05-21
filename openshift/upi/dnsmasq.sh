yum -y install dnsmasq
echo address=/apps.{{ cluster }}.{{ domain }}/{{ haproxy_ip }} >> /etc/dnsmasq.conf
{% for num in range(0, masters) %}
echo {{ masters_ips[num] }} {{ prefix }}-master-{{ num }} {{ prefix }}-master-{{ num }}.{{ cluster}}.{{ domain }} >> /etc/dnsmasq.conf
echo host-record={{ prefix }}-master-{{ num }}.{{ cluster }}.{{ domain }},etcd-{{ num }}.{{ cluster }}.{{ domain }},{{ masters_ips[num ] }},3600 >> /etc/dnsmasq.conf
echo srv-host=_etcd-server-ssl._tcp.{{ cluster }}.{{ domain }},etcd-{{ num }}.{{ cluster }}.{{ domain }},2380,0,10 >> /etc/dnsmasq.conf
{% endfor %}
systemctl enable dnsmasq
systemctl start dnsmasq
