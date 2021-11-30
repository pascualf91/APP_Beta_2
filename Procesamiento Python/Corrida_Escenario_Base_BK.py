#!/usr/bin/env python
# coding: utf-8

# In[2]:


import subprocess

cm= 'swmm5.exe Escenario_Base.inp Escenario_Base.rpt Escenario_Base.out'
subprocess.call(cm)


hidro='swmmtoolbox extract Escenario_Base.out node,O1,Total_inflow'
info=subprocess.getoutput(hidro)
file=open(r"Y:\UPV PhD\3. Herramienta Toma Decisiones\1) Modelacion y Visualizacion de Datos\E0) Escenario Base\Procesamiento Python\Archivos de Salida\O1.csv", 'w')
file.write(info)
file.close


TSS='swmmtoolbox extract Escenario_Base.out node,O1,TSS'
infoTSS=subprocess.getoutput(TSS)
file=open(r"Y:\UPV PhD\3. Herramienta Toma Decisiones\1) Modelacion y Visualizacion de Datos\E0) Escenario Base\Procesamiento Python\Archivos de Salida\TSS.csv", 'w')
file.write(infoTSS)
file.close

FT='swmmtoolbox extract Escenario_Base.out node,O1,FT'
infoFT=subprocess.getoutput(FT)
file=open(r"Y:\UPV PhD\3. Herramienta Toma Decisiones\1) Modelacion y Visualizacion de Datos\E0) Escenario Base\Procesamiento Python\Archivos de Salida\FT.csv", 'w')
file.write(infoFT)
file.close

NT='swmmtoolbox extract Escenario_Base.out node,O1,NT'
infoNT=subprocess.getoutput(NT)
file=open(r"Y:\UPV PhD\3. Herramienta Toma Decisiones\1) Modelacion y Visualizacion de Datos\E0) Escenario Base\Procesamiento Python\Archivos de Salida\NT.csv", 'w')
file.write(infoNT)
file.close


# In[ ]:




