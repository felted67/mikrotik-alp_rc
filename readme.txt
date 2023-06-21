Information & Theory
mikrotik-alp_rc - Docker-image for Mikrotik®-devices
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
(CloudHostedRouter)-systems on AMD64(x86_64)-hosts (virtual/non-virtual) and also on different
ARM/ARM64-devices (hAP ax2, hAP ax3, RB3011 and others).

Theory of the image
Mainly a docker-image consists of one process, which is running alone in the container on the host-system. This means when this
process has ended, the whole container ends. At this point this image is different. Because of using a very small Linux (Alpine Linux),
it is possible to run the openrc-init-system in the container as the main process. This openrc-process breaks the historical way a
container is meant to run, but gives also to control running tasks inside the container.
So mainly the openrc-(init) -process is running all the time, giving the chance to add several more tasks to the container.
Also it is possible to restart the processes beside openrc running inside the container without killing the complete container itself.
This is the main theory of this image - no magic for far...

Installation of docker-image
First open WinBox® and connect to the device.
Install docker-image to Mikrotik®-device and attach via "New Terminal" and /container shell number=X (where X is the number of container).
There are three arch-versions available:
amd64 => for chr-devices (x86_64)
arm64 => for arm64/aarch64-devices
arm => for arm-devices
If you don't now the number of the container, please type on the console in WInBox®:
/container print - The number of the container is given on the output.
In the previous opened shell of the container in terminal of WinBox® do:
1.) Set root-password: $ passwd root
2.) Run /sbin/first_start.sh to complete configuration of the image.
3.) Assign under IP/Firewall/NAT a DST-NAT-rule to ip of docker-container (defined under /interfaces/veth) and needed port of service in container.

Remarks
Version of image reflects the used LinuxAlpine-version.
Tag -latest is the actual stable running version.
It is useful at the beginning to assign the container a root-directory (Root-Dir) to get a "stable" filesystem for the container.
Using rose-storage-package for filesystem of container may not work if nfs-shares are used. Depending on the service and/or first_run.sh-script
a chown or chmod in the script may not work on nfs-shares.

Disclaimer
Mikrotik®, WInBox®, RouterOS, ROS®, hap x2, hap x3, RB3011 and others are or maybe trademarks or registered names of SIA Mikrotīkls.
This project is not affliated with SIA Mikrotīkls and SIA Mikrotīkls is not responsible for this project. Link: https://mikrotik.com/aboutus
All names, trademarks or other techniques are only used to illustrate ths project.
There is not responsibilty for any faults, errors, defects and so on regarding using this images.
This is a private project and all information stated here are given you as it is and with no responsibilty for any defects, errors and harm using this software
Alpine Linux is copyrighted by the Alpine Linux Development Team with all rights reserved.
Also all names and symbols from Alpine Linux are used for illustration purposes only with no responsibilty
of the Alpine Linux Development Team. Link: https://www.alpinelinux.org/