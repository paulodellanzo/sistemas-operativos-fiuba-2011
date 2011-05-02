#!bin/bash -w


#Valor de tiempo que el daemon quedará en estado "durmiendo".
_time_sleep=10
 
DIR="/home/santiago/prueba" ###############directorio de prueba###########
ARCH_AGENCIAS="/home/santiago/Archivos/agencias.mae"
ARCH_RECIBIDOS="/home/santiago/Recibidos"
ARCH_SECUENCIAS="/home/santiago/Archivos/secuencias.aux"

#Buscar si el numero de agencia se encuentra en el archivo "agencias.mae" 
#PRE: incializada la variable AGENCIAS_DIR que contiene la ruta del archivo de agencias.
#POS: retorna 0 si el codigo de agencia está registrado en caso contrario retorna -1.

#PARAM: recibe como parámetro 1-el número de agencia que tiene que encontrar en el archivo de agencias, 
#2-un parametro en el que almacena el resultado

_verificar_agencia () {
	
	#machea numero de agencia pasado como param, 11 digitos para el cuil y una desc.
	local valor=$(grep -c "^$1,[0-9]\{11\},*" $ARCH_AGENCIAS)
	local _EXIT_VALUE=$2
	local _myvalue	

	echo "valor es $valor" ####################
	if [ $valor -eq 1 ] ;	then
		_myvalue=0
		eval $_EXIT_VALUE="'$_myvalue'"
		echo "encontre un match de la agencia\n" ##########################
	else 
		_myvalue=-1
	 	eval $_EXIT_VALUE="'$_myvalue'"
		echo "no encontre un match con la agencia\n" ############################
	fi

}


#Verificar si el numero de secuencia asociado a una agencia es mayor que el numero asociado a la misma, que se
#encuentra en el archivo de agencias.

#PRE:Debe estar creado el archivo "arch_agencias.aux", que tiene el siguiente formato <cod_agencia>,<n_sec>.
#POS:Buscará en el archivo "arch_agencias.aux" por la clave <cod_agencia> y verificará si la secuencia recibida es 
#mayor o menor/igual que la del archivo. En caso de ser mayor actualizará el campo <n_sec> con el valor nuevo de sec 
#y retornará 0, sino retornará -1

#PARAM: recibe como parametros 1-codigo de agencia, 2-numero de secuencia, 3-variable para almacenar el resultado.

_verificar_secuencia () {
	#1-buscar un macheo con alguna agencia, sino encuentro un match la agrego al final
	#2-en caso de que hubiese una coincidencia en el numero de agencia entonces debo verificar que la 
	#secuencia recibida por parámetro sea mayor que la del archivo, sino retornar -1
	#3-si la secuencia es mayor entonces la debo guardar en el archivo. Retorno 0
	local _EXIT_VALUE=$3
	local _old_IFS=$IFS
	local _myvalue=0
	IFS=$'\n'
	
	touch "$ARCH_SECUENCIAS.tmp"
	for _linea in $(cat "$ARCH_SECUENCIAS");  do
		local _valor= $(grep "$1,*" $linea) #ver si estoy en la linea de la agencia pasada por param
		echo "la linea es: $_linea"
		if [ $_valor -eq 0 ];	then 
			#leer awk, tr, sed, cut para parsear oraciones
			#1-parsear la linea en agencia y secuencia
			#2-verificar si la secuencia es mayor
			local _sec=echo ${_linea#*,}
			echo "estoy en el ciclo"
			echo "la line es: $_linea"
			
			if [ $2 -gt $_sec ]; then
				local _linea="$1,$2" #2.1-modificar el valor de linea por el nuevo valor de secuencia
				echo "EL numero de secuencia es mayor" ########################
			else
				_myvalue=-1 #2.2-si secuencia es menor -> error=-1
				echo "El numero de secuencia es menor" #######################
			fi
		fi
		echo $_linea > "$ARCH_SECUENCIAS.tmp"
	done
	
	#rm "$ARHC_SECUENCIAS"
	#mv "$ARCH_SECUENCIAS.tmp" "$ARCH_SECUENCIAS"
	
	eval $_EXIT_VALUE="'$_myvalue'"
	
	IFS=$_old_IFS
}

#Valida el nombre del archivo. Para ello verifica en el nombre del archivo (con el formato <cod_ag>.<sec>)
#si cod_ag es un codigo de agencia del archivo "agencias.mae" y si sec es posterior al ultimo numero
#secuencia recibido, que se encuentra almacenado en el archivo "arch_agencias.aux".

#PRE:creada e inicializada la variable  ARRIDIR con el nombre del directorio donde se colocaran los archivos
#POS:valida el nombre y lo mueve al directorio ./recibidos o ./rechazados según sea el caso 
#Actualiza el arch_agencias.aux con la ultima secuencia recibida. Escribe en el log un mensaje indicando el 
#resultado de la operacion

#PARAM: un String con Nombre de un archivo del directorio ARRIDIR

_validar_archivo () {
	#1-debo parsear el nombre y almacenarlo en 2 variables agencia  y secuencia
	#2-llamo al metodo _verificar_agencia -> agencia
	#3-si _verificar_agencia retorna 0 llamo a verificar secuencia, sino envio un msj en log y salgo del metodo
	#4-llamo a _verificar_secuencia ->agencia,secuencia
	#5-si _verificar_secuencia retorna 0 muevo el archivo a la carpeta de recibidos y hago un log, 
	#sino escribo un log y muevo el archivo a la carpeta de rechazados}
	echo "_validar_archivo"
} 


#Verifica que se hayan recibido nuevos archivos en el directorio ./recibidos y de existir alguno invoca al 
#comando postular.
#PRE:directorio recibidos creado. 
#POS:invoca al comando postular(en el caso de que no este corriendo). Muestra el pid de postular por pantalla.
#En caso de error mandara un mensaje por pantalla.

#PARAM: No tiene

_arch_recibidos () {
if [ $(ls $ARCH_RECIBIDOS | wc -l) -ne 0 ] ; then # si el directorio de recibidos no esta vacio 
	#Aca debo hacer un chequeo de que postular no este corriendo e invocar postular
	echo "El directorio $ARCH_RECIBIDOS no esta vacio"
fi
}


i=0
#Ciclo principal del Daemon

while [  $i -lt 1 ]
do
	_old_IFS=$IFS 
	#IFS=$'\n' #Cambio el separador del sistema	
	
	_numero_agencia=111111
	_RES_OPERACION=24
	_secuencia=23	
	#_verificar_agencia $_numero_agencia _RES_OPERACION 
	_verificar_secuencia $_numero_agencia $_secuencia _RES_OPERACION 
	echo "la salida de la operacion fue $_RES_OPERACION \n"
	
	#for file in $(ls $DIR)
	#do
	#	_validar_archivo $file
	#done
	
	

	#IFS=$_old_IFS #restauro el separador del sistema
	#_arch_recibidos
	
	i=1
	#sleep _time_sleep 
done	

exit 0 
