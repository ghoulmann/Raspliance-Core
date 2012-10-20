#installs TKLPatch (SDK from http://turnkeylinux/org)
#Scripted by Rik Goldman from TKL Documentation at http://www.turnkeylinux.org/docs/tklpatch/installation
#RUN AS ROOT
	#from raspian
	#1. sudo passwd root
	#2. enter new root passwd twice
	#3. logout
	#4. Login as root with the new password

#install function
install ()
{
	apt-get update
	DEBIAN_FRONTEND=noninteractive apt-get -y \
        -o DPkg::Options::=--force-confdef \
        -o DPkg::Options::=--force-confold \
        install $@
}

#Install Dependencies
install build-essential \
	make \
	git-core \
	tar \
	gzip

#Get TKLPatch Source
git clone git://github.com/turnkeylinux/tklpatch.git /tmp/tklpatch

#Remember Current Directory


#Make TKLPatch
cd /tmp/tklpatch
make install

#go home
cd ~







