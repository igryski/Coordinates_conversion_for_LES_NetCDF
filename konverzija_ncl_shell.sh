#!/bin/bash

ncl

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

; Open the file
fin = addfile("/media/ARPS_disk/TUD275152_backup_Feb_2013/data/les_model_output_3d/les_model_output_3d/fielddump_hr20.nc","r")
; Get ql from the file
ql = fin->ql

fout=addfile("/media/ARPS_disk/TUD275152_backup_Feb_2013/data/les_model_output_3d/les_model_output_3d/converted/fielddump_hr20_rev.nc","c")
;ql2 = ql(x|:,y|:,z|:)

;fout->ql2 = (/ql2/)

fout->ql = fin->ql(z|:,y|:,x|:)   ;johan

end

