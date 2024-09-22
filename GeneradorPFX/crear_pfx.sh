#!/bin/bash

# Función para mostrar el menú principal
mostrar_menu() {
    OPCION=$(whiptail --title "Generador de Firma Digital" --menu "Elige una opción" 15 60 4 \
    "1" "Generar nuevo certificado PFX" \
    "2" "Ver detalles del certificado" \
    "3" "Salir" 3>&1 1>&2 2>&3)
    
    case $OPCION in
        1) generar_certificado ;;
        2) ver_certificado ;;
        3) exit 0 ;;
        *) whiptail --msgbox "¡Opción no válida!" 8 45 ;;
    esac
}

# Función para generar el certificado en formato PFX
generar_certificado() {
    # Recolección de información del usuario
    PAIS=$(whiptail --inputbox "Introduce tu código de país (por ejemplo, CO, MX):" 10 60 3>&1 1>&2 2>&3)
    ESTADO=$(whiptail --inputbox "Introduce tu departamento:" 10 60 3>&1 1>&2 2>&3)
    LOCALIDAD=$(whiptail --inputbox "Introduce tu ciudad o municipio:" 10 60 3>&1 1>&2 2>&3)
    ORGANIZACION=$(whiptail --inputbox "Introduce el nombre de tu institución:" 10 60 3>&1 1>&2 2>&3)
    CN=$(whiptail --inputbox "Introduce el Nombre Común (por ejemplo, hospital.com):" 10 60 3>&1 1>&2 2>&3)
    CORREO=$(whiptail --inputbox "Introduce tu correo electrónico:" 10 60 3>&1 1>&2 2>&3)
    CONTRASENA=$(whiptail --passwordbox "Introduce una contraseña para el archivo PFX:" 10 60 3>&1 1>&2 2>&3)
    
    # Generar una clave privada
    openssl genrsa -out clave_privada.key 2048
    
    # Crear un archivo de solicitud de firma de certificado (CSR)
    openssl req -new -key clave_privada.key -out cert.csr \
        -subj "/C=$PAIS/ST=$ESTADO/L=$LOCALIDAD/O=$ORGANIZACION/CN=$CN/emailAddress=$CORREO"
    
    # Crear un certificado autofirmado
    openssl x509 -req -days 365 -in cert.csr -signkey clave_privada.key -out cert.crt

    # Combinar la clave privada y el certificado en un archivo PFX
    openssl pkcs12 -export -out certificado.pfx -inkey clave_privada.key -in cert.crt -password pass:$CONTRASENA
    
    if [ $? -eq 0 ]; then
        whiptail --msgbox "¡El archivo PFX se creó con éxito! Archivo: certificado.pfx" 8 45
    else
        whiptail --msgbox "¡Error al crear el archivo PFX!" 8 45
    fi
    
    mostrar_menu
}

# Función para ver detalles del certificado PFX
ver_certificado() {
    ARCHIVO_CERT=$(whiptail --inputbox "Introduce la ruta al archivo PFX:" 10 60 3>&1 1>&2 2>&3)
    CONTRASENA=$(whiptail --passwordbox "Introduce la contraseña para el archivo PFX:" 10 60 3>&1 1>&2 2>&3)

    # Mostrar los detalles del certificado
    openssl pkcs12 -in "$ARCHIVO_CERT" -noout -info -password pass:$CONTRASENA | whiptail --textbox /dev/stdin 20 70
    
    mostrar_menu
}

# Llamar al menú principal
mostrar_menu
