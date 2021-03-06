#!/bin/sh

# Equip Maven Java Project Manager on CentOS
# Author: Brian Lee <briandl92391@gmail.com>, GitHub Username: brian-dlee
# Licence: MIT
# Component: Apache Maven
# To run, see https://github.com/brian-dlee/centos-equip

function cleanup {
    echo >&2 "! Failed installation, entering cleanup."
    rm -f /apache-maven-${MAVEN_VERSION}-bin.tar.gz 2>/dev/null
    exit 1
}

trap 'cleanup' ERR

MAVEN_MAJOR_VERSION='3'
MAVEN_VERSION=${MAVEN_MAJOR_VERSION}'.3.9'

case ${1} in
	''|3);;
	*)
		echo >&2 "Cannot install the desired version of Apache Maven (${1})"
		exit 2
esac

echo "Installing Apache Maven ${MAVEN_VERSION}."

MAVEN_ARCHIVE='apache-maven-'${MAVEN_VERSION}'-bin.tar.gz'
MAVEN_PREFIX='/usr/local'
MAVEN_INSTALL=${MAVEN_PREFIX}'/src/apache-maven-'${MAVEN_VERSION}

yum install -y -q curl

curl --silent -L http://ftp.wayne.edu/apache/maven/maven-${MAVEN_MAJOR_VERSION}/${MAVEN_VERSION}/binaries/${MAVEN_ARCHIVE} -o ${MAVEN_ARCHIVE}
tar -zxf /${MAVEN_ARCHIVE} -C ${MAVEN_PREFIX}/src
rm -f /${MAVEN_ARCHIVE}

chown -R root:root ${MAVEN_INSTALL}
chmod -R u=rwX,g=rwX,o=rX ${MAVEN_INSTALL}

if [[ ${SELINUX_ENABLED} == 1 ]]; then
	chcon -R -u system_u ${MAVEN_INSTALL}
fi

if [[ -z $JAVA_HOME ]]; then
    export JAVA_HOME=/usr/java/default
fi

cat >/etc/profile.d/maven.sh <<< "export JAVA_HOME=${JAVA_HOME}"

ln -s ${MAVEN_INSTALL}/bin/mvn ${MAVEN_PREFIX}/bin/
ln -s ${MAVEN_INSTALL}/bin/mvnDebug ${MAVEN_PREFIX}/bin/
ln -s ${MAVEN_INSTALL}/bin/mvnyjp ${MAVEN_PREFIX}/bin/

mvn --version
