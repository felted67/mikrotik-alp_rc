# **Information & Theory**

## mikrotik-alp_rc  - Docker-image for Mikrotik®-devices

This docker-image for Mikrotik®-devices is intended to install inside a container-enabled device.
If your Mikrotik®-device is able to run docker-images mainly depends on the device and the used RouterOS (ROS®).
Versions beginning from 7.5 (roughly) are able to run containers on the device. The current version this image is build for 
is RouterOS 7.10 (at the time this documentation is written). Also container-functionality is current only available for AMD64-,
ARM64- and ARM-architectures/devices. 

First you need to enable the container-feature on your device. Please use the Mikrotik®-documentation for enabling the container-mode.
The documentation can be found here: https://help.mikrotik.com/docs/display/ROS/Container

Also some preliminaries should be kept in mind. First be sure that the system is powerful enough to run a docker-container.
This means that your device must have enough available RAM and disk space (external storage), and also a powerful CPU.
Currently the following CPU-architectures are available for docker-container: ARM, ARM64 and X86_64(AMD64).
For external storage there is the paket "rose-storage" available, this can be used to mount SMB, NFS and iSCSI-devices into 
the Mikrotik®-device. Please keep in mind, that NFS-shares may lack of not allowing "chmod"- and "chown"-commands
on the shares. Also you could use a external-disk (SSD/USB-Stick) as a storage-device.

This image is build using Docker-in-Docker-techniques on a CI/CD-system. The images are tested on several CHR- 
(CloudHostedRouter)-systems on  AMD64(x86_64)-hosts (virtual/non-virtual) and also on different ARM/ARM64-devices 
(hAP ax2, hAP ax3, RB3011 and others).

### Theory of the image    

Mainly a docker-image consists of one process, which is running alone in the container on the host-system. This means when this 
process has ended, the whole container ends. At this point this image is different. Because of using a very small Linux (Alpine Linux), 
it is possible to run the openrc-init-system in the container as the main process. This openrc-process breaks the historical way a 
container is meant to run, but gives also to control running tasks inside the container. 
So mainly the openrc-(init) -process is running all the time, giving the chance to add several more tasks to the container. 
Also it is possible to restart the processes beside openrc running inside the container without killing the complete container itself.
This is the main theory of this image - no magic...

​    



  



