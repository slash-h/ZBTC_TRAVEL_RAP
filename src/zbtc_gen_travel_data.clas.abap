CLASS zbtc_gen_travel_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZBTC_GEN_TRAVEL_DATA IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

      "Empty the table first
      DELETE FROM zbtc_travel.
      DELETE FROM zbtc_booking.

      "Copy data from /DMO/TRAVEL and Insert in the table
      INSERT zbtc_travel FROM (
         SELECT FROM /dmo/travel
         FIELDS
           uuid( ) as travel_uuid,
           travel_id as travel_id,
           agency_id as agency_id,
           customer_id as customer_id,
           begin_date as begin_date,
           end_date as end_date,
           booking_fee as booking_fee,
           total_price as total_price,
           currency_code as currency_code,
           description as description,
          CASE status
            WHEN 'B' THEN 'A' " accepted
            WHEN 'X' THEN 'X' " cancelled
            ELSE 'O'          " open
          END as overall_status,
          createdby as created_by,
          createdat as created_at,
          lastchangedby as last_changed_by,
          lastchangedat as last_changed_at,
          lastchangedat as local_last_changed_at
          ORDER BY travel_id UP TO 200 ROWS
      ).

      COMMIT WORK.


     "Insert booking data
     INSERT zbtc_booking FROM (
       SELECT FROM /dmo/booking as booking
         JOIN zbtc_travel as z
         ON booking~travel_id = z~travel_id
       FIELDS
         uuid(  ) as booking_uuid,
         z~travel_uuid as travel_uuid,
         booking~booking_id as booking_id,
         booking~booking_date as booking_date,
         booking~customer_id as customer_id,
         booking~carrier_id as carrier_id,
         booking~connection_id as connection_id,
         booking~flight_date as flight_date,
         booking~flight_price as flight_price,
         booking~currency_code as currency_code,
         z~created_by as created_by,
         z~last_changed_by as last_changed_by,
         z~last_changed_at as local_last_changed_at
     ).

     COMMIT WORK.

     out->write( 'Travel and Booking data inserted' ).

  ENDMETHOD.
ENDCLASS.
