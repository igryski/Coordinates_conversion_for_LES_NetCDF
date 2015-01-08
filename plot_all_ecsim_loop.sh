#!/bin/bash

# Flags to run script on cirrus
#$ -q rijn     # lek is Edou, rijn is Stephani
#$ -l h_rt=3600
#$ -pe mpi 2

mkdir -p $PWD/extracted


# Create an array that represents all grid lines along Y-direction, of the scene
# Bash looping
#
#for ycross in {0.1, 0.1, 25.6}  # Start, increment and final line coordinate (in kilometers)
# do
  
# done
# loop finished

# Define some numerical boudaries here:
x1=0.0
x2=25.6
y1=0.0
y2=25.6
z1=0.0
z2=2.75

# Specially coordinate for x-secitons:
#ycross=24.0

# Specially for plot_slice utility:
#alt1=0.0
#alt2=2.0

# Files
#scene=lookup_scene.uff
scene=scene.uff
# 3-dimensional
threedExt=extracted/3dext_scene.nc
threedReff=extracted/3d_R_eff.nc
threedMass=extracted/3d_mass_content.nc
# Horizontal
lwp=extracted/lwp_hor.nc
opt_depth=extracted/opt_depth.nc     # NEW!
# Slices
numb_conc=extracted/numb_conc.nc     # NEW!
lwc_slice=extracted/lwc_slice.nc
reff_slice=extracted/reff_slice.nc
ssa_slice=extracted/ssa_slice.nc
dsd_slice=extracted/dsd_slice.nc

# Extractables and plottables
Ext=Extinction
Lwc=Mass_content
Reff=R_eff
Ssa=SS_alb
dsd=DSD

# Extract and plot Extincion in 3d
#extract_quantity_3d $scene $threedExt $x1 $x2 $y1 $y2 $z1 $z2 0.025 13 0
#plot_3d $threedExt $Ext $x1 $x2 $y1 $y2 $z1 $z2 10.0 1.0e-5 1.0e+0 2 1.0e-5 1 ext_3d_lookup.ps/vcps

#plot_slice 3dext_lookup_scene.nc Extinction 0.0 10.0 1.0 1.1 0.1 1 2 slice_2km_alt.ps/vcps


#plotting R_eff field, scene that ECSIM has created from inputs
#extract_quantity_3d $scene $threedReff $x1 $x2 $y1 $y2 $z1 $z2 0.025 11 0 #11=reff
#plot_3d $threedReff $Reff $x1 $x2 $y1 $y2 $z1 $z2 10.0 1.0e-5 1.0e+0 2 1.0e-5 0 reff_3d.ps/vcps

#*********** SLICES ***********


# Create an array that represents all grid lines along Y-direction, of the scene
# Bash looping
#

initValue=0
increment=0.1
finalBound=256

for (( ycross0=0; ycross0 < $finalBound; ycross0++ ))
do
 ycross=$(echo "$initValue + ( $increment * $ycross0 )" | bc)
 echo $ycross


echo "***"
echo "Y cross section done here is at grid line: "$ycross
echo "***"

#plotting a vertical slice of R_eff, from scene.uff
extract_quantity $scene $reff_slice $x1 $ycross $x2 $ycross $z1 $z2 0.05 11 0
plot_slice $reff_slice R_eff $x1 $x2 $z1 $z2 1.0e-3 1.0e+1 2 reff_slice_looped_$ycross.ps/vcps

# done
# Loop finished


#plotting a vertical slice of LWC, from scene.uff
extract_quantity $scene $lwc_slice $x1 $ycross $x2 $ycross $z1 $z2 0.05 10 0
plot_slice $lwc_slice Mass_content $x1 $x2 $z1 $z2 1 1 0 lwc_slice_looped_$ycross.ps/vcps

#plotting a vertical slice of Number concentration, from scene.uff
extract_quantity $scene $numb_conc $x1 $ycross $x2 $ycross $z1 $z2 0.05 17 0
plot_slice $numb_conc N_0 $x1 $x2 $z1 $z2 1 1 0 numb_conc_slice_loop_$ycross.ps/vcps


#plotting a vertical slice of SSA (Single-scattering albedo), from scene.uff
extract_quantity $scene $ssa_slice $x1 $ycross $x2 $ycross $z1 $z2 0.05 20 0
plot_slice $ssa_slice $Ssa $x1 $x2 $z1 $z2 0 1e-06 0 ssa_slice_loop_$ycross.ps/vcps

# BETA phase for DSD extraction
#plotting a vertical slice of DSD (Drop Size Distribution), from scene.uff. Experimentalm, added by Igor. Code 23 (from extract_quantity.f90)
extract_quantity $scene $dsd_slice $x1 $ycross $x2 $ycross $z1 $z2 0.05 23 0
plot_slice $dsd_slice $dsd $x1 $x2 $z1 $z2 1 1 0 dsd_slice_loop_$ycross.ps/vcps

done

#******************************

#plotting Mass field, scene that ECSIM has created from inputs
extract_quantity_3d $scene $threedMass $x1 $x2 $y1 $y2 $z1 $z2 0.025 10 0 #10= mass
plot_3d $threedMass $Lwc $x1 $x2 $y1 $y2 $z1 $z2 10.0 1.0e-5 1.0e+0 1 1.0e-5 1 mass_3d.ps/vcps


# Horizontal fields
# Extract and plot LWP ---------------------------------------------------------------------------------
extract_quantity_hor $scene $lwp 10 0
plot_hor $lwp Mass_Path $x1 $x2 $y1 $y2 1 1 2 lwp_hor.ps/vcps
# ------------------------------------------------------------------------------------------------------

# Extract and plot Optical Depth -----------------------------------------------------------------------
extract_quantity_hor $scene $opt_depth 13 0
plot_hor $opt_depth optical_depth_353 $x1 $x2 $y1 $y2 1 1 2 opt_depth.ps/vcps
# ------------------------------------------------------------------------------------------------------



# Convert Post Script files to PNG (custom resolution)
# ******************************************************************************************************
echo $PWD
path_in=$PWD/
mkdir -p $PWD/PNG
mkdir -p $PWD/PS
path_out=$PWD/PNG


mask='*ps'

#`cd $path_in`
#`pwd`#C9F621

flist=`ls $path_in*$mask*`

for f in $flist; do
 echo ...now converting to PNG   $f
 len=${#f}
 s_pos=$(($len-2))
#`convert -units PixelsPerInch -density 150 -rotate -90 $f ${f:0:$s_pos}'png'`
`convert -units PixelsPerInch -density 300 -rotate 0 $f ${f:0:$s_pos}'png'`

done

`mv $path_in*png $path_out`

mv *.ps PS/
# ******************************************************************************************************


