clc, clear all, close all

Info_Lluvia=readtable('Badajoz_SWMM.txt');
Info_Lluvia(:,1)=[];
Info_Lluvia=table2array(Info_Lluvia);
[Filas, Columnas]=size(Info_Lluvia);

fechaInicio=strcat(num2str(Info_Lluvia(1,2)),'/', num2str(Info_Lluvia(1,3)),'/', num2str(Info_Lluvia(1,1)));
fchaFin=strcat(num2str(Info_Lluvia(Filas,2)),'/', num2str(Info_Lluvia(Filas,3)),'/', num2str(Info_Lluvia(Filas,1)));