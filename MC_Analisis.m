%Borra todo lo que se tenga previamente
%clc, clear all, close all

%%%%%Define los Paths.
Raiz=cd;
%Raiz= 'Y:\UPV PhD\3. Herramienta Toma Decisiones\1) Modelacion y Visualizacion de Datos\E0) Escenario Base';

%Raiz= '/home/atalo/Dropbox/Pascual/UPV PhD/3. Herramienta Toma Decisiones/1) Modelacion y Visualizacion de Datos/E0) Escenario Base';

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

%Path con Matrices de resultados planos
Res_Planos='/Archivos de Salida';
P_Res_P=strcat(P_Python,Res_Planos);

%Path de las gráficas de salida
Resultados='/Resultados Escenario Base';
P_Resultados=strcat(Raiz,Resultados);

%Evalúa si incluye o no cuadal seco
caudal_seco=evalin('base', "APP_Inc_Q_Seco");

%Carga los archivos del hidrograma y del polutograma
cd(P_Python);
O1=importdata('O1.csv');
TSS=importdata('TSS.csv');
FT=importdata('FT.csv');
NT=importdata('NT.csv');
cd(Raiz);


%Elimina la primera fila de los archivos de texto
O1.textdata(1,:)=[];
TSS.textdata(1,:)=[];
FT.textdata(1,:)=[];
NT.textdata(1,:)=[];


%Define la fecha de inicio y fin del análisis que se quiere realizar
formatIn='yyyy-mm-dd';
%fechaInicio='2009-10-01 00:00:00';
%fechaFin='2010-10-01 00:00:00';

fechaInicio=evalin('base', "APP_date_time_in");
fechaFin=evalin('base', "APP_date_time_fin");


fechaInicioNum=datenum(fechaInicio);
fechaFinNum=datenum(fechaFin);

for i=1:size(O1.data)
   fechas_Num(i,1)=datenum(O1.textdata(i,1),formatIn);
end

Matriz_Datos_Unidos=[fechas_Num,O1.data,TSS.data,FT.data,NT.data];

cont_graf=1;
for i=1:size(fechas_Num)
    if Matriz_Datos_Unidos(i,1)>=fechaInicioNum && Matriz_Datos_Unidos(i,1)<=fechaFinNum
        Datos_Graficar(cont_graf,:)=Matriz_Datos_Unidos(i,:);
        cont_graf=cont_graf+1;
    else
    end
end

for i=1:size(Datos_Graficar)
Fechas_Graficar(i,1)=cellstr(datestr(Datos_Graficar(i,1),formatIn));
end

%Elimina los valores Base para todos los parámetros para el caso en que no
%hay caudal seco

if caudal_seco==0

    for i=1:size(Datos_Graficar)
    Datos_Graficar_sinQ(i,1)=Datos_Graficar(i,1)-Datos_Graficar(1,1);
    Datos_Graficar_sinQ(i,2)=Datos_Graficar(i,2)-Datos_Graficar(1,2);
    Datos_Graficar_sinQ(i,3)=Datos_Graficar(i,3)-Datos_Graficar(1,3);
    Datos_Graficar_sinQ(i,4)=Datos_Graficar(i,4)-Datos_Graficar(1,4);
    Datos_Graficar_sinQ(i,5)=Datos_Graficar(i,5)-Datos_Graficar(1,5);
    end

else
    Datos_Graficar_sinQ=Datos_Graficar;

end
%Pasa a Litros por segundo los valores del Hidrograma
for i=1:size(Datos_Graficar)
    Datos_Graficar_sinQ(i,2)=Datos_Graficar_sinQ(i,2)*1000;
end

% % % % %Genera la Gráfica para el O1
% % % % figure(1)
% % % % plot(datetime(Fechas_Graficar),Datos_Graficar_sinQ(:,2));
% % % % grid on
% % % % title('Hidrograma de Salida','fontweight','bold');
% % % % xlabel('Fecha');
% % % % ylabel('Caudal [L/S]');
% % % % 
% % % % cd(P_Resultados);
% % % % savefig('Hidrograma_2.fig');
% % % % saveas(gcf,'Hidrograma.png');
% % % % 
% % % % close
% % % % 
% % % % %Genera la Gráfica para SST
% % % % figure(2)
% % % % plot(datetime(Fechas_Graficar),Datos_Graficar_sinQ(:,3));
% % % % grid on
% % % % title('Polutograma SST','fontweight','bold');
% % % % xlabel('Fecha');
% % % % ylabel('Concentración [mg/L]');
% % % % 
% % % %  cd(P_Resultados);
% % % %  savefig('SST_2.fig');
% % % %  saveas(gcf,'SST.png');
% % % % 
% % % %  close
% % % %  
% % % % %Genera la Gráfica para FT
% % % % figure(4)
% % % % plot(datetime(Fechas_Graficar),Datos_Graficar_sinQ(:,4));
% % % % grid on
% % % % title('Polutograma PT','fontweight','bold');
% % % % xlabel('Fecha');
% % % % ylabel('Concentración [mg/L]');
% % % % 
% % % %  cd(P_Resultados);
% % % %  savefig('PT_2.fig');
% % % %  saveas(gcf,'PT.png');
% % % %  
% % % %  close
% % % % 
% % % % %Genera la Gráfica para NT
% % % % figure(5)
% % % % plot(datetime(Fechas_Graficar),Datos_Graficar_sinQ(:,5));
% % % % grid on
% % % % title('Polutograma NT','fontweight','bold');
% % % % xlabel('Fecha');
% % % % ylabel('Concentración [mg/L]');
% % % % 
% % % %  cd(P_Resultados);
% % % %  savefig('NT_2.fig');
% % % %  saveas(gcf,'NT.png');
% % % % 
% % % %  close 
% % % % 
% % % %  cd(Raiz);



 %%%%%%%%%%%%%%%%%% Exporta Datos planos de las gráficas%%%%%%%%%%%%%%%%%

assignin('base', "Datos", Datos_Graficar_sinQ);
assignin('base', "Fechas", datetime(Fechas_Graficar));


% % % % % % % %Genera una sola gráfica con todas las sub-gráficas
% % % % % % % figure(6)
% % % % % % % title('Parámetros de Calidad General','fontweight','bold');
% % % % % % % 
% % % % % % % subplot(3,1,1)
% % % % % % % plot(datetime(Fechas_Graficar),Datos_Graficar_sinQ(:,3));
% % % % % % % grid on
% % % % % % % title('Polutograma SST','fontweight','bold');
% % % % % % % 
% % % % % % % 
% % % % % % % subplot(3,1,2)
% % % % % % % plot(datetime(Fechas_Graficar),Datos_Graficar_sinQ(:,4));
% % % % % % % grid on
% % % % % % % title('Polutograma PT','fontweight','bold');
% % % % % % % ylabel('Concentración [mg/L]');
% % % % % % % 
% % % % % % % subplot(3,1,3)
% % % % % % % plot(datetime(Fechas_Graficar),Datos_Graficar_sinQ(:,5));
% % % % % % % grid on
% % % % % % % title('Polutograma NT','fontweight','bold');
% % % % % % % xlabel('Fecha');
% % % % % % % 
% % % % % % % 
% % % % % % % cd(P_Resultados);
% % % % % % % savefig('Mix_2.fig');
% % % % % % % saveas(gcf,'Polutogramas.png');
% % % % % % % cd(Raiz);
% % % % % % % 
% % % % % % % close