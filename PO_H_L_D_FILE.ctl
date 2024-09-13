options(SKIP=1)
LOAD DATA
infile *
TRUNCATE
INTO TABLE XXBB_PO_HED_LINE_DIST_STG
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS 
                 (OPERATING_UNIT             "TRIM(:OPERATING_UNIT)"                    
                 ,DOCUMENT_TYPE_CODE         "TRIM(:DOCUMENT_TYPE_CODE)"                                        
                 ,VENDOR_NAME                "TRIM(:VENDOR_NAME)"            
                 ,VENDOR_SITE_CODE           "TRIM(:VENDOR_SITE_CODE)"             
                 ,SHIP_TO_LOCATION           "TRIM(:SHIP_TO_LOCATION)"          
                 ,BILL_TO_LOCATION           "TRIM(:BILL_TO_LOCATION)"
				 ,Buyer                      "TRIM(:Buyer)"
                 ,BATCH_ID				     "TRIM(:BATCH_ID)"
                 ,LINE_TYPE                  "TRIM(:LINE_TYPE)"               
                 ,ITEM                       "TRIM(:ITEM)"            
                 ,CATEGORY                   "TRIM(:CATEGORY)"             
                 ,UNIT_OF_MEASURE            "TRIM(:UNIT_OF_MEASURE)"           
                 ,QUANTITY                   "TRIM(:QUANTITY)"           
                 ,UNIT_PRICE                 "TRIM(:UNIT_PRICE)"           
                 ,DESTINATION_TYPE           "TRIM(:DESTINATION_TYPE)"            
                 ,STATUS                     "nvl(:STATUS,'N')"              
                 ,CREATION_DATE              SYSDATE                              
                 ,CREATED_BY                 "fnd_global.user_id"                      
                 ,LAST_UPDATE_DATE           SYSDATE                
                 ,LAST_UPDATED_BY            "fnd_global.user_id"                  
                 ,LAST_UPDATE_LOGIN          "fnd_global.LOGIN_ID" )
				 
				 
						
