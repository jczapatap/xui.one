#!/bin/bash
echo -e "\nChecking that minimal requirements are ok"

# Asegurar la compatibilidad del Sistema Operativo
if [ -f /etc/centos-release ]; then
    inst() {
       rpm -q "$1" &> /dev/null
    } 
    if (inst "centos-stream-repos"); then
        OS="CentOS-Stream"
    else
        OS="CentOs"
    fi    
    VERFULL="$(sed 's/^.*release //;s/ (Fin.*$//' /etc/centos-release)"
    VER="${VERFULL:0:1}"
elif [ -f /etc/fedora-release ]; then
    inst() {
       rpm -q "$1" &> /dev/null
    } 
    OS="Fedora"
    VERFULL="$(sed 's/^.*release //;s/ (Fin.*$//' /etc/fedora-release)"
    VER="${VERFULL:0:2}"
elif [ -f /etc/lsb-release ]; then
    OS="$(grep DISTRIB_ID /etc/lsb-release | sed 's/^.*=//')"
    VER="$(grep DISTRIB_RELEASE /etc/lsb-release | sed 's/^.*=//')"
elif [ -f /etc/os-release ]; then
    OS="$(grep -w ID /etc/os-release | sed 's/^.*=//' | tr -d '"')"
    VER="$(grep -w VERSION_ID /etc/os-release | sed 's/^.*=//' | tr -d '"')"
else
    OS="$(uname -s)"
    VER="$(uname -r)"
fi

ARCH=$(uname -m)
echo "Detected : $OS  $VER  $ARCH"

# Validación de requisitos mínimos (Ubuntu 20.04, 22.04 o 24.04 x86_64)
if [[ "$OS" = "Ubuntu" && ( "$VER" = "20.04" || "$VER" = "22.04" || "$VER" = "24.04" ) && "$ARCH" == "x86_64" ]] ; then
    echo "Ok."
else
    echo "Sorry, this OS is not supported by Xtream UI use online Ubuntu LTS Version."
    echo "Use online actual Ubuntu LTS Version 20.04 22.04 or 24.04."
    exit 1
fi

# Actualizar repositorios e instalar paquetes base necesarios para arrancar el instalador
echo "Installing deployment dependencies..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update >/dev/null 2>&1
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install python3 python3-dev unzip wget >/dev/null 2>&1

# Definir directorio de trabajo principal
cd /root

# --- SECCIÓN ADICIONAL: INSTALACIÓN DE LIBSSL 1.1 ---
echo "Downloading and installing libssl1.1 legacy dependency..."
rm -f libssl1.1_1.1.1f-1ubuntu2_amd64.deb
wget http://de.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
# ----------------------------------------------------

# Limpieza estricta de archivos residuales de ejecuciones previas rotas
rm -f XUI_1.5.13.zip xui.tar.gz xui_trial.tar.gz install.python3
rm -rf XUI_1.5.13/

# Descarga del paquete comprimido principal
echo "Downloading XUI core packages..."
wget https://github.com/amidevous/xui.one/releases/download/test/XUI_1.5.13.zip -O XUI_1.5.13.zip >/dev/null 2>&1

if [ ! -f "XUI_1.5.13.zip" ]; then
    echo "Fatal Error: No se pudo descargar el archivo XUI_1.5.13.zip desde GitHub."
    exit 1
fi

echo "Extracting packages..."
unzip -q XUI_1.5.13.zip >/dev/null 2>&1

# REVISIÓN DE ESTRUCTURA: Si el .zip empaquetó los archivos dentro de un subdirectorio,
# movemos todo a /root para mantener la estructura plana que requiere install.python3
if [ -d "XUI_1.5.13" ]; then
    mv XUI_1.5.13/* /root/ >/dev/null 2>&1
    rm -rf XUI_1.5.13/
fi

# COMPROBACIÓN FINAL DE SEGURIDAD: Si por alguna razón el .zip vino incompleto y falta el .tar.gz
if [ ! -f "xui.tar.gz" ] && [ ! -f "xui_trial.tar.gz" ]; then
    echo "xui.tar.gz no se encontró en la raíz del archivo extraído. Intentando descarga directa de rescate..."
    wget https://github.com/amidevous/xui.one/releases/download/test/xui.tar.gz -O xui.tar.gz >/dev/null 2>&1
fi

# Aseguramos que el script de python final esté actualizado y presente en la ruta correcta
if [ ! -f "install.python3" ]; then
    wget https://raw.githubusercontent.com/amidevous/xui.one/master/install.python3 -O /root/install.python3 >/dev/null 2>&1
fi

# Lanzamiento del asistente de instalación interactivo/Python
if [ -f "/root/install.python3" ]; then
    echo "Launching Python internal installer..."
    python3 /root/install.python3
else
    echo "Fatal Error: El instalador base install.python3 no se encuentra disponible."
    exit 1
fi
