source /opt/stack/devstack/openrc admin olympiakos1925!
   70  env
   71  openstack service list
   72  source /opt/stack/devstack/openrc admin admin
   73  env
   74  openstack network list
   75  openstack image list
   76  openstack flavor list
   77  openstack keypair list
   78  openstack securitygroup list
   79  openstack security group list
   80  openstack region list
   81  openstack tenants list
   82  openstack tenant list
   83  openstack --help | grep tenant
   84  openstack network list
   85  openstack flavor set  m1.tiny --project 1cf7387f701c403d8c497561716b45f4
   86  openstack project list
   87  openstack flavor set  m1.tiny --project 65860745986f4aa2abb2a070f1d08b3b
   88  openstack flavor create custom.small --id auto --ram 256 --disk 5 --vcpus 1
   89  openstack flavor set custom.small --project 65860745986f4aa2abb2a070f1d08b3b
   90  openstack flavor list --private
   91  openstack flavor list
   92  openstack keypair list
   93  openstack network list



   ➜ qemu-img convert -f raw -O qcow2 alpine-standard-3.21.3-x86_64.iso alpine.qcow2




