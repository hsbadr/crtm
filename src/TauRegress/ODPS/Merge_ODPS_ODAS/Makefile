#==============================================================================
#
# Makefile for Get_Ref_Profile program
#
#==============================================================================
ROOT=$(CRTM_SOURCE_ROOT)
NETCDF=/apps/netcdf/4.1.3-intel

# -------------
# Define macros
# -------------
include $(ROOT)/make.macros

# This makefile
MAKE_FILE = Makefile

# Executable files
EXE_FILE = Merge_ODPS_ODAS 
#Get_Ref_Profile

# Source files to link
SRC_FILES = Type_Kinds.f90 \
            Message_Handler.f90 \
            Compare_Float_Numbers.f90 \
            File_Utility.f90 \
            Binary_File_Utility.f90 \
            netCDF_Utility.f90 \
            netCDF_Dimension_Utility.f90 \
            netCDF_Variable_Utility.f90 \
            netCDF_Attribute_Utility.f90 \
            Sort_Utility.f90 \
            Compare_Float_Numbers.f90 \
            Endian_Utility.f90 \
            TmpODAS_Define.f90 \
            TmpODAS_netCDF_IO.f90 \
            ODPS_Define.f90 \
            ODPS_netCDF_IO.f90 \
            ODPS_Predictor_Define.f90 \
            ODPS_Predictor.f90 \
            CRTM_Parameters.f90
 

EXE_SRC_FILE = Merge_ODPS_ODAS.f90
                      
  
# Obj files used in link phase
OBJ_FILES = ${SRC_FILES:.f90=.o} \
            ${EXE_SRC_FILE:.f90=.o} 
             

# Include and library definitions
#INCLUDES = -I$(HOME)/local/netcdf/include
#LIBRARIES = -L$(HOME)/local/netcdf/lib -lnetcdf

#INCLUDES = -I$(HOME)/local/netcdf/include
#LIBRARIES = -lessl -L$(HOME)/local/netcdf/lib -lnetcdf 
INCLUDES = -I$(NETCDF)/include
LIBRARIES = -mkl=sequential -L$(NETCDF)/lib -lnetcdff 



# ------------------
# Define dependecies
# ------------------
include $(ROOT)/make.common_targets

# Create and remove source links
create_links::
	@$(LINK_SCRIPT) $(ROOT) $(SRC_FILES)
                   
remove_links::
	@$(UNLINK_SCRIPT) $(SRC_FILES)

# Source dependencies
include make.dependencies


# --------------------
# Define default rules
# --------------------
include $(ROOT)/make.rules
