CLASS zcl_ce_btc_agency DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    INTERFACES if_rap_query_provider.

    TYPES t_agency_range TYPE RANGE OF zsc_btc_agency=>tys_z_travel_agency_es_5_type-agency_id.
    TYPES t_business_data TYPE TABLE OF zsc_btc_agency=>tys_z_travel_agency_es_5_type.

    METHODS get_agencies
        IMPORTING
            filter_cond     TYPE if_rap_query_filter=>tt_name_range_pairs OPTIONAL
            top             TYPE i OPTIONAL
            skip            TYPE i OPTIONAL
            is_data_requested   TYPE abap_bool
            is_count_requested  TYPE abap_bool OPTIONAL
        EXPORTING
            business_data       TYPE t_business_data
            count               TYPE int8
        RAISING
            /iwbep/cx_cp_remote
            /iwbep/cx_gateway
            cx_web_http_client_error
            cx_http_dest_provider_error.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ce_btc_agency IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA business_data TYPE t_business_data.
    DATA count TYPE int8.
    DATA filter_condition TYPE if_rap_query_filter=>tt_name_range_pairs.
    DATA ranges_table TYPE if_rap_query_filter=>tt_range_option.

    ranges_table = VALUE #( ( sign = 'I' option = 'GE' low = '070015' ) ).
    filter_condition = VALUE #( ( name = 'AGENCY_ID' range = ranges_table ) ).

    try.

        get_agencies(
          EXPORTING
            filter_cond        = filter_condition
            top                = 3
            skip               = 1
            is_data_requested  = abap_true
            is_count_requested = abap_true
          IMPORTING
            business_data      = business_data
            count              = count
        ).

        out->write( |Total number of records = { count }| ).
        out->write( business_data ).

      catch cx_root into data(exception).

        out->write( cl_message_helper=>get_latest_t100_exception( exception )->if_message~get_longtext( ) ).
    endtry.

  ENDMETHOD.

  METHOD get_agencies.

    DATA: filter_factory TYPE REF TO /iwbep/if_cp_filter_factory,
          filter_node TYPE REF TO /iwbep/if_cp_filter_node,
          root_filter_node TYPE REF TO /iwbep/if_cp_filter_node.

    DATA: http_client TYPE REF TO if_web_http_client,
          odata_client_proxy TYPE REF TO /iwbep/if_cp_client_proxy,
          read_list_request TYPE REF TO /iwbep/if_cp_request_read_list,
          read_list_response TYPE REF TO /iwbep/if_cp_response_read_lst.


    DATA service_consumption_name TYPE cl_web_odata_client_factory=>ty_service_definition_name.

    " Since it is not possible to test http connection in trial environment, we use create_by_url to create and simulate the http connection.
    DATA(http_destination) = cl_http_destination_provider=>create_by_url( i_url = 'https://sapes5.sapdevcenter.com' ).
    http_client = cl_web_http_client_manager=>create_by_http_destination( i_destination = http_destination ).

    service_consumption_name = to_upper( 'ZSC_BTC_AGENCY' ).

     "this code from the opensap course doen not work, so it is replace by below code taken from the generated sample code of
     " service consumption model ZSC_BTC_AGENCY
*    odata_client_proxy = cl_web_odata_client_factory=>create_v2_remote_proxy(
*            EXPORTING
*                iv_service_definition_name = service_consumption_name
*                io_http_client             = http_client
*                iv_relative_service_root   = '/sap/opu/odata/sap/ZAGENCYCDS_SRV/' ).


    odata_client_proxy = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
      EXPORTING
         is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                             proxy_model_id      = 'ZSC_BTC_AGENCY'
                                             proxy_model_version = '0001' )
         io_http_client           = http_client
         iv_relative_service_root = '/sap/opu/odata/sap/ZAGENCYCDS_SRV/' ).

    "Navigate to the resource and create a request for the read operation
    read_list_request = odata_client_proxy->create_resource_for_entity_set( 'Z_TRAVEL_AGENCY_ES_5' )->create_request_for_read( ).

    "Create the filter tree
    filter_factory = read_list_request->create_filter_factory( ).

    LOOP AT filter_cond INTO DATA(filter_condition).
      filter_node = filter_factory->create_by_range( iv_property_path  = filter_condition-name
                                                     it_range          = filter_condition-range ).

      IF root_filter_node IS INITIAL.
        root_filter_node = filter_node.
      ELSE.
        root_filter_node = root_filter_node->and( filter_node ).
      ENDIF.
    ENDLOOP.

    IF root_filter_node IS NOT INITIAL.
        read_list_request->set_filter( root_filter_node ).
    ENDIF.

    IF is_data_requested = abap_true.
        read_list_request->set_skip( skip ).
        IF top > 0.
          read_list_request->set_top( top ).
        ENDIF.
    ENDIF.

    IF is_count_requested = abap_true.
      read_list_request->request_count( ).
    ENDIF.

    IF is_data_requested = abap_false.
      read_list_request->request_no_business_data( ).
    ENDIF.

    "Execute the request and retrieve the business data and count if requested
    read_list_response = read_list_request->execute( ).

    IF is_data_requested = abap_true.
       read_list_response->get_business_data( IMPORTING et_business_data = business_data ).
    ENDIF.

    IF is_count_requested = abap_true.
       count = read_list_response->get_count( ).
    ENDIF.

  ENDMETHOD.

  METHOD if_rap_query_provider~select.

    DATA business_data TYPE t_business_data.

    DATA(top)  = io_request->get_paging( )->get_page_size( ).
    DATA(skip) = io_request->get_paging( )->get_offset( ).
    DATA(requested_fields) = io_request->get_requested_elements( ).
    DATA(sort_order) = io_request->get_sort_elements( ).

    try.
        DATA(filter_condition) = io_request->get_filter( )->get_as_ranges( ).

        get_agencies(
          EXPORTING
            filter_cond        = filter_condition
            top                = CONV i( top )
            skip               = CONV i( skip )
            is_data_requested  = abap_true
*            is_count_requested =
          IMPORTING
            business_data      = business_data
*            count              =
        ).

        io_response->set_total_number_of_records( lines( business_data ) ).
        io_response->set_data( business_data ).

      catch cx_root into DATA(exception).
    endtry.


  ENDMETHOD.

ENDCLASS.
