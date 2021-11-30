%Borra todo lo que se tenga previamente
%clc, clear all, close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Definición de Rutas de Carpetas del Proyecto %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%Carpeta Raíz del Proyecto.
%Se debe especificar a mano
Raiz=cd;
%Raiz= 'Y:\UPV PhD\3. Herramienta Toma Decisiones\1) Modelacion y Visualizacion de Datos\E0) Escenario Base';

%De acá en adelante se deja sin modificar. Sólo se deb modificar la carpeta
%Raíz

%Path de Lectura del Módulo Inicial
Mod_Ini='/Archivos de Entrada/Lectura Modulo Inicial';
P_Mod_Ini=strcat(Raiz,Mod_Ini); 

%Path de Lectura de Archivos de Lluvia
Lluv='/Archivos de Entrada/Lluvia';
P_Mod_LLuv=strcat(Raiz,Lluv); 

%Path de Lectura de Archivo de Evaporación
Evap='/Archivos de Entrada/Evaporacion';
P_Mod_Evap=strcat(Raiz,Evap); 

%Path de Lectura de Parámetros de Infiltración
Infil='/Archivos de Entrada/Infiltracion';
P_Mod_Infil=strcat(Raiz,Infil); 

%Path de Lectura de Parámetros de Calidad
Calid='/Archivos de Entrada/Calidad';
P_Mod_Calid=strcat(Raiz,Calid); 

%Path de Almacenamiento de Archivos de Salida
Salida='/Archivos de Salida';
P_Salida=strcat(Raiz,Salida); 

%Path de Procesamiento de Datos Python
Python='/Procesamiento Python';
P_Python=strcat(Raiz,Python);

%Path de Almacenamiento de Gráficas de Salida
Graficas='/Análisis de Resultados/Gráficas de Salida';
P_Graficas=strcat(Raiz,Graficas);

%Path de Lectura de Parámetros de Infiltración
IDF='/Archivos de Entrada/IDF';
P_Mod_IDF=strcat(Raiz,IDF); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Carga del Módulo Inicial %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Carga en la variable d el archivo con el módulo inicial
%El archivo mepa_read y Cuenca_1 deben estar en la dirección especificada
%en el primer cd
cd(P_Mod_Ini);
d=mepa_read_inp('Cuenca_1.inp');
cd(Raiz);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Opciones de Modelación Definidas por el usuario %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%En caso que haya un error en el cálculo de los diametros, se debe marcar 0
%para no incluir los Diametros Comerciales y dejar sólo los calculados.
incluir_Diam_Comer=0;

%Definir el número de veces que se desea replicar cada módulo en la cuenca
rep=8;

%Calcula el valor del largo de módulo para el área dada
Area_Total=evalin('base', "APP_Area");
Area_Actual=Area_Total/8;
largo=(Area_Actual*10000)^0.5;
ancho=largo;

%Definir la fecha de inicio de la modelación, del reporte y de fin de la 
%modelación
%Fecha en Formato M/D/A
fecha_inicio_dt=evalin('base', "APP_date_time_in");
fechaInicio=datestr(fecha_inicio_dt,'mm/dd/yyyy');
fechaReporte=datestr(fecha_inicio_dt,'mm/dd/yyyy');

fecha_fin_dt=evalin('base', "APP_date_time_fin");
fechaFin=datestr(fecha_fin_dt,'mm/dd/yyyy');

%Definir el paso para el reporte de la modelacion
paso_reporte='00:10:00';

%Asignar el nombre del archivo y el ID de la estación de lluvia. Debe
%coincidir con el nombre y el ID del archivo de texto con la info. de
%lluvia. EL archivo de lluvia debe estar en la dirección especificada
cd(P_Mod_LLuv);
rainID=evalin('base', "APP_ciudad");

rainFile=strcat(rainID,'_SWMM.txt');
cd(Raiz)

%Definir la pendiente lateral y longitudinal de cada subcuenca
%pendiente=1;
pendiente=evalin('base', "APP_PendLat");

pendienteLong=evalin('base', "APP_PendLong");

%Definir el nombre del pluviometro. Debe ser el nombre que viene del archivo
%de lluvia
nombre_Pluviometro='RG1';

%Definir el tipo de suelo de la cuenca para el proceso de infiltración.
%Las opciones son:
%1) Tipo A. Arenas y Gravillas. Elevada capacidad de Infiltracion
%2) Tipo B. Limos y Arenas. Capacidad moderada de Infiltración
%3) Tipo C. Limos Arcillosos o Arenosos. Capacidad diminuida de Infiltración
%4) Tipo D. Arcillosos. Capacidad muy baja de infiltración
suelo_string=evalin('base', "APP_suelo");

if suelo_string(6) == 'A'
    Tipo_Suelo=1;
elseif suelo_string(6) == 'B'
    Tipo_Suelo=2;
elseif suelo_string(6) == 'C'
    Tipo_Suelo=3;
else
    Tipo_Suelo=4;
end

%Definir si desea incluir caudal seco o no

incluir_Q_Seco=evalin('base', "APP_Inc_Q_Seco");
%incluir_Q_Seco = 0;

%Definir la densidad de población que quiere usar en las subcuencas en 
%Habitantes/Hectárea
Den_Pob=500;

%Definir la dotación de agua potable que quiere usar en las subcuencas en 
%L/Hab.Día
Dota_Potable=300;

%Define la concentración media por habitante/día de los contaminantes que
%cuentan con información. Las unidades son g/Hab.Día y se deben diligenciar
%los datos correspondientes a una red unitaria
Aporte_DBO=75;
APorte_SST=90;
Aporte_NT=11.5;
Aporte_FT=2.5;

%Definir los siguientes parámetros de entrada, los cuales serán usados para
%el dimensionamiento de las tuberias
nManning=0.01;
PeriodoRetorno=10;
CEscorrentia=0.8;
Relacion_Llenado=0.8;

%Incluir las ecuaciones de Pendiente, Longitud Principal,Tiempo de 
%Concentración y de la Curva IDF que desea utilizar para calcular la
%Intensidad de la lluvia de diseño. Este ejemplo es de Santander, España.

cd(P_Mod_IDF)
ciudad_cell={rainID};

IDF_Espana=readcell('Resumen_IDF_España.xlsx');
IDF_Colombia=readcell('Resumen_IDF_Colombia.xlsx');

ver_esp=strcmpi(ciudad_cell,IDF_Espana(:,1));

if sum(ver_esp)>0

    for i=1:length(ver_esp)
        if ver_esp(i)==1
            ind=i;
        else
        end
    end
    c1=cell2mat(IDF_Espana(ind,2));
    c2=cell2mat(IDF_Espana(ind,3));
    c3=cell2mat(IDF_Espana(ind,4));

    PendienteManning=pendiente/100;
    LongitudPrincipal=largo*4/1000;
    Tc=0.3*((LongitudPrincipal)/(PendienteManning^0.25))^0.76*60;
    I=c1*PeriodoRetorno^c2*Tc^c3;

else

    ver_col=strcmpi(ciudad_cell,IDF_Colombia(:,1));

    for i=1:length(ver_col)
        if ver_col(i)==1
            ind=i;
        else
        end
    end

C1=cell2mat(IDF_Colombia(ind,2));
x0=cell2mat(IDF_Colombia(ind,3));
C2=cell2mat(IDF_Colombia(ind,4));

PendienteManning=pendiente/100;
LongitudPrincipal=largo*4/1000;
Tc=0.3*((LongitudPrincipal)/(PendienteManning^0.25))^0.76*60;
I=C1/((Tc+x0)^C2);

end

%Definir la totalidad de posibles usos de suelo y los % que tendrá cada uno 
%para la modelación de calidad del agua. En el primer ítem marcar con 1 si 
%se va a incluir y con 0 si no se va a incluir. En el segundo ítem, definir
%el %de cubrimiento que va a tener sobre cada subcuenca

Verde=evalin('base', "APP_Uso_Verde");
%Verde=0;
UsoVerde=evalin('base',"APP_Num_Verde");
%UsoVerde=49;

Urbano=evalin('base', "APP_Uso_Urbano");
%Urbano=0;
UsoUrbano=evalin('base',"APP_Num_Urbano");
%UsoUrbano=51;

General=evalin('base', "APP_Uso_General");
%General=1;
UsoGeneral=evalin('base',"APP_Num_General");
%UsoGeneral=100;

%Definir el porcentaje de impermeabilidad que tendrá la cuenca
Impermeabilidad=evalin('base', "APP_Imper");

%Definir los parametros que desea incluir en la modelación. Se debe marcar
%con 1 si se desea incluir el parametro y con 0 si no se desea incluir. Si
%se va a trabajar con Uso de Suelo General, se pueden incluir todos los
%parametros. Si se va a trabajar con Verde y Urbano, solo se pueden
% seleccionar TSS, NT y FT, pues son los que cuentan con información.
TSS=1;
DBO=0;
DQO=0;
FT=1;
NT=1;
Zn=0;
Pb=0;
Fe=0;

%Definir la ciudad sobre la cual se está trabajando, para la definición de
%los datos de evaporación. Las opciones son:
%1=Badajoz
%2=Barcelona
%3=Bilbao
%4=Coruña
%5=Gran Canaria
%6=Granada
%7=Madrid
%8=Murcia
%9=Palma de Mallorca
%10=Santander
%11=Sevilla
%12=Sevilla
%13=Valencia
%14=Valladolid
%15=Zaragoza
%Ciudad_Evapo=10;


%Definir las profundidades de almacenamiento superficial para zonas
%permeables e impermeables. Se debe definir en mm.
D_Storage_Imp=2.54;
D_Storage_Perm=7.62;

%Definir el Método de Infiltración que quiere usar
%HORTON=1
%Curve Number=2
Metodo_Infil=2;


%%%%%Hasta acá debe definir el usuario las opciones de modelación. De acá
%%%%%en adelante, el programa calcula todo automáticamente %%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Fechas y Pasos de Modelación %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Asigna la fecha de inicio y fin de la modelación y del reporte
d.OPTIONS(8,2)=cellstr(fechaInicio);
d.OPTIONS(10,2)=cellstr(fechaReporte);
d.OPTIONS(12,2)=cellstr(fechaFin);

%Asigna el paso para el reporte de la modelacion
d.OPTIONS(17,2)=cellstr(paso_reporte);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Datos Climatológicos %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Carga la matriz con los datos de evaporación media diaria mensual para
%todas las ciudades.
cd(P_Mod_Evap)
datos_evaporacion_cell=readcell('Resumen_Ciudades.xlsx');
cd(Raiz)

%Asigna los datos de evaporacion seguna la ciudad del analisis
ver_evap=strcmpi(ciudad_cell,datos_evaporacion_cell(1,:));
for i=1:length(ver_evap)
    if ver_evap(i)==1
        ind=i;
    else
    end
end


Datos_Ciudad=cell2mat(datos_evaporacion_cell(2:13,ind));

%Se asignan los valores
for i=1:12
   d.EVAPORATION(1,i+1)= cellstr(num2str(Datos_Ciudad(i,1)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Pluviometro %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Asigna nuevamente las coordenadas del pluviometro
d.SYMBOLS(1,2)=cellstr(num2str(0));
d.SYMBOLS(1,3)=cellstr(num2str(largo*3));

%Cambia el nombre del archivo y el ID de la estación de lluvia
d.RAINGAGES(1,6)=cellstr(rainFile);
d.RAINGAGES(1,7)=cellstr(rainID);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% SUBCUENCAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Redefine la escala del mapa para ajustarlo a las dimensiones de la cuenca
d.MAP(1,4)=cellstr(num2str(largo*5));
d.MAP(1,5)=cellstr(num2str(largo*5));

%Asigna la pendiente de cada subcuenca
for i=1:rep
d.SUBCATCHMENTS(i,7)= cellstr(num2str(pendiente));
end

%Asigna el Pluviometro a todas las subcuencas
d.SUBCATCHMENTS(:,2)= cellstr(nombre_Pluviometro);

%Calcula el área de cuenca y la asigna
area=largo*largo/10000;

for i=1:rep
d.SUBCATCHMENTS(i,4)= cellstr(num2str(area));
d.SUBCATCHMENTS(i,6)= cellstr(num2str(ancho));
end

%Replica la información de la subcuenca, Subareas e Infiltracion el número
%de veces que se indica en rep
for i=2:rep
d.SUBCATCHMENTS(i,:)= d.SUBCATCHMENTS(1,:);
d.SUBAREAS(i,:)= d.SUBAREAS(1,:);
d.INFILTRATION(i,:)= d.INFILTRATION(1,:);
end

%Asigna la profundidad de almacenamiento superficial para subareas
%permeables e impermeables
d.SUBAREAS(:,4)= cellstr(num2str(D_Storage_Imp));
d.SUBAREAS(:,5)= cellstr(num2str(D_Storage_Perm));


%Asigna automáticamente nombre a cada subcuenca creada
for i=2:rep
    nombres(i,1)=i;
end

for i=2:rep
    d.SUBCATCHMENTS(i,1)=cellstr(strcat('A',num2str(nombres(i,1))));
    d.SUBAREAS(i,1)=cellstr(strcat('A',num2str(nombres(i,1))));
    d.INFILTRATION(i,1)=cellstr(strcat('A',num2str(nombres(i,1))));
end

%Asigna la primera columna de nombres a la Hoja de coordenadas de los
%poligonos. Debe haber tantos elseif como sub-cuencas se deseen agregar
for i=1:rep*4
    if i>=1 && i<=4
        d.Polygons(i,1)=cellstr('A1');
        elseif i>=5 && i<=8
        d.Polygons(i,1)=cellstr('A2');
        elseif i>=9 && i<=12
        d.Polygons(i,1)=cellstr('A3');
        elseif i>=13 && i<=16
        d.Polygons(i,1)=cellstr('A4');
        elseif i>=17 && i<=20
        d.Polygons(i,1)=cellstr('A5');
        elseif i>=21 && i<=24
        d.Polygons(i,1)=cellstr('A6');
        elseif i>=25 && i<=28
        d.Polygons(i,1)=cellstr('A7');
    else
        d.Polygons(i,1)=cellstr('A8');
            
    end
end

%Asigna el % de impermeabilidad dependiendo de los indicado en usos de
%suelo por el usuario
for i=1:rep
d.SUBCATCHMENTS(i,5)= cellstr(num2str(Impermeabilidad));
end


%%%%%%%%%%% Asignación de las coordenadas de las subcuencas %%%%%%%%%%%%%%

%%Asigna los valores de la primera fila
for i=1:15
    if i==1
     d.Polygons(i,2)=cellstr(num2str(0));
     d.Polygons(i,3)=cellstr(num2str(0));
     elseif i==2 || i== 5
     d.Polygons(i,2)=cellstr(num2str(largo));
     d.Polygons(i,3)=cellstr(num2str(0));
     elseif i==6 || i==9
     d.Polygons(i,2)=cellstr(num2str(largo*2));
     d.Polygons(i,3)=cellstr(num2str(0));
     elseif i==10 || i==13
     d.Polygons(i,2)=cellstr(num2str(largo*3));
     d.Polygons(i,3)=cellstr(num2str(0));
   elseif i==14
     d.Polygons(i,2)=cellstr(num2str(largo*4));
     d.Polygons(i,3)=cellstr(num2str(0));
   else
   end
end

%%Asigna los valores de la segunda fila
for i=3:30
    if i==4 || i== 17
     d.Polygons(i,2)=cellstr(num2str(0));
     d.Polygons(i,3)=cellstr(num2str(largo));
     elseif i==3 || i== 18 || i==21 || i==8
     d.Polygons(i,2)=cellstr(num2str(largo));
     d.Polygons(i,3)=cellstr(num2str(largo));
     elseif i==7 || i==22 || i==25 || i==12
     d.Polygons(i,2)=cellstr(num2str(largo*2));
     d.Polygons(i,3)=cellstr(num2str(largo));
     elseif i==11 || i==26 || i==29 || i==16
     d.Polygons(i,2)=cellstr(num2str(largo*3));
     d.Polygons(i,3)=cellstr(num2str(largo));
   elseif i==15 || i== 30
     d.Polygons(i,2)=cellstr(num2str(largo*4));
     d.Polygons(i,3)=cellstr(num2str(largo));
   else
   end
end

%%Asigna los valores de la tercera fila
for i=19:32
    if i==20
       d.Polygons(i,2)=cellstr(num2str(0));
       d.Polygons(i,3)=cellstr(num2str(largo*2));
     elseif i==19 || i== 24
     d.Polygons(i,2)=cellstr(num2str(largo));
     d.Polygons(i,3)=cellstr(num2str(largo*2));
     elseif i==23 || i==28
     d.Polygons(i,2)=cellstr(num2str(largo*2));
     d.Polygons(i,3)=cellstr(num2str(largo*2));
     elseif i==27 || i==32
     d.Polygons(i,2)=cellstr(num2str(largo*3));
     d.Polygons(i,3)=cellstr(num2str(largo*2));
   elseif i==31
     d.Polygons(i,2)=cellstr(num2str(largo*4));
     d.Polygons(i,3)=cellstr(num2str(largo*2));
   else
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% INFILTRATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Asigna Parámetros de HORTON
if Metodo_Infil==1;
    
d.OPTIONS(2,2)=cellstr('HORTON');

cd(P_Mod_Infil)
Param_Horton=xlsread('Horton.xlsx');
cd(Raiz)

%Asigna el parametro de presencia de Vegetación a partir de lo definido en
%usos de suelo
if General == 1
    Vegetacion_Infiltracion=0;
else
  if UsoVerde>50
    Vegetacion_Infiltracion=1;
  else
    Vegetacion_Infiltracion=0;    
  end
end

%Asigna los parametros para casos en que el suelo no cuenta con vegetación
if Vegetacion_Infiltracion==0
    
    for i=1:rep
        
        if Tipo_Suelo==1
        d.INFILTRATION(i,2)=cellstr(num2str(Param_Horton(1,1)));
        d.INFILTRATION(i,3)=cellstr(num2str(Param_Horton(3,1)));
        d.INFILTRATION(i,4)=cellstr(num2str(Param_Horton(4,1)));
        d.INFILTRATION(i,5)=cellstr(num2str(Param_Horton(5,1)));
        d.INFILTRATION(i,6)=cellstr(num2str(Param_Horton(6,1)));
        
        elseif Tipo_Suelo==2
        d.INFILTRATION(i,2)=cellstr(num2str(Param_Horton(1,2)));
        d.INFILTRATION(i,3)=cellstr(num2str(Param_Horton(3,2)));
        d.INFILTRATION(i,4)=cellstr(num2str(Param_Horton(4,2)));
        d.INFILTRATION(i,5)=cellstr(num2str(Param_Horton(5,2)));
        d.INFILTRATION(i,6)=cellstr(num2str(Param_Horton(6,2)));
        
        elseif Tipo_Suelo==3
        d.INFILTRATION(i,2)=cellstr(num2str(Param_Horton(1,3)));
        d.INFILTRATION(i,3)=cellstr(num2str(Param_Horton(3,3)));
        d.INFILTRATION(i,4)=cellstr(num2str(Param_Horton(4,3)));
        d.INFILTRATION(i,5)=cellstr(num2str(Param_Horton(5,3)));
        d.INFILTRATION(i,6)=cellstr(num2str(Param_Horton(6,3)));
        
        elseif Tipo_Suelo==4
        d.INFILTRATION(i,2)=cellstr(num2str(Param_Horton(1,4)));
        d.INFILTRATION(i,3)=cellstr(num2str(Param_Horton(3,4)));
        d.INFILTRATION(i,4)=cellstr(num2str(Param_Horton(4,4)));
        d.INFILTRATION(i,5)=cellstr(num2str(Param_Horton(5,4)));
        d.INFILTRATION(i,6)=cellstr(num2str(Param_Horton(6,4)));
       
        end
        
    end
    
end

%Asigna los parametros para casos en que el suelo cuenta con vegetación
if Vegetacion_Infiltracion==1
    
    for i=1:rep
        
        if Tipo_Suelo==1
        d.INFILTRATION(i,2)=cellstr(num2str(Param_Horton(2,1)));
        d.INFILTRATION(i,3)=cellstr(num2str(Param_Horton(3,1)));
        d.INFILTRATION(i,4)=cellstr(num2str(Param_Horton(4,1)));
        d.INFILTRATION(i,5)=cellstr(num2str(Param_Horton(5,1)));
        d.INFILTRATION(i,6)=cellstr(num2str(Param_Horton(6,1)));
        
        elseif Tipo_Suelo==2
        d.INFILTRATION(i,2)=cellstr(num2str(Param_Horton(2,2)));
        d.INFILTRATION(i,3)=cellstr(num2str(Param_Horton(3,2)));
        d.INFILTRATION(i,4)=cellstr(num2str(Param_Horton(4,2)));
        d.INFILTRATION(i,5)=cellstr(num2str(Param_Horton(5,2)));
        d.INFILTRATION(i,6)=cellstr(num2str(Param_Horton(6,2)));
        
        elseif Tipo_Suelo==3
        d.INFILTRATION(i,2)=cellstr(num2str(Param_Horton(2,3)));
        d.INFILTRATION(i,3)=cellstr(num2str(Param_Horton(3,3)));
        d.INFILTRATION(i,4)=cellstr(num2str(Param_Horton(4,3)));
        d.INFILTRATION(i,5)=cellstr(num2str(Param_Horton(5,3)));
        d.INFILTRATION(i,6)=cellstr(num2str(Param_Horton(6,3)));
        
        elseif Tipo_Suelo==4
        d.INFILTRATION(i,2)=cellstr(num2str(Param_Horton(2,4)));
        d.INFILTRATION(i,3)=cellstr(num2str(Param_Horton(3,4)));
        d.INFILTRATION(i,4)=cellstr(num2str(Param_Horton(4,4)));
        d.INFILTRATION(i,5)=cellstr(num2str(Param_Horton(5,4)));
        d.INFILTRATION(i,6)=cellstr(num2str(Param_Horton(6,4)));
       
        end
        
    end
    
end

else
    
d.OPTIONS(2,2)=cellstr('CURVE_NUMBER');

cd(P_Mod_Infil)
Param_CN=xlsread('CN.xlsx');
cd(Raiz)

%Haciendo uso de las ecuaciones de interpolación de Hoja de Infiltracion
Param_CN(1,1)=0.5751*Impermeabilidad+39.527;
Param_CN(1,2)=0.3762*Impermeabilidad+60.606;
Param_CN(1,3)=0.2475*Impermeabilidad+73.788;
Param_CN(1,4)=0.1755*Impermeabilidad+80.553;


for i=1:rep
        
    if Tipo_Suelo==1
    d.INFILTRATION(i,2)=cellstr(num2str(Param_CN(1,1)));
    d.INFILTRATION(i,3)=cellstr(num2str(Param_CN(2,1)));
    d.INFILTRATION(i,4)=cellstr(num2str(Param_CN(3,1)));

    elseif Tipo_Suelo==2
    d.INFILTRATION(i,2)=cellstr(num2str(Param_CN(1,2)));
    d.INFILTRATION(i,3)=cellstr(num2str(Param_CN(2,2)));
    d.INFILTRATION(i,4)=cellstr(num2str(Param_CN(3,2)));

    elseif Tipo_Suelo==3
    d.INFILTRATION(i,2)=cellstr(num2str(Param_CN(1,3)));
    d.INFILTRATION(i,3)=cellstr(num2str(Param_CN(2,3)));
    d.INFILTRATION(i,4)=cellstr(num2str(Param_CN(3,3)));

    elseif Tipo_Suelo==4
    d.INFILTRATION(i,2)=cellstr(num2str(Param_CN(1,4)));
    d.INFILTRATION(i,3)=cellstr(num2str(Param_CN(2,4)));
    d.INFILTRATION(i,4)=cellstr(num2str(Param_CN(3,4)));

    end
        
end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% JUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Crea las Junctions de cada Subcuenca
for i=2:rep
d.JUNCTIONS(i,:)= d.JUNCTIONS(1,:);
d.DWF(i,:)= d.DWF(1,:);
end

%Asigna automáticamente nombre a cada Junction y a los campos de
%coordenadas
for i=2:rep
    nombresJ(i,1)=i;
end

for i=2:rep
    d.JUNCTIONS(i,1)=cellstr(strcat('J',num2str(nombresJ(i,1))));
    d.COORDINATES(i,1)=cellstr(strcat('J',num2str(nombresJ(i,1))));
    d.DWF(i,1)=cellstr(strcat('J',num2str(nombresJ(i,1))));
end

%Asigna las Coordenadas X de las Junctions
coorXJ=0;
for i=1:rep/2
    d.COORDINATES(i,2)=cellstr(num2str(coorXJ));
    coorXJ=coorXJ+largo;
end

coorXJ=0;
for i=5:rep
    d.COORDINATES(i,2)=cellstr(num2str(coorXJ));
    coorXJ=coorXJ+largo;
end

%Asigna las Coordenadas Y de las Junctions
for i=1:rep
   if i<=4
        d.COORDINATES(i,3)=cellstr(num2str(0));
   elseif i>=5 && i<=8
       d.COORDINATES(i,3)=cellstr(num2str(largo));
   end
end

%%%%%%%%%%%%%%%%%%% Outfall %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Asigna Coordenadas al Outfall de la cuenca
d.COORDINATES(9,1)=cellstr('O1');
d.COORDINATES(9,2)=cellstr(num2str(largo*4));
d.COORDINATES(9,3)=cellstr(num2str(0));

%Asigna cuencas de salida a cada Junction
for i=2:rep
    d.SUBCATCHMENTS(i,3)=cellstr(strcat('J',num2str(nombresJ(i,1))));
end

%Asigna Elevación a cada Junction en función de la pendiente Lateral de la cuenca
for i=1:rep
   if i<=4
        d.JUNCTIONS(i,2)=cellstr(num2str(100));
   elseif i>=5 && i<=8
       d.JUNCTIONS(i,2)=cellstr(num2str(100+(pendiente/100*largo)));
   end
end

%Ajusta las elevaciones en función de la pendiente longitudinal de la
%cuenca
for i=1:rep-3
    if i<=4
        d.JUNCTIONS(i,2)=cellstr(num2str(100-(i-1)*(pendienteLong/100*largo)));
    elseif i==5
        d.OUTFALLS(1,2)=cellstr(num2str(100 -(i-1)*(pendienteLong/100*largo)));
    end
end

%%%%%%%%%% Asignación de Caudal de tiempo seco a todas las Junctions%%%%%%%

%Calcula el caudal unitario en tiempo seco en m3/s y lo asigna a cada Junction
%Q=Dot_Potable*Coef_Retor*Dens_Pobl*Area y conversión de unidades

if incluir_Q_Seco==0
    Caudal_Seco_Unitario=0;
else
    Caudal_Seco_Unitario=Dota_Potable*0.85*Den_Pob*Area_Actual/(24*60*60*1000);
end



for i=1:rep
    d.DWF(i,3)=cellstr(num2str(Caudal_Seco_Unitario));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Conductos %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Crea los conductos
for i=1:(rep)
d.CONDUITS(i,:)= d.CONDUITS(1,:);
d.XSECTIONS(i,:)= d.XSECTIONS(1,:);
end

%Asigna automáticamente nombre a cada Conducto y a los campos de
%coordenadas
for i=1:(rep)
    nombresC(i,1)=i;
end

for i=1:(rep)
    d.CONDUITS(i,1)=cellstr(strcat('C',num2str(nombresC(i,1))));
    d.XSECTIONS(i,1)=cellstr(strcat('C',num2str(nombresC(i,1))));
end

%Asigna longitud a cada conducto
for i=1:(rep)
d.CONDUITS(i,4)=cellstr(num2str(largo));
end

%Asigna Junction de Entrada a cada Conducto
for i=1:(rep-4)
    d.CONDUITS(i,2)=cellstr(strcat('J',num2str(i+4)));
end

for i=5:rep
    d.CONDUITS(i,2)=cellstr(strcat('J',num2str(i-4)));
end

%Asigna Junction de Salida a cada Conducto
for i=1:(rep-4)
    d.CONDUITS(i,3)=cellstr(strcat('J',num2str(i)));
end

for i=5:rep-1
    d.CONDUITS(i,3)=cellstr(strcat('J',num2str(i-3)));
end
d.CONDUITS(8,3)=cellstr(strcat('O1'));

%%%%%%%%%%%%%%%%% Dimensionamiento de las tuberias %%%%%%%%%%%%%%%%%%%%%%%%

%%%%% Asigna el Diametro a las tuberias de la C1 a la C4 %%%%%%%% 
%Calcula el caudal de agual pluvial a partir de la ecuación del método
%racional
Caudal_Pluvial_Unitario=CEscorrentia*I*area/360;

%Calcula el caudal total que se va a transportar en el sistema
Caudal_Total_Unitario=Caudal_Pluvial_Unitario+Caudal_Seco_Unitario;

%Calcula el angulo Theta de llenado  a partir de la relacion de llenado 
%permitida
Theta=2*acos(1-2*Relacion_Llenado);

%Calcula el diametro C1 al C4 a partir de la formula de manning
syms diam
eqn=((8*Caudal_Total_Unitario)/((Theta-sin(Theta))*diam^2))==((1/nManning)*((1-(sin(Theta)/Theta))*(diam/4))^(2/3)*(PendienteManning)^0.5);
Diametro=double(solve(eqn,diam,'Real',true));

%Asigna Diametro a las tuberias C1 a la C4
for i=1:(rep-4)
d.XSECTIONS(i,3)=cellstr(num2str(Diametro));
end

%%%%%%%%%%%% Asigna el Diametro a las tuberias de la C5 a la C8 %%%%%%%%%%% 
%Calcula los Caudales que transportan las tuberias C5 a la C8
Caudales_Colector=[];

cont=1;
for i=2:2:8
    Caudales_Colector(cont,1)= Caudal_Total_Unitario*i;
    cont=cont+1;
end

%Calcula los diametros de C5 a C8 a partir de los caudales calculados
syms diam_colec

for i=1:size(Caudales_Colector)
eqn=((8*Caudales_Colector(i,1))/((Theta-sin(Theta))*diam_colec^2))==((1/nManning)*((1-(sin(Theta)/Theta))*(diam_colec/4))^(2/3)*(PendienteManning)^0.5);
Diametros_Colector(i,1)=double(solve(eqn,diam_colec,'Real',true));
end

%Asigna Diametro a las tuberias C5 a la C8
for i=5:rep
d.XSECTIONS(i,3)=cellstr(num2str(Diametros_Colector(i-4,1)));
end

%%%%%%%%%%% Reasignación de Diametros Calculados a Comerciales %%%%%%%%%%%%

%Se debe definir el grosor de la tubería dependiendo del material de la
%misma. Por medio de este valor se calcula el diametro interno.
Grosor_Tuberia=4;

%Diametros de 2" a 20". Asumiendo 1 Pulgada=25.4mm y con cambios de a 2
%pulgadas. Datos de Diametros tomados de Pavco, Colombia
Diametros_Comerciales=[];
nominal=2;
interno=25.4*2;

for i=1:10
    Diametros_Comerciales(i,1)=nominal;
    Diametros_Comerciales(i,2)=interno-Grosor_Tuberia;
    
    nominal=nominal+2;
    interno=interno+(25.4*2);
end

%Diametros de 24" a 51". Asumiendo 1 Pulgada=25.4mm y con cambios de a 3
%pulgadas. Datos de Diametros tomados de Pavco, Colombia
nominal_2=24;
interno_2=25.4*24;

for i=1:10
    Diametros_Comerciales(i+10,1)=nominal_2;
    Diametros_Comerciales(i+10,2)=interno_2-Grosor_Tuberia;
    
    nominal_2=nominal_2+3;
    interno_2=interno_2+(25.4*3);
end

%Genera una matriz con los Diametros Calculados de todas las tuberias
Diametros_Calculados=[];

for i=1:(rep-3)
    Diametros_Calculados(i,1)=Diametro;
end

for i=(rep-3):rep
    Diametros_Calculados(i,1)=Diametros_Colector(i-4,1);
end

if incluir_Diam_Comer==1

%Compara 1 por 1 los Diametros Calculados con los Comerciales y genera una
%matriz con las diferencias positivas de cada diametro de C con los
%posibles diametros comerciales
Diferencias_Diametros=[];
Diferencias_Positivas=[];

for j=1:size(Diametros_Calculados)

for i=1:size(Diametros_Comerciales)
    Diferencias_Diametros(i,j)=(Diametros_Comerciales(i,2)/1000)-Diametros_Calculados(j,1);
    if Diferencias_Diametros(i,j)>0
        Diferencias_Positivas(i,j)=Diferencias_Diametros(i,j);
    else
        Diferencias_Positivas(i,j)=nan;
    end
end

end

%Calcula el número de opciones invalidadas para cada diametro calculado y
%la posición de diametro comercial que se le debe asignar a cada tubo
pos_comercial=[];
nans=0;

for j=1:size(Diametros_Calculados)
    
    for i=1:size(Diametros_Comerciales)
        if isnan(Diferencias_Positivas(i,j))
            nans=nans+1; 
        else
        end
    
    end
    pos_comercial(j,1)=nans+1;
    nans=0;
end

%Crea una nueva matriz de diametros y los Re-asigna
Nuevos_Diametros=[];
for i=1:size(Diametros_Calculados)
    Nuevos_Diametros(i,1)=Diametros_Comerciales(pos_comercial(i,1),2)/1000;
    d.XSECTIONS(i,3)=cellstr(num2str(Nuevos_Diametros(i,1)));
end

else

for i=1:size(Diametros_Calculados)
    d.XSECTIONS(i,3)=cellstr(num2str(Diametros_Calculados(i,1)));
end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Calidad %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%Calcula y define concentraciones en tiempo seco %%%%%%%%%%%%%%%%%%

%Calcula las concentraciones de cada contaminante a partir del aporte y de
%la dotación por habitante definida por el usuario. Las unidades de las
%concentraciones son en mg/L.

if incluir_Q_Seco==0
    Conce_DBO=0;
    Conce_SST=0;
    Conce_NT=0;
    Conce_FT=0;
else
    Conce_DBO=Aporte_DBO/Den_Pob*1000;
    Conce_SST=APorte_SST/Den_Pob*1000;
    Conce_NT=Aporte_NT/Den_Pob*1000;
    Conce_FT=Aporte_FT/Den_Pob*1000;
end


%%%%%%%%%%%%%%%%%%%%%Definicion de parametros de Calidad%%%%%%%%%%%%%%%%%%%

%Calcula el numero total de parametros que se incluirán
NumParame=TSS+DBO+DQO+FT+NT+Zn+Pb+Fe;

%Genera una matriz con todos los parametros posibles
NombresParametros(1,1)=cellstr('TSS');
NombresParametros(1,2)=cellstr(num2str(TSS));

NombresParametros(2,1)=cellstr('DBO');
NombresParametros(2,2)=cellstr(num2str(DBO));

NombresParametros(3,1)=cellstr('DQO');
NombresParametros(3,2)=cellstr(num2str(DQO));

NombresParametros(4,1)=cellstr('FT');
NombresParametros(4,2)=cellstr(num2str(FT));

NombresParametros(5,1)=cellstr('NT');
NombresParametros(5,2)=cellstr(num2str(NT));

NombresParametros(6,1)=cellstr('Zn');
NombresParametros(6,2)=cellstr(num2str(Zn));

NombresParametros(7,1)=cellstr('Pb');
NombresParametros(7,2)=cellstr(num2str(Pb));

NombresParametros(8,1)=cellstr('Fe');
NombresParametros(8,2)=cellstr(num2str(Fe));

%Genera una nueva matriz sólo con los parametros que se incluirán
cont=1;
for i=1:size(NombresParametros)
    if str2double(NombresParametros(i,2))==1
        NombresParamIncluir(cont,:)= NombresParametros(i,:);
        cont=cont+1;
    else
    end
end

%Duplica los parametros de calidad que se incluirán y les asigna nombres
for i=1:size(NombresParamIncluir)
    d.POLLUTANTS(i,:)=d.POLLUTANTS(1,:);
    d.POLLUTANTS(i,1)=NombresParamIncluir(i,1);
end

%%%%%%%%%%%%%%%%%%%% Definición de Usos de Suelo %%%%%%%%%%%%%%%%%%%%%%%%

%Calcula el numero total de usos de suelo que se incluirán
NumUsos=Verde+Urbano+General;

%Genera una matriz con la totalidad de usos de suelo posibles
NombresUsos(1,1)=cellstr('Verde');
NombresUsos(1,2)=cellstr(num2str(Verde));

NombresUsos(2,1)=cellstr('Urbano');
NombresUsos(2,2)=cellstr(num2str(Urbano));

NombresUsos(3,1)=cellstr('General');
NombresUsos(3,2)=cellstr(num2str(General));

%Genera una nueva matriz sólo con los usos que se incluirán
cont=1;
for i=1:size(NombresUsos)
    if str2double(NombresUsos(i,2))==1
        NombresUsosIncluir(cont,:)= NombresUsos(i,:);
        cont=cont+1;
    else
    end
end

%Duplica los Usos que se incluirán y les asigna nombres
if NumUsos==1
    %d.LANDUSES(2,:)=[];
    d.LANDUSES(1,1)=NombresUsosIncluir(1,1);
end

if NumUsos>1
for i=1:size(NombresUsosIncluir)
    d.LANDUSES(i,:)=d.LANDUSES(1,:);
    d.LANDUSES(i,1)=NombresUsosIncluir(i,1);
end
end

%%%%%%%%%%%%%% Definición de % de Cobertura de Usos Suelo %%%%%%%%%%%%%%%%

%Asigna los nombres de las Subcuencas en la hoja de usos de suelo
for i=1:rep*NumUsos
    if i>=1 && i<=NumUsos
        d.COVERAGES(i,1)=cellstr('A1');
        elseif i>=NumUsos+1 && i<=NumUsos*2
        d.COVERAGES(i,1)=cellstr('A2');
        elseif i>=NumUsos*2+1 && i<=NumUsos*3
        d.COVERAGES(i,1)=cellstr('A3');
        elseif i>=NumUsos*3+1 && i<=NumUsos*4
        d.COVERAGES(i,1)=cellstr('A4');
        elseif i>=NumUsos*4+1 && i<=NumUsos*5
        d.COVERAGES(i,1)=cellstr('A5');
        elseif i>=NumUsos*5+1 && i<=NumUsos*6
        d.COVERAGES(i,1)=cellstr('A6');
        elseif i>=NumUsos*6+1 && i<=NumUsos*7
        d.COVERAGES(i,1)=cellstr('A7');
    else
        d.COVERAGES(i,1)=cellstr('A8');
            
    end
end

%%%%%%% Asigna los nombres y % de coberturas a cada subcuenca %%%%%%%%%%%%

%Caso en el que se usa Tipo Verde y Urbano
if Verde==1 && Urbano==1 && General==0
for i=1:2:rep*NumUsos
    d.COVERAGES(i,2)=cellstr('Verde');
    d.COVERAGES(i,3)=cellstr(num2str(UsoVerde));
end
for i=2:2:rep*NumUsos
    d.COVERAGES(i,2)=cellstr('Urbano');
    d.COVERAGES(i,3)=cellstr(num2str(UsoUrbano));
end

end

%Caso en el que se usa Tipo Verde y General
if Verde==1 && Urbano==0 && General==1
for i=1:2:rep*NumUsos
    d.COVERAGES(i,2)=cellstr('Verde');
    d.COVERAGES(i,3)=cellstr(num2str(UsoVerde));
end
for i=2:2:rep*NumUsos
    d.COVERAGES(i,2)=cellstr('General');
    d.COVERAGES(i,3)=cellstr(num2str(UsoGeneral));
end

end

%Caso en el que se usa Tipo Urbano y General
if Verde==0 && Urbano==1 && General==1
for i=1:2:rep*NumUsos
    d.COVERAGES(i,2)=cellstr('Urbano');
    d.COVERAGES(i,3)=cellstr(num2str(UsoUrbano));
end
for i=2:2:rep*NumUsos
    d.COVERAGES(i,2)=cellstr('General');
    d.COVERAGES(i,3)=cellstr(num2str(UsoGeneral));
end

end

%Caso en el que se usan todos los tipos de Uso de Suelo
if NumUsos >2
    for i=1:3:rep*NumUsos
    d.COVERAGES(i,2)=cellstr('Verde');
    d.COVERAGES(i,3)=cellstr(num2str(UsoVerde));
end
for i=2:3:rep*NumUsos
    d.COVERAGES(i,2)=cellstr('Urbano');
    d.COVERAGES(i,3)=cellstr(num2str(UsoUrbano));
end
    for i=3:3:rep*NumUsos
    d.COVERAGES(i,2)=cellstr('General');
    d.COVERAGES(i,3)=cellstr(num2str(UsoGeneral));
end
end

%Caso en el que se usa solo 1 tipo de Suelo
if NumUsos ==1
    for i=1:rep
    d.COVERAGES(i,2)=cellstr(NombresUsosIncluir(1,1));
    d.COVERAGES(i,3)=cellstr(num2str(100));
    end
end

%%%%%%%%%%%%% Definición de parámetros de Build Up y Wash Off %%%%%%%%%%%%

%Define las repeticiones de los ciclos subsiguientes dependiendo del número
%de usos de suelo y de parámetros
repe=NumUsos*NumParame;

%Crea una matriz nueva con los usos a incluir para que cuadre con el
%formato que requiere la tabla de Build up y Wash Off
UsosAsignar=repmat(NombresUsosIncluir,repe);

%Crea una matriz nueva con los parametros a incluir para que cuadre con el
%formato que requiere la tabla de Build up y Wash Off
if NumUsos==1
  ParamAsignar=NombresParamIncluir;
  d.BUILDUP(2,:)=[];
  d.WASHOFF(2,:)=[];
end

if NumUsos==2
cont=1;
for i=1:NumParame
    ParamAsignar(cont,1)=NombresParamIncluir(i,1);
    ParamAsignar(cont+1,1)=NombresParamIncluir(i,1);
cont=cont+NumUsos;
end
end

if NumUsos==3
cont=1;
for i=1:NumParame
    ParamAsignar(cont,1)=NombresParamIncluir(i,1);
    ParamAsignar(cont+NumUsos-2,1)=NombresParamIncluir(i,1);
    ParamAsignar(cont+NumUsos-1,1)=NombresParamIncluir(i,1);
cont=cont+NumUsos;
end
end

%Duplica los Usos que se incluirán y les asigna nombres
for i=1:repe
    d.BUILDUP(i,:)=d.BUILDUP(1,:);
    d.BUILDUP(i,1)=UsosAsignar(i,1);
    
    d.WASHOFF(i,:)=d.WASHOFF(1,:);
    d.WASHOFF(i,1)=UsosAsignar(i,1);
end

%Asigna los contaminantes que se van a modelar a cada uso del suelo
for i=1:repe
    d.BUILDUP(i,2)=ParamAsignar(i,1);

    d.WASHOFF(i,2)=ParamAsignar(i,1);
end

%%%%%%%%%%%%%%%Asigna los parámetros de Build Up, Wash Off y DWF %%%%%%%%%%%%%%%

%Carga y asigna los parametros para TSS, FT y NT cuando se manejan los
%tipos de suelo Urbano y Verde. Solo incluye estos 3 parametros porque son
%los que cuentan con información para estos tipos de suelo.
if Verde==1 && Urbano==1 && General==0

posicion=1;
posicionDWF=1;

%TSS
if TSS==1
    
MaxBuildUpVerdeTSS=129.47;
MaxBuildUpUrbanoTSS=65.27;
RateCOnstantVerdeTSS=0.98;
RateCOnstantUrbanoTSS=0.81;

CoeficienteVerdeTSS=5.89;
CoeficienteUrbanoTSS=4.07;
ExponenteVerdeTSS=3.16;
ExponenteUrbanoTSS=2.58;


for i=posicion:size(NumParame*NumUsos)
    d.BUILDUP(i,4)=cellstr(num2str(MaxBuildUpVerdeTSS));
    d.BUILDUP(i+1,4)=cellstr(num2str(MaxBuildUpUrbanoTSS));
    d.BUILDUP(i,5)=cellstr(num2str(RateCOnstantVerdeTSS));
    d.BUILDUP(i+1,5)=cellstr(num2str(RateCOnstantUrbanoTSS));

    d.WASHOFF(i,4)=cellstr(num2str(CoeficienteVerdeTSS));
    d.WASHOFF(i+1,4)=cellstr(num2str(CoeficienteUrbanoTSS));
    d.WASHOFF(i,5)=cellstr(num2str(ExponenteVerdeTSS));
    d.WASHOFF(i+1,5)=cellstr(num2str(ExponenteUrbanoTSS));
end

posicion=posicion+2;


%Asigna el DWF concentración
d.POLLUTANTS(posicionDWF,10)=cellstr(num2str(Conce_SST));
posicionDWF=posicionDWF+1;

end

%FT
if FT==1
MaxBuildUpVerdeFT=0.01;
MaxBuildUpUrbanoFT=0.03;
RateCOnstantVerdeFT=0.05;
RateCOnstantUrbanoFT=0.12;

CoeficienteVerdeFT=2.68;
CoeficienteUrbanoFT=1.69;
ExponenteVerdeFT=2.19;
ExponenteUrbanoFT=2.27;


for i=posicion:size(NumParame*NumUsos)+posicion-1
    d.BUILDUP(i,4)=cellstr(num2str(MaxBuildUpVerdeFT));
    d.BUILDUP(i+1,4)=cellstr(num2str(MaxBuildUpUrbanoFT));
    d.BUILDUP(i,5)=cellstr(num2str(RateCOnstantVerdeFT));
    d.BUILDUP(i+1,5)=cellstr(num2str(RateCOnstantUrbanoFT));

    d.WASHOFF(i,4)=cellstr(num2str(CoeficienteVerdeFT));
    d.WASHOFF(i+1,4)=cellstr(num2str(CoeficienteUrbanoFT));
    d.WASHOFF(i,5)=cellstr(num2str(ExponenteVerdeFT));
    d.WASHOFF(i+1,5)=cellstr(num2str(ExponenteUrbanoFT));
end

posicion=posicion+2;

%Asigna el DWF concentración
d.POLLUTANTS(posicionDWF,10)=cellstr(num2str(Conce_FT));
posicionDWF=posicionDWF+1;

end

%NT
if NT==1
MaxBuildUpVerdeNT=0.26;
MaxBuildUpUrbanoNT=0.12;
RateCOnstantVerdeNT=3.61;
RateCOnstantUrbanoNT=1.65;

CoeficienteVerdeNT=21.51;
CoeficienteUrbanoNT=28.68;
ExponenteVerdeNT=3.62;
ExponenteUrbanoNT=4.44;


for i=posicion:size(NumParame*NumUsos)+posicion-1
    d.BUILDUP(i,4)=cellstr(num2str(MaxBuildUpVerdeNT));
    d.BUILDUP(i+1,4)=cellstr(num2str(MaxBuildUpUrbanoNT));
    d.BUILDUP(i,5)=cellstr(num2str(RateCOnstantVerdeNT));
    d.BUILDUP(i+1,5)=cellstr(num2str(RateCOnstantUrbanoNT));

    d.WASHOFF(i,4)=cellstr(num2str(CoeficienteVerdeNT));
    d.WASHOFF(i+1,4)=cellstr(num2str(CoeficienteUrbanoNT));
    d.WASHOFF(i,5)=cellstr(num2str(ExponenteVerdeNT));
    d.WASHOFF(i+1,5)=cellstr(num2str(ExponenteUrbanoNT));
end
posicion=posicion+2;

%Asigna el DWF concentración
d.POLLUTANTS(posicionDWF,10)=cellstr(num2str(Conce_NT));
posicionDWF=posicionDWF+1;

end
end


%Carga y Asigna los parámetros para Uso de Suelo General
if General==1 && Verde==0 && Urbano==0

%Carga a partir del archivo de Excel una matriz con los parámetros de todos
%los contaminantes
cd(P_Mod_Calid)
ParametrosGeneral=importdata('UsoGeneral.xlsx');
cd(Raiz)

%Empieza a asigna los parametros dependiendo de si el contaminantes será o
%no incluido en la modelación
posicion=1;
posicionDWF=1;

if TSS==1
   d.BUILDUP(posicion,4)=cellstr(num2str(ParametrosGeneral.data(1,1)));
   d.BUILDUP(posicion,5)=cellstr(num2str(ParametrosGeneral.data(2,1)));
   d.WASHOFF(posicion,4)=cellstr(num2str(ParametrosGeneral.data(3,1)));
   d.WASHOFF(posicion,5)=cellstr(num2str(ParametrosGeneral.data(4,1)));
   
   posicion=posicion+1;
   
   %Asigna el DWF concentración
   d.POLLUTANTS(posicionDWF,10)=cellstr(num2str(Conce_SST));
   posicionDWF=posicionDWF+1;

end


if DBO==1
   d.BUILDUP(posicion,4)=cellstr(num2str(ParametrosGeneral.data(1,2)));
   d.BUILDUP(posicion,5)=cellstr(num2str(ParametrosGeneral.data(2,2)));
   d.WASHOFF(posicion,4)=cellstr(num2str(ParametrosGeneral.data(3,2)));
   d.WASHOFF(posicion,5)=cellstr(num2str(ParametrosGeneral.data(4,2)));
   
   posicion=posicion+1;
   
   %Asigna el DWF concentración
   d.POLLUTANTS(posicionDWF,10)=cellstr(num2str(Conce_DBO));
   posicionDWF=posicionDWF+1;
   
end

if DQO==1
   d.BUILDUP(posicion,4)=cellstr(num2str(ParametrosGeneral.data(1,3)));
   d.BUILDUP(posicion,5)=cellstr(num2str(ParametrosGeneral.data(2,3)));
   d.WASHOFF(posicion,4)=cellstr(num2str(ParametrosGeneral.data(3,3)));
   d.WASHOFF(posicion,5)=cellstr(num2str(ParametrosGeneral.data(4,3)));
   
   posicion=posicion+1;
   
   posicionDWF=posicionDWF+1;
   
end

if FT==1
   d.BUILDUP(posicion,4)=cellstr(num2str(ParametrosGeneral.data(1,4)));
   d.BUILDUP(posicion,5)=cellstr(num2str(ParametrosGeneral.data(2,4)));
   d.WASHOFF(posicion,4)=cellstr(num2str(ParametrosGeneral.data(3,4)));
   d.WASHOFF(posicion,5)=cellstr(num2str(ParametrosGeneral.data(4,4)));
   
   posicion=posicion+1;
   
   %Asigna el DWF concentración
   d.POLLUTANTS(posicionDWF,10)=cellstr(num2str(Conce_FT));
   posicionDWF=posicionDWF+1;
end

if NT==1
   d.BUILDUP(posicion,4)=cellstr(num2str(ParametrosGeneral.data(1,5)));
   d.BUILDUP(posicion,5)=cellstr(num2str(ParametrosGeneral.data(2,5)));
   d.WASHOFF(posicion,4)=cellstr(num2str(ParametrosGeneral.data(3,5)));
   d.WASHOFF(posicion,5)=cellstr(num2str(ParametrosGeneral.data(4,5)));
   
   posicion=posicion+1;
   
   %Asigna el DWF concentración
   d.POLLUTANTS(posicionDWF,10)=cellstr(num2str(Conce_NT));
   posicionDWF=posicionDWF+1;
end

if Zn==1
   d.BUILDUP(posicion,4)=cellstr(num2str(ParametrosGeneral.data(1,6)));
   d.BUILDUP(posicion,5)=cellstr(num2str(ParametrosGeneral.data(2,6)));
   d.WASHOFF(posicion,4)=cellstr(num2str(ParametrosGeneral.data(3,6)));
   d.WASHOFF(posicion,5)=cellstr(num2str(ParametrosGeneral.data(4,6)));
   
   posicion=posicion+1;
end

if Pb==1
   d.BUILDUP(posicion,4)=cellstr(num2str(ParametrosGeneral.data(1,7)));
   d.BUILDUP(posicion,5)=cellstr(num2str(ParametrosGeneral.data(2,7)));
   d.WASHOFF(posicion,4)=cellstr(num2str(ParametrosGeneral.data(3,7)));
   d.WASHOFF(posicion,5)=cellstr(num2str(ParametrosGeneral.data(4,7)));
   
   posicion=posicion+1;
end

if Fe==1
   d.BUILDUP(posicion,4)=cellstr(num2str(ParametrosGeneral.data(1,8)));
   d.BUILDUP(posicion,5)=cellstr(num2str(ParametrosGeneral.data(2,8)));
   d.WASHOFF(posicion,4)=cellstr(num2str(ParametrosGeneral.data(3,8)));
   d.WASHOFF(posicion,5)=cellstr(num2str(ParametrosGeneral.data(4,8)));
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Archivo de salida %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%El archivo mepa_write_inp deb estar en la dirección especificada. El
%archivo de salida Cuenca 2 se guardará en la misma dirección
cd(P_Salida)
mepa_write_inp('Escenario_Base.inp', d);
cd(Raiz)

%Por facilidad de procesamiento de datos, el archivo INP resultando también
%se guarda automáticamente en la dirección especificada para el
%pos-procemiento en Python
cd(P_Python)
mepa_write_inp('Escenario_Base.inp', d);
cd(Raiz)
