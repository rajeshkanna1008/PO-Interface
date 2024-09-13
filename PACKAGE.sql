CREATE OR REPLACE PACKAGE APPS.po_import_pkg
IS
   PROCEDURE main_prc (errbuf OUT VARCHAR2, retcode OUT VARCHAR2);
END;
/

CREATE OR REPLACE PACKAGE BODY APPS.po_import_pkg
IS
  lv_org_id    NUMBER;
  lv_person_id NUMBER;
  s_loc_id     number ;
  b_loc_id     number ;

    PROCEDURE po_data_valid_prc
   IS
      CURSOR c1
      IS
         SELECT xhld.ROWID, xhld.*
           FROM xxbb_po_hed_line_dist_stg xhld
          WHERE status = 'N';

      e_flag                CHAR (1);
      e_msg                 VARCHAR2 (2000);
      l_count               NUMBER := 0;
    --lv_org_id             NUMBER;
      lv_po_type            VARCHAR2 (100);
      lv_vendor_site_code   VARCHAR2 (100);
      lv_vendor_id          NUMBER;
    --s_loc_id              NUMBER;
   -- b_loc_code            VARCHAR2 (100);
  --- lv_person_id          NUMBER;
      lv_line_type          VARCHAR2 (100);
      lv_cat1               VARCHAR2 (50);
      lv_cat2               VARCHAR2 (50);
      lv_displayed_field    VARCHAR2 (50);
      lv_uom_code           VARCHAR2 (100);
      lv_segment1           VARCHAR2 (10);
   BEGIN
      FOR i IN c1
      LOOP
--+====================  LOOP STARTS HERE ==========+
         e_flag := 'Y';
         e_msg := NULL;
         l_count := l_count + 1;

----------  VALIDATIONS STARTS HERE  ---------------
----------  OPERATING UNIT -----------------------
         IF i.operating_unit IS NOT NULL
         THEN
            BEGIN
               SELECT organization_id
                 INTO lv_org_id
                 FROM hr_operating_units
                WHERE NAME = i.operating_unit;

               DBMS_OUTPUT.put_line ('THE OPERATIING IS VALID' || i.operating_unit || '--->' || l_count);
            EXCEPTION
               WHEN OTHERS
               THEN
                  e_flag := 'E';
                  e_msg := e_msg || '/' || 'OPERATIING IS INVALID';
                  DBMS_OUTPUT.put_line ('THE ERRROS IS ' || SQLERRM || l_count);
            END;
         END IF;

-------------  PO TYPE VALIDATIONS HERE ----------------
         IF i.document_type_code IS NOT NULL
         THEN
            BEGIN
               SELECT lookup_code
                 INTO lv_po_type
                 FROM fnd_lookup_values
                WHERE lookup_type = 'POXMUB_DOCUMENT_TYPE'
                  AND lookup_code = i.document_type_code;

               DBMS_OUTPUT.put_line ('PO TYPE VALID ' || lv_po_type || '-->' || l_count);
            EXCEPTION
               WHEN OTHERS
               THEN
                  e_flag := 'E';
                  e_msg := e_msg || '/' || 'PO TYPE IS INVALID';
                  DBMS_OUTPUT.put_line ('THE ERRROS IS ' || SQLERRM || l_count
                                       );
            END;
         END IF;

-----------------SUPPLIER NAME --------------
         IF i.vendor_name IS NOT NULL
         THEN
            BEGIN
               SELECT vendor_id
                 INTO lv_vendor_id
                 FROM ap_suppliers
                WHERE vendor_name = i.vendor_name;

               DBMS_OUTPUT.put_line ('VENDOR NAME  VALID ' || i.vendor_name || '-->' || l_count);
            EXCEPTION
               WHEN OTHERS
               THEN
                  e_flag := 'E';
                  e_msg := e_msg || '/' || 'VENDOR NAME  IS INVALID';
                  DBMS_OUTPUT.put_line ('THE ERRROS IS ' || SQLERRM || l_count);
            END;
         END IF;

------------ SUPPLIER SITE --------------
         IF i.vendor_site_code IS NOT NULL
         THEN
            BEGIN
               SELECT vendor_site_code
                 INTO lv_vendor_site_code
                 FROM ap_supplier_sites_all
                WHERE vendor_id = lv_vendor_id
                  AND vendor_site_code = i.vendor_site_code
                  AND vendor_site_code_alt = i.vendor_site_code;

               DBMS_OUTPUT.put_line (   'VENDOR SITE  VALID ' || lv_vendor_site_code || '-->' || l_count);
            EXCEPTION
               WHEN OTHERS
               THEN
                  e_flag := 'E';
                  e_msg := e_msg || '/' || 'VENDOR SITE  IS INVALID';
                  DBMS_OUTPUT.put_line ('THE ERRROS IS ' || SQLERRM || l_count);
            END;
         END IF;

-----------------  SHIP TO -------------------
         IF i.ship_to_location IS NOT NULL
         THEN
            BEGIN
               SELECT location_id
                 INTO s_loc_id
                 FROM hr_locations
                WHERE location_code = i.ship_to_location;

               DBMS_OUTPUT.put_line (   'SHIP TO LOCATION IS VALID ' || i.ship_to_location || '-->' || l_count);
            EXCEPTION
               WHEN OTHERS
               THEN
                  e_flag := 'E';
                  e_msg := e_msg || '/' || 'SHIPT LOCATION CODE IS INVALID';
                  DBMS_OUTPUT.put_line ('THE ERRROS IS ' || SQLERRM || l_count);
            END;
         END IF;

-------------------- BILL TO ------------------------------
         IF i.bill_to_location IS NOT NULL
         THEN
            BEGIN
               SELECT location_id
                 INTO b_loc_id
                 FROM hr_locations
                WHERE location_code = i.bill_to_location;

               DBMS_OUTPUT.put_line (   'BILL TO LOCATION IS VALID ' || i.bill_to_location || '-->' || l_count);
            EXCEPTION
               WHEN OTHERS
               THEN
                  e_flag := 'E';
                  e_msg := e_msg || '/' || 'BILL LOCATION CODE IS INVALID';
                  DBMS_OUTPUT.put_line ('THE ERRROS IS ' || SQLERRM || l_count);
            END;
         END IF;

-----------------  BUYER -----------
         IF i.buyer IS NOT NULL
         THEN
            BEGIN
               SELECT person_id
                 INTO lv_person_id
                 FROM per_all_people_f
                WHERE full_name = i.buyer;

               DBMS_OUTPUT.put_line (   'BUYER IS VALID ' || i.buyer || '-->'|| l_count);
            EXCEPTION
               WHEN OTHERS
               THEN
                  e_flag := 'E';
                  e_msg := e_msg || '/' || 'Buyer IS INVALID';
                  DBMS_OUTPUT.put_line ('THE ERRROS IS ' || SQLERRM || l_count);
            END;
         END IF;

--------------  line type ---------
         IF i.line_type IS NOT NULL
         THEN
            BEGIN
               SELECT line_type
                 INTO lv_line_type
                 FROM po_line_types
                WHERE line_type = i.line_type;

               DBMS_OUTPUT.put_line (   'line type IS VALID ' || lv_line_type || '-->' || l_count);
            EXCEPTION
               WHEN OTHERS
               THEN
                  e_flag := 'E';
                  e_msg := e_msg || '/' || 'line type IS INVALID';
                  DBMS_OUTPUT.put_line ('THE ERRROS IS ' || SQLERRM || l_count);
            END;
         END IF;

---------------  uom code validation -----------------
         IF i.unit_of_measure IS NOT NULL
         THEN
            BEGIN
               SELECT uom_code
                 INTO lv_uom_code
                 FROM mtl_units_of_measure_tl
                WHERE unit_of_measure = i.unit_of_measure;

               DBMS_OUTPUT.put_line ('uom code IS VALID '|| lv_uom_code || '-->' || l_count);
            EXCEPTION
               WHEN OTHERS
               THEN
                  e_flag := 'E';
                  e_msg := e_msg || '/' || 'uom code  IS INVALID';
                  DBMS_OUTPUT.put_line ('THE ERRROS IS ' || SQLERRM || l_count);
            END;
         END IF;

--------------------   item validations ----------------
         IF i.item IS NOT NULL
         THEN
            BEGIN
               SELECT inventory_item_id
                 INTO lv_segment1
                 FROM mtl_system_items_b
                WHERE segment1 = i.item AND organization_id = lv_org_id;

               DBMS_OUTPUT.put_line ('ITEM IS VALID ' || lv_segment1|| '-->' || l_count);
            EXCEPTION
               WHEN OTHERS
               THEN
                  e_flag := 'E';
                  e_msg := e_msg || '/' || 'ITEM code  IS INVALID';
                  DBMS_OUTPUT.put_line ('THE ERRROS IS ' || SQLERRM || l_count);
            END;
         END IF;

----------------  CATEGORIES -------------
         IF i.CATEGORY IS NOT NULL
         THEN
            BEGIN
               SELECT segment1, segment2
                 INTO lv_cat1, lv_cat2
                 FROM mtl_item_categories_v
                WHERE category_concat_segs = i.CATEGORY
                  AND organization_id = lv_org_id
                  AND inventory_item_id = lv_segment1;

               DBMS_OUTPUT.put_line ('CATAGORY IS VALID ' || i.CATEGORY || '-->' || l_count);
            EXCEPTION
               WHEN OTHERS
               THEN
                  e_flag := 'E';
                  e_msg := e_msg || '/' || 'CATAGORY  IS INVALID';
                  DBMS_OUTPUT.put_line ('THE ERRROS IS ' || SQLERRM || l_count);
            END;
         END IF;

------------  DESSTINATION TYPES -----------
         IF i.destination_type IS NOT NULL
         THEN
            BEGIN
               SELECT displayed_field
                 INTO lv_displayed_field
                 FROM po_destination_types_all_v
                WHERE UPPER (displayed_field) = UPPER (i.destination_type);

               DBMS_OUTPUT.put_line ('DESTINATION TYPE IS VALID ' || lv_displayed_field || '-->' || l_count);
            EXCEPTION
               WHEN OTHERS
               THEN
                  e_flag := 'E';
                  e_msg := e_msg || '/' || ' DESTINATION TYPE IS INVALID';
                  DBMS_OUTPUT.put_line ('THE ERRROS IS ' || SQLERRM || l_count);
            END;
         END IF;

         IF e_flag = 'Y'
         THEN
            UPDATE xxbb_po_hed_line_dist_stg
               SET status = 'V'
             WHERE ROWID = i.ROWID;

            COMMIT;
         ELSE
            UPDATE xxbb_po_hed_line_dist_stg
               SET status = 'E',
                   error_msg = e_msg
             WHERE ROWID = i.ROWID;

            COMMIT;
         END IF;
      END LOOP;
   END; 

   PROCEDURE insert_prc
   IS
      CURSOR c2
      IS
         SELECT xhld.ROWID, xhld.*
           FROM xxbb_po_hed_line_dist_stg xhld
          WHERE status = 'V';
   BEGIN
      FOR j IN c2
      LOOP
         INSERT INTO po.po_headers_interface (interface_header_id,
											  BATCH_ID,
											  action, 
											  org_id,
											  agent_id, 
											  document_type_code, 
											  currency_code,
											  vendor_name, 
											  vendor_site_code, 
											  ship_to_location_id,
											  bill_to_location_id, 
											  effective_date,
											  reference_num, 
											  last_update_date)
									  VALUES (po_headers_interface_s.NEXTVAL, 
											  J.BATCH_ID,
											  'ORIGINAL',  
											  lv_org_id ,
											  lv_person_id , 
											  j.document_type_code, 
											  'USD',
											  j.vendor_name, 
											  j.vendor_site_code, 
											  s_loc_id,
											  b_loc_id, 
											  TRUNC (SYSDATE),
											  'PO' || apps.po_headers_interface_s.NEXTVAL, 
											  SYSDATE);

/****** INSERTING DATA INTO PO_LINES_INTERFACE ******/
         INSERT INTO po.po_lines_interface (interface_header_id,
										    interface_line_id, 
											line_type, 
											item,
										    CATEGORY, 
											unit_of_measure, 
											quantity,
										    unit_price, 
											need_by_date, 
											ship_to_location_ID)
								    VALUES (apps.po_headers_interface_s.CURRVAL,
											apps.po_lines_interface_s.NEXTVAL, 
											j.line_type, 
											j.item,
											j.CATEGORY, 
											j.unit_of_measure, 
											j.quantity,
										    j.unit_price, 
											TRUNC (SYSDATE), 
											s_loc_id);

/******* INSERTING DATA INTO PO_DISTRIBUTIONS_INTERFACE ******/
         INSERT INTO po.po_distributions_interface (interface_header_id,
												    interface_line_id,
												    interface_distribution_id,
												    destination_type, 
													quantity_ordered)
													-- CHARGE_ACCOUNT_ID)
											 VALUES (apps.po_headers_interface_s.CURRVAL,
													 apps.po_lines_interface_s.CURRVAL,
													 po.po_distributions_interface_s.NEXTVAL,
													 j.destination_type, 
													 j.quantity);
		END LOOP;

      COMMIT;
   END;

   PROCEDURE main_prc (errbuf OUT VARCHAR2, retcode OUT VARCHAR2)
   IS
   BEGIN
    po_data_valid_prc;
      insert_prc;
   END;
END;
/
