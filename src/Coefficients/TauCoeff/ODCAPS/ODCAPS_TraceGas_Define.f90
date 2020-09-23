!------------------------------------------------------------------------------
!M+
! NAME:
!       ODCAPS_TraceGas_Define
!
! PURPOSE:
!       Module defining the ODCAPS trace gas data structure and containing routines to 
!       manipulate it.
!       
! CATEGORY:
!       Optical Depth : Coefficients
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       USE ODCAPS_TraceGas_Define
!
! MODULES:
!       Type_Kinds:             Module containing definitions for kinds
!                               of variable types.
!
!       Message_Handler:          Module to define simple error codes and
!                               handle error conditions
!                               USEs: FILE_UTILITY module
!
! CONTAINS:
!       Associated_ODCAPS_TraceGas:    Function to test the association status
!                                      of the pointer members of a ODCAPS_TraceGas
!                                      structure.
!
!       Destroy_ODCAPS_TraceGas:       Function to re-initialize a ODCAPS_TraceGas
!                                      structure.
!
!       Allocate_ODCAPS_TraceGas:      Function to allocate the pointer members
!                                      of a ODCAPS_TraceGas structure.
!
!       Assign_ODCAPS_TraceGas:        Function to copy a valid ODCAPS_TraceGas structure.
!
!
!
! DERIVED TYPES:
!       ODCAPS_TraceGas_type:   Definition of the public ODCAPS_TraceGas data structure. Fields
!                        are...
!
!         n_Layers:            Maximum layers for the aborber coefficients.
!                              "Ilayers" dimension.
!                              UNITS:      N/A
!                              TYPE:       INTEGER( Long )
!                              DIMENSION:  Scalar
!
!         n_Predictors:        Number of predictors used in the
!                              gas absorption regression.
!                              "Iuse" dimension.
!                              UNITS:      N/A
!                              TYPE:       INTEGER( Long )
!                              DIMENSION:  Scalar
!
!         n_Channels:          Total number of spectral channels.
!                              "L" dimension.
!                              UNITS:      N/A
!                              TYPE:       INTEGER( Long )
!                              DIMENSION:  Scalar
!
!         Absorber_ID:         A flag value used to identify the individual
!                              or collective molecular species for which
!                              the gas absorption coefficients were
!                              generated.
!                              UNITS:      N/A
!                              TYPE:       INTEGER( Long )
!                              DIMENSION:  Scalar 
!
!         Channel_Index:       This is the sensor channel number associated
!                              with the data in the coefficient file. Helps
!                              in identifying channels where the numbers are
!                              not contiguous (e.g. AIRS).
!                              UNITS:      N/A
!                              TYPE:       INTEGER
!                              DIMENSION:  Rank-1 (n_Channels)
!                              ATTRIBUTES: POINTER
!
!         Trace_Coeff:         Array containing the gas absorption
!                              model coefficients.
!                              UNITS:      Variable
!                              TYPE:       REAL( Double )
!                              DIMENSION:  Iuse x Ilayer x L
!                              ATTRIBUTES: POINTER
!
!       *!IMPORTANT!*
!       -------------
!       Note that the ODCAPS_TraceGas_type is PUBLIC and its members are not
!       encapsulated; that is, they can be fully accessed outside the
!       scope of this module. This makes it possible to manipulate
!       the structure and its data directly rather than, for e.g., via
!       get() and set() functions. This was done to eliminate the
!       overhead of the get/set type of structure access in using the
!       structure. *But*, it is recommended that the user initialize,
!       destroy, allocate, assign, and concatenate the structure
!       using only the routines in this module where possible to
!       eliminate -- or at least minimise -- the possibility of 
!       memory leakage since most of the structure members are
!       pointers.
!
! INCLUDE FILES:
!       None.
!
! EXTERNALS:
!       None.
!
! COMMON BLOCKS:
!       None.
!
! FILES ACCESSED:
!       None.
!
! CREATION HISTORY:
!       Written by:     Yong Chen, CSU/CIRA 03-May-2006
!                       Yong.Chen@noaa.gov
!
!  Copyright (C) 2006 Yong Chen
!
!  This program is free software; you can redistribute it and/or
!  modify it under the terms of the GNU General Public License
!  as published by the Free Software Foundation; either version 2
!  of the License, or (at your option) any later version.
!
!  This program is distributed in the hope that it will be useful,
!  but WITHOUT ANY WARRANTY; without even the implied warranty of
!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!  GNU General Public License for more details.
!
!  You should have received a copy of the GNU General Public License
!  along with this program; if not, write to the Free Software
!  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
!M-
!------------------------------------------------------------------------------

MODULE ODCAPS_TraceGas_Define


  ! ----------
  ! Module use
  ! ----------

  USE Type_Kinds
  USE Message_Handler


  ! -----------------------
  ! Disable implicit typing
  ! -----------------------

  IMPLICIT NONE


  ! ------------
  ! Visibilities
  ! ------------

  ! -- Everything private by default
  PRIVATE

  ! -- Public procedures to manipulate the ODCAPS_TraceGas structure
  PUBLIC :: Associated_ODCAPS_TraceGas
  PUBLIC :: Destroy_ODCAPS_TraceGas
  PUBLIC :: Allocate_ODCAPS_TraceGas
  PUBLIC :: Assign_ODCAPS_TraceGas
  PUBLIC :: Zero_ODCAPS_TraceGas
 
  ! ---------------------
  ! Procedure overloading
  ! ---------------------

  INTERFACE Destroy_ODCAPS_TraceGas 
    MODULE PROCEDURE Destroy_Scalar
    MODULE PROCEDURE Destroy_Rank1
  END INTERFACE Destroy_ODCAPS_TraceGas 

  INTERFACE Allocate_ODCAPS_TraceGas 
    MODULE PROCEDURE Allocate_Scalar
    MODULE PROCEDURE Allocate_Rank1
  END INTERFACE Allocate_ODCAPS_TraceGas 

  INTERFACE Assign_ODCAPS_TraceGas 
    MODULE PROCEDURE Assign_Scalar
    MODULE PROCEDURE Assign_Rank1
  END INTERFACE Assign_ODCAPS_TraceGas 

  INTERFACE Zero_ODCAPS_TraceGas 
    MODULE PROCEDURE Zero_Scalar
    MODULE PROCEDURE Zero_Rank1
  END INTERFACE Zero_ODCAPS_TraceGas 


  ! -------------------------
  ! PRIVATE Module parameters
  ! -------------------------

  ! -- RCS Id for the module
  CHARACTER( * ), PRIVATE, PARAMETER :: MODULE_RCS_ID = &

  ! -- ODCAPS_TraceGas valid values
  INTEGER, PRIVATE, PARAMETER :: INVALID = -1
  INTEGER, PRIVATE, PARAMETER ::   VALID =  1

  ! -- Keyword set value
  INTEGER, PRIVATE, PARAMETER :: SET = 1


  ! ------------------------
  ! PUBLIC Module parameters
  ! ------------------------

  ! ------------------------------
  ! ODCAPS_TraceGas data type definition
  ! ------------------------------
 
  TYPE, PUBLIC :: ODCAPS_TraceGas_type
    INTEGER :: n_Allocates = 0

    ! -- Array dimensions
    INTEGER( Long ) :: n_Layers       = 0    ! Ilayer	 
    INTEGER( Long ) :: n_Predictors   = 0    ! Iuse	 
    INTEGER( Long ) :: n_Channels     = 0    ! L	 

    ! -- The trace gas ID 
    INTEGER( Long ) :: Absorber_ID    = 0    
   
    ! -- The actual sensor channel numbers
    INTEGER( Long ), POINTER, DIMENSION( : ) :: Channel_Index => NULL()    ! L  value from 1-2378

    ! -- The array of coefficients
    REAL( Single ),  POINTER, DIMENSION( :, :, : ) :: Trace_Coeff => NULL() ! Iuse x Ilayer x L
  END TYPE ODCAPS_TraceGas_type

CONTAINS




!##################################################################################
!##################################################################################
!##                                                                              ##
!##                          ## PRIVATE MODULE ROUTINES ##                       ##
!##                                                                              ##
!##################################################################################
!##################################################################################


!----------------------------------------------------------------------------------
!
! NAME:
!       Clear_ODCAPS_TraceGas
!
! PURPOSE:
!       Subroutine to clear the scalar members of a ODCAPS_TraceGas structure.
!
! CATEGORY:
!       Optical Depth : Coefficients
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       CALL Clear_ODCAPS_TraceGas( ODCAPS_TraceGas ) ! Output
!
! INPUT ARGUMENTS:
!       None.
!
! OPTIONAL INPUT ARGUMENTS:
!       None.
!
! OUTPUT ARGUMENTS:
!       ODCAPS_TraceGas:  ODCAPS_TraceGas structure for which the scalar members have
!                           been cleared.
!                           UNITS:	N/A
!                           TYPE:	ODCAPS_TraceGas_type
!                           DIMENSION:  Scalar
!                           ATTRIBUTES: INTENT( IN OUT )
!
! OPTIONAL OUTPUT ARGUMENTS:
!       None.
!
! CALLS:
!       None.
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
! COMMENTS:
!       Note the INTENT on the output ODCAPS_TraceGas argument is IN OUT rather than
!       just OUT. This is necessary because the argument may be defined upon
!       input. To prevent memory leaks, the IN OUT INTENT is a must.
!
! CREATION HISTORY:
!       Written by:     Yong Chen, CSU/CIRA 03-May-2006
!                       Yong.Chen@noaa.gov
!----------------------------------------------------------------------------------

  SUBROUTINE Clear_ODCAPS_TraceGas( ODCAPS_TraceGas )

    TYPE( ODCAPS_TraceGas_type ), INTENT( IN OUT ) :: ODCAPS_TraceGas

    ODCAPS_TraceGas%n_Layers        = 0   
    ODCAPS_TraceGas%n_Predictors    = 0   
    ODCAPS_TraceGas%n_Channels      = 0   
    
    ODCAPS_TraceGas%Absorber_ID     = 0 
  END SUBROUTINE Clear_ODCAPS_TraceGas





!################################################################################
!################################################################################
!##                                                                            ##
!##                         ## PUBLIC MODULE ROUTINES ##                       ##
!##                                                                            ##
!################################################################################
!################################################################################

!--------------------------------------------------------------------------------
!S+
! NAME:
!       Associated_ODCAPS_TraceGas
!
! PURPOSE:
!       Function to test the association status of the pointer members of a
!       ODCAPS_TraceGas structure.
!
! CATEGORY:
!       Optical Depth : Coefficients
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       Association_Status = Associated_ODCAPS_TraceGas( ODCAPS_TraceGas,           &  ! Input
!                                                 ANY_Test = Any_Test )  ! Optional input
!
! INPUT ARGUMENTS:
!       ODCAPS_TraceGas:    ODCAPS_TraceGas structure which is to have its pointer
!                    member's association status tested.
!                    UNITS:      N/A
!                    TYPE:       ODCAPS_TraceGas_type
!                    DIMENSION:  Scalar
!                    ATTRIBUTES: INTENT( IN )
!
! OPTIONAL INPUT ARGUMENTS:
!       ANY_Test:    Set this argument to test if ANY of the
!                    ODCAPS_TraceGas structure pointer members are associated.
!                    The default is to test if ALL the pointer members
!                    are associated.
!                    If ANY_Test = 0, test if ALL the pointer members
!                                     are associated.  (DEFAULT)
!                       ANY_Test = 1, test if ANY of the pointer members
!                                     are associated.
!
! OUTPUT ARGUMENTS:
!       None.
!
! OPTIONAL OUTPUT ARGUMENTS:
!       None.
!
! FUNCTION RESULT:
!       Association_Status:  The return value is a logical value indicating the
!                            association status of the ODCAPS_TraceGas pointer members.
!                            .TRUE.  - if ALL the ODCAPS_TraceGas pointer members are
!                                      associated, or if the ANY_Test argument
!                                      is set and ANY of the ODCAPS_TraceGas pointer
!                                      members are associated.
!                            .FALSE. - some or all of the ODCAPS_TraceGas pointer
!                                      members are NOT associated.
!                            UNITS:      N/A
!                            TYPE:       LOGICAL
!                            DIMENSION:  Scalar
!
! CALLS:
!       None.
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       This function tests the association status of the ODCAPS_TraceGas
!       structure pointer members. Therefore this function must only
!       be called after the input ODCAPS_TraceGas structure has, at least,
!       had its pointer members initialized.
!
! CREATION HISTORY:
!       Written by:     Yong Chen, CSU/CIRA 03-May-2006
!                       Yong.Chen@noaa.gov
!S-
!--------------------------------------------------------------------------------

  FUNCTION Associated_ODCAPS_TraceGas( ODCAPS_TraceGas,  & ! Input
                                         ANY_Test )          & ! Optional input
                                     RESULT( Association_Status )



    !#--------------------------------------------------------------------------#
    !#                        -- TYPE DECLARATIONS --                           #
    !#--------------------------------------------------------------------------#

    ! ---------
    ! Arguments
    ! ---------

    ! -- Input
    TYPE( ODCAPS_TraceGas_type ), INTENT( IN ) :: ODCAPS_TraceGas

    ! -- Optional input
    INTEGER,     OPTIONAL, INTENT( IN ) :: ANY_Test


    ! ---------------
    ! Function result
    ! ---------------

    LOGICAL :: Association_Status


    ! ---------------
    ! Local variables
    ! ---------------

    LOGICAL :: ALL_Test



    !#--------------------------------------------------------------------------#
    !#                           -- CHECK INPUT --                              #
    !#--------------------------------------------------------------------------#

    ! -- Default is to test ALL the pointer members
    ! -- for a true association status....
    ALL_Test = .TRUE.

    ! ...unless the ANY_Test argument is set.
    IF ( PRESENT( ANY_Test ) ) THEN
      IF ( ANY_Test == SET ) ALL_Test = .FALSE.
    END IF



    !#--------------------------------------------------------------------------#
    !#           -- TEST THE STRUCTURE POINTER MEMBER ASSOCIATION --            #
    !#--------------------------------------------------------------------------#

    Association_Status = .FALSE.

    IF ( ALL_Test ) THEN

      IF ( ASSOCIATED( ODCAPS_TraceGas%Channel_Index     ) .AND. &
           ASSOCIATED( ODCAPS_TraceGas%Trace_Coeff       )       ) THEN
        Association_Status = .TRUE.
      END IF

    ELSE

      IF ( ASSOCIATED( ODCAPS_TraceGas%Channel_Index     ) .OR. &
           ASSOCIATED( ODCAPS_TraceGas%Trace_Coeff       )       ) THEN
        Association_Status = .TRUE.
      END IF

    END IF

  END FUNCTION Associated_ODCAPS_TraceGas





!------------------------------------------------------------------------------
!S+
! NAME:
!       Destroy_ODCAPS_TraceGas
! 
! PURPOSE:
!       Function to re-initialize the scalar and pointer members of ODCAPS_TraceGas
!       data structures.
!
! CATEGORY:
!       Optical Depth : Coefficients
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       Error_Status = Destroy_ODCAPS_TraceGas( ODCAPS_TraceGas,      &  ! Output
!                                               RCS_Id = RCS_Id,	  &  ! Revision control
!                                               Message_Log = Message_Log )  ! Error messaging
!
! INPUT ARGUMENTS:
!       None.
!
! OPTIONAL INPUT ARGUMENTS:
!       Message_Log:  Character string specifying a filename in which any
!                     messages will be logged. If not specified, or if an
!                     error occurs opening the log file, the default action
!                     is to output messages to standard output.
!                     UNITS:      N/A
!                     TYPE:       CHARACTER(*)
!                     DIMENSION:  Scalar
!                     ATTRIBUTES: INTENT( IN ), OPTIONAL
!
! OUTPUT ARGUMENTS:
!       ODCAPS_TraceGas:Re-initialized ODCAPS_TraceGas structure.
!                     UNITS:      N/A
!                     TYPE:       ODCAPS_TraceGas_type
!                     DIMENSION:  Scalar
!                     ATTRIBUTES: INTENT( IN OUT )
!
! OPTIONAL OUTPUT ARGUMENTS:
!       RCS_Id:       Character string containing the Revision Control
!                     System Id field for the module.
!                     UNITS:      N/A
!                     TYPE:       CHARACTER(*)
!                     DIMENSION:  Scalar
!                     ATTRIBUTES: INTENT( OUT ), OPTIONAL
!
! FUNCTION RESULT:
!       Error_Status: The return value is an integer defining the error status.
!                     The error codes are defined in the Message_Handler module.
!                     If == SUCCESS the structure re-initialisation was successful
!                        == FAILURE - an error occurred, or
!                                   - the structure internal allocation counter
!                                     is not equal to zero (0) upon exiting this
!                                     function. This value is incremented and
!                                     decremented for every structure allocation
!                                     and deallocation respectively.
!                     UNITS:      N/A
!                     TYPE:       INTEGER
!                     DIMENSION:  Scalar
!
! CALLS:
!       Associated_ODCAPS_TraceGas:  Function to test the association status of the
!                             pointer members of a ODCAPS_TraceGas structure.
!
!       Display_Message:      Subroutine to output messages
!                             SOURCE: Message_Handler module
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
! COMMENTS:
!       Note the INTENT on the output ODCAPS_TraceGas argument is IN OUT rather than
!       just OUT. This is necessary because the argument may be defined upon
!       input. To prevent memory leaks, the IN OUT INTENT is a must.
!
! CREATION HISTORY:
!       Written by:     Yong Chen, CSU/CIRA 03-May-2006
!                       Yong.Chen@noaa.gov
!S-
!------------------------------------------------------------------------------

  FUNCTION Destroy_Scalar( ODCAPS_TraceGas,  &  ! Output
                           No_Clear,	     &  ! Optional input  
                           RCS_Id,	     &  ! Revision control
                           Message_Log )     &  ! Error messaging 
                          RESULT( Error_Status )	        



    !#--------------------------------------------------------------------------#
    !#                        -- TYPE DECLARATIONS --                           #
    !#--------------------------------------------------------------------------#

    ! ---------
    ! Arguments
    ! ---------

    ! -- Output
    TYPE( ODCAPS_TraceGas_type ),    INTENT( IN OUT ) :: ODCAPS_TraceGas

    ! -- Optional input
    INTEGER,        OPTIONAL, INTENT( IN )     :: No_Clear

    ! -- Revision control
    CHARACTER( * ), OPTIONAL, INTENT( OUT )    :: RCS_Id

    ! - Error messaging
    CHARACTER( * ), OPTIONAL, INTENT( IN )     :: Message_Log


    ! ---------------
    ! Function result
    ! ---------------

    INTEGER :: Error_Status


    ! ----------------
    ! Local parameters
    ! ----------------

    CHARACTER( * ), PARAMETER :: ROUTINE_NAME = 'Destroy_ODCAPS_TraceGas(Scalar)'


    ! ---------------
    ! Local variables
    ! ---------------

    CHARACTER( 256 ) :: message
    LOGICAL :: Clear
    INTEGER :: Allocate_Status



    !#--------------------------------------------------------------------------#
    !#                    -- SET SUCCESSFUL RETURN STATUS --                    #
    !#--------------------------------------------------------------------------#

    Error_Status = SUCCESS



    !#--------------------------------------------------------------------------#
    !#                -- SET THE RCS ID ARGUMENT IF SUPPLIED --                 #
    !#--------------------------------------------------------------------------#

    IF ( PRESENT( RCS_Id ) ) THEN
      RCS_Id = ' '
      RCS_Id = MODULE_RCS_ID
    END IF



    !#--------------------------------------------------------------------------#
    !#                      -- CHECK OPTIONAL ARGUMENTS --                      #
    !#--------------------------------------------------------------------------#

    ! -- Default is to clear scalar members...
    Clear = .TRUE.
    ! -- ....unless the No_Clear argument is set
    IF ( PRESENT( No_Clear ) ) THEN
      IF ( No_Clear == SET ) Clear = .FALSE.
    END IF


    
    !#--------------------------------------------------------------------------#
    !#                     -- PERFORM RE-INITIALISATION --                      #
    !#--------------------------------------------------------------------------#

    ! -----------------------------
    ! Initialise the scalar members
    ! -----------------------------

    IF ( Clear ) CALL Clear_ODCAPS_TraceGas( ODCAPS_TraceGas )


    ! -----------------------------------------------------
    ! If ALL pointer members are NOT associated, do nothing
    ! -----------------------------------------------------

    IF ( .NOT. Associated_ODCAPS_TraceGas( ODCAPS_TraceGas ) ) RETURN


    ! ------------------------------
    ! Deallocate the pointer members
    ! ------------------------------

    ! -- Deallocate the sensor channel number array
    IF ( ASSOCIATED( ODCAPS_TraceGas%Channel_Index ) ) THEN

      DEALLOCATE( ODCAPS_TraceGas%Channel_Index, STAT = Allocate_Status )

      IF ( Allocate_Status /= 0 ) THEN
        Error_Status = FAILURE
        WRITE( Message, '( "Error deallocating ODCAPS_TraceGas Channel_Index ", &
                          &"member. STAT = ", i5 )' ) &
                        Allocate_Status
        CALL Display_Message( ROUTINE_NAME,    &
                              TRIM( Message ), &
                              Error_Status,    &
                              Message_Log = Message_Log )
      END IF
    END IF

    ! -- Deallocate coefficients
    IF ( ASSOCIATED( ODCAPS_TraceGas%Trace_Coeff ) ) THEN

      DEALLOCATE( ODCAPS_TraceGas%Trace_Coeff, STAT = Allocate_Status )

      IF ( Allocate_Status /= 0 ) THEN
        Error_Status = FAILURE
        WRITE( Message, '( "Error deallocating ODCAPS_TraceGas coefficients ", &
                          &"member. STAT = ", i5 )' ) &
                        Allocate_Status
        CALL Display_Message( ROUTINE_NAME,    &
                              TRIM( Message ), &
                              Error_Status,    &
                              Message_Log = Message_Log )
      END IF
    END IF


    !#--------------------------------------------------------------------------#
    !#               -- DECREMENT AND TEST ALLOCATION COUNTER --                #
    !#--------------------------------------------------------------------------#

    ODCAPS_TraceGas%n_Allocates = ODCAPS_TraceGas%n_Allocates - 1

    IF ( ODCAPS_TraceGas%n_Allocates /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Allocation counter /= 0, Value = ", i5 )' ) &
                      ODCAPS_TraceGas%n_Allocates
      CALL Display_Message( ROUTINE_NAME,    &
                            TRIM( Message ), &
                            Error_Status,    &
                            Message_Log = Message_Log )
    END IF

  END FUNCTION Destroy_Scalar 


  FUNCTION Destroy_Rank1( ODCAPS_TraceGas, &  ! Output
                           No_Clear,	     &  ! Optional input  
                           RCS_Id,	     &  ! Revision control
                           Message_Log )     &  ! Error messaging 
                          RESULT( Error_Status )	        


    !#--------------------------------------------------------------------------#
    !#                        -- TYPE DECLARATIONS --                           #
    !#--------------------------------------------------------------------------#

    ! ---------
    ! Arguments
    ! ---------

    ! -- Output
    TYPE( ODCAPS_TraceGas_type ), DIMENSION( : ), INTENT( IN OUT ) :: ODCAPS_TraceGas

    ! -- Optional input
    INTEGER,        OPTIONAL, INTENT( IN )     :: No_Clear

    ! -- Revision control
    CHARACTER( * ), OPTIONAL, INTENT( OUT )    :: RCS_Id

    ! - Error messaging
    CHARACTER( * ), OPTIONAL, INTENT( IN )     :: Message_Log


    ! ---------------
    ! Function result
    ! ---------------

    INTEGER :: Error_Status


    ! ----------------
    ! Local parameters
    ! ----------------

    CHARACTER( * ), PARAMETER :: ROUTINE_NAME = 'Destroy_ODCAPS_TraceGas(Rank-1)'


    ! ---------------
    ! Local variables
    ! ---------------

    CHARACTER( 256 ) :: message
    INTEGER :: Scalar_Status
    INTEGER :: n



    !#--------------------------------------------------------------------------#
    !#                    -- SET SUCCESSFUL RETURN STATUS --                    #
    !#--------------------------------------------------------------------------#

    Error_Status = SUCCESS



    !#--------------------------------------------------------------------------#
    !#                -- SET THE RCS ID ARGUMENT IF SUPPLIED --                 #
    !#--------------------------------------------------------------------------#

    IF ( PRESENT( RCS_Id ) ) THEN
      RCS_Id = ' '
      RCS_Id = MODULE_RCS_ID
    END IF


    !#--------------------------------------------------------------------------#
    !#                       -- PERFORM REINITIALISATION --                     #
    !#--------------------------------------------------------------------------#

    DO n = 1, SIZE( ODCAPS_TraceGas )

      Scalar_Status = Destroy_Scalar( ODCAPS_TraceGas(n), &
                                      No_Clear = No_Clear, &
                                      Message_Log = Message_Log )

      IF ( Scalar_Status /= SUCCESS ) THEN
        Error_Status = Scalar_Status
        WRITE( Message, '( "Error destroying element #", i5, &
                          &" of ODCAPS_TraceGas structure array." )' ) n
        CALL Display_Message( ROUTINE_NAME, &
                              TRIM( Message ), &
                              Error_Status, &
                              Message_Log = Message_Log )
      END IF

    END DO

  END FUNCTION Destroy_Rank1



!------------------------------------------------------------------------------
!S+
! NAME:
!       Allocate_ODCAPS_TraceGas
! 
! PURPOSE:
!       Function to allocate the pointer members of the ODCAPS_TraceGas
!       data structure.
!
! CATEGORY:
!       Optical Depth : Coefficients
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       Error_Status = Allocate_ODCAPS_TraceGas( n_Layers,                &  ! Input	        
!                                                n_Predictors,	          &  ! Input	        
!                                                n_Channels,		  &  ! Input	        
!                                                ODCAPS_TraceGas,	  &  ! Output	        
!                                                RCS_Id      = RCS_Id,    &  ! Revision control
!                                                Message_Log = Message_Log)  ! Error messaging 
!
! INPUT ARGUMENTS:
!         n_Layers:            Maximum layers for the aborber coefficients.
!                              "Ilayers" dimension.
!                              UNITS:      N/A
!                              TYPE:       INTEGER( Long )
!                              DIMENSION:  Scalar
!
!         n_Predictors:        Number of predictors used in the
!                              gas absorption regression.
!                              "Iuse" dimension.
!                              UNITS:      N/A
!                              TYPE:       INTEGER( Long )
!                              DIMENSION:  Scalar
!
!         n_Channels:          Total number of spectral channels.
!                              "L" dimension.
!                              UNITS:      N/A
!                              TYPE:       INTEGER( Long )
!                              DIMENSION:  Scalar
!
! OPTIONAL INPUT ARGUMENTS:
!       Message_Log:  Character string specifying a filename in
!                     which any messages will be logged. If not
!                     specified, or if an error occurs opening
!                     the log file, the default action is to
!                     output messages to standard output.
!                     UNITS:      N/A
!                     TYPE:       CHARACTER(*)
!                     DIMENSION:  Scalar
!                     ATTRIBUTES: INTENT( IN ), OPTIONAL
!
! OUTPUT ARGUMENTS:
!       ODCAPS_TraceGas:     ODCAPS_TraceGas structure with allocated
!                     pointer members
!                     UNITS:      N/A
!                     TYPE:       ODCAPS_TraceGas_type
!                     DIMENSION:  Scalar
!                     ATTRIBUTES: INTENT( OUT )
!
!
! OPTIONAL OUTPUT ARGUMENTS:
!       RCS_Id:       Character string containing the Revision Control
!                     System Id field for the module.
!                     UNITS:      N/A
!                     TYPE:       CHARACTER(*)
!                     DIMENSION:  Scalar
!                     ATTRIBUTES: INTENT( OUT ), OPTIONAL
!
! FUNCTION RESULT:
!       Error_Status: The return value is an integer defining the error status.
!                     The error codes are defined in the Message_Handler module.
!                     If == SUCCESS the structure re-initialisation was successful
!                        == FAILURE - an error occurred, or
!                                   - the structure internal allocation counter
!                                     is not equal to one (1) upon exiting this
!                                     function. This value is incremented and
!                                     decremented for every structure allocation
!                                     and deallocation respectively.
!                     UNITS:      N/A
!                     TYPE:       INTEGER
!                     DIMENSION:  Scalar
!
! CALLS:
!       Associated_ODCAPS_TraceGas:  Function to test the association status of the
!                             pointer members of a ODCAPS_TraceGas structure.
!
!       Destroy_ODCAPS_TraceGas:     Function to re-initialize the scalar and pointer
!                             members of ODCAPS_TraceGas data structures.
!
!       Display_Message:      Subroutine to output messages
!                             SOURCE: Message_Handler module
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
! COMMENTS:
!       Note the INTENT on the output ODCAPS_TraceGas argument is IN OUT rather than
!       just OUT. This is necessary because the argument may be defined upon
!       input. To prevent memory leaks, the IN OUT INTENT is a must.
!
! CREATION HISTORY:
!       Written by:     Yong Chen, CSU/CIRA 03-May-2006
!                       Yong.Chen@noaa.gov
!S-
!------------------------------------------------------------------------------

  FUNCTION Allocate_Scalar(n_Layers,		    &  ! Input	       
                  	   n_Predictors,            &  ! Input  	          
                  	   n_Channels,  	    &  ! Input  	          
                  	   ODCAPS_TraceGas,	    &  ! Output 	          
                  	   RCS_Id ,                 &  ! Revision control         
                  	   Message_Log  )           &  ! Error messaging          
                  	RESULT( Error_Status )  			          



    !#--------------------------------------------------------------------------#
    !#                        -- TYPE DECLARATIONS --                           #
    !#--------------------------------------------------------------------------#

    ! ---------
    ! Arguments
    ! ---------

    ! -- Input
    INTEGER,                  INTENT( IN )     :: n_Layers 
    INTEGER,                  INTENT( IN )     :: n_Predictors
    INTEGER,                  INTENT( IN )     :: n_Channels

    ! -- Output
    TYPE( ODCAPS_TraceGas_type ),    INTENT( IN OUT ) :: ODCAPS_TraceGas

    ! -- Revision control
    CHARACTER( * ), OPTIONAL, INTENT( OUT )    :: RCS_Id

    ! - Error messaging
    CHARACTER( * ), OPTIONAL, INTENT( IN )     :: Message_Log


    ! ---------------
    ! Function result
    ! ---------------

    INTEGER :: Error_Status


    ! ----------------
    ! Local parameters
    ! ----------------

    CHARACTER( * ), PARAMETER :: ROUTINE_NAME = 'Allocate_ODCAPS_TraceGas(Scalar)'


    ! ---------------
    ! Local variables
    ! ---------------

    CHARACTER( 256 ) :: message

    INTEGER :: Allocate_Status



    !#--------------------------------------------------------------------------#
    !#                    -- SET SUCCESSFUL RETURN STATUS --                    #
    !#--------------------------------------------------------------------------#

    Error_Status = SUCCESS



    !#--------------------------------------------------------------------------#
    !#                -- SET THE RCS ID ARGUMENT IF SUPPLIED --                 #
    !#--------------------------------------------------------------------------#

    IF ( PRESENT( RCS_Id ) ) THEN
      RCS_Id = ' '
      RCS_Id = MODULE_RCS_ID
    END IF



    !#--------------------------------------------------------------------------#
    !#                            -- CHECK INPUT --                             #
    !#--------------------------------------------------------------------------#

    ! ----------
    ! Dimensions
    ! ----------

    IF ( n_Layers           < 1 .OR. &
         n_Predictors       < 1 .OR. &
         n_Channels         < 1      ) THEN
      Error_Status = FAILURE
      CALL Display_Message( ROUTINE_NAME, &
                            'Input ODCAPS_TraceGas dimensions must all be > 0.', &
                            Error_Status, &
                            Message_Log = Message_Log )
      RETURN
    END IF


    ! -----------------------------------------------
    ! Check if ANY pointers are already associated.
    ! If they are, deallocate them but leave scalars.
    ! -----------------------------------------------

    IF ( Associated_ODCAPS_TraceGas( ODCAPS_TraceGas, ANY_Test = SET ) ) THEN

      Error_Status = Destroy_ODCAPS_TraceGas( ODCAPS_TraceGas, &
                                       No_Clear = SET, &
                                       Message_Log = Message_Log )

      IF ( Error_Status /= SUCCESS ) THEN
        CALL Display_Message( ROUTINE_NAME,    &
                              'Error deallocating ODCAPS_TraceGas pointer members.', &
                              Error_Status,    &
                              Message_Log = Message_Log )
        RETURN
      END IF

    END IF



    !#--------------------------------------------------------------------------#
    !#                       -- PERFORM THE ALLOCATION --                       #
    !#--------------------------------------------------------------------------#

    ALLOCATE( ODCAPS_TraceGas%Channel_Index( n_Channels ), &
              ODCAPS_TraceGas%Trace_Coeff( n_Predictors, n_Layers, n_Channels ), &
              STAT = Allocate_Status )

    IF ( Allocate_Status /= 0 ) THEN
      Error_Status = FAILURE
      WRITE( Message, '( "Error allocating ODCAPS_TraceGas data arrays. STAT = ", i5 )' ) &
                      Allocate_Status
      CALL Display_Message( ROUTINE_NAME,    &
                            TRIM( Message ), &
                            Error_Status,    &
                            Message_Log = Message_Log )
      RETURN
    END IF


    !#--------------------------------------------------------------------------#
    !#                        -- ASSIGN THE DIMENSIONS --                       #
    !#--------------------------------------------------------------------------#

    ODCAPS_TraceGas%n_Layers     = n_Layers
    ODCAPS_TraceGas%n_Predictors = n_Predictors
    ODCAPS_TraceGas%n_Channels   = n_Channels



    !#--------------------------------------------------------------------------#
    !#                -- INCREMENT AND TEST ALLOCATION COUNTER --               #
    !#--------------------------------------------------------------------------#

    ODCAPS_TraceGas%n_Allocates = ODCAPS_TraceGas%n_Allocates + 1

    IF ( ODCAPS_TraceGas%n_Allocates /= 1 ) THEN
      Error_Status = WARNING
      WRITE( Message, '( "Allocation counter /= 1, Value = ", i5 )' ) &
                      ODCAPS_TraceGas%n_Allocates
      CALL Display_Message( ROUTINE_NAME,    &
                            TRIM( Message ), &
                            Error_Status,    &
                            Message_Log = Message_Log )
    END IF

  END FUNCTION Allocate_Scalar 


  FUNCTION Allocate_Rank1(n_Layers,		    &  ! Input	       
                  	   n_Predictors,            &  ! Input  	          
                   	   n_Channels,  	    &  ! Input  	          
                  	   ODCAPS_TraceGas,	    &  ! Output 	          
                  	   RCS_Id,                  &  ! Revision control         
                  	   Message_Log)             &  ! Error messaging          
                  	RESULT( Error_Status )  			          



    !#--------------------------------------------------------------------------#
    !#                        -- TYPE DECLARATIONS --                           #
    !#--------------------------------------------------------------------------#

    ! ---------
    ! Arguments
    ! ---------

    ! -- Input
    INTEGER,                  INTENT( IN )     :: n_Layers 
    INTEGER,                  INTENT( IN )     :: n_Predictors
    INTEGER,                  INTENT( IN )     :: n_Channels

    ! -- Output
    TYPE( ODCAPS_TraceGas_type ), DIMENSION( : ), INTENT( IN OUT ) :: ODCAPS_TraceGas

    ! -- Revision control
    CHARACTER( * ), OPTIONAL, INTENT( OUT )    :: RCS_Id

    ! - Error messaging
    CHARACTER( * ), OPTIONAL, INTENT( IN )     :: Message_Log


    ! ---------------
    ! Function result
    ! ---------------

    INTEGER :: Error_Status


    ! ----------------
    ! Local parameters
    ! ----------------

    CHARACTER( * ), PARAMETER :: ROUTINE_NAME = 'Allocate_ODCAPS_TraceGas(Rank-1)'


    ! ---------------
    ! Local variables
    ! ---------------

    CHARACTER( 256 ) :: message

    INTEGER :: Scalar_Status
    INTEGER :: i



    !#--------------------------------------------------------------------------#
    !#                    -- SET SUCCESSFUL RETURN STATUS --                    #
    !#--------------------------------------------------------------------------#

    Error_Status = SUCCESS



    !#--------------------------------------------------------------------------#
    !#                -- SET THE RCS ID ARGUMENT IF SUPPLIED --                 #
    !#--------------------------------------------------------------------------#

    IF ( PRESENT( RCS_Id ) ) THEN
      RCS_Id = ' '
      RCS_Id = MODULE_RCS_ID
    END IF


    !#--------------------------------------------------------------------------#
    !#                       -- PERFORM THE ALLOCATION --                       #
    !#--------------------------------------------------------------------------#

    DO i = 1, SIZE( ODCAPS_TraceGas )

      Scalar_Status = Allocate_Scalar( n_Layers, &
                                       n_Predictors, &
                                       n_Channels, &
				       ODCAPS_TraceGas(i), &
                                       Message_Log = Message_Log )


      IF ( Scalar_Status /= SUCCESS ) THEN
        Error_Status = Scalar_Status
        WRITE( Message, '( "Error allocating element #", i5, &
                          &" of ODCAPS_TraceGas structure array." )' ) i
        CALL Display_Message( ROUTINE_NAME, &
                              TRIM( Message ), &
                              Error_Status, &
                              Message_Log = Message_Log )
      END IF

    END DO

  END FUNCTION Allocate_Rank1



!------------------------------------------------------------------------------
!S+
! NAME:
!       Assign_ODCAPS_TraceGas
!
! PURPOSE:
!       Function to copy valid ODCAPS_TraceGas structures.
!
! CATEGORY:
!       Optical Depth : Coefficients
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE:
!       Error_Status = Assign_ODCAPS_TraceGas( ODCAPS_TraceGas_in,       &  ! Input
!                                              ODCAPS_TraceGas_out,	 &  ! Output    
!                                              RCS_Id	   = RCS_Id,	 &  ! Revision control 
!                                              Message_Log = Message_Log )  ! Error messaging  
!
! INPUT ARGUMENTS:
!       ODCAPS_TraceGas_in:   ODCAPS_TraceGas structure which is to be copied.
!                      UNITS:      N/A
!                      TYPE:       ODCAPS_TraceGas_type
!                      DIMENSION:  Scalar
!                      ATTRIBUTES: INTENT( IN )
!
! OPTIONAL INPUT ARGUMENTS:
!       Message_Log:   Character string specifying a filename in which any
!                      messages will be logged. If not specified, or if an
!                      error occurs opening the log file, the default action
!                      is to output messages to standard output.
!                      UNITS:      N/A
!                      TYPE:       CHARACTER(*)
!                      DIMENSION:  Scalar
!                      ATTRIBUTES: INTENT( IN ), OPTIONAL
!
! OUTPUT ARGUMENTS:
!       ODCAPS_TraceGas_out:  Copy of the input structure, ODCAPS_TraceGas_in.
!                      UNITS:      N/A
!                      TYPE:       ODCAPS_TraceGas_type
!                      DIMENSION:  Scalar
!                      ATTRIBUTES: INTENT( IN OUT )
!
!
! OPTIONAL OUTPUT ARGUMENTS:
!       RCS_Id:        Character string containing the Revision Control
!                      System Id field for the module.
!                      UNITS:      N/A
!                      TYPE:       CHARACTER(*)
!                      DIMENSION:  Scalar
!                      ATTRIBUTES: INTENT( OUT ), OPTIONAL
!
! FUNCTION RESULT:
!       Error_Status: The return value is an integer defining the error status.
!                     The error codes are defined in the Message_Handler module.
!                     If == SUCCESS the structure assignment was successful
!                        == FAILURE an error occurred
!                     UNITS:      N/A
!                     TYPE:       INTEGER
!                     DIMENSION:  Scalar
!
! CALLS:
!       Associated_ODCAPS_TraceGas:  Function to test the association status of the
!                             pointer members of a ODCAPS_TraceGas structure.
!
!       Allocate_ODCAPS_TraceGas:    Function to allocate the pointer members of
!                             the ODCAPS_TraceGas data structure.
!
!       Display_Message:      Subroutine to output messages
!                             SOURCE: Message_Handler module
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
! COMMENTS:
!       Note the INTENT on the output ODCAPS_TraceGas argument is IN OUT rather than
!       just OUT. This is necessary because the argument may be defined upon
!       input. To prevent memory leaks, the IN OUT INTENT is a must.
!
! CREATION HISTORY:
!       Written by:     Yong Chen, CSU/CIRA 03-May-2006
!                       Yong.Chen@noaa.gov
!S-
!------------------------------------------------------------------------------

  FUNCTION Assign_Scalar( ODCAPS_TraceGas_in,   &  ! Input     
                          ODCAPS_TraceGas_out,  &  ! Output      
                          RCS_Id,	 &  ! Revision control   
                          Message_Log )  &  ! Error messaging    
                        RESULT( Error_Status )		        



    !#--------------------------------------------------------------------------#
    !#                        -- TYPE DECLARATIONS --                           #
    !#--------------------------------------------------------------------------#

    ! ---------
    ! Arguments
    ! ---------

    ! -- Input
    TYPE( ODCAPS_TraceGas_type ),    INTENT( IN )     :: ODCAPS_TraceGas_in

    ! -- Output
    TYPE( ODCAPS_TraceGas_type ),    INTENT( IN OUT ) :: ODCAPS_TraceGas_out

    ! -- Revision control
    CHARACTER( * ), OPTIONAL, INTENT( OUT )    :: RCS_Id

    ! - Error messaging
    CHARACTER( * ), OPTIONAL, INTENT( IN )     :: Message_Log


    ! ---------------
    ! Function result
    ! ---------------

    INTEGER :: Error_Status


    ! ----------------
    ! Local parameters
    ! ----------------

    CHARACTER( * ), PARAMETER :: ROUTINE_NAME = 'Assign_ODCAPS_TraceGas(Scalar)'



    !#--------------------------------------------------------------------------#
    !#                -- SET THE RCS ID ARGUMENT IF SUPPLIED --                 #
    !#--------------------------------------------------------------------------#

    IF ( PRESENT( RCS_Id ) ) THEN
      RCS_Id = ' '
      RCS_Id = MODULE_RCS_ID
    END IF


    !#--------------------------------------------------------------------------#
    !#           -- TEST THE STRUCTURE ARGUMENT POINTER ASSOCIATION --          #
    !#--------------------------------------------------------------------------#

    ! ---------------------------------------
    ! ALL *input* pointers must be associated
    !
    ! If this test succeeds, then some or all of the
    ! input pointers are NOT associated, so destroy
    ! the output structure and return.
    ! ---------------------------------------

    IF ( .NOT. Associated_ODCAPS_TraceGas( ODCAPS_TraceGas_In ) ) THEN

      Error_Status = Destroy_ODCAPS_TraceGas( ODCAPS_TraceGas_Out, &
                                         Message_Log = Message_Log )
      IF ( Error_Status /= SUCCESS ) THEN 
       CALL Display_Message( ROUTINE_NAME,    &
                            'Some or all INPUT ODCAPS_TraceGas pointer '//&
                            'members are NOT associated.', &
                            Error_Status,    &
                            Message_Log = Message_Log )
      END IF
      
      RETURN
    END IF



    !#--------------------------------------------------------------------------#
    !#                       -- PERFORM THE ASSIGNMENT --                       #
    !#--------------------------------------------------------------------------#

    ! ----------------------
    ! Allocate the structure
    ! ----------------------

    Error_Status = Allocate_ODCAPS_TraceGas( ODCAPS_TraceGas_In%n_Layers, &
                                             ODCAPS_TraceGas_In%n_Predictors, &
                                             ODCAPS_TraceGas_In%n_Channels, &
                                             ODCAPS_TraceGas_Out, &
                                             Message_Log = Message_Log ) 
    IF ( Error_Status /= SUCCESS ) THEN
      CALL Display_Message( ROUTINE_NAME, &
                            'Error allocating output ODCAPS_TraceGas arrays.', &
                            Error_Status, &
                            Message_Log = Message_Log )
      RETURN
    END IF

    ! -----------------------------------
    ! Assign non-dimension scalar members
    ! -----------------------------------

    ODCAPS_TraceGas_out%Absorber_ID = ODCAPS_TraceGas_in%Absorber_ID


    ! -----------------
    ! Assign array data
    ! -----------------
    ODCAPS_TraceGas_out%Channel_Index  = ODCAPS_TraceGas_in%Channel_Index	 
    ODCAPS_TraceGas_out%Trace_Coeff    = ODCAPS_TraceGas_in%Trace_Coeff	 

  END FUNCTION Assign_Scalar 



  FUNCTION Assign_Rank1(  ODCAPS_TraceGas_in,   &  ! Input     
                          ODCAPS_TraceGas_out,  &  ! Output      
                          RCS_Id,	 &  ! Revision control   
                          Message_Log )  &  ! Error messaging    
                        RESULT( Error_Status )		        



    !#--------------------------------------------------------------------------#
    !#                        -- TYPE DECLARATIONS --                           #
    !#--------------------------------------------------------------------------#

    ! ---------
    ! Arguments
    ! ---------

    ! -- Input
    TYPE( ODCAPS_TraceGas_type ),  DIMENSION( : ), INTENT( IN )     :: ODCAPS_TraceGas_in

    ! -- Output
    TYPE( ODCAPS_TraceGas_type ),  DIMENSION( : ), INTENT( IN OUT ) :: ODCAPS_TraceGas_out

    ! -- Revision control
    CHARACTER( * ), OPTIONAL, INTENT( OUT )    :: RCS_Id

    ! - Error messaging
    CHARACTER( * ), OPTIONAL, INTENT( IN )     :: Message_Log


    ! ---------------
    ! Function result
    ! ---------------

    INTEGER :: Error_Status


    ! ----------------
    ! Local parameters
    ! ----------------

    CHARACTER( * ), PARAMETER :: ROUTINE_NAME = 'Assign_ODCAPS_TraceGas(Rank-1)'

    ! ---------------
    ! Local variables
    ! ---------------

    CHARACTER( 256 ) :: message

    INTEGER :: Scalar_Status
    INTEGER :: i, n



    !#--------------------------------------------------------------------------#
    !#                -- SET THE RCS ID ARGUMENT IF SUPPLIED --                 #
    !#--------------------------------------------------------------------------#

    IF ( PRESENT( RCS_Id ) ) THEN
      RCS_Id = ' '
      RCS_Id = MODULE_RCS_ID
    END IF



    !#--------------------------------------------------------------------------#
    !#                    -- SET SUCCESSFUL RETURN STATUS --                    #
    !#--------------------------------------------------------------------------#

    Error_Status = SUCCESS



    !#--------------------------------------------------------------------------#
    !#                -- SET THE RCS ID ARGUMENT IF SUPPLIED --                 #
    !#--------------------------------------------------------------------------#

    IF ( PRESENT( RCS_Id ) ) THEN
      RCS_Id = ' '
      RCS_Id = MODULE_RCS_ID
    END IF


    !#--------------------------------------------------------------------------#
    !#                               -- TEST THE INPUT --                       #
    !#--------------------------------------------------------------------------#

    n = SIZE( ODCAPS_TraceGas_in )

    IF ( SIZE( ODCAPS_TraceGas_out ) /= n ) THEN
      Error_Status = FAILURE
      CALL Display_Message( ROUTINE_NAME, &
                            'Input ODCAPS_TraceGas_in and ODCAPS_TraceGas_out '//&
			    'arrays have different dimensions', &
                            Error_Status, &
                            Message_Log = Message_Log )
      RETURN
    END IF


    !#--------------------------------------------------------------------------#
    !#                       -- PERFORM THE ALLOCATION --                       #
    !#--------------------------------------------------------------------------#

    DO i = 1, n 

      Scalar_Status = Assign_Scalar(   ODCAPS_TraceGas_in(i), & 
				       ODCAPS_TraceGas_out(i), &
                                       Message_Log = Message_Log )


      IF ( Scalar_Status /= SUCCESS ) THEN
        Error_Status = Scalar_Status
        WRITE( Message, '( "Error copying element #", i5, &
                          &" of ODCAPS_TraceGas structure array." )' ) i
        CALL Display_Message( ROUTINE_NAME, &
                              TRIM( Message ), &
                              Error_Status, &
                              Message_Log = Message_Log )
      END IF

    END DO
  END FUNCTION Assign_Rank1

!--------------------------------------------------------------------------------
!S+
! NAME:
!       Zero_ODCAPS_TraceGas
! 
! PURPOSE:
!       Subroutine to zero-out all members of a ODCAPS_TraceGas structure - both
!       scalar and pointer.
!
! CATEGORY:
!       Optical Depth : Coefficients: subset
!
! LANGUAGE:
!       Fortran-95
!
! CALLING SEQUENCE: 
!       CALL Zero_ODCAPS_TraceGas( ODCAPS_TraceGas)
!
! INPUT ARGUMENTS:
!       None.
!
! OPTIONAL INPUT ARGUMENTS:
!       None.
!
! OUTPUT ARGUMENTS:
!       ODCAPS_TraceGas:Zero ODCAPS_TraceGas structure.
!                     UNITS:      N/A
!                     TYPE:       ODCAPS_TraceGas_type
!                     DIMENSION:  Scalar
!                                   OR
!                                 Rank1 array
!                     ATTRIBUTES: INTENT( IN OUT )
!
! OPTIONAL OUTPUT ARGUMENTS:
!       None.
!
! CALLS:
!       None.
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       - No checking of the input structure is performed, so there are no
!         tests for pointer member association status. This means the Cloud
!         structure must have allocated pointer members upon entry to this
!         routine.
!
!       - The dimension components of the structure are *NOT*
!         set to zero.
!
!       - The cloud type component is *NOT* reset.
!
! COMMENTS:
!       Note the INTENT on the output ODCAPS_TraceGas argument is IN OUT rather than
!       just OUT. This is necessary because the argument must be defined upon
!       input.
!
! CREATION HISTORY:
!       Written by:     Yong Chen, CSU/CIRA 03-May-2006
!                       Yong.Chen@noaa.gov
!S-
!--------------------------------------------------------------------------------

  SUBROUTINE Zero_Scalar( ODCAPS_TraceGas )  ! Output
    TYPE( ODCAPS_TraceGas_type ),  INTENT( IN OUT ) :: ODCAPS_TraceGas

    ! -- Reset the array components
    ODCAPS_TraceGas%Channel_Index      = 0  
    ODCAPS_TraceGas%Trace_Coeff        = 0.0
 
  END SUBROUTINE Zero_Scalar


  SUBROUTINE Zero_Rank1( ODCAPS_TraceGas )  ! Output

    TYPE( ODCAPS_TraceGas_type ), DIMENSION( : ), INTENT( IN OUT ) :: ODCAPS_TraceGas
    INTEGER :: n

    DO n = 1, SIZE( ODCAPS_TraceGas )
      CALL Zero_Scalar( ODCAPS_TraceGas(n) )
    END DO

  END SUBROUTINE Zero_Rank1


END MODULE ODCAPS_TraceGas_Define
