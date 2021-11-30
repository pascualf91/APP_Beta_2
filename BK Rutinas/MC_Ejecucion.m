%Asigna Direccion de la carpeta de ejecución Python
dir_actual= cd;
dir_ejecucion= strcat(dir_actual, '/Procesamiento Python');
cd (dir_ejecucion);

%Corre Script de ejecución del modelo
system('python Corrida_Escenario_Base.py');

cd(dir_actual);