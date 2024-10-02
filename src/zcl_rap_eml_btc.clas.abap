CLASS zcl_rap_eml_btc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_rap_eml_btc IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

  " Step 1  -  READ
  READ ENTITIES OF ZI_BTC_Travel
   ENTITY Travel
     FROM VALUE #( (  TravelUUID = '853614445242011419005A0E6B4910BB' ) )
   RESULT DATA(travels).

   out->write(  travels ).
   out->write( '-----------------------------------------------------------------' ).


  " Step 2  -  READ with Fields
  READ ENTITIES OF ZI_BTC_Travel
   ENTITY Travel
     FIELDS (  AgencyID CustomerID )
     WITH VALUE #( (  TravelUUID = '853614445242011419005A0E6B4910BB' ) )
   RESULT DATA(travels_2).

   out->write(  travels_2 ).
   out->write( '-----------------------------------------------------------------' ).


   " Step 3  -  READ with ALL FIELDS
  READ ENTITIES OF ZI_BTC_Travel
   ENTITY Travel
     ALL FIELDS
     WITH VALUE #( (  TravelUUID = '853614445242011419005A0E6B4910BB' ) )
   RESULT DATA(travels_3).

   out->write(  travels_3 ).
   out->write( '-----------------------------------------------------------------' ).

   " Step 4  -  READ By Association
  READ ENTITIES OF ZI_BTC_Travel
   ENTITY Travel BY \_Booking    "Slash followed by association name
     ALL FIELDS
     WITH VALUE #( (  TravelUUID = '853614445242011419005A0E6B4910BB' ) )
   RESULT DATA(travels_with_bookings).

   out->write(  travels_with_bookings ).
   out->write( '-----------------------------------------------------------------' ).

   " Step 5  -  Unsuccessful READ
  READ ENTITIES OF ZI_BTC_Travel
   ENTITY Travel
     ALL FIELDS
     WITH VALUE #( (  TravelUUID = '111111111111111111111111111111' ) )
   RESULT DATA(travels_4)
   FAILED DATA(failed)
   REPORTED DATA(reported).

   out->write(  travels_4 ).
   out->write( failed ).
   out->write( reported ).
   out->write( '-----------------------------------------------------------------' ).

   " Step 6 - MODIFY Update
   MODIFY ENTITIES OF ZI_BTC_Travel
     ENTITY Travel
       UPDATE
         SET FIELDS WITH VALUE #( ( TravelUUID = '853614445242011419005A0E6B4910BB'
                                    Description = 'RAP@openSAP' ) )
     FAILED DATA(failed_2)
     REPORTED DATA(reported_2).

     out->write( 'Update done' ).
     out->write( '-----------------------------------------------------------------' ).

    "Commit the changes
    COMMIT ENTITIES
      RESPONSE OF ZI_BTC_Travel
      FAILED DATA(failed_commit)
      REPORTED DATA(reported_commit).


   " Step 7 - MODIFY CREATE new record
   MODIFY ENTITIES OF ZI_BTC_Travel
     ENTITY Travel
       CREATE
         SET FIELDS WITH VALUE #( ( %cid = 'MyContentID_1'
                                    AgencyID = '70012'
                                    CustomerID = '14'
                                    BeginDate = cl_abap_context_info=>get_system_date( )
                                    EndDate   = cl_abap_context_info=>get_system_date( ) + 10
                                    Description = 'New entry with EML - RAP@openSAP' ) )
     MAPPED DATA(mapped)
     FAILED DATA(failed_3)
     REPORTED DATA(reported_3).

     out->write( mapped-travel ).

    "Commit the changes
    COMMIT ENTITIES
      RESPONSE OF ZI_BTC_Travel
      FAILED DATA(failed_commit_2)
      REPORTED DATA(reported_commit_2).

    out->write( 'Create done' ).
    out->write( '-----------------------------------------------------------------' ).

   " Step 8 - MODIFY DELETE
*   MODIFY ENTITIES OF ZI_BTC_Travel
*     ENTITY Travel
*       DELETE FROM
*         VALUE #( (  TravelUUID =  '42EA189BBC071EDF9F8078E2E8A15A4C' ) )
*
*     FAILED DATA(failed_4)
*     REPORTED DATA(reported_4).
*
*
*    "Commit the changes
*    COMMIT ENTITIES
*      RESPONSE OF ZI_BTC_Travel
*      FAILED DATA(failed_commit_3)
*      REPORTED DATA(reported_commit_3).
*
*    out->write( 'Delete done' ).
*    out->write( '-----------------------------------------------------------------' ).

  ENDMETHOD.

ENDCLASS.
