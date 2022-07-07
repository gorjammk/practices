#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jun  8 22:51:40 2022

@author: nkv
"""

# skew-T plot 

import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1.inset_locator import inset_axes
import pandas as pd

import metpy.calc as mpcalc
from metpy.cbook import get_test_data
from metpy.plots import add_metpy_logo, Hodograph, SkewT
from metpy.units import units
col_names = ['pressure', 'height', 'temperature', 'dewpoint', 'direction', 'speed']

df = pd.read_fwf('/media/nkv/1047-ED012/m_work/Skew-Tplots/skt_rs_lin.txt',skiprows=5,
                 usecols=[0, 1, 2, 3, 4, 5], names=col_names)

# Drop any rows with all NaN values for T, Td, winds
df = df.dropna(subset=('temperature', 'dewpoint', 'direction', 'speed'
                        ), how='all').reset_index(drop=True)

hght = df['height'].values * units.hPa
p = df['pressure'].values * units.hPa
T = df['temperature'].values * units.degC
Td = df['dewpoint'].values * units.degC
wind_speed = df['speed'].values * units.knots
wind_dir = df['direction'].values * units.degrees
u, v = mpcalc.wind_components(wind_speed, wind_dir)

# Calculate the LCL
lcl_pressure, lcl_temperature = mpcalc.lcl(p[0], T[0], Td[0])
# Calculate the LFC
lfc_pressure, lfc_temperature = mpcalc.lfc(p, T, Td)
# Calculate the EL
el_pressure, el_temperature = mpcalc.el(p, T, Td)


# Create a new figure. The dimensions here give a good aspect ratio
fig = plt.figure(figsize=(9, 9))

# Grid for plots
skew = SkewT(fig, rotation=45)



# Plot the data using normal plotting functions, in this case using
# log scaling in Y, as dictated by the typical meteorological plot
skew.plot(p, T, 'r', label='Environmental Temp',linewidth=3.0)
skew.plot(p, Td, 'g', label='Dewpoint Temp',linewidth=3.0)
mask = df['pressure'] > 85
skew.plot_barbs(p[mask], u[mask], v[mask])


# Add the relevant special lines
skew.plot_dry_adiabats()
skew.plot_moist_adiabats()
skew.plot_mixing_lines()

# Good bounds for aspect ratio


skew.ax.xaxis.set_tick_params(labelsize=15)
skew.ax.yaxis.set_tick_params(labelsize=15)
# cape cin
parcel_path = mpcalc.parcel_profile(p, T[0], Td[0])
skew.plot(p, parcel_path, color='k', label='Parcel Temp',linewidth=3.0)
skew.shade_cape(p, T, parcel_path)
skew.shade_cin(p, T, parcel_path)


# Calculate the CAPE CIN
cape, cin = mpcalc.cape_cin(p, T, Td, parcel_path,
                            which_lfc='bottom', which_el='top')

# Plot the LCL, LFC, and EL as horizontal markers
if lcl_pressure:
    skew.ax.plot(lcl_temperature, lcl_pressure, marker="_", color='orange', markersize=30, markeredgewidth=3, label='LCL')
    
if lfc_pressure:   
    skew.ax.plot(lfc_temperature, lfc_pressure, marker="_", color='brown', markersize=30, markeredgewidth=3, label='LFC')
    
if el_pressure:
    skew.ax.plot(el_temperature, el_pressure, marker="_", color='blue', markersize=30, markeredgewidth=3, label='EL')
    
    
skew.ax.set_xlim(-25, 60)
skew.ax.set_ylim(1010, 90)  
plt.xlabel("degree_Celsius", fontsize=20)
plt.ylabel("Pressure (hPa)", fontsize=20)


# skew.ax.text(0.95, 0.95, 'colored text in axes coords',
#         verticalalignment='bottom', horizontalalignment='right',
#         transform=skew.ax.transAxes,
#         color='green', fontsize=15)

skew.ax.legend(frameon=False,fontsize=16)

# Create a hodograph
# ax_hod = inset_axes(skew.ax, '40%', '40%', loc=1)
# h = Hodograph(ax_hod, component_range=80.)
# h.add_grid(increment=20)
# h.plot_colormapped(u, v, hght)

print(cape)
print(cin)
print(lcl_pressure)
print(lcl_temperature)

# cape = round(cape,2)
# cin  = round(cin,2)
# lcl_pressure = round(lcl_pressure,2)
# lcl_temperature = round(lcl_temperature,2)

# cape = '3014 j/kg'
# cin  = '-9.0 j/kg'
# lcl_pressure ='973 hPa'
# lcl_temperature = '24.6 deg C'

cape = format(cape,".2f")
cin  = format(cin,".2f")
lcl_pressure = format(lcl_pressure,".2f")
lcl_temperature = format(lcl_temperature,".2f")


z=plt.title('CAPE= '+str(cape)+', CIN = '+str(cin)+',\n LCL_Temp= '+str(lcl_temperature)+', LCL_Pres= '+str(lcl_pressure),
            fontsize=14)
# plt.title('Skew-T Log-P', size=20)

plt.savefig('/m_work/Skew-Tplots/skt_rs_mod.jpg',
            dpi=300, bbox_inches='tight', pad_inches = 0.1) 

# Show the plot
plt.show()




