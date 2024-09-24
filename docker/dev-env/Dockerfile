### VARIABLES USED ###
# BASE_IMAGE (optional, defualts to openkbs/jdk-mvn-py3)
# USER_ID (optional, defaults to 1000)
# GROUP_ID (optional, defaults to 1000)
# HOME (required, work directory)
# VNC_PORT (optional, defaults to 5901)
# NO_VNC_PORT (optional, defaults to 6901)
# WINDOW_MANAGER (optional, defaults to xfce)
# OS_TYPE (required, )
# SCRIPT_DIR (required, )
# VNC_RESOLUTION (optional, defaults to 1180x600)
# VNC_PW (optional, defaults to vncpassword)
# INST_SCRIPTS (required, location in image to put additional install scripts)
# STARTUPDIR (required, )
# JAVA_VERSION (optional, default to 11)

FROM ${BASE_IMAGE:-openkbs/jdk-mvn-py3}

####
ENV USER_ID=${USER_ID:-1000}
ENV GROUP_ID=${GROUP_ID:-1000}

USER 0
WORKDIR ${HOME}

#### -----------------------------------
#### ---- Update apt-get references ----
#### -----------------------------------
RUN sudo apt-get update -y

#### --------------------------------------------------
#### ---- Connection ports for controlling the UI: ----
#### --------------------------------------------------
## Connection ports for controlling the UI:
# VNC port: 5901
# noVNC webport, connect via http://<IP>:6901/?password=vncpassword

ENV DISPLAY=${DISPLAY:-"-1"}

ENV VNC_PORT=${NVC_PORT:-"5901"}
ENV NO_VNC_PORT=${NO_VNC_PORT:-"6901"}

EXPOSE ${VNC_PORT}
EXPOSE ${NO_VNC_PORT}

#### ---------------------------------------
#### ---- Window Manager: xfce or icewm ----
#### ---------------------------------------
ENV WINDOW_MANAGER=${WINDOW_MANAGER:-xfce}

LABEL io.k8s.description="Headless VNC Container with ${WINDOW_MANAGER} window manager, firefox and chromium" \
      io.k8s.display-name="Headless VNC Container based on ${OS_TYPE}" \
      io.openshift.expose-service="${NO_VNC_PORT}:http,${VNC_PORT}:xvnc" \
      io.openshift.tags="vnc, ${OS_TYPE}, ${WINDOW_MANAGER}" \
      io.openshift.non-scalable=true

#### ---------------------
#### ---- VNC / noVNC ----
#### ---------------------

ENV TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=${HOME}/install \
    NO_VNC_HOME=${HOME}/noVNC \
    VNC_COL_DEPTH=24 \
    VNC_VIEW_ONLY=false

#### ---------------------------------
#### ---- Install CA certificates ----
#### ---------------------------------
RUN apt-get install -y ca-certificates
ADD ./certificates /certificates
RUN ${SCRIPT_DIR}/setup_system_certificates.sh

#### ----------------------------------------------------------------
#### ---- VNC Resolution (1280x1024, 1600x1024, 1920x1280, etc.) ----
#### ----------------------------------------------------------------
ENV VNC_RESOLUTION=${VNC_RESOLUTION:-1180X600}

#### ----------------------
#### ---- VNC Password ----
#### ----------------------
ENV VNC_PW=${VNC_PW:-vncpassword}

#### Add all install scripts for further steps
ADD ./src/common/install/ ${INST_SCRIPTS}/
ADD ./src/ubuntu/install/ ${INST_SCRIPTS}/
RUN find ${INST_SCRIPTS} -name '*.sh' -exec chmod a+x {} +

#### Install some common tools
RUN ${INST_SCRIPTS}/tools.sh
ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8'

#### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN ${INST_SCRIPTS}/tigervnc.sh
RUN ${INST_SCRIPTS}/no_vnc.sh

#### Install WINDOW_MANAGER (xfce or icewm) UI
RUN apt-get --fix-missing update
RUN ${INST_SCRIPT}/${WINDOW_MANAGER}_ui.sh
ADD ./src/common/${WINDOW_MANAGER}/ ${HOME}/

#### Configure startup
ADD ./src/common/scripts ${STARTUPDIR}
RUN ${INST_SCRIPTS}/set_user_permission.sh ${STARTUPDIR} ${HOME}

#### Install Firefox browser
RUN apt-get install -y firefox

#### Install XDG Open Utility
RUN apt-get install -y xdg-utils --fix-missing

#### Copy Desktop setup
COPY ./config/Desktop ${HOME}/Desktop

#### Reset owner and permissions
RUN chmod a+x /dockerstartup/vnc_startup.sh && \
    mkdir ${HOME}/.local && \
    chown -R ${USER}:${USER} ${HOME}

#### Fix missing: /host/run/dbus/system_bus_socket
ENV DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
ENV DBUS_SYSTEM_BUS_SOCKET=/host/run/dbus/system_bus_socket
    
#### ---- fixing DBUS connection issue ----
RUN echo "Set disable_coredump false" >> /etc/sudo.conf && \
    sudo apt-get install -y dbus-x11
    
RUN sudo mkdir -p ${DBUS_SYSTEM_BUS_SOCKET} && sudo chmod go+rw ${DBUS_SYSTEM_BUS_SOCKET}
    
#### -----------------------------------
#### ------- OpenJDK Installation ------
#### -----------------------------------
ENV JAVA_VERSION=${JAVA_VERSION:-11}

RUN apt-get update && \
    apt-get install -y locales && \
    rm -rf /var/lib/apt/lists/* && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# A few reasons for installing distribution-provided OpenJDK:
#
#  1. Oracle.  Licensing prevents us from redistributing the official JDK.
#
#  2. Compiling OpenJDK also requires the JDK to be installed, and it gets
#     really hairy.
#
#     For some sample build times, see Debian's buildd logs:
#       https://buildd.debian.org/status/logs.php?pkg=openjdk-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
		bzip2 \
		unzip \
		xz-utils && \
	rm -rf /var/lib/apt/lists/*

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

RUN set -ex; \
	\
# deal with slim variants not having man page directories (which causes "update-alternatives" to fail)
	if [ ! -d /usr/share/man/man1 ]; then \
		mkdir -p /usr/share/man/man1; \
	fi; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
#		openjdk-${JAVA_VERSION}-jdk="$JAVA_DEBIAN_VERSION" \
		openjdk-${JAVA_VERSION}-jdk \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
# update-alternatives so that future installs of other OpenJDK versions don't change /usr/bin/java
	update-alternatives --get-selections | awk -v home="$(readlink -f "$JAVA_HOME")" 'index($3, home) == 1 { $2 = "manual"; print | "update-alternatives --set-selections" }'; \
# ... and verify that it actually worked for one of the alternatives we care about
	update-alternatives --query java | grep -q 'Status: manual'

#### ---- NetBeans ---- ####
############################
RUN wget -c https://dlcdn.apache.org/netbeans/netbeans-installers/22/apache-netbeans_22-1_all.deb
RUN sudo dpkg -i apache-netbeans_22-1_all.deb


###############################
#### ---- VNC Startup ---- ####
###############################

WORKDIR ${HOME}

USER ${USER}

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]

ADD ./wrapper_process.sh $HOME/

# CMD ["--wait"]

## ---- Debug Use ----
#CMD ["/bin/bash"]
CMD "$HOME/wrapper_process.sh"

# (or)
#COPY ./test/say_hello.sh $HOME/
#RUN sudo chmod +x $HOME/say_hello.sh
#CMD "$HOME/say_hello.sh"
